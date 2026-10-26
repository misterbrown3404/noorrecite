import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../audio_player/domain/entities/audio_track.dart';
import '../../data/services/download_file_service.dart';
import '../../domain/entities/download_item.dart';

/// Owns the offline-download library: the manifest of completed downloads
/// (persisted as a JSON list under [StorageKeys.downloads]) plus live download
/// progress for in-flight items.
///
/// Permanent singleton (GetIt + GetX) so downloads survive navigation and can
/// be triggered from the audio player while surfaced in the Download Center.
class DownloadController extends GetxController {
  DownloadController(this._storage, this._files);

  final LocalStorageService _storage;
  final DownloadFileService _files;

  /// Completed downloads keyed by [DownloadItem.id] (same scheme as AudioTrack).
  final items = <String, DownloadItem>{}.obs;

  /// Live progress in [0.0, 1.0] for in-flight downloads, keyed by track id.
  final progress = <String, double>{}.obs;

  final _cancelTokens = <String, CancelToken>{};

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    final raw = _storage.readJsonList(StorageKeys.downloads);
    for (final json in raw) {
      final item = DownloadItem.fromJson(json);
      // Drop stale entries whose file was removed outside the app.
      if (_files.exists(item.filePath)) {
        items[item.id] = item;
      }
    }
  }

  // --- Queries ------------------------------------------------------------

  bool isDownloaded(String trackId) => items.containsKey(trackId);

  bool isDownloading(String trackId) => progress.containsKey(trackId);

  DownloadItem? itemFor(String trackId) => items[trackId];

  /// Total bytes of all completed downloads.
  int get totalBytes =>
      items.values.fold(0, (sum, item) => sum + item.sizeBytes);

  int get count => items.length;

  /// Completed downloads grouped by reciter, newest reciter activity first.
  Map<int, List<DownloadItem>> get byReciter {
    final grouped = <int, List<DownloadItem>>{};
    for (final item in items.values) {
      grouped.putIfAbsent(item.reciterId, () => []).add(item);
    }
    for (final list in grouped.values) {
      list.sort((a, b) => a.surahNumber.compareTo(b.surahNumber));
    }
    return grouped;
  }

  // --- Actions ------------------------------------------------------------

  /// Downloads the MP3 for [track] and records it in the manifest.
  /// No-op if already downloaded or currently downloading.
  Future<void> downloadTrack(AudioTrack track) async {
    if (isDownloaded(track.id) || isDownloading(track.id)) return;

    final cancelToken = CancelToken();
    _cancelTokens[track.id] = cancelToken;
    progress[track.id] = 0;

    try {
      final result = await _files.download(
        track.url,
        '${track.id}.mp3',
        cancelToken: cancelToken,
        onProgress: (p) => progress[track.id] = p,
      );

      final item = DownloadItem(
        surahNumber: track.surahNumber,
        surahName: track.surahName,
        reciterId: track.reciterId,
        reciterName: track.reciterName,
        moshafName: track.moshafName,
        url: track.url,
        filePath: result.filePath,
        sizeBytes: result.sizeBytes,
        savedAtMs: DateTime.now().millisecondsSinceEpoch,
      );
      items[track.id] = item;
      await _persist();
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) {
        Get.snackbar(
          'Download failed',
          'Could not download ${track.surahName}. Check your connection.',
        );
      }
    } catch (_) {
      Get.snackbar('Download failed', 'Could not save ${track.surahName}.');
    } finally {
      progress.remove(track.id);
      _cancelTokens.remove(track.id);
    }
  }

  /// Cancels an in-flight download.
  void cancelDownload(String trackId) {
    _cancelTokens[trackId]?.cancel();
    _cancelTokens.remove(trackId);
    progress.remove(trackId);
  }

  /// Removes a single download (file + manifest entry).
  Future<void> remove(String trackId) async {
    final item = items[trackId];
    if (item == null) return;
    await _files.delete(item.filePath);
    items.remove(trackId);
    await _persist();
  }

  /// Removes every download (files + manifest).
  Future<void> clearAll() async {
    for (final item in items.values.toList()) {
      await _files.delete(item.filePath);
    }
    items.clear();
    await _persist();
  }

  Future<void> _persist() => _storage.writeJsonList(
    StorageKeys.downloads,
    items.values.map((e) => e.toJson()).toList(),
  );
}
