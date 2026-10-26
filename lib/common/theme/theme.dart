import 'package:flutter/material.dart';

import 'torkk_dark_theme.dart';
import 'torkk_light_theme.dart';

/// Entry point used by `DriverApp`. See `torkk_theme.dart` for shared styling
/// and `torkk_light_theme.dart` / `torkk_dark_theme.dart` for each palette.
class AppTheme {
  AppTheme._();

  static ThemeData getTheme({required bool isPink, bool isDark = false}) {
    return isDark
        ? buildTorkkDarkTheme(isPink: isPink)
        : buildTorkkLightTheme(isPink: isPink);
  }
}
