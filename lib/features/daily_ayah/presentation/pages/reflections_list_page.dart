import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/reflection.dart';
import '../controllers/reflections_controller.dart';

class ReflectionsListPage extends StatelessWidget {
  const ReflectionsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reflections List'),
        // actions: [
        //   HeaderIconAction(
        //     icon: Icons.settings_rounded,
        //     onTap: () => Get.toNamed(AppRoutes.settings),
        //   ),
        // ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 40),
            children: [
              AppHeader(onMenu: Get.back),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(l10n.allReflections,
                    style: AppTypography.labelCaps
                        .copyWith(color: AppColors.primary, letterSpacing: 2)),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(l10n.yourReflections, style: AppTypography.titleLg),
                        GhostGlassButton(
                          label: l10n.addReflection,
                          borderColor: AppColors.primary,
                          onPressed: () => Get.toNamed(AppRoutes.addReflection),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ReflectionsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReflectionsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = Get.find<ReflectionsController>();
    return Obx(() {
      final reflections = controller.reflections;
      if (reflections.isEmpty) return _EmptyState();
      return Column(
        children: [
          for (final r in reflections) ...[
            _ReflectionCard(
              reflection: r,
              onDelete: () => controller.remove(r.surahId, r.ayahNumber),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      color: AppColors.onSurfaceVariant, size: 48),
                  const SizedBox(height: AppSpacing.md),
                  Text(l10n.noMoreReflections,
                      style: AppTypography.titleLg
                          .copyWith(color: AppColors.primary)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.noMoreReflectionsSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyEnSm,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Shown when the user has not saved any reflections yet.
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            const Icon(Icons.lightbulb_outline_rounded,
                color: AppColors.onSurfaceVariant, size: 48),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.noMoreReflections,
                style:
                    AppTypography.titleLg.copyWith(color: AppColors.primary)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              l10n.noMoreReflectionsSubtitle,
              textAlign: TextAlign.center,
              style: AppTypography.bodyEnSm,
            ),
            const SizedBox(height: AppSpacing.lg),
            GlowPrimaryButton(
              label: l10n.addFirstReflection,
              trailingIcon: Icons.add_circle_outline,
              onPressed: () => Get.toNamed(AppRoutes.addReflection),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReflectionCard extends StatelessWidget {
  const _ReflectionCard({required this.reflection, required this.onDelete});
  final Reflection reflection;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.addReflection),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_relativeDate(reflection.savedAtMs),
                    style: AppTypography.labelCaps
                        .copyWith(color: AppColors.primary)),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.delete_outline_rounded,
                        color: AppColors.onSurfaceVariant, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(reflection.reference,
                style: AppTypography.labelSemibold.copyWith(fontSize: 13)),
            const SizedBox(height: AppSpacing.xs),
            Text(reflection.note,
                style: AppTypography.bodyEnSm
                    .copyWith(color: AppColors.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  /// Human-friendly relative date for the saved timestamp.
  String _relativeDate(int ms) {
    if (ms <= 0) return '';
    final then = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day)
        .difference(DateTime(then.year, then.month, then.day))
        .inDays;
    if (days <= 0) return 'Today';
    if (days == 1) return 'Yesterday';
    if (days < 7) return '$days days ago';
    if (days < 30) return '${(days / 7).floor()} weeks ago';
    return '${then.year}-${then.month.toString().padLeft(2, '0')}-${then.day.toString().padLeft(2, '0')}';
  }
}
