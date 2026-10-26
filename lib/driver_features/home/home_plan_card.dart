import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/driver_features/home/home_brand.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HomePlanCard extends StatelessWidget {
  const HomePlanCard({super.key, required this.accent, required this.female});

  final Color accent;
  final bool female;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: context.h(58),
      padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        gradient: homeBrandWash(female, 0.11),
        border: Border.all(color: female ? const Color(0x69BA2879) : const Color(0x697E22CE)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: context.w(32),
            height: context.w(32),
            decoration: BoxDecoration(
              color: context.torkk.surface,
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Icon(Icons.calendar_month_rounded, color: accent, size: context.w(16)),
          ),
          SizedBox(width: context.w(10)),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.planYourTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bold.copyWith(fontSize: 13, height: 1.2, letterSpacing: -0.2),
                ),
                Text(
                  AppStrings.planYourTimeSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.regular.copyWith(fontSize: 11, height: 1.2, color: context.torkk.textSecondary),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: accent, size: context.w(18)),
        ],
      ),
    );
  }
}
