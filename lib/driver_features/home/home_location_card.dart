import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/common/constants/app_colors.dart';

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
    final dark = context.isDarkTheme;
    // Dark mode: the map stays light, so use dark content and the gender
    // brand color (blue / pink) instead of the cream theme accent.
    final brand = context.watch<ThemeBloc>().state.isPink
        ? AppColors.femalePink
        : AppColors.maleBlue;
    final tint = dark ? brand : accent;
    final titleColor = dark
        ? const Color(0xFF475569)
        : context.torkk.textSecondary;
    final placeColor = dark ? const Color(0xFF0F172A) : null;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.w(14),
        vertical: context.h(10),
      ),
      decoration: BoxDecoration(
        // Dark mode: light brand-tinted fill, map only faintly visible.
        color: dark
            ? Color.alphaBlend(
                brand.withValues(alpha: 0.14),
                Colors.white.withValues(alpha: 0.82),
              )
            : context.torkk.surface,
        borderRadius: BorderRadius.circular(context.r(16)),
        border: dark
            ? Border.all(color: brand.withValues(alpha: 0.9), width: 2)
            : null,
        boxShadow: context.isDarkTheme
            ? null
            : const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_on_rounded, color: tint, size: context.w(22)),
          SizedBox(width: context.w(8)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.currentLocation,
                  style: AppTypography.regular.copyWith(
                    fontSize: 11,
                    color: titleColor,
                  ),
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
                      color: placeColor,
                    ),
                  ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onUpdateLocation,
            style: TextButton.styleFrom(
              backgroundColor: tint.withValues(alpha: 0.12),
              foregroundColor: tint,
              padding: EdgeInsets.symmetric(
                horizontal: context.w(12),
                vertical: context.h(6),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(context.r(20)),
              ),
            ),
            icon: Icon(Icons.refresh_rounded, size: context.w(16)),
            label: Text(
              AppStrings.updateLocation,
              style: AppTypography.regular.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: tint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
