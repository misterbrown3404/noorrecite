import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../audio_player/presentation/controllers/audio_controller.dart';
import 'playlists_controller.dart';

class PlaylistsSheet extends StatelessWidget {
  const PlaylistsSheet({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PlaylistsController>();
    final audio = Get.find<AudioController>();
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          children: [
            ListTile(
              title: Text(
                'Your playlists',
                style: Theme.of(context).textTheme.titleLarge,
              ),

              leading: Icon(LucideIcons.library, color: colors.primary),
              trailing: IconButton.filledTonal(
                tooltip: 'Save current queue',
                icon: const Icon(LucideIcons.listPlus),
                onPressed: () => _save(context, audio, controller),
              ),
            ),
            Expanded(
              child: Obx(
                () => controller.playlists.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  LucideIcons.listMusic,
                                  size: 42,
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Your listening, collected.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Save your current queue to listen again.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              FilledButton.icon(
                                onPressed: () =>
                                    _save(context, audio, controller),
                                icon: const Icon(LucideIcons.plus),
                                label: const Text('Create playlist'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                        itemCount: controller.playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = controller.playlists[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Material(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(20),
                              clipBehavior: Clip.antiAlias,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: colors.primaryContainer,
                                  foregroundColor: colors.onPrimaryContainer,
                                  child: const Icon(LucideIcons.play),
                                ),
                                title: Text(playlist.name),
                                subtitle: Text(
                                  '${playlist.tracks.length} tracks',
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  audio.setQueue(playlist.tracks);
                                },
                                trailing: IconButton(
                                  tooltip: 'Delete playlist',
                                  icon: const Icon(LucideIcons.trash2),
                                  onPressed: () async {
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete playlist?'),
                                        content: Text(
                                          'Remove “${playlist.name}”? Downloaded audio will remain available.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmed == true) {
                                      await controller.remove(playlist.id);
                                    }
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(
    BuildContext context,
    AudioController audio,
    PlaylistsController controller,
  ) async {
    if (audio.queue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start a listening session before saving a playlist.'),
        ),
      );
      return;
    }
    final name = TextEditingController();
    final tracks = List.of(audio.queue);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save this queue'),
        content: TextField(
          controller: name,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isNotEmpty) {
                Navigator.pop(context, name.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    // Dispose after the dialog route finishes its reverse transition.
    Future.delayed(const Duration(seconds: 1), name.dispose);
    if (result != null) await controller.save(result, tracks);
  }
}
