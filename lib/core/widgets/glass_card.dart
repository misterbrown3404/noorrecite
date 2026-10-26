import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';

/// Level-1 floating glass panel from DESIGN.md ("Luminous Layering").
///
/// A frosted, high-blur surface with a 1px inner "light leak" stroke on the
/// top/left edges to simulate physical thickness, sitting above a soft drop
/// shadow. This is the workhorse container for cards across the app.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardInsets,
    this.borderRadius = AppRadii.cardRadius,
    this.blur = 0,
    this.fillColor,
    this.showLightLeak = true,
    this.shadows,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  /// Backdrop blur sigma. DESIGN.md specifies ~20px for glass panels.
  final double blur;

  /// Panel fill. Defaults to the semi-opaque lowest surface for legibility.
  final Color? fillColor;

  /// Whether to draw the top/left inner light-leak stroke.
  final bool showLightLeak;

  final List<BoxShadow>? shadows;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final panel = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: shadows ?? AppShadows.card,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              // DESIGN.md glass panels sit at ~40–70% fill so the frosted blur
              // reads through; 0.55 keeps text legible without going opaque.
              color:
                  fillColor ??
                  Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: borderRadius,
              border: Border.all(
                color: showLightLeak
                    ? Theme.of(
                        context,
                      ).colorScheme.outlineVariant.withValues(alpha: 0.25)
                    : Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) return panel;
    return PressableScale(onTap: onTap, child: panel);
  }
}
