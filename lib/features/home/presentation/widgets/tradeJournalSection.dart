import 'dart:ui';

import 'package:flutter/material.dart';

class TradeJournalSection extends StatelessWidget {
  const TradeJournalSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: _buildDailyJournal(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: _buildMonthlyJournal(),
        ),
      ],
    );
  }

  Widget _buildDailyJournal(BuildContext context) {
    final List<Map<String, dynamic>> dailyTrades = [
      {'id': 'T#01', 'isWin': true, 'amount': '+\$00', 'isPositive': true},
      {'id': 'T#02', 'isWin': true, 'amount': '-\$20', 'isPositive': false},
      {'id': 'T#03', 'isWin': true, 'amount': '+\$20', 'isPositive': true},
      {'id': 'T#04', 'isWin': false, 'amount': '-\$30', 'isPositive': false},
      {'id': 'T#05', 'isWin': false, 'amount': '-\$30', 'isPositive': false},
      {'id': 'T#06', 'isWin': false, 'amount': '-\$30', 'isPositive': false},
    ];

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF262C36), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Journal (12JUN2026)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFE74C3C),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
      SizedBox(
        height: 150,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) => true,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: dailyTrades.length,
              itemBuilder: (context, index) {
                  final trade = dailyTrades[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F242C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: trade['isWin']
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            trade['isWin'] ? Icons.check : Icons.close,
                            color: const Color(0xFF161B22),
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${trade['id']} - ${trade['isWin'] ? 'WIN' : 'LOSS'}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          trade['amount'],
                          style: TextStyle(
                            color: trade['isPositive']
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFFE74C3C),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
      ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildMonthlyJournal() {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFF262C36), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monthly Journal\n(June 2026)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              children: [
                const Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('150', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('100', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('50', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Text('0', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    SizedBox(height: 12),
                  ],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                4,
                                    (_) => const Divider(
                                  color: Color(0xFF262C36),
                                  height: 1,
                                  thickness: 1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _buildBar(
                                    valueFactor: 105 / 150,
                                    barColor: const Color(0xFF2ECC71),
                                  ),
                                  _buildBar(
                                    valueFactor: 40 / 150,
                                    barColor: const Color(0xFFE74C3C),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('Wins', style: TextStyle(color: Colors.grey, fontSize: 11)),
                          Text('Loss', style: TextStyle(color: Colors.grey, fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar({required double valueFactor, required Color barColor}) {
    return FractionallySizedBox(
      heightFactor: valueFactor,
      child: Container(
        width: 24,
        decoration: BoxDecoration(
          color: barColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(4),
          ),
        ),
      ),
    );
  }
}

// --- HELPER WRAPPER CARD FOR TOP ROW METRICS ---
Widget buildStatCard({
  required Color cardColor,
  required String title,
  required Color textMuted,
  required Widget child,
}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF161B22),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF262C36), width: 1.0),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    ),
  );
}