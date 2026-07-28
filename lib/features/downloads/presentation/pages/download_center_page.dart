import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../audio_player/domain/entities/audio_track.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/download_item.dart';
import '../controllers/download_controller.dart';

/// Download center: real offline library backed by [DownloadController].
/// Shows storage usage, downloads grouped by reciter with per-item delete,
/// a clear-all action, an empty state, and a persisted offline-mode toggle.
class DownloadCenterPage extends StatelessWidget {
  const DownloadCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<DownloadController>();
    final settings = Get.find<SettingsController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Downloads', style: AppTypography.titleLg),
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
          child: Obx(() {
            final grouped = downloads.byReciter;
            return ListView(
              padding: const EdgeInsets.only(bottom: 40),
              children: [
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage your offline Quranic library',
                        style: AppTypography.bodyEnSm,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _offlineToggle(settings),
                      const SizedBox(height: AppSpacing.lg),
                      _StorageCard(downloads: downloads),
                      const SizedBox(height: AppSpacing.lg),
                      if (grouped.isEmpty)
                        const _EmptyState()
                      else ...[
                        Text(
                          'DOWNLOADED BY RECITER',
                          style: AppTypography.labelCaps,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        for (final entry in grouped.entries) ...[
                          _ReciterDownloadGroup(
                            items: entry.value,
                            onRemove: downloads.remove,
                            onPlay: (item) {
                              final audio = Get.find<AudioController>();
                              final tracks = entry.value
                                  .map((i) => AudioTrack(
                                        surahNumber: i.surahNumber,
                                        surahName: i.surahName,
                                        reciterId: i.reciterId,
                                        reciterName: i.reciterName,
                                        moshafName: i.moshafName,
                                        url: i.url,
                                      ))
                                  .toList();
                              final idx = tracks.indexWhere(
                                (t) => t.id == item.id,
                              );
                              audio.setQueue(tracks, startIndex: idx < 0 ? 0 : idx);
                              Get.toNamed(AppRoutes.audioPlayer);
                            },
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ],
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _offlineToggle(SettingsController settings) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.primary,
            size: 24,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text('OFFLINE MODE', style: AppTypography.labelCaps),
          const Spacer(),
          Obx(
            () => Switch(
              value: settings.offlineMode.value,
              onChanged: settings.setOfflineMode,
              activeThumbColor: AppColors.primary,
              activeTrackColor: AppColors.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Human-readable byte size (KB / MB / GB).
String _formatBytes(int bytes) {
  if (bytes <= 0) return '0 MB';
  const kb = 1024;
  const mb = kb * 1024;
  const gb = mb * 1024;
  if (bytes >= gb) return '${(bytes / gb).toStringAsFixed(1)} GB';
  if (bytes >= mb) return '${(bytes / mb).toStringAsFixed(1)} MB';
  return '${(bytes / kb).toStringAsFixed(0)} KB';
}

class _StorageCard extends StatelessWidget {
  const _StorageCard({required this.downloads});

  final DownloadController downloads;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STORAGE USAGE', style: AppTypography.labelCaps),
                const SizedBox(height: AppSpacing.xs),
                Obx(
                  () => Text.rich(
                    TextSpan(
                      style: AppTypography.headlineLgMobile,
                      children: [
                        TextSpan(
                          text: '${_formatBytes(downloads.totalBytes)} ',
                        ),
                        TextSpan(
                          text:
                              '• ${downloads.count} ${downloads.count == 1 ? 'surah' : 'surahs'}',
                          style: AppTypography.bodyEnSm,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Obx(
            () => downloads.count == 0
                ? const SizedBox.shrink()
                : GhostGlassButton(
                    label: 'CLEAR ALL',
                    expand: false,
                    height: 36,
                    borderColor: AppColors.primary,
                    onPressed: () => _confirmClearAll(downloads),
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(DownloadController downloads) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear all downloads'),
        content: const Text(
          'This removes every downloaded surah from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              downloads.clearAll();
            },
            child: const Text('Clear all'),
          ),
        ],
      ),
    );
  }
}

class _ReciterDownloadGroup extends StatelessWidget {
  const _ReciterDownloadGroup({
    required this.items,
    required this.onRemove,
    required this.onPlay,
  });

  final List<DownloadItem> items;
  final Future<void> Function(String trackId) onRemove;
  final void Function(DownloadItem item) onPlay;

  @override
  Widget build(BuildContext context) {
    final reciterName = items.first.reciterName;
    final totalBytes = items.fold<int>(0, (s, i) => s + i.sizeBytes);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reciterName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLg.copyWith(
                        color: AppColors.primary,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${items.length} ${items.length == 1 ? 'surah' : 'surahs'} • ${_formatBytes(totalBytes)}',
                      style: AppTypography.bodyEnSm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  PressableScale(
                    onTap: () => onPlay(item),
                    child: const Icon(
                      Icons.play_circle_outline_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${item.surahNumber.toString().padLeft(3, '0')}  ${item.surahName}',
                      style: AppTypography.bodyEn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _formatBytes(item.sizeBytes),
                    style: AppTypography.bodyEnSm,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  PressableScale(
                    onTap: () => onRemove(item.id),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_download_outlined,
              color: AppColors.onSurfaceVariant,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No downloads yet',
              style: AppTypography.titleLg.copyWith(color: AppColors.primary),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap the download icon on the player to save a surah for offline listening.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyEnSm,
            ),
          ],
        ),
      ),
    );
  }
}
