import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../controllers/daily_ayah_controller.dart';
import '../controllers/reflections_controller.dart';

/// Daily reflection (mockup: daily_reflection_screen): the day's ayah with
/// Listen/Save/Share actions, a personal reflection note field, and history.
class DailyReflectionPage extends StatelessWidget {
  const DailyReflectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyAyahController>();
    return Scaffold(
      appBar: AppBar(
        title:const Text('Daily Reflection'),
      ),
      body: GeometricBackground(
        child: Stack(
          children: [
            // Lanterns glowing through the top, as in the mockup.
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 260,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.transparent],
                  stops: [0.2, 1],
                ).createShader(rect),
                child: Image.asset(
                  AppAssets.lanternsBg,
                  fit: BoxFit.cover,
                  opacity: const AlwaysStoppedAnimation(0.35),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.error.value.isNotEmpty) {
                  return Padding(
                    padding: AppSpacing.screenPadding,
                    child: ErrorStateView(
                      message: controller.error.value,
                      onRetry: controller.fetchDailyAyah,
                    ),
                  );
                }
                final ayah = controller.dailyAyah.value;
                if (ayah == null) {
                  return Center(
                    child: Text(
                      'No daily ayah available',
                      style: AppTypography.bodyEn,
                    ),
                  );
                }
                return _DailyAyahContent(ayah: ayah);
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyAyahContent extends StatelessWidget {
  const _DailyAyahContent({required this.ayah});
  final dynamic ayah;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(
          child: Text(
            ayah.reference,
            style: AppTypography.headlineLgMobile,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: AppSpacing.screenPadding,
          child: GlassCard(
            child: Column(
              children: [
                Text(
                  ayah.arabic,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTypography.displayAr.copyWith(fontSize: 40),
                ),
                const SizedBox(height: AppSpacing.md),
                // Verse divider ornament - matches Stitch design
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                        borderRadius: AppRadii.pillRadius,
                      ),
                      child: Text(
                        ayah.reference,
                        style: AppTypography.labelCaps.copyWith(
                          color: AppColors.secondary,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 32,
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ayah.translation,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyEn.copyWith(fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: AppSpacing.lg),
                // Circular action buttons with filled icons - matches Stitch
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ReflectAction(icon: Icons.play_circle, label: 'Listen'),
                    const SizedBox(width: AppSpacing.xl),
                    _ReflectAction(
                      icon: Icons.bookmark,
                      label: 'Save',
                      onTap: () {
                        final bookmarks = Get.find<BookmarksController>();
                        bookmarks.toggle(
                          Bookmark(
                            surahId: ayah.surahId,
                            surahName: ayah.reference,
                            ayah: ayah.ayahNumber,
                            arabic: ayah.arabic,
                            translation: ayah.translation,
                            reference: ayah.reference,
                            isFavorite: true,
                            savedAtMs: DateTime.now().millisecondsSinceEpoch,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    _ReflectAction(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: '${ayah.reference}\n${ayah.arabic}\n${ayah.translation}',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: AppSpacing.screenPadding,
          child: _ReflectionEditor(ayah: ayah),
        ),
        const SizedBox(height: AppSpacing.xl),
        // Previous Reflections Preview - matches Stitch design
        Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Previous Reflections', style: AppTypography.bodyAr),
                  TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.reflectionsList),
                    child: Text(
                      'View All',
                      style: AppTypography.labelSemibold.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Show up to the 3 most recent saved reflections; falls back to a
              // hint when the user hasn't written any yet.
              Obx(() {
                final reflections =
                    Get.find<ReflectionsController>().reflections;
                if (reflections.isEmpty) {
                  return Text(
                    'Your saved reflections will appear here.',
                    style: AppTypography.bodyEnSm,
                    textAlign: TextAlign.center,
                  );
                }
                return Column(
                  children: [
                    for (final r in reflections.take(3))
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _ReflectionPreviewCard(
                          reference: r.reference,
                          note: r.note,
                        ),
                      ),
                  ],
                );
              }),
              const SizedBox(height: AppSpacing.xs),
              // Card entry point for adding a standalone reflection.
              _AddReflectionCard(),
            ],
          ),
        ),
      ],
    );
  }
}

/// Editable personal note for the day's ayah, persisted locally so it survives
/// app restarts. Keyed by the ayah reference (one note per verse).
class _ReflectionEditor extends StatefulWidget {
  const _ReflectionEditor({required this.ayah});
  final dynamic ayah;

  @override
  State<_ReflectionEditor> createState() => _ReflectionEditorState();
}

class _ReflectionEditorState extends State<_ReflectionEditor> {
  final _textController = TextEditingController();
  late final ReflectionsController _reflections;

  @override
  void initState() {
    super.initState();
    _reflections = Get.find<ReflectionsController>();
    // Pre-fill with any existing note for this verse.
    final existing = _reflections.forVerse(
      widget.ayah.surahId,
      widget.ayah.ayahNumber,
    );
    _textController.text = existing?.note ?? '';
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _clear() {
    _textController.clear();
    setState(() {});
  }

  Future<void> _save() async {
    final text = _textController.text.trim();
    await _reflections.save(
      surahId: widget.ayah.surahId,
      ayahNumber: widget.ayah.ayahNumber,
      reference: widget.ayah.reference,
      note: text,
      savedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    if (mounted) FocusScope.of(context).unfocus();
    Get.snackbar(
      'Saved',
      text.isEmpty ? 'Your reflection was cleared.' : 'Your reflection was saved.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSpacing.md),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.tertiary),
              const SizedBox(width: AppSpacing.xs),
              Text('MY REFLECTION',
                  style: AppTypography.labelCaps
                      .copyWith(color: AppColors.onSurface)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: AppRadii.cardRadius,
              boxShadow: AppShadows.inset,
            ),
            child: TextField(
              controller: _textController,
              maxLines: 4,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'How does this Ayah resonate with your day?',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: _clear,
                  child: Text('Clear',
                      style: AppTypography.labelSemibold.copyWith(
                          color: AppColors.onSurfaceVariant))),
              const SizedBox(width: AppSpacing.sm),
              GlowPrimaryButton(
                label: 'Save Note',
                trailingIcon: Icons.check_circle_outline,
                expand: false,
                height: 44,
                onPressed: _save,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReflectAction extends StatelessWidget {
  const _ReflectAction({
    required this.icon,
    required this.label,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PressableScale(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              shape: BoxShape.circle,
              boxShadow: AppShadows.neumorphic,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28, fill: 1.0),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTypography.bodyEnSm),
      ],
    );
  }
}

class _ReflectionPreviewCard extends StatelessWidget {
  const _ReflectionPreviewCard({required this.reference, required this.note});
  final String reference;
  final String note;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.tertiary, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  reference,
                  style: AppTypography.labelSemibold.copyWith(
                    color: AppColors.primary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            note,
            style: AppTypography.bodyEnSm
                .copyWith(color: AppColors.onSurfaceVariant),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AddReflectionCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.addReflection),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text('Add Reflection',
                style: AppTypography.labelSemibold.copyWith(color: AppColors.primary)),
          ],
        ),
      ),
    );
  }
}
