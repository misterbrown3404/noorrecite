import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small pill-shaped tag/chip for Juz, topic, or Makki/Madani markers
/// (DESIGN.md "Chips/Tags"): a faint tint fill with `label-caps` typography.
class PillTag extends StatelessWidget {
  const PillTag({
    super.key,
    required this.label,
    this.foreground = AppColors.onSecondaryContainer,
    this.background,
    this.icon,
  });

  /// Emerald-tinted variant (default).
  const PillTag.emerald(String label, {Key? key})
      : this(key: key, label: label);

  /// Gold-tinted variant for premium / "Elite" markers.
  const PillTag.gold(String label, {Key? key})
      : this(
          key: key,
          label: label,
          foreground: AppColors.onTertiaryFixedVariant,
          background: AppColors.tertiaryFixed,
        );

  final String label;
  final Color foreground;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: background ?? AppColors.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
          child: Text(
            label.toUpperCase(),
            style: AppTypography.labelCaps.copyWith(color: foreground),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ],
      ),
    );
  }
}
