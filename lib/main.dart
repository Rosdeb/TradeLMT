import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app/app_initializer.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.init();
  // Initialize the Window Manager setup
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 650),          // Default starting window size when app launches
    minimumSize: Size(1100, 600),    // Strict minimum size threshold (Blocks mobile resizing)
    center: true,                   // Centers the app window on the desktop screen
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

  runApp(const ProviderScope(child: MyApp()));
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
