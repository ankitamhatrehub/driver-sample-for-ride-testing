import 'package:flutter/material.dart';

import 'torkk_colors.dart';

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
  );

  /// Inter Regular, 14px, line-height 20, letter-spacing 0.
  static const TextStyle regular = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0,
  );

  static TextStyle caption({Color? color}) {
    return regular.copyWith(color: color);
  }

  /// Text colors come from the theme, so [bold] and [regular] (which carry no
  /// color of their own) follow light/dark automatically.
  static TextTheme textTheme(TorkkColors colors) {
    return TextTheme(
      titleLarge: bold.copyWith(color: colors.textPrimary),
      bodyLarge: regular.copyWith(fontSize: 16, color: colors.textPrimary),
      bodyMedium: regular.copyWith(color: colors.textPrimary),
    );
  }
}
