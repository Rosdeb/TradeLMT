import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:raminups/core/utils/app_colour.dart';

import '../../../../components/AppText/appText.dart';

class DeletedAccount extends StatelessWidget {
  const DeletedAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 250,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 80,
                width: 80,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_outlined,
                  size: 40,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Delete Account",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Are you sure you want to delete your account?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                      ).copyWith(
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        // Forces the clickable hand icon cursor explicitly on desktop and web systems
                        mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                      ),
                      child: Text("Cancel",style: TextStyle(color: AppColors.textLight)),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Clear token
                        // Navigate Login Screen

                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Delete"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
