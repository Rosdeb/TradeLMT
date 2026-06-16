import 'dart:io';
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
      final r = await Process.run(
        'tasklist', ['/FI', 'PID eq $savedPid', '/NH'],
        runInShell: true,
      );
      return r.stdout.toString().contains('$savedPid');
    } catch (_) {
      return false;
    }
  }

  // ── Watcher exe start করো ──
  Future<void> _startWatcher() async {
    try {
      final watcherExe = await _getWatcherPath();
      print('[Blocker] Watcher path: $watcherExe');

      if (await File(watcherExe).exists()) {
        await Process.start(
          watcherExe, [],
          mode: ProcessStartMode.detached,
        );
        print('[Blocker] Watcher started');
      } else {
        print('[Blocker] Watcher exe not found!');
      }
    } catch (e) {
      print('[Blocker] Start error: $e');
    }
  }

  // ── Windows startup register (Task Scheduler) ──
  Future<void> _registerOnStartup() async {
    try {
      final watcherExe = await _getWatcherPath();

      // Task Scheduler দিয়ে register — PC boot হলে auto-start
      await Process.run('schtasks', [
        '/Create',
        '/F', // Force overwrite
        '/TN', 'BinanceWatcher', // Task name
        '/TR', watcherExe, // Run করার exe
        '/SC', 'ONLOGON', // Login এ auto-start
        '/RL', 'HIGHEST', // Highest privilege
      ], runInShell: true);

      print('[Blocker] Registered on startup');
    } catch (e) {
      print('[Blocker] Startup register error: $e');
    }
  }

  // ── Windows startup থেকে remove ──
  Future<void> _unregisterFromStartup() async {
    try {
      await Process.run('schtasks', [
        '/Delete',
        '/F',
        '/TN', 'BinanceWatcher',
      ], runInShell: true);

      print('[Blocker] Removed from startup');
    } catch (e) {
      print('[Blocker] Startup unregister error: $e');
    }
  }

  // ── Watcher exe path (debug + release দুটোতেই কাজ করবে) ──
  String _getWatcherPath() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    print('[Blocker] resolvedExecutable: ${Platform.resolvedExecutable}');
    return '$exeDir\\binance_watcher.exe';
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