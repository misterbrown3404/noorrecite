import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// One destination in the [FloatingNavDock].
class NavDockItem {
  const NavDockItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The floating glass bottom navigation dock from DESIGN.md ("Navigation Bar").
///
/// A frosted, pill-shaped dock hovering above the screen edge; the active
/// destination gets an emerald under-light glow. The standard destination set
/// across the mockups is Home · Quran · Audio · Saved · Profile.
class FloatingNavDock extends StatelessWidget {
  const FloatingNavDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavDockItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  /// Default 5-tab destination set used by the main shell.
  static const List<NavDockItem> mainTabs = [
    NavDockItem(icon: Icons.home_outlined, label: 'Home'),
    NavDockItem(icon: Icons.menu_book_outlined, label: 'Quran'),
    NavDockItem(icon: Icons.headphones_outlined, label: 'Audio'),
    NavDockItem(icon: Icons.bookmark_border_rounded, label: 'Saved'),
    NavDockItem(icon: Icons.download_outlined, label: 'Downloads'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        child: ClipRRect(
          borderRadius: AppRadii.pillRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest.withValues(alpha: 0.72),
                borderRadius: AppRadii.pillRadius,
                border: Border.all(color: AppColors.glassStroke),
                // Emerald-tinted dock shadow per DESIGN.md (rgba(0,106,57,0.15)).
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var i = 0; i < items.length; i++)
                    _DockButton(
                      item: items[i],
                      active: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final NavDockItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.outline;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillRadius,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: active
                  ? BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: AppShadows.primaryGlow(opacity: 0.35),
                    )
                  : null,
              child: Icon(item.icon, size: 24, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: AppTypography.labelCaps.copyWith(
                color: color,
                letterSpacing: 0,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
