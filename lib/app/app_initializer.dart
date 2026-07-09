import 'dart:io';

class AppInitializer {
  static Future<void> init() async {
    // ... তোমার existing init code ...

    // Auto-start Binance watcher on app launch
    await _startBinanceWatcher();
  }

  static Future<void> _startBinanceWatcher() async {
    try {
      final exeDir = File(Platform.resolvedExecutable).parent.path;
      final watcherPath = Platform.isWindows ? '$exeDir/binance_watcher.exe' : '$exeDir/binance_watcher';

      // আগের watcher already চলছে কিনা check করো
      final pidFile = File('${Directory.systemTemp.path}/binance_watcher.pid');
      if (await pidFile.exists()) {
        final pidStr = await pidFile.readAsString();
        final oldPid = int.tryParse(pidStr.trim());
        if (oldPid != null) {
          // Already running — skip
          bool isRunning = false;
          if (Platform.isWindows) {
            final check = await Process.run(
              'tasklist', ['/FI', 'PID eq $oldPid', '/NH'],
              runInShell: true,
            );
            isRunning = check.stdout.toString().contains(oldPid.toString());
          } else {
            final check = await Process.run('ps', ['-p', '$oldPid']);
            isRunning = check.exitCode == 0;
          }
          if (isRunning) {
            print('[Init] Watcher already running (PID: $oldPid)');
            return;
          }
        }
      }

      if (await File(watcherPath).exists()) {
        await Process.start(
          watcherPath, [],
          mode: ProcessStartMode.detached,
        );
        print('[Init] Binance watcher started');
      }
    } catch (e) {
      print('[Init] Watcher start failed: $e');
    }
  }
}