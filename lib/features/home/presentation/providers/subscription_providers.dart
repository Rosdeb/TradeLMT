import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedPlanProvider = StateProvider<String?>((ref) => null);
final activeNavProvider = StateProvider<String>((ref) => 'Subscription');