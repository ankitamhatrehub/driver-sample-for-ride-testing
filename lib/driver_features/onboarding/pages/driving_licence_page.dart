import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_driving_license_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class DrivingLicencePage extends StatelessWidget {
  const DrivingLicencePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerifyDrivingLicenseScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onHelp: () => openAiChat(context),
      onFinished: () async {
        final prefs = await SharedPreferences.getInstance();
        final number = prefs.getString('driving_licence_number') ?? '';
        if (number.isNotEmpty) _session.dlNumber.text = number;
        _session.dlVerified = true;
        _session.rememberKyc();
        if (context.mounted) context.go(AppRoutes.kyc);
      },
    );
  }
}
