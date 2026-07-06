class BrokerConnection {
  final String id;
  final String broker;
  final String displayName;
  final String subtitle;
  final String? logoKey;
  final String status;
  final String statusLabel;
  final String actionLabel;
  final bool isEnabled;
  final String? connectUrl;
  final String? manageUrl;

  BrokerConnection({
    required this.id,
    required this.broker,
    required this.displayName,
    required this.subtitle,
    this.logoKey,
    required this.status,
    required this.statusLabel,
    required this.actionLabel,
    required this.isEnabled,
    this.connectUrl,
    this.manageUrl,
  });

  factory BrokerConnection.fromJson(Map<String, dynamic> json) {
    return BrokerConnection(
      id: json['id'] as String? ?? '',
      broker: json['broker'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      logoKey: json['logoKey'] as String?,
      status: json['status'] as String? ?? 'not_connected',
      statusLabel: json['statusLabel'] as String? ?? '',
      actionLabel: json['actionLabel'] as String? ?? '',
      isEnabled: json['isEnabled'] as bool? ?? false,
      connectUrl: json['connectUrl'] as String?,
      manageUrl: json['manageUrl'] as String?,
    );
  }

  String get logoAsset {
    if (logoKey == null || logoKey!.isEmpty) {
      return 'assets/images/Tradovate.png';
    }
    final key = logoKey!.toLowerCase();
    if (key.contains('thinkorswim')) {
      return 'assets/images/Thinkorswim.png';
    } else if (key.contains('tradovate')) {
      return 'assets/images/Tradovate.png';
    } else if (key.contains('interactive') || key.contains('ibkr')) {
      return 'assets/images/Interactive Brokers.png';
    } else if (key.contains('robinhood')) {
      return 'assets/images/Robinhood.png';
    } else if (key.contains('ninjatrader')) {
      return 'assets/images/NinjaTrader.webp';
    } else if (key.contains('tradingview')) {
      return 'assets/images/tradingview-n.webp';
    }
    return 'assets/images/Tradovate.png';
  }
}
