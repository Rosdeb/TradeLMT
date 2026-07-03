import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/core/utils/app_colour.dart';
import 'package:raminups/features/home/presentation/screen/connection_screen.dart';
import 'package:raminups/features/home/presentation/screen/subscription_screen.dart';
import '../../../../components/desktop_app/desktop_app_bar.dart';
import '../providers/home_providers.dart';
import '../providers/dashboard_providers.dart';
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Trigger /auth/me API call on screen load
    ref.watch(userProfileProvider);
    
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