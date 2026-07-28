import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Elevation & depth tokens for DESIGN.md's "Luminous Layering" model.
///
/// - Level 1 (floating cards): soft drop shadow beneath a glass panel.
/// - Level 2 (interactive): neumorphic soft-extrusion — a dark shadow paired
///   with a light highlight shadow.
/// - Glows: primary buttons / active indicators get a soft emerald outer glow.
abstract final class AppShadows {
  /// Level 1 — floating glassmorphic card.
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // black @ ~8%
      blurRadius: 24,
      offset: Offset(0, 12),
      spreadRadius: -6,
    ),
  ];

  /// Level 2 — neumorphic soft-extrusion (element pushed out of the surface).
  static const List<BoxShadow> neumorphic = [
    BoxShadow(
      color: Color(0x1A000000), // dark shadow, rgba(0,0,0,0.1)
      blurRadius: 16,
      offset: Offset(6, 6),
      spreadRadius: -4,
    ),
    BoxShadow(
      color: Color(0x0DFFFFFF), // highlight, rgba(255,255,255,0.05)
      blurRadius: 16,
      offset: Offset(-6, -6),
      spreadRadius: -4,
    ),
  ];

  /// Concave / inset look for neumorphic input fields (search bar).
  static const List<BoxShadow> inset = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(2, 2),
      spreadRadius: -2,
    ),
  ];

  /// Soft outer glow in primary emerald (DESIGN.md: blur 15, spread -2).
  static List<BoxShadow> primaryGlow({double opacity = 0.45}) => [
        BoxShadow(
          color: AppColors.primary.withValues(alpha: opacity),
          blurRadius: 15,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];

  /// Gold glow for premium / "Elite" surfaces.
  static List<BoxShadow> goldGlow({double opacity = 0.4}) => [
        BoxShadow(
          color: AppColors.tertiaryContainer.withValues(alpha: opacity),
          blurRadius: 15,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];
}
