import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/widgets/onboarding_result_screen.dart';

class PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onTryAgain;

  const PermissionDeniedScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingResultScreen(
      appBarTitle: AppStrings.digilockerTitle,
      image: AppAssets.digilockerPermissionDenied,
      title: AppStrings.permissionDenied,
      message: AppStrings.permissionDeniedSubtitle,
      hint: AppStrings.permissionDeniedHint,
      primaryLabel: AppStrings.tryAgain,
      onPrimary: onTryAgain,
      onBack: onBack,
      onHelp: onHelp,
    );
  }
}
