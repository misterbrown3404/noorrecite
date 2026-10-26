import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Bi-scriptual typography from DESIGN.md.
///
/// - **Amiri** — classical Arabic (Quran + Arabic UI). Needs generous line
///   height (≥1.8×) for Tashkeel.
/// - **Inter** — expressive headings and clear interface labels.
/// - **Inter** — clean body copy and interface labels.
///
/// Fonts are **bundled locally** in `assets/google_fonts/` (offline-first) and
/// matched by filename via `google_fonts`; runtime HTTP fetching is disabled in
/// `main()`. Per project_rule.md §9.2, a licensed Uthmani-script font must be
/// verified before shipping — Amiri is the dev/preview stand-in.
abstract final class AppTypography {
  /// Large Arabic display (e.g. Daily Ayah hero). Amiri 700.
  static TextStyle displayAr = GoogleFonts.amiri(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 72 / 48, // 1.5× — DESIGN.md display line height
    color: AppColors.onSurface,
  );

  /// Body-scale Arabic (ayah text in reader/cards). Amiri 400, 2× line height.
  static TextStyle bodyAr = GoogleFonts.amiri(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 48 / 24, // 2× to accommodate diacritics
    color: AppColors.onSurface,
  );

  /// Editorial heading, desktop/large. Literata 700.
  static TextStyle headlineLg = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    color: AppColors.onSurface,
  );

  /// Editorial heading, mobile. Literata 700.
  static TextStyle headlineLgMobile = GoogleFonts.inter(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 34 / 26,
    color: AppColors.onSurface,
  );

  /// Section title (Literata 700, mid scale).
  static TextStyle titleLg = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
    color: AppColors.onSurface,
  );

  /// Latin body copy. Inter 400.
  static TextStyle bodyEn = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 26 / 16,
    color: AppColors.onSurface,
  );

  /// Smaller supporting body / captions.
  static TextStyle bodyEnSm = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AppColors.onSurfaceVariant,
  );

  /// Semibold button / emphasis label. Inter 600.
  static TextStyle labelSemibold = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 20 / 16,
    color: AppColors.onSurface,
  );

  /// Uppercase overline label (e.g. "NEXT PRAYER", "CONTINUE LISTENING").
  static TextStyle labelCaps = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: 0.05 * 12, // 0.05em
    color: AppColors.onSurfaceVariant,
  );

  /// Builds a Material [TextTheme] from the Inter/Literata families so stock
  /// Material widgets inherit sensible defaults.
  static TextTheme textTheme() {
    final base = GoogleFonts.interTextTheme();
    return base.copyWith(
      displayLarge: headlineLg,
      headlineLarge: headlineLgMobile,
      titleLarge: titleLg,
      bodyLarge: bodyEn,
      bodyMedium: bodyEnSm,
      labelLarge: labelSemibold,
      labelSmall: labelCaps,
    );
  }
}
