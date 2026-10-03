import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData getTheme({required bool isPink, bool isDark = false}) {
    final primaryColor = isPink ? AppColors.femalePink : AppColors.maleBlue;
    final bgColor = isDark ? AppColors.backgroundDark : Colors.white;
    final surfaceColor = isDark ? AppColors.surfaceDark : AppColors.slate50;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: bgColor,
      fontFamily: AppTypography.fontFamily,
      colorScheme: isDark
          ? ColorScheme.dark(
              primary: primaryColor,
              secondary: AppColors.secondary,
              surface: surfaceColor,
              error: AppColors.error,
            )
          : ColorScheme.light(
              primary: primaryColor,
              secondary: AppColors.secondary,
              surface: Colors.white,
              error: AppColors.error,
            ),
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: AppTypography.textTheme(textColor: textColor, isDark: isDark),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.slate700 : AppColors.slate100,
        labelStyle: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.blueGrey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppTypography.fontFamily),
        ),
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
        ),
      ),
    );
  }
}
