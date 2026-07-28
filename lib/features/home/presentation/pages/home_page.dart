import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

//import '../../../../app/main_shell_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../audio_player/domain/entities/audio_track.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../../../daily_ayah/domain/entities/daily_ayah.dart';
import '../../../daily_ayah/presentation/controllers/daily_ayah_controller.dart';
import '../../../reciters/domain/entities/reciter.dart';
import '../../../reciters/presentation/controllers/reciter_controller.dart';
import '../controllers/prayer_times_controller.dart';
import '../../../../core/widgets/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerController = Get.find<PrayerTimesController>();
    return Scaffold(
      appBar: AppBar(
        title: Text('QariVerse', style: AppTypography.titleLg),
        actions: [
          HeaderIconAction(
            icon: Icons.settings_rounded,
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: GeometricBackground(
        showAura: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: AppSpacing.lg),
              const _Greeting(),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    _NextPrayerCard(controller: prayerController),
                    const SizedBox(height: AppSpacing.lg),
                    const _ContinueListeningCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _DailyAyahCard(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              const _PopularReciters(),
              const SizedBox(height: AppSpacing.xl),
              // const Padding(
              //   padding: AppSpacing.screenPadding,
              //   child: _QuickActionsGrid(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Assalamu Alaikum,', style: AppTypography.titleLg)],
      ),
    );
  }
}

class _NextPrayerCard extends StatelessWidget {
  const _NextPrayerCard({required this.controller});
  final PrayerTimesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final next = controller.nextPrayer.value;
      final loading = controller.isLoading.value;
      final error = controller.error.value;

      if (loading) {
        return _Skeleton();
      }
      if (error.isNotEmpty) {
        return _ErrorCard(message: error, onRetry: controller.loadPrayerTimes);
      }
      if (next == null) {
        return _ErrorCard(
          message: 'Unable to load prayer times',
          onRetry: controller.loadPrayerTimes,
        );
      }

      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardRadius,
          boxShadow: AppShadows.card,
          image: DecorationImage(
            image: AssetImage(AppAssets.mosqueLandscape),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color(0xCC061A14),
              BlendMode.colorDodge,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    'NEXT PRAYER',
                    style: AppTypography.labelCaps.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${next.name.toUpperCase()} IN',
                          style: AppTypography.labelCaps.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Text(
                          _formatDuration(next.timeRemaining),
                          style: AppTypography.titleLg.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      duration: 1000.ms,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next.name,
                      style: AppTypography.titleLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      next.formattedTime,
                      style: AppTypography.bodyEnSm.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                PressableScale(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}

class _Skeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card,
        image: DecorationImage(
          image: AssetImage(AppAssets.mosqueLandscape),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Color(0xCC061A14),
            BlendMode.colorDodge,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadii.pillRadius,
                ),
              ),
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card,
        image: DecorationImage(
          image: AssetImage(AppAssets.mosqueLandscape),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Color(0xCC061A14),
            BlendMode.colorDodge,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTypography.bodyEnSm.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          PressableScale(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadii.pillRadius,
              ),
              child: Text(
                'Retry',
                style: AppTypography.labelSemibold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueListeningCard extends StatelessWidget {
  const _ContinueListeningCard();

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioController>();

    // This outer Obx intentionally depends ONLY on track identity
    // (currentTrack reads queue + currentIndex), so the card's shell is built
    // once per track change — not on every position tick. The ticking values
    // (progress, elapsed time, play/pause) live in their own leaf Obx widgets
    // inside _CardShell so a play head update repaints a few small widgets,
    // never the whole card.
    return Obx(() {
      final live = audio.currentTrack;

      // No live session — fall back to the persisted snapshot, if any.
      if (live == null) {
        final saved = audio.lastPlayback;
        if (saved == null) return const SizedBox.shrink();
        final rawTracks = (saved['tracks'] as List?)
            ?.cast<Map<String, dynamic>>();
        if (rawTracks == null || rawTracks.isEmpty) {
          return const SizedBox.shrink();
        }
        final index = ((saved['currentIndex'] as int?) ?? 0).clamp(
          0,
          rawTracks.length - 1,
        );
        final track = AudioTrack.fromJson(rawTracks[index]);
        final posMs = (saved['positionMs'] as int?) ?? 0;
        return _CardShell(
          title: track.surahName,
          subtitle: track.reciterName,
          positionLabel: _fmt(Duration(milliseconds: posMs)),
          onTap: () => Get.toNamed(AppRoutes.audioPlayer),
          onPlayPause: () async {
            await audio.resumeLastSession();
            Get.toNamed(AppRoutes.audioPlayer);
          },
          onPrev: null,
          onNext: null,
        );
      }

      // Live session: the shell is static; dynamic bits pull from [audio].
      return _CardShell(
        title: live.surahName,
        subtitle: live.reciterName,
        audio: audio,
        onTap: () => Get.toNamed(AppRoutes.audioPlayer),
        onPlayPause: audio.togglePlayPause,
        onPrev: audio.previous,
        onNext: audio.next,
      );
    });
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onPlayPause,
    required this.onPrev,
    required this.onNext,
    this.audio,
    this.positionLabel,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  /// When non-null the card is "live": progress, elapsed time, and the
  /// play/pause glyph subscribe to [audio] via their own leaf [Obx]. When null
  /// the card renders a static snapshot using [positionLabel].
  final AudioController? audio;
  final String? positionLabel;

  static String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final a = audio;
    return PressableScale(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CONTINUE LISTENING',
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                    borderRadius: AppRadii.cardRadius,
                  ),
                  child: const Icon(
                    Icons.headphones,
                    color: AppColors.secondary,
                    size: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.titleLg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: AppTypography.bodyEnSm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.md),
            // Leaf Obx: only the progress bar repaints on a position tick.
            if (a != null)
              Obx(() {
                final dur = a.duration.value;
                final pos = a.position.value;
                final progress = dur.inMilliseconds > 0
                    ? (pos.inMilliseconds / dur.inMilliseconds).clamp(0.0, 1.0)
                    : 0.0;
                return AnimatedProgressBar(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.surfaceContainerHigh,
                );
              })
            else
              AnimatedProgressBar(
                value: 0,
                minHeight: 6,
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                PressableScale(
                  onTap: onPrev ?? () {},
                  child: Icon(
                    Icons.skip_previous_rounded,
                    color: onPrev == null
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.4)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.primary, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: PressableScale(
                    onTap: onPlayPause,
                    // Leaf Obx: only the glyph swaps when play state flips.
                    child: a != null
                        ? Obx(
                            () => Icon(
                              a.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PressableScale(
                  onTap: onNext ?? () {},
                  child: Icon(
                    Icons.skip_next_rounded,
                    color: onNext == null
                        ? AppColors.onSurfaceVariant.withValues(alpha: 0.4)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                // Leaf Obx: only the timestamp text updates per tick.
                if (a != null)
                  Obx(
                    () => Text(
                      '${_fmt(a.position.value)} / ${_fmt(a.duration.value)}',
                      style: AppTypography.bodyEnSm,
                    ),
                  )
                else
                  Text(
                    positionLabel ?? '',
                    style: AppTypography.bodyEnSm,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyAyahCard extends StatelessWidget {
  const _DailyAyahCard();

  @override
  Widget build(BuildContext context) {
    final dailyAyahController = Get.find<DailyAyahController>();
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.dailyReflection),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppRadii.cardRadius,
          boxShadow: AppShadows.primaryGlow(opacity: 0.3),
        ),
        child: Obx(() {
          if (dailyAyahController.isLoading.value) {
            return const _DailyAyahLoading();
          }
          if (dailyAyahController.error.value.isNotEmpty) {
            ErrorStateView(
              message: dailyAyahController.error.value,
              onRetry: dailyAyahController.fetchDailyAyah,
            );
          }
          final ayah = dailyAyahController.dailyAyah.value;
          if (ayah == null) return const SizedBox.shrink();
          return Column(
            children: [
              Text(
                'DAILY AYAH',
                style: AppTypography.labelCaps.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ayah.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTypography.bodyAr.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ayah.translation,
                textAlign: TextAlign.center,
                style: AppTypography.bodyEnSm.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.tertiaryFixedDim),
                  borderRadius: AppRadii.pillRadius,
                ),
                child: Text(
                  ayah.reference.toUpperCase(),
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.tertiaryFixed,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleGlyph(
                    icon: Icons.share_outlined,
                    onTap: () => SharePlus.instance.share(
                      ShareParams(
                        text:
                            '${ayah.reference} \n\n${ayah.arabic}\n\n${ayah.translation}',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _DailyAyahFavoriteGlyph(ayah: ayah),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DailyAyahLoading extends StatelessWidget {
  const _DailyAyahLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: AppRadii.pillRadius,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 150,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _CircleGlyph extends StatelessWidget {
  const _CircleGlyph({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DailyAyahFavoriteGlyph extends StatelessWidget {
  const _DailyAyahFavoriteGlyph({required this.ayah});
  final DailyAyah ayah;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookmarksController>();
    return Obx(() {
      final saved = controller.isBookmarked(ayah.surahId, ayah.ayahNumber);
      return PressableScale(
        onTap: () => controller.toggle(
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
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    });
  }
}

class _PopularReciters extends StatelessWidget {
  const _PopularReciters();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: 'Popular Reciters',
            actionLabel: 'VIEW ALL',
            onAction: () => Get.toNamed(AppRoutes.reciters),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: Obx(() {
            final controller = Get.find<ReciterController>();
            if (controller.isLoading.value) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.screenPadding,
                itemCount: 4,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, _) => const _ReciterCardSkeleton(),
              );
            }
            final reciters = controller.reciters.take(10).toList();
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenPadding,
              itemCount: reciters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) => _ReciterCard(reciter: reciters[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _ReciterCard extends StatelessWidget {
  const _ReciterCard({required this.reciter});
  final Reciter reciter;

  @override
  Widget build(BuildContext context) {
    final imageAsset = AppAssets.reciterImage(reciter.id);
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.reciters),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: 150,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: AppRadii.cardRadius,
                boxShadow: AppShadows.card,
                gradient: AppColors.tealEmeraldGradient,
              ),
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _ReciterAvatarFallback(),
                    )
                  : const _ReciterAvatarFallback(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              reciter.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSemibold,
            ),
            Text(
              reciter.primaryMoshaf?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyEnSm,
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic avatar shown when a reciter has no mapped portrait, or the asset
/// fails to decode.
class _ReciterAvatarFallback extends StatelessWidget {
  const _ReciterAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.person_rounded, color: Colors.white, size: 56),
    );
  }
}

class _ReciterCardSkeleton extends StatelessWidget {
  const _ReciterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 150,
            height: 150,
            radius: AppRadii.cardRadius.topLeft.x,
          ),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(width: 120, height: 14),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonBox(width: 80, height: 12),
        ],
      ),
    );
  }
}

// class _QuickActionsGrid extends StatelessWidget {
//   const _QuickActionsGrid();

//   void _onAction(String title) {
//     switch (title) {
//       case 'Bookmarks':
//         // Jump to the Saved tab (index 3 in MainShell).
//         Get.find<MainShellController>().select(3);
//       default:
//         // Juz / Qibla / Zakat aren't built yet.
//         Get.snackbar(
//           title,
//           'This feature is coming soon, in sha Allah.',
//           snackPosition: SnackPosition.BOTTOM,
//           margin: const EdgeInsets.all(AppSpacing.md),
//         );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bookmarks = Get.find<BookmarksController>().bookmarks.length;
//     final actions = [
//       (Icons.menu_book_outlined, 'Juz Info', null as String?),
//       (Icons.bookmark_border_rounded, 'Bookmarks', '$bookmarks Verses Saved'),
//     ];

//     return ResponsiveGrid(
//       columns: 2,
//       spacing: AppSpacing.md,
//       runSpacing: AppSpacing.md,
//       children: [
//         for (final (icon, title, subtitle) in actions)
//           PressableScale(
//             onTap: () => _onAction(title),
//             child: Container(
//               padding: const EdgeInsets.all(AppSpacing.md),
//               decoration: BoxDecoration(
//                 color: AppColors.surfaceContainerLowest,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.05),
//                     offset: const Offset(8, 8),
//                     blurRadius: 16,
//                   ),
//                   BoxShadow(
//                     color: Colors.white.withValues(alpha: 0.8),
//                     offset: const Offset(-4, -4),
//                     blurRadius: 12,
//                   ),
//                 ],
//                 border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(AppSpacing.sm),
//                     decoration: BoxDecoration(
//                       color: AppColors.secondaryContainer.withValues(
//                         alpha: 0.5,
//                       ),
//                       borderRadius: AppRadii.cardRadius,
//                     ),
//                     child: Icon(icon, color: AppColors.primary, size: 20),
//                   ),
//                   const SizedBox(width: AppSpacing.sm),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           style: AppTypography.labelSemibold,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         if (subtitle != null)
//                           Text(
//                             subtitle,
//                             style: AppTypography.bodyEnSm.copyWith(
//                               fontSize: 11,
//                             ),
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//       ],
//     );
//   }
// }
