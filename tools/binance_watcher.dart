import 'dart:async';
import 'dart:convert';
import 'dart:io';

const List<String> domainsToBlock = [
  'tradingview.com',
  'www.tradingview.com',
  'schwab.com',
  'trade.schwab.com',
  'binance.com',
  'www.binance.com'
];

void main() async {
  final pidFile = File('${Directory.systemTemp.path}/binance_watcher.pid');
  await pidFile.writeAsString(pid.toString());

  final stateFile = File('${Directory.systemTemp.path}/binance_block_state.txt');
  final settingsFile = File('${Directory.systemTemp.path}/binance_block_settings.json');

  print('[BinanceWatcher] Started. PID: $pid');

  int pollInterval = 15; 
  int pollCounter = 12; // Start close to trigger initial poll quickly
  bool hostsBlockedState = false;

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    try {
      // 1. Read state file
      String state = 'unblocked';
      if (await stateFile.exists()) {
        state = (await stateFile.readAsString()).trim();
      }

      // 2. Read settings
      List<String> appsToBlock = ['Binance.exe'];
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
          
          bool backendLocked = false;
          bool isLimitRuleEnabled = true;
          String? newLockedUntil;
          List<String>? newApps;

          // Parse limit status
          if (apiData['remainingTrades'] != null) {
            final remaining = int.tryParse(apiData['remainingTrades'].toString()) ?? 1;
            if (remaining <= 0) {
              backendLocked = true;
            }
          }

          if (apiData['lockoutStatus'] is Map) {
            final lockout = apiData['lockoutStatus'] as Map;
            backendLocked = lockout['locked'] == true;
            if (lockout['lockedUntil'] != null) {
              newLockedUntil = lockout['lockedUntil'].toString();
            }
            if (lockout['appsToBlock'] is List) {
              newApps = (lockout['appsToBlock'] as List).map((e) => e.toString()).toList();
            }
          }

          if (apiData['tradeLimit'] is Map) {
            final tradeLimit = apiData['tradeLimit'] as Map;
            isLimitRuleEnabled = tradeLimit['isEnabled'] == true;
          }

          // Adjust poll interval: if rule is disabled, no need for intensive pulling (poll every 5 minutes)
          if (!isLimitRuleEnabled) {
            pollInterval = 300;
          } else if (backendLocked) {
            pollInterval = 15; // Intensive pulling when locked
          } else {
            pollInterval = 60; // Normal polling when rule is enabled but not locked
          }

          // Save polled state
          if (isLimitRuleEnabled && backendLocked) {
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

      // Sync local DNS/Hosts file block state
      if (isCurrentlyBlocked != hostsBlockedState) {
        await updateHostsFile(isCurrentlyBlocked);
        hostsBlockedState = isCurrentlyBlocked;
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
            final appName = app.toLowerCase().endsWith('.exe')
                ? app.substring(0, app.length - 4)
                : app;

            final check = await Process.run('pgrep', ['-i', appName]);
            if (check.exitCode == 0) {
              await Process.run('pkill', ['-9', '-i', appName]);
              print('[BinanceWatcher] Killed $appName');
            }
          }
        }
      }
    } catch (e) {
      print('[BinanceWatcher] Error in execution loop: $e');
    }
  });

  await Completer().future;
}

Future<Map<String, dynamic>?> pollBackend(String token) async {
  final client = HttpClient();
  // Set connection timeout
  client.connectionTimeout = const Duration(seconds: 5);
  try {
    final uri = Uri.parse('https://triple-console-sauce-northwest.trycloudflare.com/trade-limit');
    final request = await client.getUrl(uri);
    request.headers.add(HttpHeaders.authorizationHeader, 'Bearer $token');
    
    final response = await request.close();
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      return jsonDecode(responseBody) as Map<String, dynamic>;
    }
  } catch (e) {
    print('[BinanceWatcher] Polling error: $e');
  } finally {
    client.close();
  }
  return null;
}

Future<void> updateHostsFile(bool block) async {
  try {
    final hostsPath = Platform.isWindows
        ? r'C:\Windows\System32\drivers\etc\hosts'
        : '/etc/hosts';
    final file = File(hostsPath);
    if (!await file.exists()) return;

    final lines = await file.readAsLines();
    final newLines = <String>[];

    // Remove existing blocking block
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
      if (!insideBlock) {
        // Also ensure no stray domain lines exist
        bool containsDomain = false;
        for (final domain in domainsToBlock) {
          if (line.contains(domain)) {
            containsDomain = true;
            break;
          }
        }
        if (!containsDomain) {
          newLines.add(line);
        }
      }
    }

    if (block) {
      newLines.add('\n# TradeLMT Blocker Start');
      for (final domain in domainsToBlock) {
        newLines.add('127.0.0.1 $domain');
      }
      newLines.add('# TradeLMT Blocker End\n');
    }

    // Write back
    await file.writeAsString(newLines.join('\n'));
    print('[BinanceWatcher] Hosts file updated. Block active: $block');
  } catch (e) {
    print('[BinanceWatcher] Error writing to hosts file: $e');
  }
}