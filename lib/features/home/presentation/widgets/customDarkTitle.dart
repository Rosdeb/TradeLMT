import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raminups/core/utils/app_colour.dart';
import 'package:window_manager/window_manager.dart';
import 'package:raminups/components/Ios_effect/iosTapEffect.dart';
import '../../../../core/constants/asset_constants.dart';
import '../providers/dashboard_providers.dart';
import 'edit_profile.dart';

class CustomLightTitleBar1 extends ConsumerWidget implements PreferredSizeWidget {
  const CustomLightTitleBar1({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final userProfileAsync = ref.watch(userProfileProvider);


    return DragToMoveArea(
      child: Container(
        height: 45,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(
              Assets.logo_512,
              height: 40,
            ),
            const Spacer(),

            // User Info
            userProfileAsync.when(
              data: (user) {
                return Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "Premium User",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 10),
                    IosTapEffect(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => const EditProfileDialog(),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(2), // Space between image and border
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.black, // Green border, change color if needed
                            width: 0.8,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: (user.avatar != null && user.avatar!.isNotEmpty)
                              ? Image.network(
                                  user.avatar!,
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Image.network(
                                    "https://img.magnific.com/free-photo/expressive-woman-posing-outdoor_344912-3079.jpg?semt=ais_hybrid&w=740&q=80",
                                    width: 34,
                                    height: 34,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Image.network(
                                  "https://img.magnific.com/free-photo/expressive-woman-posing-outdoor_344912-3079.jpg?semt=ais_hybrid&w=740&q=80",
                                  width: 34,
                                  height: 34,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              error: (_, __) => const SizedBox(),
            ),
            const SizedBox(width: 20),

            // Clean Window Controls Section
            _buildWindowButton(
              icon: Icons.remove,
              iconSize: 16,
              onPressed: () async => await windowManager.minimize(),
            ),
            _buildWindowButton(
              icon: Icons.crop_square,
              iconSize: 14,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),
            _buildWindowButton(
              icon: Icons.close,
              iconSize: 16,
              isCloseButton: true, // Optional: highlight red color on hover if needed
              onPressed: () async => await windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }

  // Refactored Helper widget to eliminate standard frame artifacts
  Widget _buildWindowButton({
    required IconData icon,
    required double iconSize,
    required VoidCallback onPressed,
    bool isCloseButton = false,
  }) {
    return IconButton(
      icon: Icon(icon, size: iconSize),
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      splashRadius: 18,
      style: IconButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.transparent, // Forces transparent state when not active
        hoverColor: isCloseButton
            ? Colors.red.withValues(alpha: 0.8)
            : Colors.black.withOpacity(0.06), // Controlled subtle background overlay ONLY on hover
        highlightColor: Colors.black.withOpacity(0.1),
      ),
    );
  }
}