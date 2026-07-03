import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:raminups/core/constants/asset_constants.dart';
import '../../../../core/services/api_service.dart';
import '../../../auth/data/models/user_model.dart';
import '../data/models/tradingplatform.dart';

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

final userProfileProvider = FutureProvider<UserModel>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  final response = await apiService.get('/auth/me');
  final userResponse = UserResponse.fromJson(response.data);
  return userResponse.user;
});
