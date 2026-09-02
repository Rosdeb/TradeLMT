import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/core/utils/app_colour.dart';
import '../providers/dashboard_providers.dart';
import '../providers/trade_limit_state.dart';
import 'iconsButton.dart';

class DailyTradeLimitConfigWidget extends ConsumerWidget {
  const DailyTradeLimitConfigWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitState = ref.watch(tradeLimitStateProvider);
    if (!limitState.loaded) {
      return const _DailyTradeLimitConfigShimmer();
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white_bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.security, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 12),
              AppText(
                "Daily Trade Limit",
                fontSize: 15,
                color: AppColors.textDark,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppText(
            "Configure your daily trade limit to prevent overtrading. The terminal will enter Restricted Mode upon reaching this limit.",
            fontWeight: FontWeight.w400,
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 12),

          // Counter and Selector Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "Max Trades",
                    fontSize: 12,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(height: 6),
                  const TradeLimitCounter(),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "Lockout Duration",
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 34,
                      width: double.infinity,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final selectedDuration = ref.watch(
                            lockDurationProvider,
                          );
                          final isLockedInner = ref.watch(
                            isTradeLimitLockedProvider,
                          );
                          final durations = [1, 2, 4, 8, 12, 24];

                          return ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            itemCount: durations.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final duration = durations[index];
                              final isSelected = selectedDuration == duration;

                              return InkWell(
                                onTap: isLockedInner
                                    ? null
                                    : () {
                                        ref.read(lockDurationProvider.notifier,).state = duration;
                                      },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 36,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(
                                            0xFF2ECC71,
                                          ).withValues(alpha: 0.1)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: AppText(
                                      "$duration H",
                                      color: isSelected
                                          ? const Color(0xFF2ECC71)
                                          : const Color(0xFF000000),
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final isLockedInner = ref.watch(isTradeLimitLockedProvider);
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLockedInner
                      ? null
                      : () async {
                          try {
                            final repository = ref.read(settingRepositoryProvider,);
                            final dailyLimit = ref.read(tradeLimitCountProvider,);
                            final lockoutHours = ref.read(lockDurationProvider);

                            await repository.updateTradeLimit(
                              dailyLimit: dailyLimit,
                              lockoutHours: lockoutHours,
                            );
                            ref.read(tradeMonitorProvider).refreshNow('limit-change');
                            ref.invalidate(todayTradesProvider);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Daily Lock Limit saved successfully!',
                                ),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Color(0xFF2ECC71),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update limit: $e'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                  icon: Icon(
                    isLockedInner ? Icons.lock : Icons.check_circle_outline,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: AppText(
                    isLockedInner ? "Active Lock" : "Save Changes",
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLockedInner
                        ? Colors.grey
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    elevation: isLockedInner ? 0 : 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TradeLimitCounter extends ConsumerWidget {
  const TradeLimitCounter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tradeLimit = ref.watch(tradeLimitCountProvider);
    final isLocked = ref.watch(isTradeLimitLockedProvider);

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
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
          Container(
            width: 34,
            alignment: Alignment.center,
            child: AppText(
              tradeLimit.toString(),
              color: AppColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          CircleIconButton(
            icon: Icons.add,
            onPressed: isLocked
                ? () {}
                : () {
                    ref.read(tradeLimitCountProvider.notifier).state++;
                  },
          ),
        ],
      ),
    );
  }
}

class _DailyTradeLimitConfigShimmer extends StatefulWidget {
  const _DailyTradeLimitConfigShimmer();

  @override
  State<_DailyTradeLimitConfigShimmer> createState() =>
      _DailyTradeLimitConfigShimmerState();
}

class _DailyTradeLimitConfigShimmerState
    extends State<_DailyTradeLimitConfigShimmer>
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
          constraints: const BoxConstraints(minHeight: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white_bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Opacity(
            opacity: opacity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 140,
                      height: 20,
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
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 60,
                          height: 8,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 100,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 8,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 34,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
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
