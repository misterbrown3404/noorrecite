import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

import '../error/crash_reporter.dart';

/// Materializes bundled image assets to on-disk files so they can be used as
/// `MediaItem.artUri` on the lock-screen / notification media card.
///
/// `just_audio_background` (and the underlying platform media sessions) require
/// a `file://`, `content://`, or `http(s)://` URI for artwork — it cannot read
/// a Flutter `asset:` path directly. This copies the asset into the app-support
/// directory once and hands back a `file://` URI, caching the result in memory
/// so a long single-reciter queue resolves each distinct portrait exactly once.
class MediaArtworkService {
  MediaArtworkService._();
  static final MediaArtworkService instance = MediaArtworkService._();

  /// asset path → materialized `file://` URI.
  final Map<String, Uri> _cache = {};
  Directory? _dir;

  Future<Directory> _artDir() async {
    final cached = _dir;
    if (cached != null) return cached;
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}/artwork');
    if (!await dir.exists()) await dir.create(recursive: true);
    _dir = dir;
    return dir;
  }

  /// Returns a `file://` URI for [assetPath], copying it to disk on first use.
  /// Returns null if the asset can't be loaded — artwork is optional, so the
  /// caller simply omits it and the media card falls back to the app icon.
  Future<Uri?> uriForAsset(String assetPath) async {
    final hit = _cache[assetPath];
    if (hit != null) return hit;
    try {
      final dir = await _artDir();
      final name = assetPath.split('/').last;
      final file = File('${dir.path}/$name');
      if (!await file.exists()) {
        final data = await rootBundle.load(assetPath);
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }
      final uri = Uri.file(file.path);
      _cache[assetPath] = uri;
      return uri;
    } catch (e, s) {
      CrashReporter.instance.recordError(
        e,
        s,
        reason: 'artwork materialize: $assetPath',
      );
      return null;
    }
  }
}
