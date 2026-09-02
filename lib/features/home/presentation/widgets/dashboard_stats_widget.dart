import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/core/utils/app_colour.dart';
import '../providers/dashboard_providers.dart';

class DashboardStatsWidget extends ConsumerWidget {
  const DashboardStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const mintGreen = Color(0xFF00C887);
    const textMuted = Color(0xFF7A869A);
    final tradeLimit = ref.watch(tradeLimitCountProvider);
    final todayTradesAsync = ref.watch(todayTradesProvider);
    final tradesToday = todayTradesAsync.value ?? 0;
    final remainingTrades = (tradeLimit - tradesToday).clamp(0, tradeLimit);

    return Column(
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
                  text: '$tradesToday',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                TextSpan(
                  text: ' / $tradeLimit',
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                  value: tradeLimit > 0
                      ? (tradesToday / tradeLimit).clamp(0.0, 1.0)
                      : 0.0,
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
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
            ],
          ),
        ),
      ],
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
