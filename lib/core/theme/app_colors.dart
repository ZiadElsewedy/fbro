import 'package:flutter/material.dart';

/// FBRO color system — minimal black & white with a single indigo accent.
///
/// Design language: Apple / Linear. Surfaces and text are strictly neutral
/// greys (no blue tint); the indigo [primary] is the ONLY chromatic color and
/// is reserved for primary actions, focus states, and key accents.
class AppColors {
  AppColors._();

  // ─── Accent ──────────────────────────────────────────────────────────────
  // Strictly monochrome: on the near-black UI the "accent" is white. Used for
  // focus states, links, and small highlights. Primary buttons use a solid
  // white fill (see AppButton) — there is no chromatic color anywhere.
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryLight = Color(0xFFE5E5EA);
  static const Color primaryDark = Color(0xFFC7C7CC);

  // Monochrome gradient (white → light grey) — used sparingly.
  static const Color gradientStart = Color(0xFFFFFFFF);
  static const Color gradientEnd = Color(0xFFE5E5EA);

  // ─── Dark theme — true neutral near-black ────────────────────────────────
  static const Color darkBg = Color(0xFF0A0A0B);
  static const Color darkSurface = Color(0xFF141416);
  static const Color darkSurfaceElevated = Color(0xFF1C1C20);
  static const Color darkBorder = Color(0xFF26262B);

  // ─── Light theme — clean neutral white ───────────────────────────────────
  static const Color lightBg = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF4F4F5);
  static const Color lightBorder = Color(0xFFEAEAEC);

  // ─── Text — neutral greys ────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF); // dark-mode heading
  static const Color textSecondary = Color(0xFF9A9AA2); // neutral grey
  static const Color textTertiary = Color(0xFF5C5C63);
  static const Color textDark = Color(0xFF0A0A0B); // light-mode heading
  static const Color textDarkSecondary = Color(0xFF5C5C63);

  // ─── Semantic (used sparingly, only for status) ──────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFF0D2E1A);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFF2E0D0D);
  static const Color warning = Color(0xFFF59E0B);

  // ─── Utility ─────────────────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Monochrome white→grey gradient (used sparingly).
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Very low-opacity neutral wash for subtle surfaces.
  static const LinearGradient subtleGradient = LinearGradient(
    colors: [Color(0x14FFFFFF), Color(0x08FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
