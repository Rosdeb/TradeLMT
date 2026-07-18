# Process Blocker & Anti-Uninstall System Documentation

This document describes how the Process Blocker system works, how it integrates with the `/trades/sync` API and SSE (Server-Sent Events), how it executes background blocking when the UI app is closed, and how it is protected against uninstallation.

---

## 1. How the Process Blocker Works

The system divides responsibilities between two components:
1. **The Desktop UI Application** (Flutter / Dart UI)
2. **The Detached Watcher Executable** (`binance_watcher.exe`)

### Architecture Flow:
```
[SSE Server Event] ──> [Flutter App (Active)] 
                             │
                             ├──> 1. Writes "blocked" to temp state file
                             ├──> 2. Starts "binance_watcher.exe" (Detached)
                             └──> 3. Registers "binance_watcher.exe" to Windows Task Scheduler
```

### Local State Persistence:
- The block state is saved in the system temp directory: `${temp_dir}/binance_block_state.txt`.
- The process ID (PID) of the active watcher is written to `${temp_dir}/binance_watcher.pid`.

---

## 2. Triggering Block via SSE & Background Persistence

Since a standard Flutter UI application cannot run code or listen to network sockets when closed, here is how the system handles block and unblock notifications:

### Scenario A: App is Active (Real-Time SSE Sync)
1. The Flutter UI app runs in the foreground and maintains an active connection to the Server-Sent Events (SSE) stream.
2. When the backend triggers an event stating that the trade limit has been reached, the Flutter app immediately calls `BinanceBlockerService().enableBlock()`.
3. This writes `blocked` to the state file and fires up the detached `binance_watcher.exe`.

### Scenario B: App is Closed (How does it sync block/unblock?)
When the UI application is closed, it cannot listen to SSE events. To handle lock/unlock states in the background, you have two design options:

#### Option 1: Polling inside `binance_watcher.exe` (Recommended)
Instead of only checking the local text file, the background watcher (`binance_watcher.exe`) is programmed to poll the backend API (e.g. `GET /trade-limit` or `/trades/sync`) in a loop (e.g., every 30 or 60 seconds):
- **If the API response returns `locked: true`**: The watcher keeps the block active and continues killing restricted apps.
- **If the API response returns `locked: false` (lockout expired or manual unlock)**: The watcher writes `unblocked` to the local state file, stops blocking, and exits.

#### Option 2: Expiry Timestamp Logic (Offline Expiry Check)
When the block is first activated (via SSE or API sync while the app is open), the API returns a `lockedUntil` timestamp (e.g., `"2026-07-06T20:00:00.000Z"`).
1. The Flutter app saves this timestamp into the local state file (`binance_block_state.txt`).
2. Even when the UI app is closed, `binance_watcher.exe` continually compares the current PC system time against the saved `lockedUntil` timestamp.
3. Once the PC system time exceeds `lockedUntil`, the watcher automatically marks the state as `unblocked`, stops terminating processes, and terminates itself.

---

## 3. Handling Polling Race Conditions (Over-trading in 30 seconds)

If the user completes trades faster than the background polling interval (e.g. executing 3 quick trades inside a 30-second window), you can prevent over-trading using the following strategies:

### Strategy 1: High-Frequency Status Polling
Rather than checking the entire `/trades/sync` payload, design a dedicated ultra-lightweight endpoint on your server (e.g., `GET /lockout-status` returning only `{"locked": true/false}`). 
- Since the payload size is extremely small, `binance_watcher.exe` can query it every **1 to 2 seconds** with negligible CPU/network footprint. This narrows the race window to near-zero.

### Strategy 2: Persistent SSE Stream inside the Watcher
Instead of polling, the background watcher executable (`binance_watcher.exe`) can open and hold its own persistent SSE connection to the backend directly. 
- Because the watcher is compiled native code (C# / Go / Rust / C++), it can run a continuous background socket socket connection even if the Flutter UI is closed. When the 8th trade is completed, the server pushes the event, and the watcher kills the platforms in sub-milliseconds.

---

## 4. Scaling to 10,000+ Concurrent Users

If 10,000 background watchers poll the API every 1-2 seconds, it creates **5,000 to 10,000 Requests Per Second (RPS)**, which can overload backend databases. Here is how to scale this cleanly:

### 1. Establish SSE / WebSockets (Idle Connections)
Instead of polling, watchers keep an open SSE or WebSocket connection. 
- Keeping 10,000 connections open is extremely cheap in memory (e.g., Node.js / Go can hold 100,000+ open sockets on a single small server).
- No API calls are made continuously. When a user locks out, the server fires one message. Bandwidth and server load are virtually **zero** during idle times.

### 2. In-Memory Key-Value Caching (Redis)
If you must use polling:
- Keep the `locked` status cache in **Redis** with the key `user_locked:<userId>`.
- Redis runs completely in RAM and easily handles **100k+ reads/second**. The server verifies the token and retrieves status directly from Redis, bypassing the slower relational database (PostgreSQL/MySQL) entirely.

### 3. Adaptive (Smart) Polling
Change the polling frequency dynamically based on user activity:
- **Low Risk (0 trades made)**: Poll once every **5 minutes**.
- **Medium Risk (4 of 8 trades made)**: Poll every **30 seconds**.
- **High Risk (7 of 8 trades made)**: Poll every **2 seconds**.
- By slowing down polling when users are far from their limits, you reduce server request load by **95%**.

---

## 5. Preventing Uninstallation

To prevent non-admin users from stopping the service or deleting/uninstalling the system:

1. **System Startup Task Locking**:
   The Task Scheduler registration uses `/RL HIGHEST`, running the watcher task with administrator privileges.
2. **Directory ACLs Protection**:
   Install the application files and `binance_watcher.exe` to a system-protected path (e.g., `C:\Program Files\TradeLMT`). Configure Windows directory permissions so only Administrator users have write/delete permissions. Ordinary users will be blocked from deleting the executable.
3. **Taskkill Guard**:
   Since the task is registered and run via Task Scheduler with elevated privileges, ordinary non-administrator users cannot easily kill the `binance_watcher.exe` process from Windows Task Manager.
