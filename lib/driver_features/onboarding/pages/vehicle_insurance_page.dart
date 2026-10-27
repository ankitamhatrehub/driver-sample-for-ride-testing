import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/screens/vehicle_insurance_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

class VehicleInsurancePage extends StatelessWidget {
  const VehicleInsurancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VehicleInsuranceScreen(
      onBack: () => context.go(AppRoutes.kycPhotos),
      onHelp: () => openAiChat(context),
      onSkip: () => context.go(AppRoutes.kyc),
    );
  }
}
