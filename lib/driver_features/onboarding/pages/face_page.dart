import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/face_verification_screen.dart';

OnboardingSession get _session => OnboardingSession.instance;

class FacePage extends StatelessWidget {
  const FacePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FaceVerificationScreen(
      onBack: () => context.go(AppRoutes.kyc),
      onFinished: () {
        _session.faceVerified = true;
        _session.rememberKyc();
        context.go(AppRoutes.kyc);
      },
    );
  }
}
