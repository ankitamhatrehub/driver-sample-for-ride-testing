import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/widgets/onboarding_result_screen.dart';

class VerificationFailedScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onRetry;

  const VerificationFailedScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingResultScreen(
      appBarTitle: AppStrings.digilockerTitle,
      image: AppAssets.digilockerVerificationFailed,
      title: AppStrings.verificationFailed,
      message: AppStrings.verificationFailedSubtitle,
      primaryLabel: AppStrings.retryVerification,
      onPrimary: onRetry,
      onBack: onBack,
      onHelp: onHelp,
    );
  }
}
