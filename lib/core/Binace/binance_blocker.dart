import 'dart:async';
import 'dart:io';

class BinanceBlocker {
  static final BinanceBlocker _instance = BinanceBlocker._internal();
  factory BinanceBlocker() => _instance;
  BinanceBlocker._internal();

  Timer? _timer;
  bool _isBlocking = false;
  bool get isBlocking => _isBlocking;

  void startBlocking() {
    if (_isBlocking) return;
    _isBlocking = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _killBinance());
  }

  void stopBlocking() {
    _timer?.cancel();
    _isBlocking = false;
  }

  Future<void> _killBinance() async {
    try {
      if (Platform.isWindows) {
        final check = await Process.run(
          'tasklist', ['/FI', 'IMAGENAME eq Binance.exe', '/NH'],
          runInShell: true,
        );
        if (check.stdout.toString().toLowerCase().contains('binance.exe')) {
          await Process.run('taskkill', ['/F', '/IM', 'Binance.exe'], runInShell: true);
        }
      } else if (Platform.isMacOS || Platform.isLinux) {
        final check = await Process.run('pgrep', ['-i', 'binance']);
        if (check.exitCode == 0) {
          await Process.run('pkill', ['-9', '-i', 'binance']);
        }
      }
    } catch (_) {}
  }

  void dispose() => stopBlocking();
}