import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(
        milliseconds: ApiConstants.connectTimeout,
      ),
      receiveTimeout: const Duration(
        milliseconds: ApiConstants.receiveTimeout,
      ),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.contentType,
      },
    ),
  ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requiresAuth'] ?? true;
          if (requiresAuth) {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
    Options? options,
  }) async {
    try {
      final finalOptions = options ?? Options();
      finalOptions.extra = {
        ...?finalOptions.extra,
        'requiresAuth': requiresAuth,
      };
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: finalOptions,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
      String endpoint, {
        dynamic data,
        bool requiresAuth = true,
      }) async {
    try {
      return await _dio.post(
        endpoint,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
      String endpoint, {
        dynamic data,
        bool requiresAuth = true,
      }) async {
    try {
      return await _dio.put(
        endpoint,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
      String endpoint, {
        dynamic data,
        bool requiresAuth = true,
      }) async {
    try {
      return await _dio.patch(
        endpoint,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
      String endpoint, {
        dynamic data,
        bool requiresAuth = true,
      }) async {
    try {
      return await _dio.delete(
        endpoint,
        data: data,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(
      String endpoint, {
        required String filePath,
        required String fieldName,
        Map<String, dynamic>? extraData,
        bool requiresAuth = true,
      }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (extraData != null) ...extraData,
      });

      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(extra: {'requiresAuth': requiresAuth}),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final responseData = error.response?.data;
      if (responseData != null && responseData is Map<String, dynamic>) {
        final message = responseData['message'];
        if (message is List) {
          return message.join('\n');
        } else if (message is String) {
          return message;
        }
      }
      return 'Something went wrong';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.badResponse:
        return 'Bad response from server';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      default:
        return 'No internet connection';
    }
  }
}