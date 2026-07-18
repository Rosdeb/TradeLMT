# Website Blocking Guide

This guide explains how the website blocking feature works in the TradeLMT background watcher, how to customize the blocked websites list, and how to troubleshoot caching issues.

---

## 🔍 How Website Blocking Works

The background watcher implements **DNS Blackholing** by modifying the operating system's local hosts file:
* **Windows**: `C:\Windows\System32\drivers\etc\hosts`
* **macOS / Linux**: `/etc/hosts`

When the user enters a lockout state, the watcher appends block rules to redirect target domain names to the local loopback address (`127.0.0.1`). This completely cuts off the browser's ability to communicate with those websites:

```text
# TradeLMT Blocker Start
127.0.0.1 tradingview.com
127.0.0.1 www.tradingview.com
127.0.0.1 schwab.com
127.0.0.1 trade.schwab.com
# TradeLMT Blocker End
```

When the lockout expires or is disabled, the watcher automatically cleans up these entries, restoring normal web access.

---

## 🛠️ How to Add More Websites to the Blocklist

To add or modify the blocked domains:

1. Open `tools/binance_watcher.dart`.
2. Locate the `domainsToBlock` list near the top of the file:
   ```dart
   const List<String> domainsToBlock = [
     'tradingview.com',
     'www.tradingview.com',
     'schwab.com',
     'trade.schwab.com',
     'binance.com',
     'www.binance.com',
     // ADD NEW DOMAINS HERE (e.g., 'ibkr.com', 'www.interactivebrokers.com')
   ];
   ```
3. Re-compile the watcher executable:
   * **Windows**:
     ```bash
     dart compile exe tools/binance_watcher.dart -o build/binance_watcher.exe
     ```
   * **macOS**:
     ```bash
     dart compile exe tools/binance_watcher.dart -o build/binance_watcher
     ```

---

## ⚡ Troubleshooting & DNS Flushing

Sometimes browsers cache DNS records, meaning a website might still load for a few minutes even after the hosts file is updated. To bypass DNS caching, flush the DNS cache:

### Windows (Command Prompt as Admin)
```cmd
ipconfig /flushdns
```

### macOS (Terminal)
```bash
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

### Browser-specific flush
If the site still loads, you can force-clear the internal DNS cache inside Google Chrome:
1. Open Chrome and navigate to: `chrome://net-internals/#dns`
2. Click the **"Clear host cache"** button.

---

## ⚠️ Important Note on Permissions
Because the `hosts` file is a protected system file, **the background watcher process must be running with Administrator (Windows) or Root (macOS) privileges** to successfully block/unblock websites. Running the daemon as a Windows Service or macOS LaunchDaemon handles this automatically.
