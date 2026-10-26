import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The recurring "QariVerse" top bar used across most screens: a leading menu
/// icon, the gradient wordmark, and trailing actions (search, avatar).
///
/// Not a real [AppBar] — it's a plain row so it can sit inside the scrollable
/// glass layouts without Material's elevation/scrim behavior.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.showMenu = true,
    this.actions = const [],
    this.onMenu,
  });

  final bool showMenu;
  final List<Widget> actions;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.margin,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          if (showMenu)
            IconButton(
              onPressed: onMenu,
              icon: const Icon(LucideIcons.menu),
              color: AppColors.primary,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          if (showMenu) const SizedBox(width: AppSpacing.md),
          Text(
            'QariVerse',
            style: AppTypography.titleLg.copyWith(color: AppColors.primary),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}

/// A circular emerald icon button for header actions (search etc.).
class HeaderIconAction extends StatelessWidget {
  const HeaderIconAction({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon),
      color: AppColors.primary,
    );
  }
}
