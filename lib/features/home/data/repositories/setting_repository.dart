import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/services/api_service.dart';

class SettingRepository {
  final ApiService _apiService;

  SettingRepository(this._apiService);

  Future<void> changePassword(
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      await _apiService.patch(
        '/auth/change-password',
        data: {"newPassword": newPassword, "confirmPassword": confirmPassword},
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String name,
    String? avatarFilePath,
  }) async {
    try {
      final data = FormData.fromMap({
        "name": name,
        if (avatarFilePath != null)
          "avatar": await MultipartFile.fromFile(avatarFilePath),
      });

      await _apiService.patch('/auth/me', data: data, requiresAuth: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getTradeLimit() async {
    try {
      final response = await _apiService.get(
        '/trade-limit',
        requiresAuth: true,
      );
      print("response : $response");
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  /// `GET /lockout/status` — the backend's source of truth for whether trading
  /// is blocked right now. Returns `{ locked: false }` or
  /// `{ locked: true, lockedUntil, reason, appsToBlock: [...] }`.
  Future<Map<String, dynamic>?> getLockoutStatus() async {
    try {
      final response = await _apiService.get(
        '/lockout/status',
        requiresAuth: true,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> syncTrades() async {
    try {
      final response = await _apiService.post(
        '/trades/sync',
        requiresAuth: true,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getTodayTrades() async {
    try {
      final response = await _apiService.get(
        '/trades/today',
        requiresAuth: true,
      );
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTradeLimit({
    required int dailyLimit,
    required int lockoutHours,
    bool isEnabled = true,
  }) async {
    try {
      await _apiService.post(
        '/trade-limit',
        data: {
          'dailyLimit': dailyLimit,
          'lockoutHours': lockoutHours,
          'isEnabled': isEnabled,
        },
        requiresAuth: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
