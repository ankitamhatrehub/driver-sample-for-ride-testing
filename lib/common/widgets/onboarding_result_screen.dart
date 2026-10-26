import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/onboarding_info_banner.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Shared layout for DigiLocker results that look the same:
/// illustration, title, message, optional hint, and actions.
class OnboardingResultScreen extends StatelessWidget {
  const OnboardingResultScreen({
    super.key,
    required this.appBarTitle,
    required this.image,
    required this.title,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onBack,
    this.onHelp,
    this.hint,
    this.secondaryLabel,
    this.onSecondary,
  });

  final String appBarTitle;
  final String image;
  final String title;
  final String message;
  final String? hint;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final VoidCallback onBack;
  final VoidCallback? onHelp;

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: appBarTitle,
      onBack: onBack,
      onHelp: onHelp,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(12), context.w(24), context.h(16)),
        child: Column(
          children: [
            Image.asset(image, height: context.h(180), fit: BoxFit.contain),
            SizedBox(height: context.h(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.bold.copyWith(fontSize: 20, height: 1.2),
            ),
            SizedBox(height: context.h(8)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(
                color: context.torkk.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const Spacer(),
            if (hint != null) ...[
              OnboardingInfoBanner(message: hint!),
              SizedBox(height: context.h(16)),
            ],
            UnifiedButton(label: primaryLabel, onPressed: onPrimary),
            if (secondaryLabel != null && onSecondary != null) ...[
              SizedBox(height: context.h(12)),
              OnboardingOutlineButton(label: secondaryLabel!, onPressed: onSecondary!),
            ],
          ],
        ),
      ),
    );
  }
}

class OnboardingOutlineButton extends StatelessWidget {
  const OnboardingOutlineButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: context.h(52),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.torkk.surface,
          borderRadius: BorderRadius.circular(context.r(14)),
          border: Border.all(color: context.legible(AppColors.primary)),
        ),
        child: Text(
          label,
          style: AppTypography.bold.copyWith(color: AppColors.primary, fontSize: 16, height: 1.2),
        ),
      ),
    );
  }
}
