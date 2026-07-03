import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

// 0 = Welcome/Get Started panel
// 1 = Login panel
// 2 = Create Account panel
final onboardingStepProvider = StateProvider<int>((ref) => 0);

