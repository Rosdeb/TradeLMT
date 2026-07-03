import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';

class SettingRepository {
  final ApiService _apiService;

  SettingRepository(this._apiService);

  Future<void> changePassword(String newPassword, String confirmPassword) async {
    try {
      await _apiService.patch(
        '/auth/change-password',
        data: {
          "newPassword": newPassword,
          "confirmPassword": confirmPassword,
        },
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({required String name, String? avatarFilePath}) async {
    try {
      final data = FormData.fromMap({
        "name": name,
        if (avatarFilePath != null)
          "avatar": await MultipartFile.fromFile(avatarFilePath),
      });

      await _apiService.patch(
        '/auth/me',
        data: data,
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
