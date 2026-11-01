import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class VehicleHeader extends StatelessWidget {
  const VehicleHeader({super.key, this.title = ''});

  /// Line under the label, e.g. the vehicle type. Shows a dash when empty.
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: context.torkk.border),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(72),
            height: context.h(48),
            decoration: BoxDecoration(
              color: context.adaptiveTint(const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
          ),
          SizedBox(width: context.w(12)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.carModel,
                style: AppTypography.regular.copyWith(
                  fontSize: 12,
                  color: context.torkk.textSecondary,
                ),
              ),
              Text(
                title.isEmpty ? '-' : title,
                style: AppTypography.bold.copyWith(
                  fontSize: 14,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
