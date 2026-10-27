import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/aadhaar_verification_flow.dart';
import 'package:rider_app/driver_features/onboarding/digilocker_launch.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class AadhaarPage extends StatelessWidget {
  const AadhaarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return AadhaarVerificationFlow(
          isLoading: _session.loading,
          aadhaarController: _session.aadhaar,
          onBack: () => context.go(AppRoutes.kyc),
          onHelp: () => openAiChat(context),
          onStartDigilocker: () async {
            final error = await launchDigilocker(context);
            if (context.mounted && error != null) showOnboardingSnack(context, error);
          },
          onSubmitUpload: () async {
            final error = await _session.verifyAadhaar();
            if (!context.mounted) return;
            if (error != null) {
              showOnboardingSnack(context, error);
              return;
            }
            showOnboardingSnack(context, 'Aadhaar Verified successfully!');
            context.go(AppRoutes.kyc);
          },
          onVerified: () {
            _session.playDigilockerSuccess = false;
            _session.touch();
            context.go(AppRoutes.kyc);
          },
          alreadyVerified:
              _session.aadhaarVerified && !_session.playDigilockerSuccess,
          playSuccess: _session.playDigilockerSuccess,
          onSuccessPlayed: () {
            _session.playDigilockerSuccess = false;
            _session.touch();
          },
        );
      },
    );
  }
}
