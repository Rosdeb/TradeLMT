import 'package:flutter/material.dart';

class JournalOverviewWidget extends StatelessWidget {
  const JournalOverviewWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7C2C2),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFF262C36),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
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

          // Metrics — Wrap so the tiles flow to the next line on narrow
          // windows instead of overflowing the row.
          const Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              _JournalMetric(isWin: true, title: '60% Wins', subtitle: '40% Loss'),
              _JournalMetric(isWin: false, title: '30% Wins', subtitle: '10% Loss'),
              _JournalMetric(isWin: false, title: '20% Wins', subtitle: '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _JournalMetric extends StatelessWidget {
  const _JournalMetric({
    required this.isWin,
    required this.title,
    required this.subtitle,
  });

  final bool isWin;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 96, maxWidth: 170),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status dot
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
          // Text stats — allowed to wrap, column sized to its content
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  softWrap: true,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  softWrap: true,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
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
