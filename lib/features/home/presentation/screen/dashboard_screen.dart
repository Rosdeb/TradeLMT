import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/core/utils/app_colour.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/iconsButton.dart';
import '../widgets/trading_list_assets.dart';

final maxTradesProvider = StateProvider<double>((ref) => 5);
final apiStatusProvider = StateProvider<bool>((ref) => true);
final timeLockProvider = StateProvider<bool>((ref) => true);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApiConnected = ref.watch(apiStatusProvider);
    final isTimeLocked = ref.watch(timeLockProvider);
    const mintGreen = Color(0xFF00C887);
    const textMuted = Color(0xFF7A869A);
    final tradeLimit = ref.watch(tradeLimitCountProvider);
    print("tradeLimit: $tradeLimit");
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Trades Today Card
                Expanded(
                  child: _buildStatCard(
                    cardColor: AppColors.white_bg,
                    title: 'Trades Today',
                    textMuted: textMuted,
                    child: RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                            text: '4',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: '10/5',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Lock Status Card
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

                // Platforms Card
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

            Container(
              constraints: const BoxConstraints(minWidth: 300),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.white_bg,
                borderRadius: BorderRadius.circular(16),
               ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header title and percentage layout
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Daily Trade Limit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '80%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: mintGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Linear Progress Indicator matching the mint styling
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      value: 0.8,
                      minHeight: 12,
                      backgroundColor: Color(0xFFAFADAD),
                      valueColor: AlwaysStoppedAnimation<Color>(mintGreen),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Footer Caption text
                  const Text(
                    '1 trade remaining before auto-lock',
                    style: TextStyle(fontSize: 13, color: textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            TradingPlatformsWidget(),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),

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
                            Icon(Icons.dashboard),
                            const SizedBox(width: 10),
                            AppText(
                              "Daily Trade Limit",
                              fontSize: 20,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          "The maximum number of positions allowed before the terminal enters Restricted Mode.",
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                        const SizedBox(height: 10),
                        TradeLimitCounter(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white_bg,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer, color: Colors.black),
                            const SizedBox(width: 10),
                            AppText(
                              "Lock Duration",
                              fontSize: 20,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        AppText(
                          "The maximum number of positions allowed before the terminal enters Restricted Mode.",
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 45,
                          child: Consumer(
                            builder: (context, ref, child) {
                              final selectedDuration = ref.watch(lockDurationProvider);

                              final durations = [1, 2, 4, 8];

                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: durations.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 10),
                                itemBuilder: (context, index) {
                                  final duration = durations[index];
                                  final isSelected = selectedDuration == duration;

                                  return InkWell(
                                    onTap: () {
                                      ref.read(lockDurationProvider.notifier).state = duration;
                                    },
                                    child: Container(
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.blue
                                            : Colors.white70,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: AppColors.textDark
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.textDark.withValues(alpha: 0.12),
                                            blurRadius: 2,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: AppText(
                                          "$duration Hour",
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.w600,
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
                ),
              ],
            ),
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
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            spreadRadius: 0,
            blurRadius: 1,
            offset: Offset(1, -1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
          ),
          child,
        ],
      ),
    );
  }

  // Helper metric display block
  Widget _buildMetricCard(
    String title,
    String val,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(height: 4),
              AppText(
                val,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                AppText(
                  subtitle,
                  style: const TextStyle(color: Colors.green, fontSize: 12),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // Helper block for structural breakdown analytics
  Widget _buildPerformanceSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Performance Analytics',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 16),
          _buildRowMetric('Average Profit Trade', '+\$450.00', Colors.green),
          const Divider(height: 20),
          _buildRowMetric('Average Loss Trade', '-\$180.00', Colors.red),
          const Divider(height: 20),
          _buildRowMetric(
            'Active Running Trades',
            '2 Positions Open',
            Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _buildRowMetric(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          label,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
        ),
        AppText(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // Column 2 Component: Simulating TradingView Engine
  Widget _buildTradingViewPlaceholder() {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 10,
                ),
                itemBuilder: (context, index) => Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 0.5),
                  ),
                ),
              ),
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.candlestick_chart, size: 48, color: Colors.green),
                SizedBox(height: 12),
                AppText(
                  'TradingView Live Integration Stream',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                AppText(
                  'BTC/USD · 1m Chart Active',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrokerListSection() {
    final brokers = [
      {
        'name': 'Thinkorswim',
        'status': 'Connected',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'name': 'Tradovate',
        'status': 'Connected',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
      {
        'name': 'Interactive Brokers',
        'status': 'Disconnected',
        'icon': Icons.cancel,
        'color': Colors.red,
      },
      {
        'name': 'Robinhood',
        'status': 'Connected',
        'icon': Icons.check_circle,
        'color': Colors.green,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Connected Broker Accounts',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: brokers
                .map(
                  (broker) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          AppText(
                            broker['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Color(0xFF1E293B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Icon(
                            broker['icon'] as IconData,
                            color: broker['color'] as Color,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // Column 3 Component: Active Interactive Sliders for Custom Risk Guardrails
  Widget _buildRiskManagementConsole(WidgetRef ref) {
    final maxTrades = ref.watch(maxTradesProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              AppText(
                'Risk Management Rules',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                'Max trades / day',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              AppText(
                '${maxTrades.toInt()} Trades',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          Slider(
            value: maxTrades,
            min: 1,
            max: 20,
            activeColor: Colors.orange,
            inactiveColor: const Color(0xFFE2E8F0),
            onChanged: (val) =>
                ref.read(maxTradesProvider.notifier).state = val,
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Max loss / day cap',
                style: TextStyle(
                  color: Color(0xFF334155),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              AppText(
                '\$500.00 Limit',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppText(
                      'Cooldown Rest Timer',
                      style: TextStyle(
                        color: Color(0xFF7C2D12),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const AppText(
                        'Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: AppText(
                    'Locks orders for 15 minutes immediately following any sudden multi-point trailing stop-out event.',
                    style: TextStyle(
                      color: Color(0xFF9A3412),
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
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

    return Row(
      children: [
        CircleIconButton(
          icon: Icons.remove,
          onPressed: () {
            if(tradeLimit == 0){

            }else{
              ref.read(tradeLimitCountProvider.notifier).state--;
            }
            print("hello ");
          },
        ),

        const SizedBox(width: 10),
        AppText(tradeLimit.toString()),
        const SizedBox(width: 10),
        CircleIconButton(
          icon: Icons.add,
          onPressed: () {
            ref.read(tradeLimitCountProvider.notifier).state++;
          },
        ),
      ],
    );
  }
}
