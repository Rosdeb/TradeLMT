import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/components/AppText/appText.dart';

import '../providers/subscription_providers.dart';

class SubscriptionCard extends ConsumerStatefulWidget {
  final String title;
  final String price;
  final double? height;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    this.height,
    required this.period,
    required this.description,
    required this.features,
    required this.isPopular,
  });

  @override
  ConsumerState<SubscriptionCard> createState() =>
      _SubscriptionCardState();
}

class _SubscriptionCardState
    extends ConsumerState<SubscriptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isSelected = selectedPlan == widget.title;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: widget.height ?? 450, // Fixed height
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF131C2E),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.indigo : Colors.grey.shade800,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  widget.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AppText(
                    widget.period,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            AppText(
              widget.description,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            const Divider(),

            const SizedBox(height: 12),

            /// Feature List
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.features.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: widget.isPopular
                              ? Colors.indigo
                              : Colors.green,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppText(
                            widget.features[index],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(selectedPlanProvider.notifier)
                      .state = widget.title;
                },
                child: Text(
                  isSelected ? "Selected" : "Choose Plan",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}