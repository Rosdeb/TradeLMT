import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raminups/features/home/presentation/screen/connection_screen.dart';
import 'package:raminups/features/home/presentation/screen/subscription_screen.dart';
import 'package:window_manager/window_manager.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/home_providers.dart';
import '../providers/dashboard_providers.dart';
import '../providers/trade_limit_state.dart';
import '../widgets/customDarkTitle.dart';
import 'app_sidebar.dart';
import 'dashboard_screen.dart';
import 'setting_screen.dart';


// Views are const — Flutter reuses them across rebuilds with no allocation cost.
const List<Widget> _kViews = [
  DashboardScreen(),
  ConnectionScreen(),
  GuardrailsScreen(),
  SubscriptionScreen(),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver, WindowListener {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    windowManager.addListener(this);
    // The one and only place the trade-limit monitor is started.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tradeMonitorProvider).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    windowManager.removeListener(this);
    ref.read(tradeMonitorProvider).stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(tradeMonitorProvider).refreshNow('app-resumed');
    }
  }

  // Desktop: fired when the user brings the window back to the foreground
  // (e.g. alt-tabbing from the broker terminal). Closest thing to a
  // "before trade" re-check we can do.
  @override
  void onWindowFocus() {
    ref.read(tradeMonitorProvider).refreshNow('window-focus');
  }

  @override
  Widget build(BuildContext context) {
    // Trigger /auth/me API call on screen load
    ref.watch(userProfileProvider);

    // Bounce to login if the monitor saw a 401/403.
    ref.listen<bool>(sessionExpiredProvider, (prev, expired) {
      if (expired == true && mounted) {
        ref.read(sessionExpiredProvider.notifier).state = false;
        context.goNamed(AppRoutes.splash);
      }
    });

    final index = ref.watch(activeTabProvider);

    return Scaffold(
      // ── Custom title bar spans full width above everything ─────────────────
      appBar: const CustomLightTitleBar1(),
      body: Row(
        children: [
          // ── Sidebar ────────────────────────────────────────────────────────
          const AppSidebar(),

          // ── Content area ───────────────────────────────────────────────────
          Expanded(
            child: IndexedStack(
              index: index,
              children: _kViews,
            ),
          ),
        ],
      ),
    );
  }
}
