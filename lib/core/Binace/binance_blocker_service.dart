import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class BinanceBlockerService {
  static final BinanceBlockerService _instance = BinanceBlockerService._();
  factory BinanceBlockerService() => _instance;
  BinanceBlockerService._();

  // State file — block on/off save হবে এখানে
  static File get _stateFile =>
      File('${Directory.systemTemp.path}/binance_block_state.txt');

  static File get _pidFile =>
      File('${Directory.systemTemp.path}/binance_watcher.pid');

  static File get _settingsFile =>
      File('${Directory.systemTemp.path}/binance_block_settings.json');

  Future<void> saveSettings({
    required List<String> appsToBlock,
    String? lockedUntil,
    String? token,
  }) async {
    try {
      final data = {
        'appsToBlock': appsToBlock,
        'lockedUntil': lockedUntil,
        'token': token,
      };
      await _settingsFile.writeAsString(jsonEncode(data));
      print('[Blocker] Saved settings: $data');
    } catch (e) {
      print('[Blocker] Error saving settings: $e');
    }
  }

  // ── Block state read করো ──
  Future<bool> isBlocking() async {
    try {
      if (!await _stateFile.exists()) return false;
      final state = await _stateFile.readAsString();
      return state.trim() == 'blocked';
    } catch (_) {
      return false;
    }
  }

  // ── BLOCK START ──
  Future<void> enableBlock() async {
    // State save করো
    await _stateFile.writeAsString('blocked');

    // Watcher already চলছে কিনা check
    if (await _isWatcherRunning()) {
      print('[Blocker] Watcher already running');
      return;
    }

    // Watcher start করো
    await _startWatcher();

    // Windows startup-এ register করো (PC restart হলেও চলবে)
    await _registerOnStartup();
  }

  // ── BLOCK STOP ──
  Future<void> disableBlock() async {
    // State unblocked করো — watcher নিজেই বন্ধ হবে
    await _stateFile.writeAsString('unblocked');

    // Startup থেকে remove করো
    await _unregisterFromStartup();

    print('[Blocker] Block disabled');
  }

  // ── Watcher চলছে কিনা check ──
  Future<bool> _isWatcherRunning() async {
    try {
      if (!await _pidFile.exists()) return false;
      final savedPid = int.tryParse((await _pidFile.readAsString()).trim()) ?? 0;
      if (Platform.isWindows) {
        final r = await Process.run(
          'tasklist', ['/FI', 'PID eq $savedPid', '/NH'],
          runInShell: true,
        );
        return r.stdout.toString().contains('$savedPid');
      } else {
        final r = await Process.run('ps', ['-p', '$savedPid']);
        return r.exitCode == 0;
      }
    } catch (_) {
      return false;
    }
  }

  // ── Watcher exe start করো (with Admin/Root privileges) ──
  Future<void> _startWatcher() async {
    try {
      if (Platform.isWindows) {
        // Run the task we registered
        await Process.run('powershell', [
          '-Command',
          'Start-Process cmd -ArgumentList \'/c schtasks /Run /TN "BinanceWatcher"\' -Verb RunAs -WindowStyle Hidden'
        ]);
        print('[Blocker] Watcher started via Task Scheduler (Windows)');
      } else if (Platform.isMacOS) {
        // Load the daemon
        final script = 'do shell script "launchctl load /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist" with administrator privileges';
        await Process.run('osascript', ['-e', script]);
        print('[Blocker] Watcher started via LaunchDaemon (macOS)');
      }
    } catch (e) {
      print('[Blocker] Start error: $e');
    }
  }

  // ── Startup register (schtasks on Windows, LaunchDaemon plist on macOS) ──
  Future<void> _registerOnStartup() async {
    try {
      final watcherExe = await _getWatcherPath();
      if (Platform.isWindows) {
        // Task Scheduler দিয়ে SYSTEM privilege-এ register (Prompts for UAC Admin)
        final createCommand = 'schtasks /Create /F /TN "BinanceWatcher" /TR \\"$watcherExe\\" /SC ONSTART /RU "SYSTEM" /RL HIGHEST';
        final runCommand = 'schtasks /Run /TN "BinanceWatcher"';
        
        await Process.run('powershell', [
          '-Command',
          'Start-Process cmd -ArgumentList \'/c $createCommand & $runCommand\' -Verb RunAs -WindowStyle Hidden'
        ]);
        
        print('[Blocker] Registered on startup & started as SYSTEM via UAC (Windows)');
      } else if (Platform.isMacOS) {
        // Create the plist in a temp directory first
        final tempPlist = File('${Directory.systemTemp.path}/com.tradelmt.binancewatcher.plist');
        final plistContent = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.tradelmt.binancewatcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>$watcherExe</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>''';
        await tempPlist.writeAsString(plistContent);
        
        // Use osascript to copy to /Library/LaunchDaemons and load it with root privileges
        final script = '''
do shell script "cp ${tempPlist.path} /Library/LaunchDaemons/ && chown root:wheel /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist && chmod 644 /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist && launchctl load /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist" with administrator privileges
''';
        await Process.run('osascript', ['-e', script]);
        print('[Blocker] Registered on startup (macOS LaunchDaemon with root)');
      }
    } catch (e) {
      print('[Blocker] Startup register error: $e');
    }
  }

  // ── Startup থেকে remove ──
  Future<void> _unregisterFromStartup() async {
    try {
      if (Platform.isWindows) {
        await Process.run('powershell', [
          '-Command',
          'Start-Process cmd -ArgumentList \'/c schtasks /Delete /F /TN "BinanceWatcher"\' -Verb RunAs -WindowStyle Hidden'
        ]);
        print('[Blocker] Removed from startup (Windows)');
      } else if (Platform.isMacOS) {
        final script = 'do shell script "launchctl unload /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist && rm /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist" with administrator privileges';
        await Process.run('osascript', ['-e', script]);
        print('[Blocker] Removed from startup (macOS LaunchDaemon)');
      }
    } catch (e) {
      print('[Blocker] Startup unregister error: $e');
    }
  }

  // ── Watcher exe path (debug + release দুটোতেই কাজ করবে) ──
  String _getWatcherPath() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    print('[Blocker] resolvedExecutable: ${Platform.resolvedExecutable}');
    if (Platform.isWindows) {
      return '$exeDir\\binance_watcher.exe';
    } else {
      return '$exeDir/binance_watcher';
    }
  }

  // ── App launch হলে auto-resume (block state check) ──
  Future<void> resumeIfBlocking() async {
    final blocking = await isBlocking();
    if (blocking && !await _isWatcherRunning()) {
      print('[Blocker] Resuming block on app launch...');
      await _startWatcher();
    }
  }
}