import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// A section header row with a Literata title and an optional trailing action
/// (e.g. "VIEW ALL", a filter icon), as seen above "Popular Reciters",
/// "My Bookmarks", and "Downloaded by Reciter" in the mockups.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.trailing,
  });

  final String title;
  final String? subtitle;

  /// Text action rendered in emerald (e.g. "VIEW ALL"). Ignored if [trailing]
  /// is supplied.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Custom trailing widget (e.g. a filter/sort icon) overriding [actionLabel].
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleLg),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: AppTypography.bodyEnSm),
              ],
            ],
          ),
        ),
        if (trailing != null)
          trailing!
        else if (actionLabel != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: AppTypography.labelCaps.copyWith(
                color: AppColors.primary,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}
