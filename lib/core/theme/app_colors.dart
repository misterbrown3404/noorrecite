import 'package:flutter/material.dart';

/// Expressive QariVerse palette: violet actions, mint highlights, coral accents.
/// Shared tokens keep the reader, library, audio, and supporting screens aligned.
abstract final class AppColors {
  // --- Primary (Violet) — main actions, active states ---------------------
  static const primary = Color(0xFF5145CD);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF7162EB);
  static const onPrimaryContainer = Color(0xFFF6FFF4);
  static const inversePrimary = Color(0xFFC5BAFF);
  static const surfaceTint = Color(0xFF5145CD);

  static const primaryFixed = Color(0xFFE4DDFF);
  static const primaryFixedDim = Color(0xFFC5BAFF);
  static const onPrimaryFixed = Color(0xFF21174D);
  static const onPrimaryFixedVariant = Color(0xFF4937A1);

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
  static const background = Color(0xFFF7F6FC);
  static const onBackground = Color(0xFF25213E);

  static const surface = Color(0xFFF7F6FC);
  static const surfaceDim = Color(0xFFD8DADC);
  static const surfaceBright = Color(0xFFF7F6FC);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF0EDF9);
  static const surfaceContainer = Color(0xFFE9E5F5);
  static const surfaceContainerHigh = Color(0xFFE2DDEF);
  static const surfaceContainerHighest = Color(0xFFDAD5E9);
  static const surfaceVariant = Color(0xFFDAD5E9);

  static const onSurface = Color(0xFF25213E);
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
    colors: [Color(0xFFF7F6FC), Color(0xFFEDE9FC)],
  );

  /// Lush emerald gradient for primary buttons and the play/pause control.
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7162EB), Color(0xFF5145CD)],
  );

  /// Deep-teal → emerald, used for the most tactile audio controls.
  static const tealEmeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF006B5F), Color(0xFF5145CD)],
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
