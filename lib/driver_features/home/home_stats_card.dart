import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rider_app/app/theme/theme_bloc.dart';
import 'package:rider_app/common/constants/app_colors.dart';

import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HomeStatsCard extends StatelessWidget {
  const HomeStatsCard({
    super.key,
    required this.todayEarnings,
    required this.completedJobs,
    required this.onEarnings,

    required this.accent,
  });

  final double todayEarnings;
  final int completedJobs;
  final VoidCallback onEarnings;

  final Color accent;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkTheme;
    // Dark mode: gender brand color (blue / pink) instead of the cream accent.
    final brand = context.watch<ThemeBloc>().state.isPink
        ? AppColors.femalePink
        : AppColors.maleBlue;
    final icon = dark ? context.legible(brand, minContrast: 3) : accent;
    return Container(
      height: context.h(196),
      padding: EdgeInsets.all(context.w(16)),
      decoration: BoxDecoration(
        color: dark ? null : const Color(0x0D57278D),
        gradient: dark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [brand.withValues(alpha: 0.45), context.torkk.surface],
              )
            : null,
        borderRadius: BorderRadius.circular(context.r(dark ? 16 : 12)),
        border: Border.all(
          color: dark ? brand.withValues(alpha: 0.7) : const Color(0x3640105F),
          width: dark ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: dark
                ? brand.withValues(alpha: 0.28)
                : const Color(0x0A000000),
            offset: dark ? const Offset(0, 4) : const Offset(0, 1),
            blurRadius: dark ? 18 : 3.3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onEarnings,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.todayEarnings,
                        style: AppTypography.regular.copyWith(
                          fontSize: 11,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        _rupees(todayEarnings),
                        style: AppTypography.bold.copyWith(
                          fontSize: 26,
                          height: 1.15,
                          letterSpacing: -0.6,
                        ),
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        completedJobs == 1 ? '1 ride' : '$completedJobs rides',
                        style: AppTypography.regular.copyWith(
                          fontSize: 14,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: context.w(36),
                  height: context.w(36),
                  decoration: BoxDecoration(
                    color: dark
                        ? brand.withValues(alpha: 0.25)
                        : context.torkk.surface,
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  child: Icon(
                    Icons.show_chart_rounded,
                    color: icon,
                    size: context.w(18),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            constraints: BoxConstraints(minHeight: context.h(55)),
            padding: EdgeInsets.symmetric(
              horizontal: context.w(10),
              vertical: context.h(6),
            ),
            decoration: BoxDecoration(
              color: dark
                  ? Colors.black.withValues(alpha: 0.28)
                  : context.torkk.surface.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(context.r(12)),
              border: Border.all(
                color: dark
                    ? brand.withValues(alpha: 0.35)
                    : context.torkk.border,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.todayCompletedJobs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.regular.copyWith(
                          fontSize: 12,
                          height: 1.1,
                          color: context.torkk.textSecondary,
                        ),
                      ),
                      Text(
                        '$completedJobs',
                        style: AppTypography.bold.copyWith(
                          fontSize: 16,
                          height: 1.1,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.directions_car_filled_rounded,
                  color: icon,
                  size: context.w(18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _rupees(double amount) {
    final digits = amount.round().abs().toString();
    if (digits.length <= 3) return '₹$digits';
    final tail = digits.substring(digits.length - 3);
    var head = digits.substring(0, digits.length - 3);
    final parts = <String>[];
    while (head.length > 2) {
      parts.insert(0, head.substring(head.length - 2));
      head = head.substring(0, head.length - 2);
    }
    if (head.isNotEmpty) parts.insert(0, head);
    return '₹${parts.join(',')},$tail';
  }
}
