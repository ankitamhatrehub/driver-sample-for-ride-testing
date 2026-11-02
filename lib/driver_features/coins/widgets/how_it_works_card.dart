import 'package:flutter/material.dart';

import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

import '../../../common/constants/string_constants.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.badge_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF3E8FF),
        AppStrings.completeEligibleJob,
        AppStrings.oneEligibleJobOneScratchCard,
      ),
      (
        Icons.paid_rounded,
        const Color(0xFFF59E0B),
        const Color(0xFFFEF3C7),
        AppStrings.scratchYourCard,
        AppStrings.findOutWhatYouWon,
      ),
      (
        Icons.card_giftcard_rounded,
        const Color(0xFFF43F5E),
        const Color(0xFFFFF1F2),
        AppStrings.getYourReward,
        AppStrings.rewardsCreditedAutomatically,
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            AppStrings.howItWorks,
            style: AppTypography.regular.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.h(8)),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(color: context.torkk.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) Divider(height: 1, color: context.torkk.border),
                Padding(
                  padding: EdgeInsets.all(context.w(14)),
                  child: Row(
                    children: [
                      Container(
                        width: context.w(36),
                        height: context.w(36),
                        decoration: BoxDecoration(
                          color: steps[i].$3,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                        child: Icon(
                          steps[i].$1,
                          color: steps[i].$2,
                          size: context.w(18),
                        ),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[i].$4,
                              style: AppTypography.regular.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: context.h(2)),
                            Text(
                              steps[i].$5,
                              style: AppTypography.regular.copyWith(
                                fontSize: 11,
                                color: context.torkk.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
