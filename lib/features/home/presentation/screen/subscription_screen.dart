import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/core/utils/app_colour.dart';

import '../widgets/subscription_card.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          children: [

            AppText("Pick a plan right for you?",fontSize: 28,color: AppColors.textDark,fontWeight: FontWeight.w500,),
            AppText("Choose a plan that work best for you and your team.",fontSize: 16,color: AppColors.textDark,),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SubscriptionCard(
                    title: 'Starter',
                    height: 400,
                    price: '\$9',
                    period: '/month',
                    description: 'Perfect for individuals getting started.',
                    features: const [
                      'Access to core features',
                      '5GB Cloud Storage',
                      'Email Support',
                    ],
                    isPopular: false,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SubscriptionCard(
                    title: 'Starter',
                    price: '\$9',
                    period: '/month',
                    description: 'Perfect for individuals getting started.',
                    features: const [
                      'Access to core features',
                      '5GB Cloud Storage',
                      'Email Support',
                    ],
                    isPopular: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SubscriptionCard(
                    title: 'Starter',
                    price: '\$9',
                    height: 400,
                    period: '/month',
                    description: 'Perfect for individuals getting started.',
                    features: const [
                      'Access to core features',
                      '5GB Cloud Storage',
                      'Email Support',
                    ],
                    isPopular: false,
                  ),
                ),

              ],
            )
          ],
        ),
      ),
    );
  }
}
