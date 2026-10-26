import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'torkk_colors.dart';
import 'torkk_theme.dart';

/// Dark mode: #101114 background, #202126 surface, cream accent.
ThemeData buildTorkkDarkTheme({required bool isPink}) {
  const base = TorkkColors.dark;
  final primary = isPink ? TorkkColors.darkPinkAccent : base.accent;
  return buildTorkkTheme(
    scheme: ColorScheme.dark(
      primary: primary,
      onPrimary: base.onAccent,
      secondary: AppColors.secondary,
      surface: base.surface,
      onSurface: base.textPrimary,
      error: AppColors.error,
    ),
    colors: base.copyWith(accent: primary),
  );
}
