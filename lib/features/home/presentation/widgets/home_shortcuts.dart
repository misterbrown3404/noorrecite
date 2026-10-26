import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/main_shell_controller.dart';
import '../../../../app/routes/app_routes.dart';

/// Keep the daily essentials visible; secondary destinations are one tap away.
class HomeShortcuts extends StatelessWidget {
  const HomeShortcuts({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = <(String, IconData, VoidCallback)>[
      (
        'Quran',
        LucideIcons.bookOpen,
        () => Get.find<MainShellController>().select(1),
      ),
      ('Reciters', LucideIcons.speech, () => Get.toNamed(AppRoutes.reciters)),
      ('Azkar', LucideIcons.sunrise, () => Get.toNamed(AppRoutes.azkar)),
      ('More', LucideIcons.layoutGrid, () => _showMore(context)),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = MediaQuery.textScalerOf(context).scale(14) > 22 ? 2 : 4;
        return Wrap(
          spacing: 8,
          runSpacing: 12,
          children: [
            for (final item in items)
              SizedBox(
                width: (constraints.maxWidth - (columns - 1) * 8) / columns,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: item.$3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              item.$2,
                              color: colors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.$1,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: colors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showMore(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    'Explore',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                for (final item in [
                  ('Duas', LucideIcons.bookOpen, AppRoutes.duas),
                  (
                    '99 Names of Allah',
                    LucideIcons.sparkles,
                    AppRoutes.allahNames,
                  ),
                  ('Tasbih', LucideIcons.circleDot, AppRoutes.tasbih),
                  (
                    'Reflections',
                    LucideIcons.notebookPen,
                    AppRoutes.reflectionsList,
                  ),
                  ('Daily ayah', LucideIcons.sun, AppRoutes.dailyReflection),
                  (
                    'Reading statistics',
                    LucideIcons.chartNoAxesCombined,
                    AppRoutes.statistics,
                  ),
                ])
                  ListTile(
                    leading: Icon(item.$2),
                    title: Text(item.$1),
                    trailing: const Icon(LucideIcons.chevronRight, size: 20),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Get.toNamed(item.$3);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
