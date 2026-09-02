import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/app_exception.dart';
import '../Binace/binance_blocker_service.dart';
import '../../features/home/data/repositories/setting_repository.dart';
import '../../features/home/presentation/providers/dashboard_providers.dart';
import '../../features/home/presentation/providers/trade_limit_state.dart';

/// The single trade-limit monitor.
///
/// One instance for the whole app (created by `tradeMonitorProvider`). Owns
/// exactly one [Timer]. Started once from `HomeScreen.initState`, stopped on
/// logout / screen dispose. Never started from `build` or a provider body.
///
/// Responsibilities:
///  * poll `GET /trade-limit` + `GET /lockout/status` on an adaptive cadence,
///  * publish [TradeLimitState] (and mirror the legacy `StateProvider`s),
///  * hand the closed-app helper the auth token + `appsToBlock` + `lockedUntil`,
///  * flip the OS-level blocker **only on a successful read** — a failed request
///    freezes the last known state.
class TradeMonitorService {
  TradeMonitorService(this._ref);

  final Ref _ref;

  Timer? _timer;
  bool _running = false;
  bool _ticking = false;
  bool? _lastBlocking;
  int _startCount = 0;

  SettingRepository get _repo => _ref.read(settingRepositoryProvider);

  /// Debug/QA: how many times [start] actually spun up a loop this process.
  int get startCount => _startCount;
  bool get isRunning => _running;

  Future<void> start() async {
    if (_running) return;
    _running = true;
    _startCount++;
    // Seed the transition guard from whatever the blocker is doing right now so
    // the first tick doesn't needlessly re-run enable/disable side effects.
    _lastBlocking = await BinanceBlockerService().isBlocking();
    _scheduleImmediate();
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }

  /// Force an immediate re-check. Safe to call from many places at once — the
  /// in-flight-tick guard coalesces bursts. No-op if the monitor isn't running.
  Future<void> refreshNow(String reason) async {
    if (!_running) return;
    _timer?.cancel();
    await _tick(reason);
  }

  void _scheduleImmediate() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 50), () => _tick('start'));
  }

  void _reschedule(Duration d) {
    if (!_running) return;
    _timer?.cancel();
    _timer = Timer(d, () => _tick('poll'));
  }

  Future<void> _tick(String reason) async {
    if (!_running || _ticking) return;
    _ticking = true;
    try {
      final token = await _authToken();
      if (token == null || token.isEmpty) {
        // Not signed in yet / signed out — idle slowly, don't touch the blocker.
        _reschedule(const Duration(seconds: 30));
        return;
      }

      final limit = await _repo.getTradeLimit();
      final lockout = await _repo.getLockoutStatus();
      final next = TradeLimitState.fromApi(limit: limit, lockout: lockout);

      if (kDebugMode) {
        print('[TradeMonitor] reason=$reason $next '
            'next=${next.pollInterval.inSeconds}s');
      }
      _publish(next);
      await _pushToHelper(next, token);
      await _applyBlocker(next);

      _reschedule(next.pollInterval);
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        _publishStale();
        stop();
        _ref.read(sessionExpiredProvider.notifier).state = true;
        return;
      }
      // 404 / 429 / 5xx / network — keep the last known state, back off.
      _publishStale();
      _reschedule(e.isRateLimited
          ? const Duration(seconds: 120)
          : const Duration(seconds: 60));
    } catch (_) {
      _publishStale();
      _reschedule(const Duration(seconds: 60));
    } finally {
      _ticking = false;
    }
  }

  void _publish(TradeLimitState s) {
    _ref.read(tradeLimitStateProvider.notifier).state = s;
    // Mirror into the legacy providers the dashboard widgets still read.
    _ref.read(tradeLimitCountProvider.notifier).state = s.dailyLimit;
    _ref.read(lockDurationProvider.notifier).state = s.lockoutHours;
    _ref.read(remainingTradesProvider.notifier).state =
        s.remainingTrades ?? s.dailyLimit;
    _ref.read(isTradeLimitLockedProvider.notifier).state = s.shouldBlock;
  }

  void _publishStale() {
    final cur = _ref.read(tradeLimitStateProvider);
    _ref.read(tradeLimitStateProvider.notifier).state =
        cur.copyWith(stale: true);
  }

  Future<void> _pushToHelper(TradeLimitState s, String token) async {
    // Exactly what the backend sent in lockoutStatus.appsToBlock — no fallback,
    // no hard-coded Binance. An empty list means "block nothing".
    await BinanceBlockerService().saveSettings(
      appsToBlock: s.appsToBlock,
      lockedUntil: s.lockedUntil?.toUtc().toIso8601String(),
      token: token,
    );
  }

  Future<void> _applyBlocker(TradeLimitState s) async {
    final want = s.shouldBlock;
    if (_lastBlocking == want) return;
    _lastBlocking = want;
    if (want) {
      await BinanceBlockerService().enableBlock();
    } else {
      await BinanceBlockerService().disableBlock();
    }
  }

  Future<String?> _authToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
