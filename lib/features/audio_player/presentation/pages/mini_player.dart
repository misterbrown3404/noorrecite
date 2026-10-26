import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/audio_controller.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});
  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioController>();
    final colors = Theme.of(context).colorScheme;
    return Obx(() {
      final track = audio.currentTrack;
      if (track == null) return const SizedBox.shrink();
      final total = audio.duration.value.inMilliseconds;
      final fraction = total > 0
          ? (audio.position.value.inMilliseconds / total).clamp(0.0, 1.0)
          : 0.0;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Material(
          color: colors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 16,
                  end: 8,
                ),
                onTap: () => Get.toNamed(AppRoutes.audioPlayer),
                leading: Icon(
                  LucideIcons.audioLines,
                  color: colors.onPrimaryContainer,
                ),
                title: Text(
                  track.surahName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  track.reciterName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.onPrimaryContainer.withValues(alpha: .8),
                  ),
                ),
                trailing: audio.isBuffering.value
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        tooltip: audio.isPlaying.value ? 'Pause' : 'Play',
                        icon: Icon(
                          audio.isPlaying.value
                              ? LucideIcons.pause
                              : LucideIcons.play,
                          color: colors.onPrimaryContainer,
                        ),
                        onPressed: audio.togglePlayPause,
                      ),
              ),
              LinearProgressIndicator(
                value: fraction,
                minHeight: 3,
                color: colors.onPrimaryContainer,
                backgroundColor: Colors.transparent,
              ),
            ],
          ),
        ),
      );
    });
  }
}
