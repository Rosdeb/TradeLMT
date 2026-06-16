import 'package:flutter/material.dart';
import 'package:raminups/core/utils/app_colour.dart';
import '../../../../components/AppText/appText.dart'; // Maintains your exact custom text component path

class PasswordChangeDialog extends StatefulWidget {
  const PasswordChangeDialog({super.key});

  @override
  State<PasswordChangeDialog> createState() => _PasswordChangeDialogState();
}

class _PasswordChangeDialogState extends State<PasswordChangeDialog> {
  // Local form key & controllers for text validation
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State handles for toggling password visibility
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme configurations syncing directly with your trading terminal color palette
    const Color mintGreen = Color(0xFF2ECC71);
    const Color darkSlateBg = Color(0xFF161B22);
    const Color inputFieldBg = Color(0xFF1F242C);
    const Color borderStrokeColor = Color(0xFF262C36);

    return Dialog(
      backgroundColor: AppColors.white_bg, // Matches global TradeLMT container theme
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        width: 340, // Expanded slightly to provide optimal horizontal spacing for text input
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header System Security Key Icon
                Center(
                  child: Container(
                    height: 70,
                    width: 70,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: mintGreen.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.vpn_key_outlined,
                      size: 36,
                      color: mintGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Center(
                  child: AppText(
                    "Update Password",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),

                Center(
                  child: AppText(
                    "Ensure your broker APIs and terminal connections stay secure.",
                    textAlign: TextAlign.center,
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),

                // 1. New Password Input
                _buildPasswordField(
                  controller: _newPasswordController,
                  hintText: "Enter New Password",
                  labelText: "NEW PASSWORD",
                  obscureText: _obscureNewPassword,
                  backgroundColor: inputFieldBg,
                  borderColor: borderStrokeColor,
                  toggleVisibility: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) return "Password cannot be empty";
                    if (value.length < 6) return "Must be at least 6 characters";
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 2. Confirm Password Input
                _buildPasswordField(
                  controller: _confirmPasswordController,
                  hintText: "Confirm New Password",
                  labelText: "CONFIRM PASSWORD",
                  obscureText: _obscureConfirmPassword,
                  backgroundColor: inputFieldBg,
                  borderColor: borderStrokeColor,
                  toggleVisibility: () {
                    setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                  validator: (value) {
                    if (value != _newPasswordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                // Form Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.white_bg,
                          minimumSize: const Size(0, 46),
                          // Removes the web/desktop focus rings, splash ripples, and hover background color changes
                          splashFactory: NoSplash.splashFactory,
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          // Forces the clickable hand icon cursor explicitly on desktop and web systems
                          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                        ),
                        child: AppText(
                          "Cancel",
                          color: AppColors.textLight,
                          fontSize: 13,
                          fontWeight: FontWeight.bold, // Swapped from w600 to bold per your requirement
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Process update logic securely right here
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 46),
                          backgroundColor: mintGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(Colors.transparent),
                          mouseCursor: WidgetStateProperty.all(SystemMouseCursors.click),
                        ),
                        child: AppText(
                          "Save Changes",
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Textfield Extraction Helper Module for clean maintenance
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required bool obscureText,
    required Color backgroundColor,
    required Color borderColor,
    required VoidCallback toggleVisibility,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          labelText,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.black, fontSize: 13),
            filled: true,
            fillColor: AppColors.white_bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2.0),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2.0),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey,
                size: 18,
              ),
              onPressed: toggleVisibility,
            ),
          ),
        ),
      ],
    );
  }
}