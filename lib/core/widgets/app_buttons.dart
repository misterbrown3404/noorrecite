import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'animations.dart';

/// Primary action button from DESIGN.md ("Components > Buttons"):
/// a lush emerald gradient pill with a soft emerald outer glow and an
/// Inter-Semibold white label. Optionally shows a trailing arrow, matching
/// the "GET STARTED →" / "Continue →" affordances in the mockups.
class GlowPrimaryButton extends StatelessWidget {
  const GlowPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.trailingIcon,
    this.gradient = AppColors.primaryGradient,
    this.expand = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final Gradient gradient;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            label,
            style: AppTypography.labelSemibold.copyWith(
              color: AppColors.onPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.sm),
          Icon(trailingIcon, color: AppColors.onPrimary, size: 20),
        ],
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: PressableScale(
        onTap: onPressed,
        child: Container(
          height: height,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: AppRadii.controlRadius,
            boxShadow: enabled ? AppShadows.primaryGlow() : null,
          ),
          child: content,
        ),
      ),
    );
  }
}

/// Secondary "ghost glass" button — a subtle translucent surface with a faint
/// gold border (DESIGN.md). Used for lower-emphasis actions like "Back".
class GhostGlassButton extends StatelessWidget {
  const GhostGlassButton({
    super.key,
    required this.label,
    this.onPressed,
    this.expand = true,
    this.height = 56,
    this.borderColor = AppColors.tertiaryFixedDim,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final double height;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onPressed,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest.withValues(alpha: 0.5),
          borderRadius: AppRadii.controlRadius,
          border: Border.all(color: borderColor.withValues(alpha: 0.6)),
        ),
        child: Text(label, style: AppTypography.labelSemibold),
      ),
    );
  }
}
