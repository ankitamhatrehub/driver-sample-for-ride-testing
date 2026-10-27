import 'package:flutter/material.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/select_vehicle_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class VehiclePage extends StatelessWidget {
  const VehiclePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _session,
      builder: (context, _) {
        return SelectVehicleScreen(
          selectedVehicle: _session.vehicleType,
          isLoading: _session.loading,
          onBack: _session.returnToReview
              ? () =>
                    leaveOnboardingStep(context, AppRoutes.vehicleDetails, AppRoutes.welcome)
              : null,
          onHelp: () => openAiChat(context),
          onSelected: (value) {
            _session.vehicleType = value;
            _session.touch();
          },
          onContinue: () async {
            await _session.saveVehicle();
            if (!context.mounted) return;
            leaveOnboardingStep(context, AppRoutes.vehicleDetails, AppRoutes.kyc);
          },
        );
      },
    );
  }
}
