import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../components/AppText/appText.dart';
import '../widgets/subscription_card.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Subscription',
                        style: TextStyle(
                          color: Color(0xFF111827),
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Manage plan access, billing limits, and trading workspace capacity.',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                _CurrentPlanBadge(),
              ],
            ),
            const SizedBox(height: 18),
            //const _UsageOverview(),
            const SizedBox(height: 16),
            const Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SubscriptionCard(
                      title: 'Starter',
                      price: '\$9',
                      period: '/mo',
                      description:
                          'For individual traders building a basic workflow.',
                      features: [
                        '1 broker connection',
                        'Core risk dashboard',
                        '5GB cloud storage',
                        'Email support',
                      ],
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: SubscriptionCard(
                      title: 'Starter Pro',
                      price: '\$15',
                      period: '/mo',
                      description:
                          'For active traders who need more automation.',
                      features: [
                        '3 broker connections',
                        'Advanced guardrails',
                        '25GB cloud storage',
                        'Priority support',
                      ],
                      isPopular: true,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: SubscriptionCard(
                      title: 'Enterprise',
                      price: '\$35',
                      period: '/mo',
                      description:
                          'For teams managing multiple desks and accounts.',
                      features: [
                        'Unlimited connections',
                        'Team policy controls',
                        'More Broker Connection',
                        'Dedicated onboarding',
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _BillingFooter(),
          ],
        ),
      ),
    );
  }
}

class _CurrentPlanBadge extends StatelessWidget {
  const _CurrentPlanBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E7ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: Color(0xFF2563EB),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Current Plan',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 10.5),
              ),
              SizedBox(height: 2),
              Text(
                'Starter Pro',
                style: TextStyle(
                  color: Color(0xFF111827),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageOverview extends StatelessWidget {
  const _UsageOverview();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _UsageTile(
            label: 'Billing Cycle',
            value: 'Renews Jun 30',
            icon: Icons.event_available_outlined,
            color: Color(0xFF2563EB),
            bg: Color(0xFFEFF6FF),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _UsageTile(
            label: 'Broker Seats',
            value: '2 of 3 used',
            icon: Icons.hub_outlined,
            color: Color(0xFF0D9488),
            bg: Color(0xFFE6FFFA),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _UsageTile(
            label: 'Storage',
            value: '8.2GB of 25GB',
            icon: Icons.storage_outlined,
            color: Color(0xFFD97706),
            bg: Color(0xFFFEF3C7),
          ),
        ),
      ],
    );
  }
}

class _UsageTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color bg;

  const _UsageTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E7ED)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF111827),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

class _BillingFooter extends StatelessWidget {
  const _BillingFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE4E7ED)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, color: Color(0xFF2563EB), size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Billing changes are encrypted and applied at the next renewal unless upgraded immediately.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11.5),
            ),
          ),
          const SizedBox(width: 14),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1D4ED8),
              side: const BorderSide(color: Color(0xFF2563EB)),
              minimumSize: const Size(116, 34),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(7),
              ),
            ),
            child: const Text(
              'Billing Portal',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
