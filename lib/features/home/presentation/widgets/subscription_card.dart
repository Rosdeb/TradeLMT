import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/subscription_providers.dart';

class SubscriptionCard extends ConsumerStatefulWidget {
  final String title;
  final String price;
  final String period;
  final String description;
  final List<String> features;
  final bool isPopular;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.period,
    required this.description,
    required this.features,
    this.isPopular = false,
  });

  @override
  ConsumerState<SubscriptionCard> createState() => _SubscriptionCardState();
}

class _SubscriptionCardState extends ConsumerState<SubscriptionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final selectedPlan = ref.watch(selectedPlanProvider);
    final isSelected =
        selectedPlan == widget.title ||
        (selectedPlan == null && widget.title == 'Starter Pro');
    final accent = widget.isPopular
        ? const Color(0xFF2563EB)
        : const Color(0xFF0D9488);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () =>
            ref.read(selectedPlanProvider.notifier).state = widget.title,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? accent
                  : _isHovered
                  ? const Color(0xFFBDC3CF)
                  : const Color(0xFFE4E7ED),
              width: isSelected ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: _isHovered ? 0.07 : 0.035,
                ),
                blurRadius: _isHovered ? 12 : 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Color(0xFF111827),
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (widget.isPopular) _PlanBadge(color: accent),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.price,
                    style: const TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      widget.period,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                widget.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              const Divider(color: Color(0xFFE4E7ED), height: 1),
              const SizedBox(height: 14),
              Expanded(
                child: Column(
                  children: [
                    for (final feature in widget.features)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, color: accent, size: 16),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                feature,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF374151),
                                  fontSize: 12,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(selectedPlanProvider.notifier).state =
                          widget.title,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: isSelected
                        ? accent
                        : const Color(0xFFF9FAFB),
                    foregroundColor: isSelected
                        ? Colors.white
                        : const Color(0xFF374151),
                    side: BorderSide(
                      color: isSelected ? accent : const Color(0xFFD1D5DB),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                  ),
                  child: Text(
                    isSelected ? 'Selected' : 'Choose Plan',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  final Color color;

  const _PlanBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Text(
        'POPULAR',
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
