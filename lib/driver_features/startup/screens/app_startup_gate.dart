import 'package:flutter/material.dart';

import 'package:rider_app/driver_features/onboarding/onboarding_pages.dart';

/// Opens the splash route screen. Navigation after splash is handled by [SplashPage].
class AppStartupGate extends StatelessWidget {
  const AppStartupGate({super.key});

  @override
  Widget build(BuildContext context) {
    return const SplashPage();
  }
}
