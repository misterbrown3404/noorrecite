import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';

/// Home "Continue Listening" card. Renders the live playback session when one
/// is active, otherwise a static snapshot rebuilt from the persisted session.
///
/// The outer [Obx] depends ONLY on track identity (queue + currentIndex), so
/// the shell rebuilds once per track change — not on every position tick. The
/// ticking values (progress, elapsed time, play/pause glyph) live in their own
/// leaf [Obx] widgets inside [_CardShell].
class ContinueListeningCard extends StatelessWidget {
  const ContinueListeningCard({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioController>();

    return Obx(() {
      final live = audio.currentTrack;

      // No live session — fall back to the persisted snapshot, if any.
      if (live == null) {
        final saved = audio.lastPlayback;
        if (saved == null) return const SizedBox.shrink();
        final surahName = saved['surahName'] as String?;
        final reciterName = saved['reciterName'] as String?;
        if (surahName == null || reciterName == null) {
          return const SizedBox.shrink();
        }
        final posMs = (saved['positionMs'] as int?) ?? 0;
        return _CardShell(
          title: surahName,
          subtitle: reciterName,
          positionLabel: DurationFormat.clock(Duration(milliseconds: posMs)),
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
                    LucideIcons.headphones,
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
                    LucideIcons.skipBack,
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
                                  ? LucideIcons.pause
                                  : LucideIcons.play,
                              color: AppColors.primary,
                            ),
                          )
                        : const Icon(
                            LucideIcons.play,
                            color: AppColors.primary,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                PressableScale(
                  onTap: onNext ?? () {},
                  child: Icon(
                    LucideIcons.skipForward,
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
                      '${DurationFormat.clock(a.position.value)} / ${DurationFormat.clock(a.duration.value)}',
                      style: AppTypography.bodyEnSm,
                    ),
                  )
                else
                  Text(positionLabel ?? '', style: AppTypography.bodyEnSm),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
