import 'package:flutter/material.dart';

import 'package:rider_app/common/routes/app_routes.dart';
import 'package:rider_app/driver_features/onboarding/onboarding_session.dart';
import 'package:rider_app/driver_features/onboarding/screens/bank_payout_screen.dart';
import 'package:rider_app/driver_features/onboarding/pages/page_helpers.dart';

OnboardingSession get _session => OnboardingSession.instance;

class BankPage extends StatelessWidget {
  const BankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BankPayoutScreen(
      onBack: () =>
          leaveOnboardingStep(context, AppRoutes.kycBank, AppRoutes.kyc),
      onHelp: () => openAiChat(context),
      onFinished: (details) {
        _session.rememberBank(details);
        _session.bankVerified = true;
        _session.rememberKyc();
        leaveOnboardingStep(context, AppRoutes.kycBank, AppRoutes.kyc);
      },
    );
  }
}
