import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/services/trade_monitor_service.dart';

/// Immutable snapshot of the trade-limit + lockout situation.
///
/// Built by [TradeMonitorService] from `GET /trade-limit` + `GET /lockout/status`
/// and pushed into [tradeLimitStateProvider]. The rest of the app reads this one
/// object instead of the loose legacy `StateProvider`s (which the monitor still
/// mirrors for backward compatibility).
class TradeLimitState {
  /// `tradeLimit.isEnabled` — is the daily-limit rule switched on at all.
  final bool ruleEnabled;
  final int dailyLimit;
  final int lockoutHours;

  /// `remainingTrades` from the API. Null when no rule has been saved.
  final int? remainingTrades;

  /// `locked` from `/lockout/status`.
  final bool locked;
  final DateTime? lockedUntil;
  final String? lockReason;

  /// Process / app names the helper should kill (`lockoutStatus.appsToBlock`).
  final List<String> appsToBlock;

  /// True once at least one successful refresh has completed.
  final bool loaded;

  /// True when the last refresh failed and this is a stale copy.
  final bool stale;

  const TradeLimitState({
    required this.ruleEnabled,
    required this.dailyLimit,
    required this.lockoutHours,
    required this.remainingTrades,
    required this.locked,
    required this.lockedUntil,
    required this.lockReason,
    required this.appsToBlock,
    required this.loaded,
    required this.stale,
  });

  static const initial = TradeLimitState(
    ruleEnabled: false,
    dailyLimit: 2,
    lockoutHours: 4,
    remainingTrades: null,
    locked: false,
    lockedUntil: null,
    lockReason: null,
    appsToBlock: <String>[],
    loaded: false,
    stale: false,
  );

  /// The single blocking rule (doc §6).
  bool get tradingAllowed =>
      !locked && !(ruleEnabled && (remainingTrades ?? 1) <= 0);

  bool get shouldBlock => !tradingAllowed;

  /// Adaptive poll cadence, matching the helper.
  Duration get pollInterval {
    if (shouldBlock) return const Duration(seconds: 15);
    if (!ruleEnabled) return const Duration(seconds: 300);
    return const Duration(seconds: 60);
  }

  factory TradeLimitState.fromApi({
    Map<String, dynamic>? limit,
    Map<String, dynamic>? lockout,
  }) {
    final tl = limit?['tradeLimit'] as Map<String, dynamic>?;

    final ruleEnabled = (tl?['isEnabled'] as bool?) ?? false;
    final dailyLimit = (tl?['dailyLimit'] as num?)?.toInt() ?? initial.dailyLimit;
    final lockoutHours =
        (tl?['lockoutHours'] as num?)?.toInt() ?? initial.lockoutHours;
    final remaining = (limit?['remainingTrades'] as num?)?.toInt();

    final locked = (lockout?['locked'] as bool?) ?? false;
    DateTime? until;
    final lu = lockout?['lockedUntil'];
    if (lu is String) until = DateTime.tryParse(lu);

    final apps = <String>[];
    final ab = lockout?['appsToBlock'];
    if (ab is List) {
      apps.addAll(ab.map((e) => e.toString()).where((s) => s.isNotEmpty));
    }

    return TradeLimitState(
      ruleEnabled: ruleEnabled,
      dailyLimit: dailyLimit,
      lockoutHours: lockoutHours,
      remainingTrades: remaining,
      locked: locked,
      lockedUntil: until,
      lockReason: lockout?['reason'] as String?,
      appsToBlock: apps,
      loaded: true,
      stale: false,
    );
  }

  TradeLimitState copyWith({bool? stale}) => TradeLimitState(
        ruleEnabled: ruleEnabled,
        dailyLimit: dailyLimit,
        lockoutHours: lockoutHours,
        remainingTrades: remainingTrades,
        locked: locked,
        lockedUntil: lockedUntil,
        lockReason: lockReason,
        appsToBlock: appsToBlock,
        loaded: loaded,
        stale: stale ?? this.stale,
      );

  @override
  String toString() =>
      'TradeLimitState(enabled: $ruleEnabled, daily: $dailyLimit, remaining: '
      '$remainingTrades, locked: $locked, until: $lockedUntil, block: $shouldBlock, '
      'loaded: $loaded, stale: $stale)';
}

final tradeLimitStateProvider =
    StateProvider<TradeLimitState>((ref) => TradeLimitState.initial);

/// Set by [TradeMonitorService] on a 401/403 so the UI can bounce to login.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);

/// The one trade-limit monitor for the whole app. Lives for the life of the
/// [ProviderScope]; `HomeScreen` calls `.start()`, `LogoutDialog` calls `.stop()`.
final tradeMonitorProvider = Provider<TradeMonitorService>((ref) {
  final service = TradeMonitorService(ref);
  ref.onDispose(service.stop);
  return service;
});
