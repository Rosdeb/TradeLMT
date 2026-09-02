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
    TradingPlatform(name: 'Tradovate', islock: true, logo: Assets.Tradeovate),
    TradingPlatform(
      name: 'TradingView',
      islock: false,
      logo: Assets.TradingView,
    ),
    TradingPlatform(islock: true, name: 'Robinhood', logo: Assets.Robinhood),
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
final tradeLimitCountProvider = StateProvider<int>((ref) => 2);
final weeklytradeLimitCountProvider = StateProvider<int>((ref) => 2);
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

final todayTradesProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(settingRepositoryProvider);
  final data = await repository.getTodayTrades();
  if (data != null && data['trades'] != null) {
    final trades = data['trades'] as List;
    return trades.length;
  }
  return 0;
});

/// Legacy providers — still read by the dashboard widgets. They are now written
/// exclusively by `TradeMonitorService`, never fetched ad-hoc.
final isTradeLimitLockedProvider = StateProvider<bool>((ref) => false);
final remainingTradesProvider = StateProvider<int>((ref) => 1);
