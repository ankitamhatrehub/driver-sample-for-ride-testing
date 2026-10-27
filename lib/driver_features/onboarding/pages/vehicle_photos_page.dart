import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/vehicle_photos_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class VehiclePhotosPage extends StatelessWidget {
  const VehiclePhotosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return VehiclePhotosScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onHelp: () => openAiChat(context),
      onFinished: () {
        _session.photosVerified = true;
        _session.rememberKyc();
        context.go(AppRoutes.kycInsurance);
      },
    );
  }
}
