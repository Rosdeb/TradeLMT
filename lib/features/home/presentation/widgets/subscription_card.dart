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
  ConsumerState<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<SubscriptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(selectedPlanProvider) == widget.title;

    final cardHeight = widget.height ?? (widget.isPopular ? 450.0 : 400.0);
    final accentColor = widget.isPopular ? const Color(0xFF3F51B5) : Colors.green;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: cardHeight,
        transform: _isHovered
            ? (Matrix4.identity()..translate(0.0, -6.0, 0.0))
            : Matrix4.identity(),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.indigo.shade400 : Colors.transparent,
            width: isSelected ? 2.5 : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.25 : 0.15),
              blurRadius: _isHovered ? 25 : 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  widget.price,
                  style: const TextStyle(color: Colors.white, fontSize: 46, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: AppText(
                    widget.period,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13), // Swapped code here
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            AppText(
              widget.description,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4), // Swapped code here
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.features.length,
                padding: EdgeInsets.all(0),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: accentColor, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppText(
                          widget.features[index],
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => ref.read(selectedPlanProvider.notifier).state = widget.title,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.indigo.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  isSelected ? "Selected" : "Choose Plan",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}