import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/constants/asset_constants.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

/// Screen after KYC. The two actions open their own screens.
class VerifyAadhaarScreen extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onHelp;
  final VoidCallback onContinueDigilocker;
  final VoidCallback onUploadManually;

  const VerifyAadhaarScreen({
    super.key,
    required this.onBack,
    required this.onHelp,
    required this.onContinueDigilocker,
    required this.onUploadManually,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.verifyAadhaarPan,
      subtitle: AppStrings.verifyAadhaarSubtitle,
      onBack: onBack,
      onHelp: onHelp,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
          context.w(24),
          context.h(0),
          context.w(24),
          context.h(150),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(AppAssets.aadhaarImage, fit: BoxFit.contain),
            ),
            UnifiedButton(
              label: AppStrings.continueWithDigilocker,
              onPressed: onContinueDigilocker,
            ),
            SizedBox(height: context.h(12)),
            // OnboardingOutlineButton(
            //   label: AppStrings.uploadManually,
            //   onPressed: onUploadManually,
            // ),
            // SizedBox(height: context.h(33)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock,
                  size: context.w(14),
                  color: AppColors.green600,
                ),
                SizedBox(width: context.w(10)),
                Text(
                  AppStrings.dataSafeWithUs,
                  style: AppTypography.regular.copyWith(
                    fontSize: 12,
                    color: context.legible(AppColors.green700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
