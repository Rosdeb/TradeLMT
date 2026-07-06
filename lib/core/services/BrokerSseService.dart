import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:raminups/core/services/api_service.dart';

class BrokerSseService {
  BrokerSseService(this._apiService);

  final ApiService _apiService;

  Stream<String> connect() async* {
    try {
      final response = await _apiService.get(
        '/broker-connections/events',
        requiresAuth: true,
        options: Options(
          responseType: ResponseType.stream,
          headers: {
            'Accept': 'text/event-stream',
            'Cache-Control': 'no-cache',
          },
        ),
      );

      final responseBody = response.data as ResponseBody;
      yield* responseBody.stream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter());
    } catch (e) {
      rethrow;
    }
  }
}