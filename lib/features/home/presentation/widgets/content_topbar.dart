import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:raminups/components/AppText/appText.dart';
import 'package:raminups/core/utils/app_colour.dart';

class ContentTopBar extends StatelessWidget {
  const ContentTopBar({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
      child: Row(
        children: [
          AppText(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          _IconBtn(icon: Iconsax.notification),
          const SizedBox(width: 8),
          _IconBtn(icon: Iconsax.setting_2),
          const SizedBox(width: 8),
          _Avatar(initials: 'JD'),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  const _IconBtn({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.border, width: 0.5),
    ),
    child: Icon(icon, size: 16, color: AppColors.textSecondary),
  );
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: const BoxDecoration(
      color: AppColors.activeGreen,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(
      initials,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF0f1a0f),
      ),
    ),
  );
}
