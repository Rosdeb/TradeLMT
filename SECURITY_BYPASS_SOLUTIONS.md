# Blocker Security & Anti-Tampering Plan (Windows & macOS)

This document analyzes the common tricks users use to bypass local trade-limit lockouts and provides the best practical implementation strategies for both Windows and macOS.

---

## 🛡️ Core Defense Matrix

| User Trick | Windows Defense Strategy | macOS Defense Strategy | Security Level |
| :--- | :--- | :--- | :--- |
| **Close TradeLMT Dashboard** | Run the enforcement engine as a **Windows Service** (running as `LocalSystem`), not a desktop UI process. | Run the enforcement engine as a **LaunchDaemon** (running as `root`), not a user LaunchAgent. | 🔴 High |
| **Kill Blocker Process** | Standard users cannot kill a `SYSTEM`-level Windows Service from Task Manager. | Standard users cannot kill `root` processes from Activity Monitor or Terminal. | 🔴 High |
| **Stop or Uninstall Blocker Service** | Configure the service recovery to **Auto-Restart** on failure. Lock down service control permissions using SDDL. | Set `<key>KeepAlive</key> <true/>` in the plist configuration. Restrict plist write access to root. | 🔴 High |
| **Rename/Move Broker Executable** | Inspect process metadata, check **Digital Signatures** (Authenticode), and monitor standard install paths. | Query **Bundle Identifiers** (`com.tdameritrade.thinkorswim`) and code signatures (`codesign -dv`). | 🟡 Medium |
| **Trade via Web Browsers** | Update `hosts` file or inject Windows Firewall rules to blackhole broker domains during lockout. | Update `/etc/hosts` (requires root) to blackhole broker domains during lockout. | 🟡 Medium |
| **Disconnect Internet to Avoid Lockout** | Cache lockout status locally (`fail-closed` approach). Block app launch if server can't be resolved. | Cache lockout status locally in a root-owned file. Lock out app if connectivity is manipulated. | 🔴 High |
| **Uninstall TradeLMT** | Set folder permissions to prevent standard users from deleting files in `Program Files`. | Restrict uninstall permissions for the application bundle inside `/Applications`. | 🟡 Medium |

---

## 💻 Technical Implementation Details

### 1. Elevated Privileges (Windows Service vs. macOS LaunchDaemon)
To ensure the blocker cannot be killed by a standard non-admin account, the background watcher must be installed as a system daemon.

#### 🪟 Windows (LocalSystem Service)
Instead of using Dart's `Process.start` directly from the user-level Flutter app:
* Use a service wrapper (e.g., `winsw` or compile a native service binary).
* Install with `sc create`:
  ```cmd
  sc create TradeLMTWatcher binPath= "C:\Program Files\TradeLMT\binance_watcher.exe" start= auto
  sc failure TradeLMTWatcher reset= 86400 actions= restart/1000/restart/5000/restart/10000
  ```

#### 🍎 macOS (System LaunchDaemon)
Move the `.plist` file from the user scope (`~/Library/LaunchAgents`) to the system scope (`/Library/LaunchDaemons`) which causes it to execute as `root`:
* File location: `/Library/LaunchDaemons/com.tradelmt.binancewatcher.plist`
* Property List Configuration:
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
      <key>Label</key>
      <string>com.tradelmt.binancewatcher</string>
      <key>ProgramArguments</key>
      <array>
          <string>/Library/Application Support/TradeLMT/binance_watcher</string>
      </array>
      <key>RunAtLoad</key>
      <true/>
      <key>KeepAlive</key>
      <true/>
  </dict>
  </plist>
  ```
* Set file permissions to root:
  ```bash
  sudo chown root:wheel /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist
  sudo chmod 644 /Library/LaunchDaemons/com.tradelmt.binancewatcher.plist
  ```

---

### 2. Preventing Executable Renaming/Relocation
If a user renames `thinkorswim.exe` or `Binance.app`, simple name checks fail.

#### 🪟 Windows Code Signature Verification
Query the publisher certificate of the running process:
```powershell
# Get signature details of running process
Get-Process | Where-Object {$_.Path} | Get-AuthenticodeSignature | Where-Object {$_.SignerCertificate.Subject -like "*Schwab*" -or $_.SignerCertificate.Subject -like "*Binance*"}
```

#### 🍎 macOS Bundle Identifier Check
Rather than checking process names, query the App Bundle identifier which does not change even if the application is renamed:
```bash
# Finds the path of the app matching the Bundle Identifier
mdfind "kMDItemCFBundleIdentifier == 'com.tdameritrade.thinkorswim'"
```
Or check code-signature info:
```bash
codesign -dv /Applications/Binance.app 2>&1 | grep -E "Identifier|Authority"
```

---

### 3. Blocking Web Browser-Based Trading
To prevent users from switching to Chrome, Safari, or Edge to place trades when the desktop application is blocked:

* **DNS Blackholing (`hosts` manipulation)**:
  During a lockout, the system daemon inserts block rules into the hosts file (`C:\Windows\System32\drivers\etc\hosts` on Windows, `/etc/hosts` on macOS):
  ```text
  127.0.0.1 trade.schwab.com
  127.0.0.1 binance.com
  ```
  Since the daemon runs as `SYSTEM`/`root`, it is the only process with permission to write to the hosts file. When the lockout expires, the daemon cleans up the file.

---

### 4. Offline Fail-Closed Security
If the user pulls their ethernet plug or disconnects Wi-Fi to stop the daemon from receiving the lock status from the server:
* Cache the latest `lockedUntil` timestamp in a root-accessible secure database or directory (e.g., `/Library/Application Support/TradeLMT/state`).
* If the daemon starts up but cannot reach the server, it compares the current system clock with the cached `lockedUntil` timestamp.
* If NTP servers are also blocked/unreachable, it defaults to a **fail-closed** mode (blocking all trading processes) until connection is established and the server authorizes an unlock.
