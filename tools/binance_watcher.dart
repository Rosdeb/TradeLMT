import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:raminups/core/constants/api_constants.dart';

/// Broker keyword -> domains to null-route in the hosts file while blocked.
/// The keyword is an `appsToBlock` entry (from the backend) with any `.exe` /
/// `.app` suffix stripped and lower-cased. Nothing here is applied unless the
/// backend actually names that app.
const Map<String, List<String>> kBrokerDomains = {
  'thinkorswim': ['schwab.com', 'www.schwab.com', 'trade.schwab.com', 'client.schwab.com'],
  'schwab': ['schwab.com', 'www.schwab.com', 'trade.schwab.com', 'client.schwab.com'],
  'tradingview': ['tradingview.com', 'www.tradingview.com'],
  'binance': ['binance.com', 'www.binance.com', 'accounts.binance.com'],
  'tradovate': ['tradovate.com', 'trader.tradovate.com'],
  'ninjatrader': ['ninjatrader.com', 'www.ninjatrader.com'],
  'interactivebrokers': ['interactivebrokers.com', 'www.interactivebrokers.com'],
  'ibkr': ['interactivebrokers.com', 'www.interactivebrokers.com'],
  'robinhood': ['robinhood.com', 'www.robinhood.com'],
  'tastytrade': ['tastytrade.com', 'trade.tastytrade.com'],
  'tastyworks': ['tastytrade.com', 'trade.tastytrade.com'],
};

/// Every domain the blocker might ever add — used ONLY to scrub stray lines
/// during cleanup, never to decide what to block.
final Set<String> kAllBrokerDomains =
    kBrokerDomains.values.expand((e) => e).toSet();

/// appsToBlock entries -> lower-cased keywords (suffix stripped).
List<String> keywordsFor(List<String> apps) => apps
    .map((a) {
      var k = a.toLowerCase().trim();
      for (final s in const ['.exe', '.app']) {
        if (k.endsWith(s)) k = k.substring(0, k.length - s.length);
      }
      return k.trim();
    })
    .where((k) => k.isNotEmpty)
    .toList();

/// Keywords -> the domains to block for exactly those brokers.
List<String> domainsFor(Iterable<String> keywords) {
  final out = <String>{};
  for (final k in keywords) {
    for (final entry in kBrokerDomains.entries) {
      if (k.contains(entry.key) || entry.key.contains(k)) {
        out.addAll(entry.value);
      }
    }
  }
  final list = out.toList()..sort();
  return list;
}

void main() async {
  final pidFile = File('${Directory.systemTemp.path}/binance_watcher.pid');
  await pidFile.writeAsString(pid.toString());

  final stateFile = File('${Directory.systemTemp.path}/binance_block_state.txt');
  final settingsFile = File('${Directory.systemTemp.path}/binance_block_settings.json');

  print('[BinanceWatcher] Started. PID: $pid');

  int pollInterval = 15;
  int pollCounter = 12; // Start close to trigger initial poll quickly
  String lastHostsSig = '';

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      // 1. Read state file
      String state = 'unblocked';
      if (await stateFile.exists()) {
        state = (await stateFile.readAsString()).trim();
      }

      // 2. Read settings. appsToBlock is whatever the backend sent — no default.
      List<String> appsToBlock = <String>[];
      String? token;
      
      if (await settingsFile.exists()) {
        try {
          final settingsContent = await settingsFile.readAsString();
          final settings = jsonDecode(settingsContent) as Map<String, dynamic>;
          
          if (settings['token'] != null) {
            token = settings['token'].toString();
          }

          // Check lockoutUntil expiration
          if (settings['lockedUntil'] != null) {
            final lockedUntil = DateTime.tryParse(settings['lockedUntil'].toString());
            if (lockedUntil != null) {
              if (DateTime.now().toUtc().isAfter(lockedUntil.toUtc())) {
                print('[BinanceWatcher] Lockout expired at $lockedUntil. Unblocking.');
                await stateFile.writeAsString('unblocked');
                state = 'unblocked';
              } else {
                // If we are before lockedUntil, we must enforce blocking
                if (state != 'blocked') {
                  await stateFile.writeAsString('blocked');
                  state = 'blocked';
                }
              }
            }
          }

          if (settings['appsToBlock'] is List) {
            appsToBlock = (settings['appsToBlock'] as List).map((e) => e.toString()).toList();
          }
        } catch (e) {
          print('[BinanceWatcher] Error reading settings: $e');
        }
      }

      // 3. Poll Backend
      pollCounter++;
      if (pollCounter >= pollInterval && token != null && token.isNotEmpty) {
        pollCounter = 0;
        final apiData = await pollBackend(token);
        if (apiData != null) {
          print('[BinanceWatcher] Polled backend: $apiData');
          
          bool isLimitRuleEnabled = true;
          int? remaining;
          bool lockoutLocked = false;
          String? newLockedUntil;
          List<String>? newApps;

          if (apiData['tradeLimit'] is Map) {
            final tradeLimit = apiData['tradeLimit'] as Map;
            isLimitRuleEnabled = tradeLimit['isEnabled'] == true;
          }

          if (apiData['remainingTrades'] != null) {
            remaining = int.tryParse(apiData['remainingTrades'].toString());
          }

          // /lockout/status is the source of truth.
          if (apiData['lockoutStatus'] is Map) {
            final lockout = apiData['lockoutStatus'] as Map;
            lockoutLocked = lockout['locked'] == true;
            if (lockout['lockedUntil'] != null) {
              newLockedUntil = lockout['lockedUntil'].toString();
            }
            if (lockout['appsToBlock'] is List) {
              newApps = (lockout['appsToBlock'] as List).map((e) => e.toString()).toList();
            }
          }

          // Same rule as the in-app TradeLimitState: an explicit lockout always
          // blocks; the counter only blocks while the rule is enabled.
          final backendLocked = lockoutLocked ||
              (isLimitRuleEnabled && remaining != null && remaining <= 0);

          // Adjust poll interval: if rule is disabled, no need for intensive pulling (poll every 5 minutes)
          if (!isLimitRuleEnabled) {
            pollInterval = 300;
          } else if (backendLocked) {
            pollInterval = 15; // Intensive pulling when locked
          } else {
            pollInterval = 60; // Normal polling when rule is enabled but not locked
          }

          // Save polled state
          if (backendLocked) {
            await stateFile.writeAsString('blocked');
            state = 'blocked';

            final updatedSettings = {
              'appsToBlock': newApps ?? appsToBlock,
              'lockedUntil': newLockedUntil ?? DateTime.now().add(const Duration(hours: 4)).toUtc().toIso8601String(),
              'token': token,
            };
            await settingsFile.writeAsString(jsonEncode(updatedSettings));
          } else {
            // Unlock if server states we are free or rule is disabled
            if (state == 'blocked') {
              await stateFile.writeAsString('unblocked');
              state = 'unblocked';
            }
          }
        }
      }

      // 4. Enforce Blocks
      final isCurrentlyBlocked = (state == 'blocked');
      final keywords = keywordsFor(appsToBlock).toSet();
      final activeDomains = isCurrentlyBlocked ? domainsFor(keywords) : <String>[];

      // Sync the hosts file whenever the block state OR the domain set changes
      // (the backend can change appsToBlock between polls).
      final hostsSig = '$isCurrentlyBlocked|${activeDomains.join(',')}';
      if (hostsSig != lastHostsSig) {
        await updateHostsFile(isCurrentlyBlocked, activeDomains);
        lastHostsSig = hostsSig;
      }

      // Kill running apps if blocked
      if (isCurrentlyBlocked) {
        for (final app in appsToBlock) {
          if (app.isEmpty) continue;
          if (Platform.isWindows) {
            final result = await Process.run(
              'tasklist',
              ['/FI', 'IMAGENAME eq $app', '/NH'],
              runInShell: true,
            );

            if (result.stdout.toString().toLowerCase().contains(app.toLowerCase())) {
              await Process.run(
                'taskkill',
                ['/F', '/IM', app],
                runInShell: true,
              );
              print('[BinanceWatcher] Killed $app');
            }
          } else if (Platform.isMacOS || Platform.isLinux) {
            // API names are Windows-style ("thinkorswim.exe"). Strip any
            // .exe/.app suffix and match by process name anywhere — including
            // an app launched straight from a mounted .dmg.
            var keyword = app.toLowerCase();
            for (final suffix in const ['.exe', '.app']) {
              if (keyword.endsWith(suffix)) {
                keyword = keyword.substring(0, keyword.length - suffix.length);
              }
            }
            keyword = keyword.trim();
            if (keyword.isEmpty) continue;

            // -f matches the full command path (catches apps run from a mounted
            // .dmg). Resolve pids ourselves so we never kill this watcher — its
            // own path contains "binance".
            final check = await Process.run('pgrep', ['-if', keyword]);
            if (check.exitCode == 0) {
              final pids = check.stdout
                  .toString()
                  .split('\n')
                  .map((s) => int.tryParse(s.trim()))
                  .whereType<int>()
                  .where((p) => p != pid)
                  .toList();
              for (final p in pids) {
                await Process.run('kill', ['-9', '$p']);
              }
              if (pids.isNotEmpty) {
                print('[BinanceWatcher] Killed $keyword -> $pids');
              }
            }
          }
        }

        // macOS: force-eject any broker .dmg volume so the user can't run the
        // app from the disk image or re-mount it during a lockout. Volume-name
        // keywords are derived from the same backend appsToBlock list, plus a
        // couple of brand aliases (a Schwab installer volume is "thinkorswim").
        if (Platform.isMacOS && keywords.isNotEmpty) {
          final volKeywords = {...keywords};
          if (keywords.contains('thinkorswim')) volKeywords.add('schwab');
          await ejectBrokerDmgs(volKeywords);
        }
      }
    } catch (e) {
      print('[BinanceWatcher] Error in execution loop: $e');
    }
  });

  await Completer().future;
}

/// Polls `/trade-limit` (rule + remaining count) and `/lockout/status` (source
/// of truth) and merges them into the shape the main loop expects:
/// `{ tradeLimit, remainingTrades, lockoutStatus: {...} }`.
Future<Map<String, dynamic>?> pollBackend(String token) async {
  final limit = await _getJson('${ApiConstants.baseUrl}/trade-limit', token);
  final lockout = await _getJson('${ApiConstants.baseUrl}/lockout/status', token);
  if (limit == null && lockout == null) return null;
  return {
    if (limit != null) ...limit,
    if (lockout != null) 'lockoutStatus': lockout,
  };
}

Future<Map<String, dynamic>?> _getJson(String url, String token) async {
  final client = HttpClient();
  client.connectionTimeout = const Duration(seconds: 5);
  try {
    final request = await client.getUrl(Uri.parse(url));
    request.headers.add(HttpHeaders.authorizationHeader, 'Bearer $token');
    final response = await request.close();
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } else {
      print('[BinanceWatcher] $url -> HTTP ${response.statusCode}');
    }
  } catch (e) {
    print('[BinanceWatcher] Polling error ($url): $e');
  } finally {
    client.close();
  }
  return null;
}

/// `hdiutil detach -force` any mounted volume whose name matches a broker
/// keyword. Idempotent — a re-mount is ejected again on the next loop.
Future<void> ejectBrokerDmgs(Set<String> keywords) async {
  try {
    final vols = Directory('/Volumes');
    if (!vols.existsSync()) return;
    for (final entity in vols.listSync()) {
      final name = entity.path.split('/').last.toLowerCase();
      if (name == 'macintosh hd') continue;
      if (keywords.any((k) => k.isNotEmpty && name.contains(k))) {
        await Process.run('hdiutil', ['detach', '-force', entity.path]);
        print('[BinanceWatcher] Ejected broker volume: ${entity.path}');
      }
    }
  } catch (e) {
    print('[BinanceWatcher] DMG eject error: $e');
  }
}

Future<void> updateHostsFile(bool block, List<String> domainsToAdd) async {
  try {
    final hostsPath = Platform.isWindows
        ? r'C:\Windows\System32\drivers\etc\hosts'
        : '/etc/hosts';
    final file = File(hostsPath);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    final newLines = <String>[];

    // Strip any previous TradeLMT block (markers) and any stray broker line.
    bool insideBlock = false;
    for (final line in lines) {
      if (line.contains('# TradeLMT Blocker Start')) {
        insideBlock = true;
        continue;
      }
      if (line.contains('# TradeLMT Blocker End')) {
        insideBlock = false;
        continue;
      }
      if (insideBlock) continue;

      final stray = kAllBrokerDomains.any((d) => line.contains(d));
      if (!stray) newLines.add(line);
    }

    if (block && domainsToAdd.isNotEmpty) {
      newLines.add('\n# TradeLMT Blocker Start');
      for (final domain in domainsToAdd) {
        newLines.add('127.0.0.1 $domain');
        newLines.add('::1 $domain');
      }
      newLines.add('# TradeLMT Blocker End\n');
    }

    await file.writeAsString(newLines.join('\n'));
    print('[BinanceWatcher] Hosts updated. block=$block domains=$domainsToAdd');
  } catch (e) {
    print('[BinanceWatcher] Error writing to hosts file: $e');
  }
}