import 'package:get/get.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../audio_player/domain/entities/audio_track.dart';

class SavedPlaylist {
  const SavedPlaylist({
    required this.id,
    required this.name,
    required this.tracks,
  });
  final String id;
  final String name;
  final List<AudioTrack> tracks;
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tracks': tracks.map((t) => t.toJson()).toList(),
  };
  factory SavedPlaylist.fromJson(Map<String, dynamic> json) => SavedPlaylist(
    id: json['id'] as String,
    name: json['name'] as String,
    tracks: (json['tracks'] as List)
        .map((t) => AudioTrack.fromJson(Map<String, dynamic>.from(t as Map)))
        .toList(),
  );
}

class PlaylistsController extends GetxController {
  PlaylistsController(this.storage) {
    for (final json in storage.readJsonList('playlists_v1')) {
      try {
        playlists.add(SavedPlaylist.fromJson(json));
      } catch (_) {
        /* Skip malformed entries without losing other playlists. */
      }
    }
  }
  final LocalStorageService storage;
  final playlists = <SavedPlaylist>[].obs;
  Future<void> save(String name, List<AudioTrack> tracks) async {
    if (name.trim().isEmpty || tracks.isEmpty) return;
    final next = [
      ...playlists,
      SavedPlaylist(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name.trim(),
        tracks: List.of(tracks),
      ),
    ];
    await storage.writeJsonList(
      'playlists_v1',
      next.map((p) => p.toJson()).toList(),
    );
    playlists.assignAll(next);
  }

  Future<void> remove(String id) async {
    final next = playlists.where((p) => p.id != id).toList();
    await storage.writeJsonList(
      'playlists_v1',
      next.map((p) => p.toJson()).toList(),
    );
    playlists.assignAll(next);
  }
}
