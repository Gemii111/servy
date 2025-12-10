import 'package:flutter/material.dart';
import '../../../customer/screens/onboarding/onboarding_screen.dart';

/// Onboarding screen for Driver app (reuses Customer onboarding structure)
class DriverOnboardingScreen extends StatelessWidget {
  const DriverOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Reuse the customer onboarding screen
    // You can create a custom driver onboarding if needed
    return const OnboardingScreen();
  }
}
