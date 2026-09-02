import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app/app_initializer.dart';
import 'core/Binace/binance_blocker_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();

  if (Platform.isWindows || Platform.isMacOS) {
    // Re-arm an active lockout if the app was quit while blocked (W4).
    await BinanceBlockerService().resumeIfBlocking();
  }

  // Initialize the Window Manager setup
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 650),
    // Default starting window size when app launches
    minimumSize: Size(1100, 600),
    // Strict minimum size threshold (Blocks mobile resizing)
    center: true,
    // Centers the app window on the desktop screen
    backgroundColor: Colors.black,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: "TradeLMT Control Console",
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
    await windowManager.setBrightness(Brightness.dark);
  });

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final initialRoute = (token != null && token.isNotEmpty) ? AppPaths.home : AppPaths.splash;

  runApp(ProviderScope(
    overrides: [
      initialRouteProvider.overrideWithValue(initialRoute),
    ],
    child: const MyApp(),
  ));
}

void _launchBinanceWatcher() async {
  try {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final watcherExe = '$exeDir/binance_watcher.exe';

    final pidFile = File('${Directory.systemTemp.path}/binance_watcher.pid');

    // Already running? skip
    if (await pidFile.exists()) {
      final pid = int.tryParse((await pidFile.readAsString()).trim()) ?? 0;
      final r = await Process.run('tasklist', [
        '/FI',
        'PID eq $pid',
        '/NH',
      ], runInShell: true);
      if (r.stdout.toString().contains('$pid')) return;
    }

    if (await File(watcherExe).exists()) {
      await Process.start(watcherExe, [], mode: ProcessStartMode.detached);
    }
  } catch (_) {}
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Community Message App',
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
