import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/driver_features/home/home_brand.dart';
import 'package:rider_app/common/utils/screen_utils.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';

class HomeGlassButton extends StatelessWidget {
  const HomeGlassButton({
    super.key,
    required this.onTap,
    this.icon,
    this.asset,
  });

  final VoidCallback onTap;
  final IconData? icon;
  final String? asset;

  @override
  Widget build(BuildContext context) {
    final size = context.w(32);
    final female =
        Theme.of(context).colorScheme.primary == AppColors.femalePink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color(0x0D000000),
              offset: Offset(0, 1.07),
              blurRadius: 2.14,
            ),
          ],
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: homeHelpButtonFill(female),
            border: Border.all(color: homeHelpButtonBorder, width: 1),
          ),
          child: asset != null
              ? Image.asset(
                  asset!,
                  width: context.w(17),
                  height: context.w(17),
                  fit: BoxFit.contain,
                  color: Colors.white,
                )
              : Icon(
                  icon,
                  size: context.w(17),
                  color: context.torkk.textPrimary,
                ),
        ),
      ),
    );
  }
}
