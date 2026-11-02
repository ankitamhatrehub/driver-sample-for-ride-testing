import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/kyc_verification_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class KycPage extends StatelessWidget {
  const KycPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return KycVerificationScreen(
          aadhaarVerified: _session.aadhaarVerified,
          dlVerified: _session.dlVerified,
          rcVerified: _session.rcVerified,
          vehiclePhotosVerified: _session.photosVerified,
          faceVerified: _session.faceVerified,
          bankVerified: _session.bankVerified,
          profileSubmitted: false,
          onBack: () => leaveOnboardingStep(
            context,
            AppRoutes.kyc,
            AppRoutes.vehicleDetails,
          ),
          onHelp: () => openAiChat(context),
          onAadhaarTap: () => context.go(AppRoutes.kycAadhaar),
          onDlTap: () => context.go(AppRoutes.kycDrivingLicence),
          onRcTap: () => context.go(AppRoutes.kycRc),
          onVehiclePhotosTap: () => context.go(AppRoutes.kycPhotos),
          onFaceTap: () => context.go(AppRoutes.kycFace),
          onBankTap: () => context.go(AppRoutes.kycBank),
          onProfileTap: () => context.go(AppRoutes.driverDetails),
        );
      },
    );
  }
}
