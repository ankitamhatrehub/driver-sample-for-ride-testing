/// Reusable spacing, border radius, and sizing constants.
///
/// Keeps UI dimensions consistent and makes future design-system
/// changes a single-file update.
class AppDimensions {
  AppDimensions._();

  // ── Spacing (Padding / Margin) ─────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // ── Border Radius ──────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusFull = 100.0; // Pill / Circle

  // ── Icon Sizes ─────────────────────────────────────────────────
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 28.0;
  static const double iconXxl = 36.0;

  // ── Avatar Sizes ──────────────────────────────────────────────
  static const double avatarSm = 32.0;
  static const double avatarMd = 44.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 80.0;
  static const double avatarXxl = 110.0;

  // ── Button Heights ────────────────────────────────────────────
  static const double buttonHeight = 50.0;
  static const double buttonHeightSm = 40.0;

  // ── Card Elevation ────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;
}
