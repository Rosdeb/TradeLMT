# TradeLMT — Trade Limit Enforcement: Diagnosis + Integration Plan

> API facts are from the live OpenAPI spec embedded in `https://crypto.xdtunnel.icu/docs/` (`swagger-ui-init.js`).
> Targets: **Windows + macOS desktop** (Flutter, Riverpod 3, Dio, window_manager). No mobile targets exist.

---

## Implementation status — DONE (2026-08-28)

The plan in §7 has been implemented. `flutter analyze` is clean (0 new errors),
`flutter build macos --debug` succeeds, and a live run against the backend was verified:

```
[TradeMonitor] reason=start TradeLimitState(enabled: true, daily: 2, remaining: 2,
   locked: false, until: null, block: false, loaded: true, stale: false) next=60s
[Blocker] Saved settings: {appsToBlock: [Binance.exe], lockedUntil: null, token: <jwt>}
```

…and the compiled helper polling both endpoints:

```
[BinanceWatcher] Polled backend: {tradeLimit: {dailyLimit: 2, lockoutHours: 8,
   isEnabled: true, ...}, remainingTrades: 2, lockoutStatus: {locked: false}}
```

**Files changed**

| File | Change |
|---|---|
| `lib/core/errors/app_exception.dart` | new `ApiException` (message + statusCode) |
| `lib/core/services/api_service.dart` | `_handleError` now throws `ApiException` with the HTTP status |
| `lib/core/services/trade_monitor_service.dart` | **new** — the single monitor (Timer, adaptive interval, blocker wiring, helper push, error branching) |
| `lib/features/home/presentation/providers/trade_limit_state.dart` | **new** — `TradeLimitState` model + `tradeLimitStateProvider`, `sessionExpiredProvider`, `tradeMonitorProvider` |
| `lib/features/home/data/repositories/setting_repository.dart` | + `getLockoutStatus()` (`GET /lockout/status`) |
| `lib/features/home/presentation/providers/dashboard_providers.dart` | removed `fetchTradeLimitProvider`, `_triggerTradeSync`, `_hasSyncedTrades`, `resetTradeSyncState`, `date`/`lockDate` logic; legacy `StateProvider`s kept (monitor mirrors them) |
| `lib/features/home/presentation/screen/home_screen.dart` | now `ConsumerStatefulWidget` + `WidgetsBindingObserver` + `WindowListener`; starts/stops the monitor; refresh on resume / window focus; routes to login on `sessionExpiredProvider` |
| `lib/features/home/presentation/screen/dashboard_screen.dart` | reads `tradeLimitStateProvider` (shimmer until `loaded`); save button calls `refreshNow('limit-change')` |
| `lib/features/home/presentation/screen/connection_screen.dart` | **one line** — `refreshNow('broker-connected')` at end of `_triggerSyncFlow()` |
| `lib/features/home/presentation/widgets/logout_widgets.dart` | `tradeMonitorProvider.stop()` on logout |
| `lib/features/auth/presentation/screen/getstart_screen.dart` | login/signup refresh updated to the new providers |
| `lib/main.dart` | `resumeIfBlocking()` also on macOS (W4) |
| `lib/features/home/presentation/widgets/journalOverview.dart` | overflow fix — `Wrap` + `Flexible` + bounded width; fixed the malformed `Color(0xFC7C2C2)` |
| `tools/binance_watcher.dart` | polls `/lockout/status` + `/trade-limit` merged (W5); unified blocking rule; **no hard-coded `Binance.exe`** — kills exactly `appsToBlock`; hosts domains derived from `appsToBlock` via `kBrokerDomains`; macOS `pkill -if` + self-kill guard + `ejectBrokerDmgs()` for `.dmg` volumes |

**Still manual (cannot be done from a build machine)**
- Compile + bundle the helper into the release app (§8 → "Building & bundling the helper").
- The macOS LaunchAgent swap (§8) — currently still the LaunchDaemon path.
- Full E2E lockout test with `POST /lockout/manual` on a real account (§12).

---

## 0. Scope — what this is and isn't

**The one feature to deliver:** when the user's daily trade limit is reached (or the backend
reports a lockout), the app must **block the broker trading apps** — kill them and keep them from
reopening for the lockout window — so the user physically cannot place more trades. This must work
while the app is open **and** while the app is closed, on macOS and Windows.

**In scope**
- The trade-limit *monitoring loop* (currently missing).
- Wiring `remainingTrades == 0` / `/lockout/status` → the OS-level app blocker.
- The persistent helper (`binance_watcher`) that enforces the block when the app is closed.
- App lifecycle / resume / logout handling of the monitor.
- The `journalOverview.dart` overflow (separate UI bug, section 11).

**Out of scope — do not touch**
- The broker / SWIM / Schwab **connection flow** (`connection_screen.dart`, `connection_repository.dart`,
  SSE, `/schwab/*`). It already works. The only interaction with it is **one added line** — a
  `refreshNow()` call after a successful connect (step 6) — and nothing else in that file changes.
- The existing API integration for `/trade-limit`, `/trades/sync`, `/auth/*` — reuse the methods
  that already exist in `SettingRepository`; only **one** new method (`getLockoutStatus`) is added.

**Apps to block** come from the API — `lockoutStatus.appsToBlock`, e.g.
`["thinkorswim.exe", "TradingView.exe", "Binance.exe"]`. The app passes that list **straight through**
to the helper with **no fallback** — if the backend sends `["thinkorswim.exe"]` only thinkorswim is
killed; if it sends `[]`, nothing is killed. The old hard-coded `Binance.exe` default is gone
(both in `TradeMonitorService` and the helper).

Domain blocking (`/etc/hosts`) is now **derived from the same list**: `kBrokerDomains` in the helper
maps each `appsToBlock` keyword to its login domains (`thinkorswim` → `schwab.com…`, `tradingview` →
`tradingview.com`, `binance` → `binance.com`, plus tradovate / ninjatrader / ibkr / robinhood /
tastytrade). Only the domains for the brokers the backend actually named are blocked.

**macOS `.app` / `.dmg`:** the API names are Windows `.exe` names. On macOS the helper must also
(a) match the same name against `.app` bundles and processes launched from anywhere — including a
mounted disk image — and (b) **force-eject any broker `.dmg` volume** during a lockout so the user
can't run the app straight from the disk image or re-mount it. See section 8 → "macOS: `.app`
bundles and `.dmg` volumes".

---

## 1. Verdict

**There is no monitoring loop.** What looks like monitoring is a one-shot fetch that runs once
when the dashboard first builds. And the blocker is wired to the wrong signal, behind a guard
that fires at most once per app launch.

- `fetchTradeLimitProvider` is a `FutureProvider<void>`. `DashboardScreen` is kept alive inside an
  `IndexedStack` (`home_screen.dart:16-21, 43-47`), so the provider runs **exactly once per launch**
  and never again unless something calls `ref.invalidate` — only the "Daily Lock" button
  (`dashboard_screen.dart:415`) and logout (`logout_widgets.dart:97`) do.
- The only thing that switches the OS-level blocker on is `_triggerTradeSync()`
  (`dashboard_providers.dart:79-108`), which:
  - reads lock state from `POST /trades/sync` instead of the real `GET /lockout/status`,
  - is gated behind a top-level `bool _hasSyncedTrades` reset only on logout,
  - never looks at `remainingTrades` at all,
  - silently swallows the `404` that `/trades/sync` returns when Schwab isn't connected.

Your log confirms it: `trade limi data : {… remainingTrades: 2}` is that single fetch; the later
`remainingTrades: 3` is the second run triggered when you pressed save. Between those two events
nothing polls. `[Blocker] Block disabled` is `disableBlock()` from the `else` branch of that one sync.

The background helper (`tools/binance_watcher.dart`) — the part meant to run when the app is closed —
is pointed at a **dead URL** and is **never given an auth token**, so it can never reach the server either.

---

## 2. Architecture map (what already exists — reuse all of it)

| Concern | Where | Notes |
|---|---|---|
| HTTP client | `core/services/api_service.dart` | Single `Dio`, interceptor injects `Authorization: Bearer` from `SharedPreferences['auth_token']`. 15s timeouts. `_handleError` throws a **`String`**, not a typed error. |
| Token | `features/auth/.../authproviders.dart:27,43` | Stored as `auth_token` on login/register. `TokenService` (keys `access_token`/`refresh_token`) is **dead code**. No refresh-token flow wired. |
| Repositories | `home/data/repositories/setting_repository.dart` | Already has `getTradeLimit()` (`GET /trade-limit`), `syncTrades()` (`POST /trades/sync`), `updateTradeLimit()` (`POST /trade-limit`). **No `/lockout/status` call anywhere.** |
| State | `home/.../providers/dashboard_providers.dart` | Legacy `StateProvider`s: `tradeLimitCountProvider`, `lockDurationProvider`, `isTradeLimitLockedProvider`, `remainingTradesProvider`, plus the broken `fetchTradeLimitProvider`. |
| Broker connect | `connection_screen.dart` + `connection_repository.dart` | Schwab OAuth via `/schwab/connect-url`, opens system browser, then SSE (`/broker-connections/events`) + 2s/4s polling of `/schwab/status`. On success → `_triggerSyncFlow()`. |
| Blocker (foreground) | `core/Binace/binance_blocker.dart` | 1s `Timer.periodic` that `pkill`/`taskkill`s Binance while the app runs. Singleton. **Not used by the limit flow.** |
| Blocker (persistent) | `core/Binace/binance_blocker_service.dart` | Writes `binance_block_state.txt` / `binance_block_settings.json` to the temp dir; registers Task Scheduler task (Windows) / LaunchDaemon (macOS); starts `binance_watcher`. |
| Background helper | `tools/binance_watcher.dart` | Standalone Dart program: 1s loop, reads state file, polls backend every N s, edits `/etc/hosts`, kills `appsToBlock`. **Must be compiled + bundled** next to the app executable — currently only source exists. |
| Lifecycle | — | Only `_ActionButton` (`connection_screen.dart:414`) observes lifecycle. `HomeScreen` / `main.dart` do **not**. No `window_manager` close/focus hook. |
| Trade execution | *(none in app)* | Trades happen in the broker's own terminal. Backend detects them by polling Schwab via `/trades/sync`. "Blocking a trade" here = locking/killing the broker apps + hosts block. The `TradeLimitCounter` +/- buttons (`dashboard_screen.dart:517-551`) only mutate a local config number. |

---

## 3. The real API

Auth: `bearerAuth` = `Authorization: Bearer <JWT>` on **every** endpoint below.
Base URL stays `https://crypto.xdtunnel.icu` — the spec's `servers: http://localhost:5050` is the
backend author's dev default, **not** yours. No versioned path prefix.

| Method / path | Purpose | Response |
|---|---|---|
| **`GET /lockout/status`** ← use this | **Source of truth: is trading blocked right now.** App never calls it today. | `{ locked:false }` **or** `{ locked:true, lockedUntil, reason, appsToBlock:[...] }` |
| `GET /trade-limit` | Current rule + remaining count. | `{ tradeLimit: { id,userId,dailyLimit,lockoutHours(4\|8\|12\|24),isEnabled,createdAt,updatedAt } \| null, remainingTrades: int\|null }` |
| `POST /trade-limit` | Create/update rule. Body `{ dailyLimit>=1, lockoutHours∈{4,8,12,24}, isEnabled? }`. Already used by save button. | same as GET; `400` on validation error |
| `POST /trades/sync` | Pull today's Schwab fills, recount, recompute lockout. **Requires Schwab connected — `404` otherwise.** Call after connect / around a suspected trade, **not** as the poll loop. | `{ synced, fetchedCount, insertedCount, lockoutStatus:{ locked, lockedUntil, reason, appsToBlock } }` |
| `GET /trades/today` | Today's saved trade logs (journal UI). | `{ trades: TradeLog[] }` |
| `GET /schwab/status` | Is Schwab connected. Already used. | `{ connected, expiresAt, updatedAt }` |
| `POST /lockout/manual` / `POST /lockout/unlock` | Test/admin: force a lockout / clear it. Use for QA. | `LockoutStatusLocked` / `{ unlocked:true }` |

---

## 4. Flow trace — where the chain breaks

| Stage | Status | Detail |
|---|---|---|
| Broker / Schwab connected | ✅ works | `_ActionButton` → `/schwab/connect-url` → browser → SSE + `/schwab/status` polling → `_triggerSyncFlow()` |
| Authentication / user id | ✅ works | JWT under `auth_token`, attached by Dio interceptor. Backend derives user from token. |
| Trade-limit API | ❌ | Called once from `DashboardScreen.build` via `ref.watch(fetchTradeLimitProvider)` (`dashboard_screen.dart:29`). IndexedStack keeps the screen alive → never re-runs. No timer, no resume hook, no post-connect refresh. `/lockout/status` never called. |
| `remainingTrades` | ❌ | Stored in `remainingTradesProvider` and displayed, but **no code path turns `remainingTrades == 0` into a block.** Display-only. |
| Trade-limit state provider | ❌ | `isTradeLimitLockedProvider` computed from `tradeLimit['date']` / `tradeLimit['lockDate']` (`dashboard_providers.dart:125-133`) — **fields that don't exist** in the model (only `createdAt`/`updatedAt`). `isToday` always false → lock state never engages. |
| Trade blocker | ❌ | Only `_triggerTradeSync()` flips it, only from `syncResult['lockoutStatus']['locked']`. Guarded by `_hasSyncedTrades` (once/launch), gated on `if (isEnabled)`, swallows the Schwab `404`. |
| Persistent watcher (app closed) | ❌ | Polls `https://triple-console-sauce-northwest.trycloudflare.com/trade-limit` — a dead quick-tunnel. `saveSettings()` called without `token:` → `pollBackend()` skipped (`token == null`). Helper binary has no build/bundle step. |

---

## 5. Root causes (each independently breaks enforcement — fix all)

### In-app (Flutter / Riverpod)

| # | Cause | Location |
|---|---|---|
| C1 | **No polling loop.** One-shot `FutureProvider` behind a kept-alive `IndexedStack` screen. | `dashboard_providers.dart:110` · `dashboard_screen.dart:29` · `home_screen.dart:16-21,43-47` |
| C2 | **Blocker not driven by `remainingTrades`.** The `== 0` condition is never evaluated against the blocker. | `dashboard_providers.dart:134` (set, never read for blocking) |
| C3 | **`_triggerTradeSync` runs once per process.** `bool _hasSyncedTrades` reset only by logout. | `dashboard_providers.dart:73-81,137` |
| C4 | **Lock state from non-existent fields.** `tradeLimit['date']` / `['lockDate']` always null. `/lockout/status` never called. | `dashboard_providers.dart:125-133` |
| C5 | **Wrong lock source + silent 404.** `/trades/sync` needs Schwab; `404` discarded → disconnected user has no enforcement. | `dashboard_providers.dart:104-107` · `setting_repository.dart:53-60` |
| C6 | **No lifecycle / resume refresh.** `HomeScreen` is a `ConsumerWidget` with no observer; `main.dart` has no `window_manager` focus/close hook. | `home_screen.dart` · `main.dart:38-42` |

### Persistent watcher (`tools/binance_watcher.dart`)

| # | Cause | Location |
|---|---|---|
| W1 | **Dead poll URL** (`triple-console-sauce-northwest.trycloudflare.com`). Every poll throws. | `binance_watcher.dart:195` |
| W2 | **Token never handed to the helper.** Both `saveSettings()` call sites omit `token:`; helper skips `pollBackend()` when `token == null`. | `dashboard_providers.dart:95-98` · `connection_screen.dart:532-535` · `binance_blocker_service.dart:20-36` · `binance_watcher.dart:76` |
| W3 | **Helper binary not built/bundled.** Only `.dart` source exists. `enableBlock()` silently starts nothing if the exe is missing. | `app_initializer.dart:11-51` · `binance_blocker_service.dart:98-117,186-195` |
| W4 | **macOS resume is Windows-only.** `main.dart` calls `resumeIfBlocking()` inside `if (Platform.isWindows)`. | `main.dart:17-20` |
| W5 | **Wrong endpoint for a poller.** Polls `/trade-limit`, infers lock from `remainingTrades <= 0`, then overwrites with a `lockoutStatus` key `/trade-limit` never returns. Should poll `/lockout/status`. | `binance_watcher.dart:85-104,190-210` |

---

## 6. Behaviour decisions (resolved against existing copy + helper intent)

### The single blocking rule

```dart
bool shouldBlock =
    lockout.locked == true
    || (limit.isEnabled == true
        && limit.remainingTrades != null
        && limit.remainingTrades <= 0);
```

- `remainingTrades > 0` → allowed, blocker released (unless a manual lockout is active).
- `remainingTrades == 0` and rule enabled → block for `lockoutHours`. Backend will also start
  returning `locked:true` from `/lockout/status` after the next `/trades/sync`; either is authoritative.
- `lockout.locked == true` → block until `lockedUntil`, regardless of the counter (manual lockouts,
  profit protection).

### `isEnabled == false`

The dashboard text ("Once your daily trade limit is reached…") and the helper's own logic
(`binance_watcher.dart:112` `if (!isLimitRuleEnabled) pollInterval = 300`) already define this:
**the rule is off.** So — **never block on the counter, and release any counter-based block
(not a manual lockout).** Keep polling slowly (300s), because the user can re-enable and a manual
lockout can still land.

### Network failure ≠ lockout

Nothing in the product requires fail-closed. On timeout / no-internet / 5xx: **keep the last known
state.** Don't create a new block from a failed request; don't release an existing one either
(a real lockout must survive going offline — the helper already enforces `lockedUntil` locally).
**Only a successful `{locked:false}` (or disabled rule) releases.**

### `401 / 403`

Token expired/rejected. Stop the monitor, clear `auth_token`, route to login. Leave any active local
lockout — the helper keeps enforcing `lockedUntil` from its settings file until it expires.

---

## 7. Integration plan (smallest change set — no new packages)

### Step 1 — Add `getLockoutStatus()` to `SettingRepository`

`home/data/repositories/setting_repository.dart` — mirror `getTradeLimit()`:

```dart
Future<Map<String, dynamic>?> getLockoutStatus() async {
  final r = await _apiService.get('/lockout/status', requiresAuth: true);
  return r.data as Map<String, dynamic>?;
}
```

### Step 2 — One immutable state object

New file `home/.../providers/trade_limit_state.dart`:

```dart
class TradeLimitState {
  final bool ruleEnabled;
  final int dailyLimit;
  final int lockoutHours;
  final int? remainingTrades;
  final bool locked;            // from /lockout/status
  final DateTime? lockedUntil;
  final List<String> appsToBlock;
  final bool stale;             // last refresh failed
  const TradeLimitState(/* ... */);

  bool get tradingAllowed =>
      !locked && !(ruleEnabled && (remainingTrades ?? 1) <= 0);

  TradeLimitState copyWith(/* ... */);
}

final tradeLimitStateProvider = StateProvider<TradeLimitState?>((ref) => null);
```

Keep the old `StateProvider`s as thin derived getters if other widgets still read them, or migrate
those reads (`dashboard_screen.dart` uses `tradeLimitCountProvider`, `remainingTradesProvider`,
`isTradeLimitLockedProvider`, `lockDurationProvider`).

### Step 3 — `TradeMonitorService` (the single monitor)

New file `core/services/trade_monitor_service.dart`. Plain singleton (same pattern as
`BinanceBlocker`). Owns **one** `Timer?`. Surface: `start(Ref)`, `refreshNow(String reason)`, `stop()`.

```dart
Future<void> _tick() async {
  try {
    final limit = await _repo.getTradeLimit();      // {tradeLimit, remainingTrades}
    final lock  = await _repo.getLockoutStatus();   // {locked, ...}
    final next  = _merge(limit, lock);              // -> TradeLimitState
    _ref.read(tradeLimitStateProvider.notifier).state = next;

    // hand the closed-app helper everything it needs, every tick (fixes W2)
    await BinanceBlockerService().saveSettings(
      appsToBlock: next.appsToBlock.isEmpty ? const ['Binance.exe'] : next.appsToBlock,
      lockedUntil: next.lockedUntil?.toUtc().toIso8601String(),
      token: await _authToken(),
    );

    if (next.locked || !next.tradingAllowed) {
      await BinanceBlockerService().enableBlock();
    } else {
      await BinanceBlockerService().disableBlock();  // only on a *successful* read
    }
    _reschedule(next);   // 15s locked · 60s enabled+unlocked · 300s rule disabled
  } on Unauthorized {
    stop();
    _ref.read(authProvider.notifier).forceLogout();
  } catch (_) {
    _ref.read(tradeLimitStateProvider.notifier).update((s) => s?.copyWith(stale: true));
    _reschedule(null, failed: true);   // backoff; never block/unblock on a failed read
  }
}
```

`start()` is a no-op if a timer is already live. `refreshNow()` cancels the in-flight tick, debounces
bursts, runs `_tick()` immediately.

### Step 4 — Delete the broken one-shot

Remove `fetchTradeLimitProvider`, `_triggerTradeSync`, `_hasSyncedTrades`, and the `date`/`lockDate`
logic from `dashboard_providers.dart`. The dashboard shimmer keys off `tradeLimitStateProvider == null`
instead of `fetchLimitAsync.when(loading/error)` (`dashboard_screen.dart:286-442`).

### Step 5 — Start/stop at the session boundary

Convert `HomeScreen` to `ConsumerStatefulWidget` with `WidgetsBindingObserver`:

- `initState` → `TradeMonitorService().start(ref)` (the **only** place it starts).
- `didChangeAppLifecycleState(resumed)` → `refreshNow('resume')`.
- `dispose` → `stop()`.

`LogoutDialog` (`logout_widgets.dart:93`): add `TradeMonitorService().stop()` next to
`resetTradeSyncState()`.
`main.dart`: register a `window_manager` `WindowListener` → `onWindowFocus` calls `refreshNow('focus')`
(this is the closest thing to a "before trade" check on desktop — when the user alt-tabs back from the
broker terminal, the limit is re-checked within a second).

### Step 6 — Refresh on every required trigger

| Trigger | Call site | Touches connection code? |
|---|---|---|
| App start / user logs in | `HomeScreen.initState` → `start()` (start does an immediate tick) | no |
| App resumes / window refocus | `WidgetsBindingObserver` + `window_manager` `onWindowFocus` (step 5) | no |
| User changes the limit | after `updateTradeLimit()` (`dashboard_screen.dart:415`) → `refreshNow('limit-change')` instead of `ref.invalidate` | no |
| Broker / SWIM connects | **one line** at the very end of the existing `_triggerSyncFlow()` in `connection_screen.dart`: `TradeMonitorService().refreshNow('broker-connected');` — nothing else in that method or file changes | 1 line only |

The old inline blocker block inside `_triggerSyncFlow()` (`connection_screen.dart:521-540`) can be
**left exactly as is** — it is now redundant (the monitor owns blocking) but harmless. Removing it is
optional cleanup, not required. Same for the duplicate in `dashboard_providers.dart:79-108`, which is
deleted in step 4 anyway.

### Step 7 — Fix the persistent helper

- **W1:** replace the hardcoded URL with `ApiConstants.baseUrl` (share a tiny constant, or read it from
  the settings JSON the app writes).
- **W5:** poll `GET /lockout/status` as primary; keep `/trade-limit` only for `isEnabled` +
  `remainingTrades`.
- **W2:** app now writes `token` every tick (step 3) — the helper already reads it.
- **W3:** add a build step —
  `dart compile exe tools/binance_watcher.dart -o build/helper/binance_watcher` — and copy the binary
  into the Runner bundle (macOS: `*.app/Contents/MacOS/`, Windows: next to the `.exe`) via the
  platform build scripts / CI.
- **W4:** in `main.dart` call `resumeIfBlocking()` for `Platform.isMacOS` too.
- **macOS `.app` / `.dmg`:** extend the helper's macOS kill branch with `pkill -9 -if <keyword>` and
  a `_ejectBrokerDmgs()` pass that `hdiutil detach -force`s any mounted broker volume while blocked
  (full code in section 8 → "macOS: `.app` bundles and `.dmg` volumes").

---

## 8. How the block works + background enforcement

### The block itself (what "block the broker apps" means here)

When `shouldBlock` is true, `BinanceBlockerService().enableBlock()` writes `blocked` to
`binance_block_state.txt` and makes sure the helper process is running. The helper
(`binance_watcher`) then, every second:

1. Kills every process in `appsToBlock` (`taskkill /F /IM <name>` on Windows, `pkill -9 -i <name>`
   on macOS) — so thinkorswim / TradingView / Binance close immediately and cannot stay open.
2. Adds `127.0.0.1 <domain>` lines to the hosts file for `tradingview.com`, `schwab.com`,
   `binance.com` etc. — so the web versions and the desktop apps' APIs can't reach the broker.
3. Reads `lockedUntil` from `binance_block_settings.json`; when the current time passes it, it writes
   `unblocked`, removes the hosts lines, and stops killing — the lockout self-expires with no network.

`disableBlock()` writes `unblocked`; the helper cleans up on its next loop.

### macOS: `.app` bundles and `.dmg` volumes

The current helper (`binance_watcher.dart:169-179`) only strips `.exe` and runs `pgrep -i` /
`pkill -9 -i`. That misses two macOS cases the client wants covered — apps run from a mounted
disk image, and the `.dmg` itself. Add this to the helper's macOS branch:

**1 — match processes anywhere (incl. a mounted image).**
`pkill -9 -i` matches the process *name* only. An app launched from
`/Volumes/Thinkorswim/Thinkorswim.app/Contents/MacOS/thinkorswim` has the same process name, so
`pkill -9 -i thinkorswim` already kills it. Also add `-f` so a rename can't dodge it:

```dart
// macOS branch, per keyword derived from appsToBlock (".exe"/".app" stripped, lower-cased)
await Process.run('pkill', ['-9', '-if', keyword]);      // -f: match full command path
```

**2 — force-eject broker `.dmg` volumes.** While `state == 'blocked'`, on each loop enumerate
`/Volumes` and detach any mount whose volume name (or backing image name) contains a broker keyword:

```dart
Future<void> _ejectBrokerDmgs(List<String> keywords) async {
  final vols = Directory('/Volumes');
  if (!vols.existsSync()) return;
  for (final v in vols.listSync()) {
    final name = v.path.split('/').last.toLowerCase();
    if (keywords.any((k) => name.contains(k))) {
      await Process.run('hdiutil', ['detach', '-force', v.path]);
      print('[BinanceWatcher] Ejected broker volume: ${v.path}');
    }
  }
}
```

`keywords` = each `appsToBlock` entry with `.exe`/`.app` removed and lower-cased
(`thinkorswim`, `tradingview`, `binance`, plus `schwab`). Run `_ejectBrokerDmgs` right after the
process-kill loop, only when blocked. Ejecting is idempotent — a re-mount is detached again within
1 s, so the user cannot keep it open.

**3 — (optional, stronger) block by bundle id.** If the API later sends bundle identifiers
(`com.devexperts.thinkorswim`, `com.tradingview.desktop`), prefer
`pkill -9 -if <bundleId>` and, on Apple Silicon, `launchctl bootout` the app's login item. Not
required for the current API shape.

Nothing here needs root — `pkill` and `hdiutil detach` on the user's own session/volumes work from
the per-user LaunchAgent. Only the `/etc/hosts` edit still needs the one-time admin authorization.

### Split of responsibility

| | App open | App closed |
|---|---|---|
| Who checks the backend | `TradeMonitorService` timer (15 / 60 / 300 s) + refresh on focus/resume | `binance_watcher` polls `/lockout/status` on its own interval |
| Who enforces the kill/hosts block | `binance_watcher` (started by the app) | `binance_watcher` (kept alive by Task Scheduler / LaunchAgent) |
| Source of truth | backend `/lockout/status`; local `lockedUntil` while offline | same |

The Flutter process never kills anything itself — it only decides *whether* to block and hands the
helper the token + `appsToBlock` + `lockedUntil`. This is why the helper must be built and bundled.

### Building & bundling the helper — required

```bash
# one build command, run per-platform in CI or the release script
dart compile exe tools/binance_watcher.dart -o build/helper/binance_watcher      # macOS/Linux
dart compile exe tools/binance_watcher.dart -o build/helper/binance_watcher.exe  # Windows
```

- **macOS:** copy `binance_watcher` into `TradeLMT.app/Contents/MacOS/` (next to the Flutter
  executable — this is what `File(Platform.resolvedExecutable).parent.path` resolves to). Add it as a
  build phase in `macos/Runner.xcodeproj`, or a `cp` step after `flutter build macos`. It must be
  signed with the same identity and included in notarization or Gatekeeper will kill it.
- **Windows:** copy `binance_watcher.exe` next to `tradelmt.exe` in the build output. Add a
  post-build `copy` in `windows/` packaging or the installer script.
- Verify at runtime: `AppInitializer._startBinanceWatcher()` already checks
  `File(watcherPath).exists()` — add a visible log/telemetry when it's missing so a broken bundle is
  caught in QA.

### Auto-start when the app is closed

- **Windows:** keep the existing Task Scheduler registration (`schtasks /Create … /SC ONSTART`).
  It survives reboot and runs the helper without the Flutter app. The UAC prompt on first enable is
  expected. No change needed beyond the URL/token fixes (W1/W2).
- **macOS:** the current code installs a **`/Library/LaunchDaemons`** plist through an `osascript`
  *admin-password* prompt on every `enableBlock()`. Change this to a **per-user LaunchAgent** at
  `~/Library/LaunchAgents/com.tradelmt.watcher.plist` with `RunAtLoad` + `KeepAlive` — no password
  prompt, starts at login, restarts if killed. The hosts-file edit is the only part that needs root;
  do that via one cached `osascript` authorization instead of per-lock. Install the LaunchAgent once
  (first successful login) rather than on every block.

### Offline behaviour

The helper is the local enforcement authority when there's no network: it keeps killing the broker
apps until `lockedUntil` passes, then releases on its own. The backend re-confirms on the next
reachable poll. A real lockout therefore survives the user pulling the network cable.

### iOS/Android

Not targets. If ever added: no always-on background is possible (Android → foreground service or
`WorkManager` 15-min floor; iOS → opportunistic `BGProcessingTask`). Correct model there is
server-push on lockout + hard refresh on foreground, with server-side enforcement.

---

## 9. One monitor per session (no duplicate timers)

- `TradeMonitorService` is a singleton holding a single `Timer?`. `start()` is a no-op if a timer is
  live — same guard `BinanceBlocker.startBlocking()` already uses.
- Started from exactly one place — `HomeScreen.initState` — never from `build`, never from a provider
  body, never from a rebuilding widget. Provider rebuilds and navigation cannot spawn a second loop.
- `refreshNow()` cancels any in-flight tick and debounces bursts (focus + resume firing together).
- Broker reconnects call `refreshNow()`, not `start()` → N connect events = N refreshes, one timer.
- The helper already guards duplicates via its PID file (`_isWatcherRunning()`) — keep that.
- On logout `stop()` nulls the timer; the next login's `initState` starts a fresh one bound to the
  new token.

---

## 10. Error handling

`ApiService._handleError` currently throws a bare `String`. Introduce a small typed set
(`Unauthorized`, `NotFound`, `RateLimited`, `ServerError`, `NetworkError`) so the monitor can branch.

| Condition | Monitor action | Blocker |
|---|---|---|
| `401 / 403` | `stop()`, clear token, route to login | untouched — helper keeps enforcing `lockedUntil` |
| `404` on `/trades/sync` | expected when Schwab not connected — skip sync, keep using `/lockout/status` + `/trade-limit` | no change |
| `404` / null on `/trade-limit` | treat as "no rule": `ruleEnabled = false` | release counter-based block |
| `429` | honour `Retry-After` if present, else backoff 60→120→300s (cap 300) | keep last state |
| `500–599` | backoff, `stale = true`, show subtle "last checked N min ago" chip | keep last state |
| timeout / no internet | backoff, `stale = true` | keep last state — never flip on a failed read |
| malformed / missing fields | null-safe parse with model defaults; if both `tradeLimit` and `lockout` unparseable → treat as failed read | keep last state |
| token refresh | no refresh endpoint wired for app-JWT today → `401` = full re-login. If `/auth/refresh-token` is adopted, retry the tick once after refresh. | — |

**Key rule:** a state *transition* (block ↔ unblock) may only happen on a *successful* response.
Failures freeze the last good state.

---

## 11. `journalOverview.dart` overflow

Two separate overflows, both in this widget as rendered inside the dashboard's right-hand
`Expanded(flex:3)` column.

**Horizontal — "overflowed by 103 px on the right" (line 37):** the `Row` holds three
`_buildJournalMetric` blocks + two fixed `SizedBox(width: 32)` spacers, none `Flexible`. Each metric
is a `Row` → `Column` of two non-wrapping `Text` lines. On a 1100px window the right panel is ≈500px;
three metrics + 64px of hard spacers don't fit.

**Vertical — `RenderFlex … direction: vertical … h=73 … spaceBetween`:** the inner metric `Column`
handed a height-constrained slot (inherits the ~73px content box of the sibling stat cards). Two
14/12px lines + 2px gap fit 73px normally, but not at a larger system text scale.

**Fix — flow instead of fixed row:**

```dart
// line 37: replace the Row(...) with:
Wrap(
  spacing: 24,
  runSpacing: 12,
  children: const [
    _JournalMetric(isWin: true,  title: '60% Wins', subtitle: '40% Loss'),
    _JournalMetric(isWin: false, title: '30% Wins', subtitle: '10% Loss'),
    _JournalMetric(isWin: false, title: '20% Wins', subtitle: '—'),
  ],
),

// _buildJournalMetric -> a real widget, width-bounded, text allowed to wrap:
ConstrainedBox(
  constraints: const BoxConstraints(minWidth: 96, maxWidth: 160),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      /* dot */,
      Flexible(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,    softWrap: true, style: /* ... */),
            const SizedBox(height: 2),
            Text(subtitle, softWrap: true, style: /* ... */),
          ],
        ),
      ),
    ],
  ),
)
```

- `Wrap` lets the three metrics drop to a second line on narrow windows instead of overflowing — no
  fixed width, no scroll.
- `Flexible` + `softWrap` removes the vertical clip; inner `Column` is `MainAxisSize.min` so it never
  fights a tight height.
- `minWidth/maxWidth` keeps columns tidy across small/normal/large screens and longer localised
  strings without hard-coding one value.
- While here: **line 13 `color: const Color(0xFC7C2C2)`** is a 7-digit value → parses as
  near-transparent `0x0FC7C2C2`. If a card background is intended, use full 8-digit ARGB
  (e.g. `0xFFF7C2C2`) or a theme token.

---

## 12. Testing checklist

**Test rig**
- Force lock/unlock without real trades: `POST /lockout/manual {lockoutHours:4}` and `POST /lockout/unlock`.
- Set the rule: `POST /trade-limit {dailyLimit:N, lockoutHours:4, isEnabled:true}`.
- Simulate the counter hitting 0: easiest is `POST /lockout/manual`; to test the pure
  `remainingTrades == 0` path you need real Schwab fills or a backend that lets you set the count.
- Watch these while testing:
  - `binance_block_state.txt`, `binance_block_settings.json` — Windows: `%TEMP%`, macOS: `$TMPDIR` (`echo $TMPDIR`).
  - Helper stdout — run the compiled `binance_watcher` from a terminal during dev.
  - App logs — add a one-line log in `TradeMonitorService._tick()` with state + next interval.
- Install a couple of the real broker apps (or rename any harmless app to `thinkorswim.exe` /
  `Thinkorswim.app`) to see the kill actually happen.

**End-to-end happy path (run this first, both OSes)**
- [ ] Login → dashboard shows the correct `dailyLimit` and remaining count within ~1s
- [ ] `POST /lockout/manual` → within one poll (≤15s, or instant on window refocus) the broker apps are
      killed, hosts entries appear, dashboard shows "Limit reached (Auto-locked)"
- [ ] Try to reopen a blocked broker app → it closes again within ~1s
- [ ] `POST /lockout/unlock` → within one poll the block clears, hosts entries removed, apps stay open
- [ ] Quit the Flutter app entirely, `POST /lockout/manual` again → broker apps still get killed (helper alone)
- [ ] Relaunch the app → it shows the locked state, does not double-block

**Limit values**
- [ ] `dailyLimit 3`, remaining 3 → not blocked, dashboard shows 3 left, poll interval 60s
- [ ] `dailyLimit 2`, remaining 1 → not blocked, "1 trade remaining" copy
- [ ] remaining drops to 1 → still allowed
- [ ] remaining hits 0 → blocked within one poll; broker apps + Binance killed; hosts entries added; interval → 15s
- [ ] after `lockoutHours` passes → helper auto-unblocks even with no network; app confirms next successful poll

**Rule toggle**
- [ ] `isEnabled true` then remaining 0 → block
- [ ] `isEnabled false` → never blocks on counter; existing counter-block released; manual lockout still blocks; interval → 300s

**Broker**
- [ ] Schwab connected → `_triggerSyncFlow` ends with `refreshNow('connect')`; state reflects real fills
- [ ] Schwab never connected → no `404` spam; enforcement still works off `/lockout/status` + `/trade-limit`
- [ ] Schwab disconnected mid-session → monitor keeps running, sync skipped gracefully

**Lifecycle**
- [ ] foreground → background → foreground → immediate refresh, no second timer (log a start counter)
- [ ] window close then reopen → `resumeIfBlocking()` restores active lockout (verify on macOS specifically)
- [ ] app fully quit while locked → helper still kills broker apps; relaunch shows locked state
- [ ] app restart after lockout expired → starts unblocked

**Network & auth**
- [ ] disconnect network while unlocked → no block created; "stale" chip appears; reconnect clears it
- [ ] disconnect while locked → stays locked; helper still enforces
- [ ] expire / corrupt `auth_token` → monitor stops, routed to login, active lockout persists locally
- [ ] force `429` / `500` → backoff, no state flip
- [ ] truncated JSON body → parse defaults, treated as failed read

**Sessions**
- [ ] log out → `stop()`; log in as different user → fresh monitor, that user's limit, no carry-over
- [ ] switch broker account → `refreshNow`, counts update
- [ ] rapid connect/disconnect/connect → exactly one timer throughout

**Windows (release build)**
- [ ] `binance_watcher.exe` is present next to `tradelmt.exe` in the packaged output
- [ ] First `enableBlock()` → UAC prompt, then Task Scheduler task `BinanceWatcher` exists (`schtasks /Query /TN BinanceWatcher`)
- [ ] Lock active → `taskkill` closes the broker apps; `C:\Windows\System32\drivers\etc\hosts` gets the `# TradeLMT Blocker` block
- [ ] Reboot with lockout active → task relaunches the helper on startup, block still enforced
- [ ] `lockoutHours` elapses while offline → helper writes `unblocked`, removes hosts lines, stops killing
- [ ] Unblock → hosts block removed, task can be left registered (idempotent)

**macOS (release .app, notarised)**
- [ ] `binance_watcher` is inside `TradeLMT.app/Contents/MacOS/`, signed, passes `spctl -a -vv`
- [ ] Helper runs without Gatekeeper killing it (`log stream` shows it alive, not "killed: code signature")
- [ ] LaunchAgent `~/Library/LaunchAgents/com.tradelmt.watcher.plist` loads at login (`launchctl list | grep tradelmt`)
- [ ] Lock active → `pkill` closes the broker apps; `/etc/hosts` edit prompts for admin **once**, then cached
- [ ] broker app run **from a mounted `.dmg`** (e.g. `/Volumes/Thinkorswim/…`) → killed within ~1s
- [ ] mount a broker `.dmg` while locked → volume is force-ejected within ~1s; re-mounting ejects again
- [ ] non-broker `.dmg` (e.g. some unrelated installer) stays mounted — keyword match doesn't over-reach
- [ ] `main.dart` calls `resumeIfBlocking()` on macOS (W4) → quit + relaunch while locked keeps the block
- [ ] `lockoutHours` elapses → self-unblock, hosts restored
- [ ] System Settings › Privacy: the app has whatever automation permission `osascript` needs

**UI**
- [ ] `journalOverview` renders with no overflow at 1100 / 1280 / 1440 / 1920 window width
- [ ] no overflow at system text scale 1.0 and 1.3, and with longer strings ("45% Wins" → "Ganancias 45%")
- [ ] dashboard "Daily Trade Limit" card and the config card below it show consistent numbers after a refresh
