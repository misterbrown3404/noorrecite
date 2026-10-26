import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Handles MP3 file downloads, deletions, and size queries.
/// Pure I/O — no state; callers own progress tracking.
///
/// Storage: `getApplicationSupportDirectory()/noorrecite_audio/`
///   - iOS  → `Library/Application Support/noorrecite_audio/`
///             Private, not user-browsable, excluded from iCloud backup
///             via `NSURLIsExcludedFromBackupKey` (set after each download).
///   - Android → `data/data/&lt;pkg&gt;/files/noorrecite_audio/`
///             Private internal storage, inaccessible to other apps.
/// Both satisfy App Store / Play Store policies for privately cached,
/// re-downloadable media content.
class DownloadFileService {
  DownloadFileService(this._dio);

  final Dio _dio;

  static const _channel = MethodChannel('net.mp3quran.noorrecite/storage');

  Future<Directory> _audioDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/noorrecite_audio');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// Downloads [url] to the private audio directory.
  /// Returns the absolute [filePath] and [sizeBytes] on completion.
  /// [onProgress] receives values in [0.0, 1.0].
  Future<({String filePath, int sizeBytes})> download(
    String url,
    String fileName, {
    void Function(double progress)? onProgress,
    CancelToken? cancelToken,
  }) async {
    final dir = await _audioDir();
    final filePath = '${dir.path}/$fileName';

    await _dio.download(
      url,
      filePath,
      cancelToken: cancelToken,
      options: Options(receiveTimeout: const Duration(minutes: 10)),
      onReceiveProgress: onProgress == null
          ? null
          : (received, total) {
              if (total > 0) onProgress(received / total);
            },
    );

    // iOS: mark file as excluded from iCloud backup.
    // Apple rejects apps that back up large re-downloadable content
    // (App Store Review Guideline 2.23). The native side sets
    // NSURLIsExcludedFromBackupKey via URLResourceValues.
    if (Platform.isIOS) {
      await _channel.invokeMethod<void>('excludeFromBackup', filePath);
    }

    final sizeBytes = File(filePath).lengthSync();
    return (filePath: filePath, sizeBytes: sizeBytes);
  }

  /// Deletes the file at [filePath]. No-op if already absent.
  Future<void> delete(String filePath) async {
    final file = File(filePath);
    if (file.existsSync()) await file.delete();
  }

  /// Returns true if the file at [filePath] exists on disk.
  bool exists(String filePath) => File(filePath).existsSync();
}
