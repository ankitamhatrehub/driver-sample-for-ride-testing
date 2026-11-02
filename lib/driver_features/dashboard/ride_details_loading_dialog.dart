import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/constants/string_constants.dart';
import 'package:rider_app/common/theme/app_typography.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

/// Centered card shown on the home screen while a ride's details are loading.
class RideDetailsLoadingOverlay extends StatelessWidget {
  const RideDetailsLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final female =
        Theme.of(context).colorScheme.primary == AppColors.femalePink;
    final colors = female
        ? const [Color(0xFFE85AAD), Color(0xFFBA2879), Color(0xFF6B1848)]
        : const [Color(0xFF0F3FBF), Color(0xFF7C3AED), Color(0xFF40105F)];

    return AbsorbPointer(
      child: Center(
        child: Container(
          width: context.w(230),
          padding: EdgeInsets.fromLTRB(
            context.w(20),
            context.h(28),
            context.w(20),
            context.h(22),
          ),
          decoration: BoxDecoration(
            color: context.torkk.surface,
            borderRadius: BorderRadius.circular(context.r(20)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                offset: Offset(0, 8),
                blurRadius: 24,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: context.w(48),
                height: context.w(48),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return SweepGradient(colors: colors).createShader(bounds);
                  },
                  child: const CircularProgressIndicator(
                    strokeWidth: 5,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: context.h(18)),
              Text(
                AppStrings.gettingRideDetails,
                textAlign: TextAlign.center,
                style: AppTypography.bold.copyWith(
                  fontSize: 16,
                  height: 1.3,
                  letterSpacing: -0.2,
                ),
              ),
              SizedBox(height: context.h(6)),
              Text(
                AppStrings.pleaseWait,
                textAlign: TextAlign.center,
                style: AppTypography.regular.copyWith(
                  fontSize: 13,
                  color: AppColors.slate400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
