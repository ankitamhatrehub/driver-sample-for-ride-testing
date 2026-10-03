import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/widgets/onboarding_result_screen.dart';

class DocumentNotFoundScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onTryAgain;

  const DocumentNotFoundScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingResultScreen(
      appBarTitle: AppStrings.digilockerTitle,
      image: AppAssets.digilockerDocumentNotFound,
      title: AppStrings.documentNotFound,
      message: AppStrings.documentNotFoundSubtitle,
      hint: AppStrings.documentNotFoundHint,
      primaryLabel: AppStrings.tryAgain,
      onPrimary: onTryAgain,
      onBack: onBack,
      onHelp: onHelp,
    );
  }
}
