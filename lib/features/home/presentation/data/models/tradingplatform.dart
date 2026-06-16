class TradingPlatform {
  final String name;
  final bool islock;
  final String logo;

  const TradingPlatform({
    required this.name,
    this.islock = false,
    required this.logo,
  });
}