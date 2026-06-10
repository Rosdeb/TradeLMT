import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:raminups/components/AppText/appText.dart';
import '../providers/subscription_providers.dart';
import '../widgets/subscription_card.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeNav = ref.watch(activeNavProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // LEFT SIDEBAR NAVIGATION RAIL

          // MAIN CONTENT SPACE
          Expanded(
            child: Column(
              children: [
                // TOP APP HEADER BAR

                // SUBSCRIPTION INTERFACE BODY
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(40, 20, 40, 40),
                    child: Column(
                      children: [
                        const AppText(
                          'Pick a plan right for you?',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const AppText(
                          'Choose a plan that work best for you and your team.',
                          style: TextStyle(color: Color(0xFF475569), fontSize: 15),
                        ),
                        const SizedBox(height: 50),

                        Container(
                          constraints: const BoxConstraints(maxWidth: 1100),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: const [
                              Expanded(
                                child: SubscriptionCard(
                                  title: 'Starter',
                                  price: '\$9',
                                  period: '/month',
                                  description: 'Perfect for individuals getting started.',
                                  features: [
                                    'Access to core features',
                                    '5GB Cloud Storage',
                                  ],
                                  isPopular: false,
                                ),
                              ),
                              SizedBox(width: 24),
                              Expanded(
                                child: SubscriptionCard(
                                  title: 'Starter Pro',
                                  price: '\$15',
                                  period: '/month',
                                  description: 'Perfect for growing individuals getting started.',
                                  features: [
                                    'Access to core features',
                                    '5GB Cloud Storage',
                                    'Email Support',
                                  ],
                                  isPopular: true,
                                ),
                              ),
                              SizedBox(width: 24),
                              Expanded(
                                child: SubscriptionCard(
                                  title: 'Enterprise',
                                  price: '\$35',
                                  period: '/month',
                                  description: 'Perfect for scaling business teams.',
                                  features: [
                                    'Access to core features',
                                    '5GB Cloud Storage',
                                  ],
                                  isPopular: false,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildNavItem(WidgetRef ref, String activeNav, String label, IconData icon) {
    final isSelected = activeNav == label;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => ref.read(activeNavProvider.notifier).state = label,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFC1DDC6) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected ? Border.all(color: const Color(0xFF4CAF50), width: 1.5) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFF475569), size: 20),
                const SizedBox(height: 6),
                AppText(
                  label,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFF1B5E20) : const Color(0xFF334155),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}