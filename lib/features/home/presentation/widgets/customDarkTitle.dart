import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:window_manager/window_manager.dart';
import 'package:raminups/components/Ios_effect/iosTapEffect.dart';
import '../../../../core/constants/asset_constants.dart';

class CustomLightTitleBar1 extends StatelessWidget implements PreferredSizeWidget {
  const CustomLightTitleBar1({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text(
                      "Rosdeb",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.black,
                      ),
                    ),
                    Text(
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
                  onTap: () {},
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      "https://img.magnific.com/free-photo/expressive-woman-posing-outdoor_344912-3079.jpg?semt=ais_hybrid&w=740&q=80",
                      width: 34,
                      height: 34,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
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