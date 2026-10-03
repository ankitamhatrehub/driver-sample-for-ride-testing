import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/widgets/onboarding_result_screen.dart';

class AuthenticationFailedScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onTryAgain;
  final VoidCallback onUseAnotherMethod;

  const AuthenticationFailedScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onTryAgain,
    required this.onUseAnotherMethod,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingResultScreen(
      appBarTitle: AppStrings.digilockerTitle,
      image: AppAssets.digilockerAuthFailed,
      title: AppStrings.authenticationFailed,
      message: AppStrings.authenticationFailedSubtitle,
      hint: AppStrings.authenticationFailedHint,
      primaryLabel: AppStrings.tryAgain,
      onPrimary: onTryAgain,
      secondaryLabel: AppStrings.useAnotherMethod,
      onSecondary: onUseAnotherMethod,
      onBack: onBack,
      onHelp: onHelp,
    );
  }
}
