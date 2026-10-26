import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../../domain/entities/daily_ayah.dart';
import '../controllers/daily_ayah_controller.dart';
import '../controllers/reflections_controller.dart';

class DailyReflectionPage extends StatelessWidget {
  const DailyReflectionPage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DailyAyahController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily reflection'),
        centerTitle: false,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
        actions: [
          IconButton(
            tooltip: 'Reflection history',
            onPressed: () => Get.toNamed(AppRoutes.reflectionsList),
            icon: const Icon(LucideIcons.history),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty) {
          return ErrorStateView(
            message: controller.error.value,
            onRetry: controller.fetchDailyAyah,
          );
        }
        final ayah = controller.dailyAyah.value;
        if (ayah == null) {
          return const Center(child: Text('No daily ayah available'));
        }
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  Icon(
                    LucideIcons.sparkles,
                    color: colors.onPrimaryContainer,
                    size: 26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ayah.reference,
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SelectableText(
                    ayah.arabic,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 32,
                      height: 1.9,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    color: colors.onPrimaryContainer.withValues(alpha: .2),
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    ayah.translation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.8,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Obx(() {
                  final bookmarks = Get.find<BookmarksController>();
                  final saved = bookmarks.bookmarks.any(
                    (b) =>
                        b.surahId == ayah.surahId && b.ayah == ayah.ayahNumber,
                  );
                  return FilledButton.tonalIcon(
                    icon: Icon(
                      saved ? LucideIcons.check : LucideIcons.bookmark,
                    ),
                    label: Text(saved ? 'Saved' : 'Save ayah'),
                    onPressed: () => bookmarks.toggle(
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
                    ),
                  );
                }),
                OutlinedButton.icon(
                  icon: const Icon(LucideIcons.share2),
                  label: const Text('Share'),
                  onPressed: () {
                    final box = context.findRenderObject() as RenderBox?;
                    SharePlus.instance.share(
                      ShareParams(
                        text:
                            '${ayah.reference}\n${ayah.arabic}\n${ayah.translation}',
                        sharePositionOrigin: box == null
                            ? null
                            : box.localToGlobal(Offset.zero) & box.size,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ReflectionEditor(key: ValueKey(ayah.reference), ayah: ayah),
            const SizedBox(height: 20),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(LucideIcons.notebookPen, color: colors.primary),
              title: const Text('Your reflections'),
              trailing: const Icon(LucideIcons.chevronRight),
              onTap: () => Get.toNamed(AppRoutes.reflectionsList),
            ),
          ],
        );
      }),
    );
  }
}

class _ReflectionEditor extends StatefulWidget {
  const _ReflectionEditor({super.key, required this.ayah});
  final DailyAyah ayah;

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
      text.isEmpty
          ? 'Your reflection was cleared.'
          : 'Your reflection was saved.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(AppSpacing.md),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.notebookPen, color: colors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'MY REFLECTION',
                style: AppTypography.labelCaps.copyWith(
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadii.cardRadius,
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
                child: Text(
                  'Clear',
                  style: AppTypography.labelSemibold.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              GlowPrimaryButton(
                label: 'Save Note',
                trailingIcon: LucideIcons.circleCheck,
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
