import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../reciters/presentation/controllers/reciter_controller.dart';
import '../controllers/audio_controller.dart';

class AudioQueueSheet extends StatelessWidget {
  const AudioQueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioController>();
    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Text('QUEUE', style: AppTypography.labelSemibold),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                final queue = audio.queue;
                if (queue.isEmpty) {
                  return const Center(child: Text('No surahs in queue'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: queue.length,
                  itemBuilder: (context, index) {
                    final track = queue[index];
                    final isCurrent = index == audio.currentIndex.value;
                    return ListTile(
                      leading: Icon(
                        isCurrent ? LucideIcons.play : LucideIcons.circle,
                        color: isCurrent
                            ? AppColors.primary
                            : AppColors.onSurfaceVariant,
                        size: isCurrent ? 24 : 16,
                      ),
                      title: Text(
                        quran.getSurahName(track.surahNumber),
                        style: isCurrent
                            ? AppTypography.labelSemibold.copyWith(
                                color: AppColors.primary,
                              )
                            : AppTypography.labelSemibold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Surah ${track.surahName} • ${track.reciterName}',
                        style: AppTypography.bodyEnSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () {
                        audio.playAt(index);
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reciter picker sheet: lists every reciter (scrollable), tapping one starts
/// playback of the current surah with that reciter.
class ReciterPickerSheet extends StatelessWidget {
  const ReciterPickerSheet({super.key, required this.currentSurahNumber});

  /// The surah currently loaded in the player, so switching reciters keeps
  /// listening to the same surah rather than restarting from Surah 1.
  final int? currentSurahNumber;

  @override
  Widget build(BuildContext context) {
    final reciterController = Get.find<ReciterController>();
    final audio = Get.find<AudioController>();

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Text('RECITERS', style: AppTypography.labelSemibold),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(LucideIcons.x),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Obx(() {
                if (reciterController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (reciterController.error.value.isNotEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: ErrorStateView(
                        message: reciterController.error.value,
                        onRetry: reciterController.fetchReciters,
                      ),
                    ),
                  );
                }
                final reciters = reciterController.filteredReciters;
                if (reciters.isEmpty) {
                  return const Center(child: Text('No reciters available'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];
                    final isCurrent =
                        audio.currentTrack?.reciterName == reciter.name;
                    final imageAsset = AppAssets.reciterImage(reciter.id);

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: imageAsset != null
                            ? AssetImage(imageAsset)
                            : null,
                        child: imageAsset == null
                            ? const Icon(
                                LucideIcons.userRound,
                                color: AppColors.outline,
                              )
                            : null,
                      ),
                      title: Text(
                        reciter.name,
                        style: isCurrent
                            ? AppTypography.labelSemibold.copyWith(
                                color: AppColors.primary,
                              )
                            : AppTypography.labelSemibold,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        reciter.primaryMoshaf?.name ?? '',
                        style: AppTypography.bodyEnSm.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isCurrent
                          ? const Icon(
                              LucideIcons.play,
                              color: AppColors.primary,
                            )
                          : null,
                      onTap: () {
                        audio.playReciter(
                          reciter,
                          startSurahNumber: currentSurahNumber ?? 1,
                        );
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
