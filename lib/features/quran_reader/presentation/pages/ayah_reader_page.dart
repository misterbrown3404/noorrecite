import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../controllers/ayah_controller.dart';
import '../../domain/entities/ayah.dart';

class AyahReaderPage extends StatelessWidget {
  const AyahReaderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AyahController>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.surah.value?.name ?? '',
          style: AppTypography.titleLg,
        ),
        actions: [
          HeaderIconAction(
            icon: Icons.play_arrow_rounded,
            onTap: controller.playSurah,
          ),
        ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (controller.error.value.isNotEmpty) {
                    return Padding(
                      padding: AppSpacing.screenPadding,
                      child: ErrorStateView(
                        message: controller.error.value,
                        onRetry: () {
                          final s = controller.surah.value;
                          if (s != null) controller.fetchAyat(s.id);
                        },
                      ),
                    );
                  }
                  final surahId = controller.surah.value?.id ?? 0;
                  final surahLatin = surahId > 0
                      ? quran.getSurahName(surahId)
                      : '';
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 120),
                    children: [
                     //if (surahId != 9) Shrink(),
                      const SizedBox(height: AppSpacing.md),
                      ...controller.ayat.map(
                        (a) => Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppSpacing.margin,
                            0,
                            AppSpacing.margin,
                            AppSpacing.md,
                          ),
                          child: _AyahRow(ayah: a, surahLatin: surahLatin),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class _AyahRow extends StatelessWidget {
  const _AyahRow({required this.ayah, required this.surahLatin});
  final Ayah ayah;
  final String surahLatin;

  @override
  Widget build(BuildContext context) {
    final bookmarks = Get.find<BookmarksController>();
    return AyahCard(
      arabic: ayah.arabic,
      translation: ayah.translation,
      surahName: surahLatin,
      ayahNumber: ayah.number,
      trailing: Obx(() {
        final saved = bookmarks.isBookmarked(ayah.surahId, ayah.number);
        return PressableScale(
          onTap: () => bookmarks.toggle(
            Bookmark(
              surahId: ayah.surahId,
              surahName: surahLatin,
              ayah: ayah.number,
              arabic: ayah.arabic,
              translation: ayah.translation,
              reference: '$surahLatin ${ayah.surahId}:${ayah.number}',
              savedAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          ),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: saved ? AppColors.primary : AppColors.onSurfaceVariant,
            size: 20,
          ),
        );
      }),
    );
  }
}
