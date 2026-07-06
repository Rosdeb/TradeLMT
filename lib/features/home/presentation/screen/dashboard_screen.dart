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
import '../providers/connection_providers.dart';
import '../widgets/iconsButton.dart';
import '../widgets/tradeJournalSection.dart';
import '../widgets/trading_list_assets.dart';

final maxTradesProvider = StateProvider<double>((ref) => 5);
final apiStatusProvider = StateProvider<bool>((ref) => true);
final timeLockProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the broker list when the dashboard is loaded
    ref.watch(brokerConnectionsProvider);
    ref.watch(fetchTradeLimitProvider);

    final isApiConnected = ref.watch(apiStatusProvider);
    final isTimeLocked = ref.watch(timeLockProvider);
    const mintGreen = Color(0xFF00C887);
    const textMuted = Color(0xFF7A869A);
    final tradeLimit = ref.watch(tradeLimitCountProvider);
    final remainingTrades = ref.watch(remainingTradesProvider);
    final tradesToday = (tradeLimit - remainingTrades).clamp(0, tradeLimit);

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
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Trades Today Full Width
                      _buildStatCard(
                        cardColor: AppColors.white_bg,
                        title: 'Trades Today',
                        textMuted: textMuted,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$tradeLimit',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: ' / $tradesToday',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Lock Status + Platforms
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              cardColor: AppColors.white_bg,
                              title: 'Lock Status',
                              textMuted: textMuted,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: mintGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Active',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: mintGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _buildStatCard(
                              cardColor: AppColors.white_bg,
                              title: 'Platforms',
                              textMuted: textMuted,
                              child: const Text(
                                '3',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Daily Trade Limit
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white_bg,
                          borderRadius: BorderRadius.circular(16),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Daily Trade Limit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                 Text(
                                  '${tradeLimit > 0 ? ((tradesToday / tradeLimit).clamp(0.0, 1.0) * 100).toInt() : 0}%',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: mintGreen,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: tradeLimit > 0 ? (tradesToday / tradeLimit).clamp(0.0, 1.0) : 0.0,
                                minHeight: 12,
                                backgroundColor: const Color(0xFFAFADAD),
                                valueColor: const AlwaysStoppedAnimation<Color>(mintGreen),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              remainingTrades > 0
                                  ? '$remainingTrades trade(s) remaining before auto-lock'
                                  : 'Limit reached (Auto-locked)',
                              style: TextStyle(
                                fontSize: 13,
                                color: textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Right: Trade Journal Card
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
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
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final fetchLimitAsync = ref.watch(fetchTradeLimitProvider);
                      return fetchLimitAsync.when(
                        data: (_) {
                          return Container(
                            constraints: const BoxConstraints(minHeight: 200), // Keeps cards uniformly sized
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: AppColors.white_bg,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.dashboard, color: Colors.black),
                                    const SizedBox(width: 10),
                                    AppText(
                                      "Daily Trade Limit",
                                      fontSize: 18,
                                      color: AppColors.textDark,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AppText(
                                  "Once your daily trade limit is reached, the terminal will enter Restricted Mode and all connected trading platforms will be locked for the selected lock duration.",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),

                                // Counter and Selector Grid
                                Row(
                                  children: [
                                    const TradeLimitCounter(),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SizedBox(
                                        height: 40,
                                        width: double.infinity,
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final selectedDuration = ref.watch(lockDurationProvider);
                                            final isLockedInner = ref.watch(isTradeLimitLockedProvider);
                                            // Complete duration list matching client rules (1, 2, 4, 8, 12, 24)
                                            final durations = [1, 2, 4, 8, 12, 24];

                                            return ListView.separated(
                                              physics: const ScrollPhysics(),
                                              scrollDirection: Axis.horizontal,
                                              itemCount: durations.length,
                                              separatorBuilder: (_, __) => const SizedBox(width: 8),
                                              itemBuilder: (context, index) {
                                                final duration = durations[index];
                                                final isSelected = selectedDuration == duration;

                                                return InkWell(
                                                  onTap: isLockedInner
                                                      ? null
                                                      : () {
                                                          ref.read(lockDurationProvider.notifier).state = duration;
                                                        },
                                                  borderRadius: BorderRadius.circular(50),
                                                  child: Container(
                                                    width: 40,
                                                    height: 35,
                                                    decoration: BoxDecoration(
                                                      color: isSelected ? Colors.white : const Color(0xFFF5F6F8),
                                                      borderRadius: BorderRadius.circular(50),
                                                      border: Border.all(
                                                        color: isSelected ? const Color(0xFF2ECC71) : const Color(0xFFE5E7EB),
                                                        width: 1.5,
                                                      ),
                                                      boxShadow: [
                                                        if (isSelected)
                                                          BoxShadow(
                                                            color: const Color(0xFF2ECC71).withValues(alpha: 0.15),
                                                            blurRadius: 8,
                                                            offset: const Offset(0, 2),
                                                          ),
                                                      ],
                                                    ),
                                                    child: Center(
                                                      child: AppText(
                                                        "$duration H",
                                                        color: isSelected
                                                            ? const Color(0xFF2ECC71)
                                                            : const Color(0xFF6B7280),
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  )
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Consumer(
                                  builder: (context, ref, child) {
                                    final isLockedInner = ref.watch(isTradeLimitLockedProvider);
                                    return ElevatedButton.icon(
                                      onPressed: isLockedInner
                                          ? null
                                          : () async {
                                              try {
                                                final repository = ref.read(settingRepositoryProvider);
                                                final dailyLimit = ref.read(tradeLimitCountProvider);
                                                final lockoutHours = ref.read(lockDurationProvider);

                                                await repository.updateTradeLimit(
                                                  dailyLimit: dailyLimit,
                                                  lockoutHours: lockoutHours,
                                                );
                                                ref.invalidate(fetchTradeLimitProvider);

                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('Daily Lock Limit saved successfully!')),
                                                );
                                              } catch (e) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Failed to update limit: $e')),
                                                );
                                              }
                                            },
                                      icon: const Icon(Icons.lock_clock, size: 16, color: Colors.white),
                                      label: AppText(isLockedInner ? "Locked" : "Daily Lock", color: Colors.white, fontSize: 12),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isLockedInner ? Colors.grey : AppColors.red,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                        loading: () => const _DailyTradeLimitConfigShimmer(),
                        error: (err, stack) => const _DailyTradeLimitConfigShimmer(),
                      );
                    },
                  ),
                ),
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

  Widget _buildStatCard({
    required Color cardColor,
    required String title,
    required Color textMuted,
    required Widget child,
  }) {
    return Container(
      height: 105,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cardColor,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

// ── TradeLimitCounter ────────────────────────────────────────────────────────

class TradeLimitCounter extends ConsumerWidget {
  const TradeLimitCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradeLimit = ref.watch(tradeLimitCountProvider);
    final isLocked = ref.watch(isTradeLimitLockedProvider);

    return Row(
      children: [
        CircleIconButton(
          icon: Icons.remove,
          onPressed: isLocked
              ? () {}
              : () {
                  if (tradeLimit > 0) {
                    ref.read(tradeLimitCountProvider.notifier).state--;
                  }
                },
        ),
        const SizedBox(width: 10),
        AppText(tradeLimit.toString(), color: AppColors.black),
        const SizedBox(width: 10),
        CircleIconButton(
          icon: Icons.add,
          onPressed: isLocked
              ? () {}
              : () {
                  ref.read(tradeLimitCountProvider.notifier).state++;
                },
        ),
      ],
    );
  }
}

// ── BinanceBlockButton ───────────────────────────────────────────────────────

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isBlocking
            ? '🔴 Binance blocked — stays blocked until you unblock'
            : '✅ Binance unblocked'),
        backgroundColor: _isBlocking ? Colors.red : Colors.green,
      ));
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
          BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 4)
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
              Text('Binance Block',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
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
            width: 24, height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : ElevatedButton(
            onPressed: _toggle,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBlocking ? Colors.orange : Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
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

// ─────────────────────────────────────────────
//  SHIMMER LOADING CONFIG CARD
// ─────────────────────────────────────────────

class _DailyTradeLimitConfigShimmer extends StatefulWidget {
  const _DailyTradeLimitConfigShimmer();

  @override
  State<_DailyTradeLimitConfigShimmer> createState() => _DailyTradeLimitConfigShimmerState();
}

class _DailyTradeLimitConfigShimmerState extends State<_DailyTradeLimitConfigShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double opacity = 0.3 + (_controller.value * 0.4);
        return Container(
          constraints: const BoxConstraints(minHeight: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white_bg,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 120,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 100,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 110,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
