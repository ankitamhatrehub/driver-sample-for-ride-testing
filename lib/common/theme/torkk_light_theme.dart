import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'torkk_colors.dart';
import 'torkk_theme.dart';

/// Light mode. Keeps the colors the app shipped with.
ThemeData buildTorkkLightTheme({required bool isPink}) {
  final primary = isPink ? AppColors.femalePink : AppColors.maleBlue;
  const base = TorkkColors.light;
  return buildTorkkTheme(
    scheme: ColorScheme.light(
      primary: primary,
      secondary: AppColors.secondary,
      surface: base.surface,
      error: AppColors.error,
    ),
    colors: base.copyWith(accent: primary),
  );
}
