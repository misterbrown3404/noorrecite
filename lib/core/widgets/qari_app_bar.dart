import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';

/// Shared rounded header with clear hierarchy and accessible touch targets.
class QariAppBar extends StatelessWidget implements PreferredSizeWidget {
  const QariAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions = const [],
  });
  final String title, subtitle;
  final List<Widget> actions;
  @override
  Size get preferredSize => const Size.fromHeight(80);
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return AppBar(
      toolbarHeight: 80,
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: const RoundedRectangleBorder(),
      leadingWidth: 64,
      leading: Navigator.of(context).canPop()
          ? Padding(
              padding: const EdgeInsetsDirectional.only(start: 16),
              child: Center(
                child: IconButton.filledTonal(
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(LucideIcons.arrowLeft, size: 21),
                ),
              ),
            )
          : null,
      titleSpacing: 16,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.primary,
              fontSize: 11,
              letterSpacing: .4,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 23,
              fontWeight: FontWeight.w700,
              letterSpacing: -.5,
            ),
          ),
        ],
      ),
      actions: [...actions, const SizedBox(width: 12)],
    );
  }
}
