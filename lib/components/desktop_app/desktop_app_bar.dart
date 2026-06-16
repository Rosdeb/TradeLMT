import 'package:flutter/material.dart';
import 'package:raminups/core/constants/asset_constants.dart';
import 'package:window_manager/window_manager.dart';

class CustomLightTitleBar extends StatelessWidget implements PreferredSizeWidget {

  const CustomLightTitleBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(32);

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 45,
        color: Colors.white, // Light background bar
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            // App Title/Logo
            Image.asset(Assets.logo_512),
            const Spacer(),

            // Minimize Button (Black Icon)
            IconButton(
              icon: const Icon(Icons.remove, color: Colors.black, size: 16),
              onPressed: () async => await windowManager.minimize(),
            ),
            const SizedBox(width: 16),

            // Maximize/Restore Button (Black Icon)
            IconButton(
              icon: const Icon(Icons.crop_square, color: Colors.black, size: 14),
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  windowManager.unmaximize();
                } else {
                  windowManager.maximize();
                }
              },
            ),
            const SizedBox(width: 16),

            // Close Button (Black Icon)
            IconButton(
              icon: const Icon(Icons.close, color: Colors.black, size: 16),
              onPressed: () async => await windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }
}