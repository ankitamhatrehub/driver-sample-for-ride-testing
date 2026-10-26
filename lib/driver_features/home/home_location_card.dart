import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HomeLocationCard extends StatelessWidget {
  const HomeLocationCard({
    super.key,
    required this.locationLabel,
    required this.onUpdateLocation,
    required this.accent,
  });

  final String locationLabel;
  final VoidCallback onUpdateLocation;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final place = locationLabel.trim();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(14), vertical: context.h(10)),
      decoration: BoxDecoration(
        color: context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        boxShadow: const [
          BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: accent, size: context.w(22)),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentLocation,
                  style: AppTypography.regular.copyWith(fontSize: 11, color: context.torkk.textSecondary),
                ),
                if (place.isNotEmpty)
                  Text(
                    place,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bold.copyWith(
                      fontSize: 14,
                      height: 1.3,
                      letterSpacing: -0.2,
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onUpdateLocation,
            style: TextButton.styleFrom(
              backgroundColor: accent.withValues(alpha: 0.12),
              foregroundColor: accent,
              padding: EdgeInsets.symmetric(horizontal: context.w(12), vertical: context.h(6)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(20))),
            ),
            icon: Icon(Icons.refresh_rounded, size: context.w(16)),
            label: Text(
              AppStrings.updateLocation,
              style: AppTypography.regular.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
