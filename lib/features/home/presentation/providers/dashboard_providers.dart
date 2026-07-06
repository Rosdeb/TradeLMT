import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:raminups/core/constants/asset_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../data/models/tradingplatform.dart';
import '../../data/repositories/setting_repository.dart';

final tradingPlatformsProvider = Provider<List<TradingPlatform>>((ref) {
  return [
    TradingPlatform(
      name: 'Thinkorswim',
      islock: false,
      logo: Assets.Thinkorswim,
    ),
    TradingPlatform(
      name: 'Tradovate',
      islock: true,
      logo: Assets.Tradeovate,
    ),
    TradingPlatform(
      name: 'TradingView',
      islock: false,
      logo: Assets.TradingView,
    ),
    TradingPlatform(
      islock: true,
      name: 'Robinhood',
      logo: Assets.Robinhood,
    ),
    TradingPlatform(
      name: 'NinjaTrader',
      islock: false,
      logo: Assets.NinjaTrader,
    ),
    TradingPlatform(
      name: 'Interactive',
      islock: true,
      logo: Assets.InteractiveBroker,
    ),
  ];
});

final selectedPlatformsProvider = StateProvider<List<String>>((ref) => []);
final tradeLimitCountProvider = StateProvider<int>((ref)=>2);
final weeklytradeLimitCountProvider = StateProvider<int>((ref)=>2);
final lockDurationProvider = StateProvider<int>((ref) => 4);
final weeklylockDurationProvider = StateProvider<int>((ref) => 4);

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final settingRepositoryProvider = Provider<SettingRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return SettingRepository(apiService);
});

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.get('/auth/me');
  final userResponse = UserResponse.fromJson(response.data);
  return userResponse.user;
});

final isTradeLimitLockedProvider = StateProvider<bool>((ref) => false);
final remainingTradesProvider = StateProvider<int>((ref) => 1);

final fetchTradeLimitProvider = FutureProvider<void>((ref) async {
  final repository = ref.watch(settingRepositoryProvider);
  try {
    final data = await repository.getTradeLimit();
    print("trade limi data : $data");
    if (data is Map<String, dynamic> && data['tradeLimit'] is Map<String, dynamic>) {
      final tradeLimit = data['tradeLimit'] as Map<String, dynamic>;
      final dailyLimit = tradeLimit['dailyLimit'] as int? ?? 2;
      final lockoutHours = tradeLimit['lockoutHours'] as int? ?? 4;
      final isEnabled = tradeLimit['isEnabled'] as bool? ?? false;
      final remaining = data['remainingTrades'] as int? ?? dailyLimit;
      
      ref.read(tradeLimitCountProvider.notifier).state = dailyLimit;
      ref.read(lockDurationProvider.notifier).state = lockoutHours;
      ref.read(isTradeLimitLockedProvider.notifier).state = isEnabled;
      ref.read(remainingTradesProvider.notifier).state = remaining;
    }
  } catch (e) {
    // Fail silently or handle accordingly
  }
});
