import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/connection_providers.dart';
import '../providers/dashboard_providers.dart';
import '../providers/home_providers.dart';
import '../providers/subscription_providers.dart';

class LogoutDialog extends ConsumerWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 250,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  size: 40,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Log Out",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to log out from your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        )
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // 1. Clear all local cache & tokens completely
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        
                        // 2. Reset global trade sync status
                        resetTradeSyncState();

                        // 3. Invalidate cached Riverpod providers so old account data isn't preserved
                        ref.invalidate(userProfileProvider);
                        ref.invalidate(fetchTradeLimitProvider);
                        ref.invalidate(brokerConnectionsProvider);
                        ref.invalidate(activeTabProvider);
                        ref.invalidate(isTradeLimitLockedProvider);
                        ref.invalidate(remainingTradesProvider);
                        ref.invalidate(tradeLimitCountProvider);
                        ref.invalidate(lockDurationProvider);
                        ref.invalidate(selectedPlatformsProvider);
                        ref.invalidate(sseConnectedProvider);
                        ref.invalidate(selectedPlanProvider);

                        // 4. Navigate to Splash (Login Screen) using GoRouter
                        if (context.mounted) {
                          context.goNamed(AppRoutes.splash);
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
