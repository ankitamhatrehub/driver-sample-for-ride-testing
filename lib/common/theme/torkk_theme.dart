import 'package:flutter/material.dart';

import 'app_typography.dart';
import 'torkk_colors.dart';

/// Builds the app theme from a color scheme and its [TorkkColors].
///
/// Light mode keeps exactly the component styling the app shipped with.
/// Dark mode adds the extra component themes (dialogs, sheets, switches,
/// checkboxes, ...) that Material's light defaults do not cover.
ThemeData buildTorkkTheme({
  required ColorScheme scheme,
  required TorkkColors colors,
}) {
  final isDark = scheme.brightness == Brightness.dark;
  final primary = scheme.primary;

  OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
  final fieldBorder = isDark ? Colors.white24 : Colors.black12;

  final base = ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    fontFamily: AppTypography.fontFamily,
    scaffoldBackgroundColor: colors.background,
    extensions: [colors],
    textTheme: AppTypography.textTheme(colors),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      iconTheme: IconThemeData(color: colors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.inputFill,
      labelStyle: TextStyle(
        color: isDark ? colors.textSecondary : Colors.blueGrey.shade600,
      ),
      border: inputBorder(fieldBorder),
      enabledBorder: inputBorder(fieldBorder),
      focusedBorder: inputBorder(primary, 2),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: AppTypography.fontFamily,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? colors.surface : colors.surfaceMuted,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white12 : Colors.black12),
      ),
    ),
  );

  if (!isDark) return base;
  return base.copyWith(
    canvasColor: colors.background,
    dividerColor: colors.divider,
    disabledColor: colors.textDisabled,
    iconTheme: IconThemeData(color: colors.textPrimary),
    primaryIconTheme: IconThemeData(color: scheme.onPrimary),
    appBarTheme: base.appBarTheme.copyWith(
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: base.inputDecorationTheme.copyWith(
      hintStyle: TextStyle(color: colors.textSecondary),
      prefixIconColor: colors.textSecondary,
      suffixIconColor: colors.textSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: base.elevatedButtonTheme.style!.copyWith(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colors.surfaceMuted
              : primary,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.disabled)
              ? colors.textDisabled
              : scheme.onPrimary,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: scheme.onPrimary,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.textPrimary,
        side: BorderSide(color: colors.border),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AppTypography.bold.copyWith(color: colors.textPrimary),
      contentTextStyle: AppTypography.regular.copyWith(
        color: colors.textSecondary,
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colors.surface,
      modalBackgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: primary,
      unselectedItemColor: colors.textSecondary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: DividerThemeData(color: colors.divider, thickness: 1),
    listTileTheme: ListTileThemeData(
      iconColor: colors.textSecondary,
      textColor: colors.textPrimary,
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colors.surfaceMuted,
      side: BorderSide(color: colors.border),
      labelStyle: TextStyle(color: colors.textPrimary),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colors.surfaceMuted,
      contentTextStyle: TextStyle(
        color: colors.textPrimary,
        fontFamily: AppTypography.fontFamily,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: colors.surfaceMuted,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? scheme.onPrimary
            : colors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primary
            : colors.switchTrackOff,
      ),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStatePropertyAll(scheme.onPrimary),
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primary
            : Colors.transparent,
      ),
      side: BorderSide(color: colors.textSecondary, width: 1.5),
    ),
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? primary
            : colors.textSecondary,
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionHandleColor: primary,
      selectionColor: primary.withValues(alpha: 0.3),
    ),
  );
}
