import '../../../../core/services/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<dynamic> login(String email, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      data: {
        "email": email,
        "password": password,
      },
    );
    return response.data;
  }

  Future<dynamic> register(String name, String email, String password) async {
    final response = await _apiService.post(
      '/auth/register',
      data: {
        "name": name,
        "email": email,
        "password": password,
      },
    );
    return response.data;
  }
}
