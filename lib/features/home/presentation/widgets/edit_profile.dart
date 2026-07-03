import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:io';
import 'dart:convert';
import 'package:raminups/core/utils/app_colour.dart';
import '../../../../components/AppText/appText.dart';
import '../providers/dashboard_providers.dart';
import '../providers/setting_providers.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  const EditProfileDialog({super.key});

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  String? _selectedImagePath;
  String? _currentAvatarUrl;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProfileProvider).value;
    if (user != null) {
      _nameController.text = user.name;
      _currentAvatarUrl = user.avatar;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    const XTypeGroup typeGroup = XTypeGroup(
      label: 'images',
      extensions: <String>['jpg', 'jpeg', 'png'],
    );
    final XFile? file = await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);

    if (file != null) {
      final int bytes = await file.length();
      if (bytes > 1024 * 1024) { // 1 MB limit
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image size must be less than 1 MB.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _selectedImagePath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileUpdateProvider);

    return Dialog(
      backgroundColor: AppColors.white_bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 340,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: AppText(
                    "Update Profile",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),

                // Avatar Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: _selectedImagePath != null
                              ? FileImage(File(_selectedImagePath!)) as ImageProvider
                              : (_currentAvatarUrl != null ? NetworkImage(_currentAvatarUrl!) : null),
                          child: _selectedImagePath == null && _currentAvatarUrl == null
                              ? const Icon(Icons.person, size: 40, color: Colors.grey)
                              : null,
                        ),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _nameController,
                  hintText: "Enter Name",
                  labelText: "FULL NAME",
                  validator: (value) => value == null || value.isEmpty ? "Name required" : null,
                ),
                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: AppText("Cancel", color: AppColors.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      await ref.read(profileUpdateProvider.notifier).updateProfile(
                                        name: _nameController.text,
                                        avatarFilePath: _selectedImagePath,
                                      );
                                      if (mounted) {
                                        // Refresh profile data
                                        ref.refresh(userProfileProvider);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
                                        );
                                        Navigator.pop(context);
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            //: SystemMouseCursors.click,
                            minimumSize: const Size(0, 46),
                            backgroundColor: const Color(0xFF2ECC71),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          child: isLoading
                              ? const SizedBox(width: 20, height: 20, child: CupertinoActivityIndicator(color: Colors.green))
                              : AppText("Save", color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 12),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String labelText,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(labelText, fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black, fontSize: 14),
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColors.white_bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF262C36), width: 1.0)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF2ECC71), width: 2.0)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent, width: 1.0)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.redAccent, width: 2.0)),
          ),
        ),
      ],
    );
  }
}
