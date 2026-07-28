import 'package:flutter/material.dart';

/// QariVerse color tokens.
///
/// Ported verbatim from the design system spec
/// (`assets/stitch_qariverse_ai_quran_experience/qariverse/DESIGN.md`), which
/// uses a Material-3 token set rooted in the "Emerald Sanctum" scheme.
///
/// Note: this palette (primary `#006a39`) is the authoritative visual source
/// and deliberately differs from project_rule.md §9.1 (`#0F5C4A`). The Stitch
/// mockups are what we build to.
abstract final class AppColors {
  // --- Primary (Emerald) — main actions, active states ---------------------
  static const primary = Color(0xFF006A39);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF008649);
  static const onPrimaryContainer = Color(0xFFF6FFF4);
  static const inversePrimary = Color(0xFF64DD91);
  static const surfaceTint = Color(0xFF006D3A);

  static const primaryFixed = Color(0xFF82FAAB);
  static const primaryFixedDim = Color(0xFF64DD91);
  static const onPrimaryFixed = Color(0xFF00210E);
  static const onPrimaryFixedVariant = Color(0xFF00522B);

  // --- Secondary (Deep Teal) — headers, structural containers --------------
  static const secondary = Color(0xFF006B5F);
  static const onSecondary = Color(0xFFFFFFFF);
  static const secondaryContainer = Color(0xFF8DF5E4);
  static const onSecondaryContainer = Color(0xFF007165);

  static const secondaryFixed = Color(0xFF8DF5E4);
  static const secondaryFixedDim = Color(0xFF70D8C8);
  static const onSecondaryFixed = Color(0xFF00201C);
  static const onSecondaryFixedVariant = Color(0xFF005048);

  // --- Tertiary (Gold) — verse markers, premium, sparing highlights --------
  static const tertiary = Color(0xFF805200);
  static const onTertiary = Color(0xFFFFFFFF);
  static const tertiaryContainer = Color(0xFFA16800);
  static const onTertiaryContainer = Color(0xFFFFFBFF);

  static const tertiaryFixed = Color(0xFFFFDDB5);
  static const tertiaryFixedDim = Color(0xFFFFB957);
  static const onTertiaryFixed = Color(0xFF2A1800);
  static const onTertiaryFixedVariant = Color(0xFF643F00);

  // --- Error ---------------------------------------------------------------
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  // --- Surfaces / background -----------------------------------------------
  static const background = Color(0xFFF7F9FB);
  static const onBackground = Color(0xFF191C1E);

  static const surface = Color(0xFFF7F9FB);
  static const surfaceDim = Color(0xFFD8DADC);
  static const surfaceBright = Color(0xFFF7F9FB);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F6);
  static const surfaceContainer = Color(0xFFECEEF0);
  static const surfaceContainerHigh = Color(0xFFE6E8EA);
  static const surfaceContainerHighest = Color(0xFFE0E3E5);
  static const surfaceVariant = Color(0xFFE0E3E5);

  static const onSurface = Color(0xFF191C1E);
  static const onSurfaceVariant = Color(0xFF3E4A3F);
  static const inverseSurface = Color(0xFF2D3133);
  static const inverseOnSurface = Color(0xFFEFF1F3);

  static const outline = Color(0xFF6D7A6F);
  static const outlineVariant = Color(0xFFBDCABC);

  // --- Gradients & glass (DESIGN.md "Luminous Layering") -------------------

  /// Soft off-white → pale mint background wash for light mode.
  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF7F9FB), Color(0xFFEAF4EE)],
  );

  /// Lush emerald gradient for primary buttons and the play/pause control.
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF008649), Color(0xFF006A39)],
  );

  /// Deep-teal → emerald, used for the most tactile audio controls.
  static const tealEmeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006B5F), Color(0xFF006A39)],
  );

  /// Gold gradient for premium badges / "Elite" surfaces.
  static const goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA16800), Color(0xFF805200)],
  );

  /// Fill for glass panels in light mode (15% white per DESIGN.md).
  static const glassFill = Color(0x26FFFFFF); // white @ ~15%

  /// 1px inner "light leak" stroke on the top/left edges of floating cards.
  static const glassStroke = Color(0x33FFFFFF); // white @ 20%
}
