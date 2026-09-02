import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/core/utils/app_colour.dart';
import 'package:raminups/features/home/presentation/widgets/journalOverview.dart';
import 'package:raminups/features/home/presentation/widgets/manualDatePickerLock.dart';
import '../../../../core/Binace/binance_blocker.dart';
import '../../../../core/Binace/binance_blocker_service.dart';
import '../providers/dashboard_providers.dart';
import '../providers/trade_limit_state.dart';
import '../providers/connection_providers.dart';
import '../widgets/iconsButton.dart';
import '../widgets/tradeJournalSection.dart';
import '../widgets/trading_list_assets.dart';
import '../widgets/dashboard_stats_widget.dart';
import '../widgets/daily_trade_limit_config.dart';

final maxTradesProvider = StateProvider<double>((ref) => 5);
final apiStatusProvider = StateProvider<bool>((ref) => true);
final timeLockProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the broker list when the dashboard is loaded
    ref.watch(brokerConnectionsProvider);

    final isApiConnected = ref.watch(apiStatusProvider);
    final isTimeLocked = ref.watch(timeLockProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left: Stat Cards + Trade Limit Progress
                const Expanded(flex: 3, child: DashboardStatsWidget()),
                const SizedBox(width: 16),

                // Right: Trade Journal Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.green,
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(-2, 0),
                        ),
                        const BoxShadow(
                          color: Colors.green,
                          spreadRadius: 0,
                          blurRadius: 0,
                          offset: Offset(2, 0),
                        ),
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          spreadRadius: 0,
                          blurRadius: 1,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            AppText(
                              "Trade Journal",
                              color: AppColors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            const Spacer(),
                            Icon(Icons.menu_sharp, color: AppColors.back_icon),
                          ],
                        ),
                        const SizedBox(height: 5),
                        JournalOverviewWidget(),
                        const SizedBox(height: 5),
                        const TradeJournalSection(), // ← fixed scroll here
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TradingPlatformsWidget(),
            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. LEFT PANEL: Daily Trade Limit Configuration
                const Expanded(child: DailyTradeLimitConfigWidget()),
                const SizedBox(width: 16),

                // 2. RIGHT PANEL: Manual Lockout & Profit Protection Control
                ManualProtectionLockPanel(),
              ],
            ),

            const SizedBox(height: 16),
            const BinanceBlockButton(),
          ],
        ),
      ),
    );
  }
} // ── BinanceBlockButton ───────────────────────────────────────────────────────

class BinanceBlockButton extends StatefulWidget {
  const BinanceBlockButton({super.key});
  @override
  State<BinanceBlockButton> createState() => _BinanceBlockButtonState();
}

class _BinanceBlockButtonState extends State<BinanceBlockButton> {
  final _service = BinanceBlockerService();
  bool _isBlocking = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    // Saved state load করো
    _service.isBlocking().then((v) {
      setState(() {
        _isBlocking = v;
        _loading = false;
      });
    });
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    if (_isBlocking) {
      await _service.disableBlock();
    } else {
      await _service.enableBlock();
    }
    final state = await _service.isBlocking();
    setState(() {
      _isBlocking = state;
      _loading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBlocking
                ? '🔴 Binance blocked — stays blocked until you unblock'
                : '✅ Binance unblocked',
          ),
          backgroundColor: _isBlocking ? Colors.red : Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Icon(
            _isBlocking ? Icons.block : Icons.check_circle_outline,
            color: _isBlocking ? Colors.red : Colors.green,
            size: 26,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Binance Block',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              Text(
                _isBlocking
                    ? 'Blocked permanently until unblocked'
                    : 'Binance can open freely',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          _loading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : ElevatedButton(
                  onPressed: _toggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBlocking ? Colors.orange : Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _isBlocking ? 'Unblock' : 'Block Binance',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}
