import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/widgets/onboarding_step_scaffold.dart';
import 'package:rider_app/common/widgets/unified_button.dart';

class DocumentValidationScreen extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onBack;
  final VoidCallback? onHelp;
  final VoidCallback onRetake;

  const DocumentValidationScreen({
    super.key,
    required this.title,
    required this.message,
    required this.onBack,
    required this.onRetake,
    this.onHelp,
  });

  @override
  Widget build(BuildContext context) {
    return OnboardingStepScaffold(
      title: AppStrings.documentValidation,
      onBack: onBack,
      onHelp: onHelp,
      body: Padding(
        padding: EdgeInsets.fromLTRB(context.w(24), context.h(24), context.w(24), context.h(16)),
        child: Column(
          children: [
            const _DocumentSketch(),
            SizedBox(height: context.h(20)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: AppColors.error, size: context.w(16)),
                SizedBox(width: context.w(6)),
                Text(
                  title,
                  style: AppTypography.regular.copyWith(color: AppColors.error, fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: context.h(6)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.regular.copyWith(color: AppColors.secondaryTextColor, fontSize: 13),
            ),
            const Spacer(),
            UnifiedButton(label: AppStrings.retake, onPressed: onRetake),
          ],
        ),
      ),
    );
  }
}

class _DocumentSketch extends StatelessWidget {
  const _DocumentSketch();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.w(220),
      height: context.h(130),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7FB),
        borderRadius: BorderRadius.circular(context.r(16)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(48),
            height: context.w(48),
            decoration: const BoxDecoration(color: Color(0xFFE7EEF6), shape: BoxShape.circle),
            child: Icon(Icons.person, color: const Color(0xFFC5D0DE), size: context.w(28)),
          ),
          SizedBox(width: context.w(14)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _bar(context, 1),
                SizedBox(height: context.h(8)),
                _bar(context, 0.75),
                SizedBox(height: context.h(8)),
                _bar(context, 0.5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(BuildContext context, double widthFactor) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          height: context.h(8),
          decoration: BoxDecoration(color: const Color(0xFFE3EAF2), borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }
}
