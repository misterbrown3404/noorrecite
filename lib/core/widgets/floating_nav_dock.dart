import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavDockItem {
  const NavDockItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

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
  static const mainTabs = [
    NavDockItem(icon: LucideIcons.house, label: 'Home'),
    NavDockItem(icon: LucideIcons.bookOpen, label: 'Quran'),
    NavDockItem(icon: LucideIcons.audioLines, label: 'Listen'),
    NavDockItem(icon: LucideIcons.library, label: 'Saved'),
    NavDockItem(icon: LucideIcons.download, label: 'Offline'),
  ];
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: .3),
            ),
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: .12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: Semantics(
                      selected: i == currentIndex,
                      button: true,
                      label: items[i].label,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          if (i != currentIndex) {
                            HapticFeedback.selectionClick();
                          }
                          onTap(i);
                        },
                        child: AnimatedContainer(
                          duration: MediaQuery.disableAnimationsOf(context)
                              ? Duration.zero
                              : const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: i == currentIndex
                                ? colors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                items[i].icon,
                                color: i == currentIndex
                                    ? colors.onPrimary
                                    : colors.onSurfaceVariant,
                                size: 23,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                items[i].label,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: i == currentIndex
                                      ? colors.onPrimary
                                      : colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
