import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../audio_player/domain/entities/audio_track.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../controllers/download_controller.dart';

class DownloadCenterPage extends StatelessWidget {
  const DownloadCenterPage({super.key});
  @override
  Widget build(BuildContext context) {
    final downloads = Get.find<DownloadController>();
    final settings = Get.find<SettingsController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        toolbarHeight: 80,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'Clear downloads',
              onPressed: downloads.count == 0
                  ? null
                  : () async {
                      final remove = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear all downloads?'),
                          content: const Text(
                            'Saved audio will be removed from this device.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Keep'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Clear all'),
                            ),
                          ],
                        ),
                      );
                      if (remove == true) await downloads.clearAll();
                    },
              icon: const Icon(LucideIcons.trash),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        final groups = downloads.byReciter.entries.toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 160),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ready wherever you are',
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _formatBytes(downloads.totalBytes),
                          style: TextStyle(
                            color: colors.onPrimaryContainer,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${downloads.count} saved recitations',
                          style: TextStyle(color: colors.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    LucideIcons.circleCheck,
                    size: 44,
                    color: colors.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile(
                secondary: Icon(LucideIcons.wifiOff, color: colors.primary),
                title: const Text(
                  'Offline mode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Play downloaded audio only'),
                value: settings.offlineMode.value,
                onChanged: settings.setOfflineMode,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Your downloads',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    Icon(
                      LucideIcons.cloudDownload,
                      size: 54,
                      color: colors.primary,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Take your recitations with you',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Download a surah from the player to listen offline.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: () => Get.toNamed(AppRoutes.reciters),
                      child: const Text('Browse reciters'),
                    ),
                  ],
                ),
              ),
            for (final group in groups)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Material(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  clipBehavior: Clip.antiAlias,
                  child: ExpansionTile(
                    key: PageStorageKey('downloads-${group.key}'),
                    initiallyExpanded: groups.length == 1,
                    shape: const Border(),
                    collapsedShape: const Border(),
                    tilePadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                      child: const Icon(LucideIcons.speech),
                    ),
                    title: Text(
                      group.value.first.reciterName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${group.value.length} surahs · ${_formatBytes(group.value.fold<int>(0, (sum, item) => sum + item.sizeBytes))}',
                    ),
                    children: [
                      for (final item in group.value)
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          leading: Icon(
                            LucideIcons.circlePlay,
                            color: colors.primary,
                            size: 32,
                          ),
                          title: Text(
                            item.surahName,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(_formatBytes(item.sizeBytes)),
                          onTap: () {
                            final tracks = group.value
                                .map(
                                  (i) => AudioTrack(
                                    surahNumber: i.surahNumber,
                                    surahName: i.surahName,
                                    reciterId: i.reciterId,
                                    reciterName: i.reciterName,
                                    moshafName: i.moshafName,
                                    url: i.url,
                                  ),
                                )
                                .toList();
                            final index = tracks.indexWhere(
                              (track) => track.id == item.id,
                            );
                            Get.find<AudioController>().setQueue(
                              tracks,
                              startIndex: index < 0 ? 0 : index,
                            );
                            Get.toNamed(AppRoutes.audioPlayer);
                          },
                          trailing: IconButton(
                            tooltip: 'Remove download',
                            icon: const Icon(LucideIcons.trash2, size: 20),
                            onPressed: () async {
                              final remove = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Remove download?'),
                                  content: Text(item.surahName),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Keep'),
                                    ),
                                    FilledButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              );
                              if (remove == true) {
                                await downloads.remove(item.id);
                              }
                            },
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
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
