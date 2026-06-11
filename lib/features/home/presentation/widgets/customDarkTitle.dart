import 'package:flutter/material.dart';
import 'package:raminups/components/Ios_effect/iosTapEffect.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/constants/asset_constants.dart';

class CustomLightTitleBar1 extends StatelessWidget
    implements PreferredSizeWidget {
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
              Assets.logo,
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
                  onTap: () {

                  },
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

            // Minimize
            IconButton(
              icon: const Icon(
                Icons.remove,
                color: Colors.black,
                size: 16,
              ),
              onPressed: () async => await windowManager.minimize(),
            ),

            // Maximize
            IconButton(
              icon: const Icon(
                Icons.crop_square,
                color: Colors.black,
                size: 14,
              ),
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.unmaximize();
                } else {
                  await windowManager.maximize();
                }
              },
            ),

            // Close
            IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.black,
                size: 16,
              ),
              onPressed: () async => await windowManager.close(),
            ),
          ],
        ),
      ),
    );
  }
}