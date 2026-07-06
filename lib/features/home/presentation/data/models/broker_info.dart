enum BrokerStatus { connected, notConnected, comingSoon }

class BrokerInfo {
  final String name;
  final String subtitle;
  final String icon;
  final BrokerStatus status;

  const BrokerInfo({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.status,
  });
}