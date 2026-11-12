import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Semantic, theme-aware colors. Read them with `context.torkk`.
///
/// Brand and status colors (blue, pink, green, amber, red) stay in
/// [AppColors]; this holds only the colors that must flip with the theme.
@immutable
class TorkkColors extends ThemeExtension<TorkkColors> {
  const TorkkColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textBody,
    required this.textSecondary,
    required this.textDisabled,
    required this.inputFill,
    required this.switchTrackOff,
    required this.accent,
    required this.onAccent,
    required this.statusOnline,
    required this.statusOffline,
    required this.isDark,
  });

  /// Screen background.
  final Color background;

  /// Cards, sheets, dialogs and other raised containers.
  final Color surface;

  /// Subtle fills inside a surface (chips, tiles, nested panels).
  final Color surfaceMuted;
  final Color border;
  final Color divider;
  final Color textPrimary;

  /// Body copy one step softer than [textPrimary].
  final Color textBody;
  final Color textSecondary;
  final Color textDisabled;
  final Color inputFill;

  /// Switch track when off (the thumb is white in light mode).
  final Color switchTrackOff;

  /// Primary action color and the color drawn on top of it.
  final Color accent;
  final Color onAccent;

  /// Online / offline status colors. Dark mode uses softer, dimmer shades so
  /// the status card does not glare against the dark surface.
  final Color statusOnline;
  final Color statusOffline;
  final bool isDark;

  /// Solid button fill in dark mode: brand blue, or brand pink when the
  /// pink (female) theme is active. Labels and icons on it are white.
  Color get buttonFill => isPink ? AppColors.femalePink : AppColors.maleBlue;

  /// True when the pink (female) theme is active, in light or dark mode.
  bool get isPink =>
      accent == darkPinkAccent || accent == AppColors.femalePink;

  /// Fill for a primary call-to-action. Light mode keeps [lightFill] (the
  /// button's own brand color); dark mode uses [buttonFill] (blue / pink).
  Color actionFill(Color lightFill) => isDark ? buttonFill : lightFill;


  /// Matches the colors the app used before dark mode was themed.
  static const light = TorkkColors(
    background: Colors.white,
    surface: Colors.white,
    surfaceMuted: AppColors.slate50,
    border: AppColors.slate200,
    divider: AppColors.slate100,
    textPrimary: AppColors.textPrimary,
    textBody: AppColors.slate600,
    textSecondary: AppColors.slate500,
    textDisabled: AppColors.slate300,
    inputFill: AppColors.slate100,
    switchTrackOff: AppColors.gray200,
    accent: AppColors.maleBlue,
    onAccent: Colors.white,
    statusOnline: Color(0xFF22C55E),
    statusOffline: Color(0xFFEF4444),
    isDark: false,
  );

  static const dark = TorkkColors(
    background: Color(0xFF101114),
    surface: Color(0xFF202126),
    surfaceMuted: Color(0xFF2A2B31),
    border: Color(0xFF34353C),
    divider: Color(0xFF2C2D33),
    textPrimary: Color(0xFFF4F2E8),
    textBody: Color(0xFFD2D2D8),
    textSecondary: Color(0xFFA3A4AD),
    textDisabled: Color(0xFF5C5D66),
    inputFill: Color(0xFF202126),
    switchTrackOff: Color(0xFF3A3B42),
    accent: Color(0xFFEEEBDA),
    onAccent: Color(0xFF282B4A),
    statusOnline: Color(0xFF4E9F73),
    statusOffline: Color(0xFFC46A6D),
    isDark: true,
  );

  /// Dark-mode pink accent, lightened so it stays readable on [dark].
  static const darkPinkAccent = Color(0xFFF08FC4);

  @override
  TorkkColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceMuted,
    Color? border,
    Color? divider,
    Color? textPrimary,
    Color? textBody,
    Color? textSecondary,
    Color? textDisabled,
    Color? inputFill,
    Color? switchTrackOff,
    Color? accent,
    Color? onAccent,
    Color? statusOnline,
    Color? statusOffline,
    bool? isDark,
  }) {
    return TorkkColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceMuted: surfaceMuted ?? this.surfaceMuted,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textBody: textBody ?? this.textBody,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      inputFill: inputFill ?? this.inputFill,
      switchTrackOff: switchTrackOff ?? this.switchTrackOff,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      statusOnline: statusOnline ?? this.statusOnline,
      statusOffline: statusOffline ?? this.statusOffline,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  TorkkColors lerp(ThemeExtension<TorkkColors>? other, double t) {
    if (other is! TorkkColors) return this;
    return TorkkColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      switchTrackOff: Color.lerp(switchTrackOff, other.switchTrackOff, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      statusOnline: Color.lerp(statusOnline, other.statusOnline, t)!,
      statusOffline: Color.lerp(statusOffline, other.statusOffline, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension TorkkColorsContext on BuildContext {
  /// Theme-aware semantic colors. Falls back to light if the theme has none
  /// (for example a bare `MaterialApp` in a widget test).
  TorkkColors get torkk =>
      Theme.of(this).extension<TorkkColors>() ?? TorkkColors.light;

  bool get isDarkTheme => torkk.isDark;

  /// Gender brand color for buttons: blue (male) or pink (female), in both
  /// light and dark mode. Use this for every solid button fill.
  Color get brandColor => torkk.buttonFill;

  /// Lighter, softer tint of [brandColor] for icon chips and soft backgrounds.
  Color get brandTint => brandColor.withValues(alpha: 0.12);

  /// A color that differs by mode. Prefer a semantic [torkk] token; use this
  /// only when light mode needs a specific value the tokens do not hold.
  Color themed({required Color light, required Color dark}) =>
      isDarkTheme ? dark : light;

  /// A pastel highlight (for example a selected tile). Light mode keeps
  /// [lightTint] as designed; dark mode shows it as a faint tint over the
  /// surface so theme-colored text on top stays readable.
  Color adaptiveTint(Color lightTint) {
    final colors = torkk;
    return isDarkTheme
        ? Color.alphaBlend(lightTint.withValues(alpha: 0.1), colors.surface)
        : lightTint;
  }
}

/// Keeps a fixed brand color readable as text, an icon or a border.
///
/// Light mode returns [color] untouched. Dark mode lightens it just enough to
/// reach [minContrast] against the dark surface, so deep purples and navies
/// stay recognisable instead of disappearing.
extension TorkkLegibleColor on BuildContext {
  Color legible(Color color, {double minContrast = 4.5}) {
    final colors = torkk;
    if (!colors.isDark) return color;
    final bg = colors.surface.computeLuminance() + 0.05;
    var result = color;
    for (var i = 0; i < 30; i++) {
      if ((result.computeLuminance() + 0.05) / bg >= minContrast) break;
      result = Color.lerp(result, Colors.white, 0.15)!;
    }
    return result;
  }
}

/// A readable label/icon color for a fixed [background], picked by contrast.
///
/// Use it for brand or status fills that do not come from the theme, because
/// the theme's own `onPrimary` is dark in dark mode and would not suit them.
Color onColorFor(Color background) {
  const dark = Color(0xFF111827);
  final bg = background.computeLuminance() + 0.05;
  final whiteContrast = 1.05 / bg;
  final darkContrast = bg / (dark.computeLuminance() + 0.05);
  return whiteContrast >= darkContrast ? Colors.white : dark;
}
