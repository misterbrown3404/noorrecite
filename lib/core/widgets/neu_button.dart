import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';

/// Level-2 neumorphic "soft-extrusion" button (DESIGN.md). A circular or
/// rounded control that appears pushed out of the glass surface via paired
/// dark + light shadows. Used for the secondary transport controls (prev/next,
/// shuffle, repeat) and small icon actions in the mockups.
class NeuIconButton extends StatelessWidget {
  const NeuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 56,
    this.iconSize = 24,
    this.iconColor = AppColors.primary,
    this.backgroundColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.surfaceContainerLowest,
          shape: BoxShape.circle,
          boxShadow: AppShadows.neumorphic,
        ),
        child: Icon(icon, size: iconSize, color: iconColor),
      ),
    );
  }
}

/// A concave (inset) neumorphic surface for search fields, per DESIGN.md's
/// "Input Fields" note — softly pressed into the background.
class NeuInsetField extends StatelessWidget {
  const NeuInsetField({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: 14,
    ),
    this.borderRadius = AppRadii.controlRadius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: borderRadius,
        boxShadow: AppShadows.inset,
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }
}
