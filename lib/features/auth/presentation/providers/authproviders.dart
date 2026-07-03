import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/api_service.dart';
import '../../data/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ApiService());
});

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

class AuthNotifier extends StateNotifier<bool> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(false);

  Future<void> login(String email, String password) async {
    state = true;
    try {
      final responseData = await _authRepository.login(email, password);
      print('Login Response: $responseData');
      if (responseData != null && responseData['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
      }
      state = false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  Future<void> accountSignUp(String name, String email, String password) async {
    state = true;
    try {
      final responseData = await _authRepository.register(name, email, password);
      print('Sign Response: $responseData');
      if (responseData != null && responseData['token'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', responseData['token']);
      }
      state = false;
    } catch (e) {
      state = false;
      rethrow;
    }
  }
}
