import 'package:flutter/material.dart';

/// Centralized color palette for the Torkk Driver app.
///
/// Every color used across 3+ screens is defined here as a named constant.
/// Use these instead of inline `Color(0xFF...)` for consistency and easy theming.
class AppColors {
  AppColors._(); // Prevent instantiation

  // ── Primary Brand ──────────────────────────────────────────────
  static const Color primary = Color(0xFF40105F);       // Onboarding purple
  static const Color maleBlue = Color(0xFF0F3FBF);
  static const Color femalePink = Color(0xFFBA2879);
  static const Color primaryDark = Color(0xFF4F46E5);   // Indigo darker
  static const Color secondary = Color(0xFFEC4899);     // Pink
  static const Color accent = Color(0xFF10B981);        // Emerald Green
  static const Color error = Color(0xFFDA2527);         // ERROR RED
  static const Color secondaryTextColor = Color(0xFF64748B);     // SECONDARY TEXT COLOR

  // ── Primary Gradient (used in buttons, headers) ────────────────
  static const List<Color> primaryGradient = [primary, primaryDark];

  // ── Blues ───────────────────────────────────────────────────────
  static const Color blue700 = Color(0xFF1D4ED8);
  static const Color blue600 = Color(0xFF2563EB);
  static const Color blue900 = Color(0xFF1E3A8A);
  static const Color blueLight = Color(0xFFEFF6FF);

  // ── Greens ─────────────────────────────────────────────────────
  static const Color green500 = Color(0xFF22C55E);
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green800 = Color(0xFF166534);
  static const Color emerald500 = Color(0xFF10B981);
  static const Color teal600 = Color(0xFF059669);

  // ── Warnings / Amber ──────────────────────────────────────────
  static const Color amber500 = Color(0xFFF59E0B);
  static const Color amber600 = Color(0xFFD97706);
  static const Color amber700 = Color(0xFFB45309);
  static const Color yellow300 = Color(0xFFFDE047);
  static const Color amberLight = Color(0xFFFEF3C7);

  // ── Slate / Grays (Light Theme Text & Backgrounds) ────────────
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate50 = Color(0xFFF8FAFC);

  // ── Neutral Grays ─────────────────────────────────────────────
  static const Color gray900 = Color(0xFF111827);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color zinc800 = Color(0xFF27272A);

  // ── Dark Theme Backgrounds ────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);

  // ── Text Colors ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDark = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);

  // ── Deep Purple (Onboarding gradients) ────────────────────────
  static const Color onboardingHeader = Color(0xFFEFF6FD);
  static const Color fieldFill = Color(0xFFF8FAFC);
  static const Color fieldBorder = Color(0xFFE2E8F0);
  static const Color otpInfoFill = Color(0xFF57278D);
  static const Color otpInfoBorder = Color(0xFF40105F);
  static const Color snackBarBackground = Color(0xFFFFFFFF);
  static const Color buttonPurple = Color(0xFF4C1D95);
  static const Color deepPurple = Color(0xFF2E1065);
  static const Color royalBlue = Color(0xFF0F4CBA);
  static const Color navyBlue = Color(0xFF163E93);
}
