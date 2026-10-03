import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

/// Blue hint used at the bottom of onboarding steps.
class OnboardingInfoBanner extends StatelessWidget {
  const OnboardingInfoBanner({
    super.key,
    required this.message,
    this.icon = Icons.info,
  });

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textColor = AppColors.blue900.withValues(alpha: 0.8);

    return Container(
      width: context.w(337),
      constraints: BoxConstraints(minHeight: context.h(48)),
      padding: EdgeInsets.all(context.w(14)),
      decoration: BoxDecoration(
        color: AppColors.blueLight.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(context.r(12)),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: textColor, size: context.w(16)),
            SizedBox(width: context.w(10)),
          ],
          Expanded(
            child: Text(
              message,
              style: AppTypography.regular.copyWith(
                fontSize: 11,
                height: 17.88 / 11,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
