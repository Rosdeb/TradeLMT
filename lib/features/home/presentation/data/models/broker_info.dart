import 'dart:ui';

import '../../screen/connection_screen.dart';

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