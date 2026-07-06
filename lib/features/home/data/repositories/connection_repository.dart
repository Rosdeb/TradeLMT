import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:isolate';

import 'package:raminups/core/services/api_service.dart';
import '../models/broker_connection.dart';

class ConnectionRepository {
  final ApiService _apiService;
  ConnectionRepository(this._apiService);

  Future<List<BrokerConnection>> fetchConnectionMethod() async {
    try {
      final response = await _apiService.get(
        '/broker-connections',
        requiresAuth: true,
      );

      final data = response.data;
      developer.log('Broker connections data received: $data', name: 'ConnectionRepository');
      final brokers = await Isolate.run(() {
        if (data is Map<String, dynamic> && data['brokers'] is List) {
          final list = data['brokers'] as List;
          return list.map((json) => BrokerConnection.fromJson(json as Map<String, dynamic>)).toList();
        }
        return <BrokerConnection>[];
      });
      return brokers;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> connectBroker(String brokerId) async {
    try {
      final response = await _apiService.get(
        '/broker-connections/$brokerId/connect',
        requiresAuth: true,
      );

      final data = response.data as Map<String, dynamic>;

      developer.log(
        'Connect broker response: $data',
        name: 'ConnectionRepository',
      );

      return data['url'] as String?;
    } catch (e) {
      rethrow;
    }
  }

}