import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dashboard_providers.dart';
import '../../data/repositories/setting_repository.dart';

final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SettingRepository(apiService);
});

final passwordChangeProvider = StateNotifierProvider<PasswordChangeNotifier, bool>((ref) {
  return PasswordChangeNotifier(ref.watch(settingRepositoryProvider));
});

class PasswordChangeNotifier extends StateNotifier<bool> {
  final SettingRepository _repository;

  PasswordChangeNotifier(this._repository) : super(false);

  Future<void> changePassword(String newPassword, String confirmPassword) async {
    state = true;
    try {
      await _repository.changePassword(newPassword, confirmPassword);
      state = false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }
}

final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, bool>((ref) {
  return ProfileUpdateNotifier(ref.watch(settingRepositoryProvider));
});

class ProfileUpdateNotifier extends StateNotifier<bool> {
  final SettingRepository _repository;

  ProfileUpdateNotifier(this._repository) : super(false);

  Future<void> updateProfile({required String name, String? avatarFilePath}) async {
    state = true;
    try {
      await _repository.updateProfile(name: name, avatarFilePath: avatarFilePath,);
      state = false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }
}
