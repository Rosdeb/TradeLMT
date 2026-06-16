import 'dart:async';
import 'dart:io';

void main() async {
  final pidFile = File('${Directory.systemTemp.path}/binance_watcher.pid');
  await pidFile.writeAsString(pid.toString());

  final stateFile = File('${Directory.systemTemp.path}/binance_block_state.txt');

  print('[BinanceWatcher] Started. PID: $pid');

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      // State check
      if (await stateFile.exists()) {
        final state = await stateFile.readAsString();
        if (state.trim() == 'unblocked') {
          print('[BinanceWatcher] Unblocked. Exiting.');
          timer.cancel();
          await pidFile.delete().catchError((_) {});
          exit(0);
        }
      } else {
        timer.cancel();
        exit(0);
      }

      // Binance kill
      final result = await Process.run(
        'tasklist',
        ['/FI', 'IMAGENAME eq Binance.exe', '/NH'],
        runInShell: true,
      );

      if (result.stdout.toString().toLowerCase().contains('binance.exe')) {
        await Process.run(
          'taskkill',
          ['/F', '/IM', 'Binance.exe'],
          runInShell: true,
        );
        print('[BinanceWatcher] Killed Binance.exe');
      }
    } catch (e) {
      print('[BinanceWatcher] Error: $e');
    }
  });

  await Completer().future;
}