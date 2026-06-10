class TradingPlatform {
  final String name;
  final bool isConnected;
  final String logo;

  const TradingPlatform({
    required this.name,
    this.isConnected = false,
    required this.logo,
  });
}