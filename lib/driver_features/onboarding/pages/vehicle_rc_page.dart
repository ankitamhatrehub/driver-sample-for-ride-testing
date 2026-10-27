import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/verify_vehicle_rc_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class VehicleRcPage extends StatelessWidget {
  const VehicleRcPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VerifyVehicleRcScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onHelp: () => openAiChat(context),
      onFinished: () async {
        final prefs = await SharedPreferences.getInstance();
        final number = prefs.getString('rc_number') ?? '';
        if (number.isNotEmpty) _session.rcNumber.text = number;
        _session.rcVerified = true;
        _session.rememberKyc();
        if (context.mounted) context.go(AppRoutes.kycPhotos);
      },
    );
  }
}
