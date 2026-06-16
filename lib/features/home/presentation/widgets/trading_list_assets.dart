import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/components/Ios_effect/iosTapEffect.dart'; // Using your custom iOS tap effect!

import '../providers/dashboard_providers.dart';

class TradingPlatformsWidget extends ConsumerWidget {
  const TradingPlatformsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platforms = ref.watch(tradingPlatformsProvider);
    // Watch the list of currently selected platform names
    final selectedPlatforms = ref.watch(selectedPlatformsProvider);

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: platforms.length,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final item = platforms[index];
          // Check if this specific item is currently selected
          final isSelected = selectedPlatforms.contains(item.name);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IosTapEffect(
                onTap: () {
                  final currentSelected = ref.read(selectedPlatformsProvider);

                  if (currentSelected.contains(item.name)) {
                    // If already selected, remove it from the list
                    ref.read(selectedPlatformsProvider.notifier).state =
                        currentSelected.where((name) => name != item.name).toList();
                  } else {
                    // If not selected, add it to the list
                    ref.read(selectedPlatformsProvider.notifier).state =
                    [...currentSelected, item.name];
                  }
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Base Circle Container
                    Container(
                      width: 54,
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? const Color(0xFF2ECC71) : Colors.transparent,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        item.logo,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Top-Right Status Badge (Checkmark or Lock)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFF161B22),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: isSelected
                              ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                              : const Icon(
                            Icons.lock,
                            size: 9,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Platform Label Text Block
               Text(
                  item.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF2ECC71) : Colors.black  ,
                  ),
                ),

            ],
          );
        },
      ),
    );
  }
}