import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'torkk_colors.dart';
import 'torkk_theme.dart';

/// Dark mode: #101114 background, #202126 surface. Buttons and other solid
/// primary fills are brand blue (or pink) with white content; the lighter
/// cream / light-pink accent is kept for text and outlines on dark surfaces.
ThemeData buildTorkkDarkTheme({required bool isPink}) {
  const base = TorkkColors.dark;
  final accent = isPink ? TorkkColors.darkPinkAccent : base.accent;
  final colors = base.copyWith(accent: accent);
  return buildTorkkTheme(
    scheme: ColorScheme.dark(
      primary: colors.buttonFill,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      surface: base.surface,
      onSurface: base.textPrimary,
      error: AppColors.error,
    ),
    colors: colors,
  );
}
