import 'package:flutter/material.dart';

class JournalOverviewWidget extends StatelessWidget {
  const JournalOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Using the dark mode background requested by the user/snippet
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFC7C2C2), // Dark slate/navy background
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF262C36), // Subtle border outline
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Row
          const Text(
            'Journal Overview',
            style: TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),

          // Metrics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildJournalMetric(
                isWin: true,
                title: '60% Wins',
                subtitle: 'Loss Loss',
              ),
              const SizedBox(width: 32), // Spacing between metrics
              _buildJournalMetric(
                isWin: false,
                title: '30% Wins',
                subtitle: '10% Loss',
              ),
              const SizedBox(width: 32),
              _buildJournalMetric(
                isWin: false,
                title: '20% Wins',
                subtitle: 'Loss Loss',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJournalMetric({
    required bool isWin,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status indicator dot (Green for overall wins, Red for losses/drawdowns)
        Padding(
          padding: const EdgeInsets.only(top: 4.0, right: 8.0),
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isWin ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Text stats block
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:  TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xFF94A3B8), // Muted grey-blue text for readable labels
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }
}