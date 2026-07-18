import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/repositories/connection_repository.dart';
import '../../data/models/broker_connection.dart';
import '../../../../core/services/BrokerSseService.dart';
import 'dashboard_providers.dart';

final connectionRepositoryProvider = Provider<ConnectionRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ConnectionRepository(apiService);
});

final brokerConnectionsProvider = FutureProvider<List<BrokerConnection>>((ref) async {
  final repository = ref.watch(connectionRepositoryProvider);
  return repository.fetchConnectionMethod();
});

final brokerSseServiceProvider = Provider<BrokerSseService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BrokerSseService(apiService);
});

final sseConnectedProvider = StateProvider<bool>((ref) => false);
