import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../reading_progress/domain/reading_progress.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../core/widgets/widgets.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../../../reading_progress/presentation/reading_progress_controller.dart';
import '../controllers/ayah_controller.dart';
import '../controllers/surah_controller.dart';

class AyahReaderPage extends StatefulWidget {
  const AyahReaderPage({super.key});
  @override
  State<AyahReaderPage> createState() => _AyahReaderPageState();
}

class _AyahReaderPageState extends State<AyahReaderPage> {
  bool _translation = true;
  bool _practice = false;
  double _fontSize = 28;
  final Set<int> _revealed = {};
  final Set<int> _read = {};
  @override
  void initState() {
    super.initState();
    final id = Get.find<AyahController>().surah.value?.id;
    final today =
        Get.find<ReadingProgressController>()
            .progress
            .value
            .days[ReadingProgress.dayKey(DateTime.now())] ??
        {};
    for (final value in today) {
      final parts = value.split(':');
      if (parts.length == 2 && int.tryParse(parts[0]) == id) {
        final verse = int.tryParse(parts[1]);
        if (verse != null) _read.add(verse);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AyahController>();
    final colors = Theme.of(context).colorScheme;
    final surah = controller.surah.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(surah?.name ?? 'Quran reader'),
        actions: [
          IconButton(
            tooltip: 'Reading preferences',
            icon: const Icon(LucideIcons.slidersHorizontal),
            onPressed: _preferences,
          ),
          IconButton(
            tooltip: 'Listen to this surah',
            icon: const Icon(LucideIcons.circlePlay),
            onPressed: controller.playSurah,
          ),
        ],
      ),
      body: GeometricBackground(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.error.value.isNotEmpty) {
            return ErrorStateView(
              message: controller.error.value,
              onRetry: () {
                if (surah != null) controller.fetchAyat(surah.id);
              },
            );
          }
          final verses = controller.ayat;
          final name = surah == null ? '' : quran.getSurahName(surah.id);
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: colors.primary,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _practice
                                  ? 'MEMORIZATION PRACTICE'
                                  : 'A MOMENT WITH THE QURAN',
                              style: TextStyle(
                                color: colors.onPrimary.withValues(alpha: .75),
                                fontSize: 10,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.w800,
                                color: colors.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${verses.length} verses · ${surah?.revelationLabel ?? ''}',
                              style: TextStyle(
                                color: colors.onPrimary.withValues(alpha: .8),
                              ),
                            ),
                            if (surah != null &&
                                quran.getBismillah(surah.id) != null) ...[
                              const SizedBox(height: 18),
                              Text(
                                quran.getBismillah(surah.id)!,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Amiri',
                                  fontSize: 24,
                                  height: 1.8,
                                  color: colors.onPrimary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilterChip(
                              selected: _practice,
                              label: const Text('Practice mode'),
                              avatar: const Icon(LucideIcons.brain, size: 18),
                              onSelected: (value) => setState(() {
                                _practice = value;
                                _revealed.clear();
                              }),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_read.length}/${verses.length} read',
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ],
                      ),
                      if (_practice)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Recite from memory, then tap a verse to reveal it.',
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  final revealed =
                      !_practice || _revealed.contains(verse.number);
                  final bookmarks = Get.find<BookmarksController>();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.primary.withValues(alpha: .1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${verse.surahId}:${verse.number}',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Obx(() {
                                final saved = bookmarks.isBookmarked(
                                  verse.surahId,
                                  verse.number,
                                );
                                return IconButton(
                                  tooltip: saved
                                      ? 'Remove bookmark'
                                      : 'Bookmark verse',
                                  icon: Icon(
                                    saved
                                        ? LucideIcons.bookmarkCheck
                                        : LucideIcons.bookmark,
                                    color: colors.primary,
                                  ),
                                  onPressed: () async {
                                    try {
                                      final saved = await bookmarks.toggle(
                                        Bookmark(
                                          surahId: verse.surahId,
                                          surahName: name,
                                          ayah: verse.number,
                                          arabic: verse.arabic,
                                          translation: verse.translation,
                                          reference:
                                              '$name ${verse.surahId}:${verse.number}',
                                          savedAtMs: DateTime.now()
                                              .millisecondsSinceEpoch,
                                        ),
                                      );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                saved
                                                    ? 'Verse bookmarked'
                                                    : 'Bookmark removed',
                                              ),
                                            ),
                                          );
                                      }
                                    } catch (_) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                          ..hideCurrentSnackBar()
                                          ..showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Could not save bookmark. Please try again.',
                                              ),
                                            ),
                                          );
                                      }
                                    }
                                  },
                                );
                              }),
                              IconButton(
                                tooltip: _read.contains(verse.number)
                                    ? 'Marked read'
                                    : 'Mark verse read',
                                icon: Icon(
                                  _read.contains(verse.number)
                                      ? LucideIcons.circleCheck
                                      : LucideIcons.circle,
                                  color: colors.primary,
                                ),
                                onPressed: _read.contains(verse.number)
                                    ? null
                                    : () async {
                                        try {
                                          await Get.find<
                                                ReadingProgressController
                                              >()
                                              .markRead(
                                                verse.surahId,
                                                verse.number,
                                              );
                                          if (mounted) {
                                            setState(
                                              () => _read.add(verse.number),
                                            );
                                          }
                                          if (surah != null &&
                                              Get.isRegistered<
                                                SurahController
                                              >()) {
                                            await Get.find<SurahController>()
                                                .markOpened(
                                                  surah,
                                                  ayah: verse.number,
                                                );
                                          }
                                          if (mounted) {
                                            setState(
                                              () => _read.add(verse.number),
                                            );
                                          }
                                        } catch (_) {
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Could not save progress. Please try again.',
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 250),
                            child: revealed
                                ? Text(
                                    verse.arabic,
                                    key: const ValueKey('verse'),
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: _fontSize,
                                      height: 2,
                                      color: colors.onSurface,
                                    ),
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    height: 100,
                                    child: TextButton.icon(
                                      onPressed: () => setState(
                                        () => _revealed.add(verse.number),
                                      ),
                                      icon: const Icon(LucideIcons.eye),
                                      label: const Text('Tap to reveal verse'),
                                    ),
                                  ),
                          ),
                          if (_translation && revealed) ...[
                            const SizedBox(height: 16),
                            Divider(
                              color: colors.outlineVariant.withValues(
                                alpha: .5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              verse.translation,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.7,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                          if (_practice && revealed)
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: TextButton(
                                onPressed: () => setState(
                                  () => _revealed.remove(verse.number),
                                ),
                                child: const Text('Hide and try again'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 48)),
            ],
          );
        }),
      ),
    );
  }

  void _preferences() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, updateSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Make it yours',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Show translation'),
                  value: _translation,
                  onChanged: (value) {
                    setState(() => _translation = value);
                    updateSheet(() {});
                  },
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Arabic text size'),
                ),
                Slider(
                  value: _fontSize,
                  min: 22,
                  max: 42,
                  divisions: 10,
                  label: '${_fontSize.round()}',
                  onChanged: (value) {
                    setState(() => _fontSize = value);
                    updateSheet(() {});
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
