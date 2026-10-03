import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Two Inter bases, loaded from the font files in pubspec.
/// Change size, color, or weight with [TextStyle.copyWith].
///
/// Medium is `regular.copyWith(fontWeight: FontWeight.w500)`.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  /// Inter Bold, 20px, line-height 32, letter-spacing -0.6.
  static const TextStyle bold = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w700,
    fontSize: 20,
    height: 32 / 20,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  /// Inter Regular, 14px, line-height 20, letter-spacing 0.
  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0,
    color: AppColors.textPrimary,
  );

  static TextStyle caption({Color? color}) {
    return regular.copyWith(color: color);
  }

  static TextTheme textTheme({required Color textColor, required bool isDark}) {
    final bodyColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryColor = isDark ? Colors.white60 : Colors.black54;
    return TextTheme(
      titleLarge: bold.copyWith(color: textColor),
      bodyLarge: regular.copyWith(fontSize: 16, color: bodyColor),
      bodyMedium: regular.copyWith(color: secondaryColor),
    );
  }
}
