import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:rider_app/common/constants/app_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

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
    final size = context.w(40);
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
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0x33FFFFFF),
                border: Border.all(
                  color: const Color(0xFFF1F5F9),
                  width: context.w(1.07),
                ),
              ),
              child: asset != null
                  ? Image.asset(
                      asset!,
                      width: context.w(20),
                      height: context.w(20),
                      fit: BoxFit.contain,
                    )
                  : Icon(
                      icon,
                      size: context.w(20),
                      color: AppColors.textPrimary,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
