import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/main_shell_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../quran_reader/presentation/controllers/surah_controller.dart';
import '../../domain/entities/bookmark.dart';
import '../controllers/bookmarks_controller.dart';

/// Bookmarks / Saved tab (mockup: bookmarks_screen): a "Continue Reading" hero
/// followed by the saved-ayah list rendered with verse badges and notes.
class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BookMark', style: AppTypography.titleLg),
        actions: [
          HeaderIconAction(
            icon: Icons.settings_rounded,
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const Padding(
                padding: AppSpacing.screenPadding,
                child: _ContinueReadingCard(),
              ),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Obx(() {
                  final count = Get.find<BookmarksController>().count;
                  return SectionHeader(
                    title: 'My Bookmarks',
                    subtitle: '$count Saved ${count == 1 ? 'Ayah' : 'Ayahs'}',
                    trailing: Row(
                      children: const [
                        Icon(
                          Icons.filter_list_rounded,
                          color: AppColors.onSurfaceVariant,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Icon(
                          Icons.sort_rounded,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              const _BookmarksList(),
              const SizedBox(height: AppSpacing.xl),
              // Previous Reflections Preview
              // Padding(
              //   padding: AppSpacing.screenPadding,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text(
              //             'Previous Reflections',
              //             style: AppTypography.bodyAr,
              //           ),
              //           TextButton(
              //             onPressed: () {},
              //             child: Text(
              //               'View All',
              //               style: AppTypography.labelSemibold.copyWith(
              //                 color: AppColors.primary,
              //               ),
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: AppSpacing.md),
              //       Row(
              //         children: [
              //           Expanded(
              //             child: _PreviousReflectionCard(
              //               date: 'Yesterday',
              //               ayah: 'Al-Baqarah 2:255',
              //               preview:
              //                   'This verse provides immense spiritual protection...',
              //               hasNote: true,
              //             ),
              //           ),
              //           const SizedBox(width: AppSpacing.md),
              //           Expanded(
              //             child: _PreviousReflectionCard(
              //               date: '2 days ago',
              //               ayah: 'Ash-Sharh 94:6',
              //               preview:
              //                   'A reminder that every struggle has a purpose...',
              //               hasNote: true,
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: AppSpacing.md),
              //       _AddReflectionCard(),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard();

  @override
  Widget build(BuildContext context) {
    final surahController = Get.find<SurahController>();
    return GlassCard(
      child: Column(
        children: [
          // Hero image with Quran text overlay - matches Stitch design
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: AppRadii.cardRadius,
              boxShadow: AppShadows.card,
              image: const DecorationImage(
                image: AssetImage(AppAssets.quranOnCushion),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0x66004D33),
                  BlendMode.darken,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              'القرآن',
              style: AppTypography.displayAr.copyWith(
                color: Colors.white,
                fontSize: 40,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Last Read badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadii.pillRadius,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.history_rounded,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'Last Read',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Obx(() {
            final lr = surahController.lastRead.value;
            return Column(
              children: [
                Text(
                  lr == null ? 'No surah opened yet' : 'Surah ${lr.surahId}',
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  lr == null
                      ? 'Open a surah from the Quran tab'
                      : 'Ayah ${lr.ayah} • Pages ${lr.pageStart}–${lr.pageEnd}',
                  style: AppTypography.bodyEnSm,
                ),
              ],
            );
          }),
          const SizedBox(height: AppSpacing.md),
          GlowPrimaryButton(
            label: 'Continue Reading',
            trailingIcon: Icons.arrow_forward_rounded,
            height: 48,
            onPressed: () => Get.find<MainShellController>().select(1),
          ),
        ],
      ),
    );
  }
}

// class _PreviousReflectionCard extends StatelessWidget {
//   const _PreviousReflectionCard({
//     required this.date,
//     required this.ayah,
//     required this.preview,
//     required this.hasNote,
//   });
//   final String date;
//   final String ayah;
//   final String preview;
//   final bool hasNote;

//   @override
//   Widget build(BuildContext context) {
//     return GlassCard(
//       padding: const EdgeInsets.all(AppSpacing.md),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 date,
//                 style: AppTypography.labelCaps.copyWith(
//                   color: AppColors.primary,
//                 ),
//               ),
//               if (hasNote)
//                 const Icon(
//                   Icons.auto_awesome_rounded,
//                   color: AppColors.tertiary,
//                   size: 18,
//                 ),
//             ],
//           ),
//           const SizedBox(height: AppSpacing.xs),
//           Text(ayah, style: AppTypography.labelSemibold.copyWith(fontSize: 13)),
//           const SizedBox(height: AppSpacing.xs),
//           Text(
//             preview,
//             style: AppTypography.bodyEnSm.copyWith(
//               color: AppColors.onSurfaceVariant,
//             ),
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _AddReflectionCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return PressableScale(
//       onTap: () {},
//       child: GlassCard(
//         padding: const EdgeInsets.all(AppSpacing.md),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.add_circle_outline_rounded,
//               color: AppColors.primary,
//               size: 22,
//             ),
//             const SizedBox(width: AppSpacing.sm),
//             Text(
//               'Add Reflection',
//               style: AppTypography.labelSemibold.copyWith(
//                 color: AppColors.primary,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class _BookmarksList extends StatelessWidget {
  const _BookmarksList();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookmarksController>();
    return Obx(() {
      if (controller.bookmarks.isEmpty) return _EmptyBookmarksState();
      return Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            for (final b in controller.bookmarks)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: _BookmarkCard(bookmark: b),
              ),
          ],
        ),
      );
    });
  }
}

class _BookmarkCard extends StatelessWidget {
  const _BookmarkCard({required this.bookmark});
  final Bookmark bookmark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookmarksController>();
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurahOrnamentNumber(number: bookmark.surahId),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bookmark.reference.isNotEmpty
                      ? bookmark.reference
                      : '${bookmark.surahName} • Ayah ${bookmark.ayah}',
                  style: AppTypography.labelSemibold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (bookmark.arabic.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    bookmark.arabic,
                    textDirection: TextDirection.rtl,
                    style: AppTypography.bodyAr.copyWith(fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (bookmark.translation.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    bookmark.translation,
                    style: AppTypography.bodyEnSm.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              PressableScale(
                onTap: () => controller.toggleFavorite(bookmark.id),
                child: Icon(
                  bookmark.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: bookmark.isFavorite
                      ? AppColors.primary
                      : AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              PressableScale(
                onTap: () => controller.remove(bookmark.id),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyBookmarksState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceContainerLowest,
                boxShadow: AppShadows.card,
              ),
              child: Center(
                child: Icon(
                  Icons.bookmark_border_rounded,
                  color: AppColors.primary.withValues(alpha: 0.4),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'No Bookmarks Yet',
              style: AppTypography.headlineLgMobile.copyWith(
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Start saving your favorite Ayahs to build your personal spiritual treasury.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyEnSm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GhostGlassButton(
              label: 'Explore Quran',
              borderColor: AppColors.primary,
              onPressed: () => Get.find<MainShellController>().select(1),
            ),
          ],
        ),
      ),
    );
  }
}
