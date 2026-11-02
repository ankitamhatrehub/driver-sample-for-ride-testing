import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rider_app/common/theme/torkk_colors.dart';
import 'package:rider_app/common/utils/screen_utils.dart';

/// Frosted-glass card for the home sheet: a translucent [tint] wash over a
/// blurred backdrop, a soft edge highlight and a light shadow.
class HomeGlassCard extends StatelessWidget {
  const HomeGlassCard({
    super.key,
    required this.tint,
    required this.child,
    this.radius = 20,
    this.padding,
  });

  final Color tint;
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDarkTheme;
    final shape = BorderRadius.circular(context.r(radius));
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: dark
                ? Colors.black.withValues(alpha: 0.25)
                : tint.withValues(alpha: 0.10),
            offset: const Offset(0, 4),
            blurRadius: 14,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: shape,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: dark ? 0.26 : 0.16),
                  tint.withValues(alpha: dark ? 0.08 : 0.05),
                ],
              ),
              border: Border.all(
                color: dark
                    ? Colors.white.withValues(alpha: 0.16)
                    : tint.withValues(alpha: 0.28),
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
