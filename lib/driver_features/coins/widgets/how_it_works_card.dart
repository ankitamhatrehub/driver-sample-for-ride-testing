import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

class HowItWorksCard extends StatelessWidget {
  const HowItWorksCard({super.key, this.showTitle = true});

  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    const steps = [
      (
        Icons.badge_outlined,
        Color(0xFF7C3AED),
        Color(0xFFF3E8FF),
        'Complete an eligible job',
        'One eligible job = one scratch card',
      ),
      (
        Icons.paid_rounded,
        Color(0xFFF59E0B),
        Color(0xFFFEF3C7),
        'Scratch your card',
        "Find out what you've won",
      ),
      (
        Icons.card_giftcard_rounded,
        Color(0xFFF43F5E),
        Color(0xFFFFF1F2),
        'Get your reward',
        'Coins or other rewards will be credited automatically',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle) ...[
          Text(
            'How it works ?',
            style: AppTypography.regular.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.h(8)),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(context.r(16)),
            border: Border.all(color: const Color(0xFFE8EDF5)),
          ),
          child: Column(
            children: [
              for (var i = 0; i < steps.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9)),
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
                        child: Icon(steps[i].$1, color: steps[i].$2, size: context.w(18)),
                      ),
                      SizedBox(width: context.w(12)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              steps[i].$4,
                              style: AppTypography.regular.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: context.h(2)),
                            Text(
                              steps[i].$5,
                              style: AppTypography.regular.copyWith(fontSize: 11, color: AppColors.slate500),
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
