import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:raminups/core/constants/asset_constants.dart';

import '../data/models/tradingplatform.dart';

final tradingPlatformsProvider = Provider<List<TradingPlatform>>((ref) {
  return [
    TradingPlatform(
      name: 'Thinkorswim',
      isConnected: false,
      logo: Assets.Thinkorswim,
    ),
    TradingPlatform(
      name: 'Tradovate',
      isConnected: true,
      logo: Assets.Tradeovate,
    ),
    TradingPlatform(
      name: 'TradingView',
      isConnected: false,
      logo: Assets.TradingView,
    ),
    TradingPlatform(
      isConnected: true,
      name: 'Robinhood',
      logo: Assets.Robinhood,
    ),
    TradingPlatform(
      name: 'NinjaTrader',
      isConnected: false,
      logo: Assets.NinjaTrader,
    ),
    TradingPlatform(
      name: 'Interactive Brokers',
      isConnected: true,
      logo: Assets.InteractiveBroker,
    ),
  ];
});
final tradeLimitCountProvider = StateProvider<int>((ref)=>2);
