import 'package:equatable/equatable.dart';

/// A single downloaded surah recitation stored on-device. Mirrors the fields of
/// an `AudioTrack` plus the local [filePath] and [sizeBytes], so the audio
/// player can rebuild a playable track without any network call.
class DownloadItem extends Equatable {
  const DownloadItem({
    required this.surahNumber,
    required this.surahName,
    required this.reciterId,
    required this.reciterName,
    required this.moshafName,
    required this.url,
    required this.filePath,
    required this.sizeBytes,
    required this.savedAtMs,
  });

  final int surahNumber;
  final String surahName;
  final int reciterId;
  final String reciterName;
  final String moshafName;

  /// Original remote URL (kept so we can re-download or fall back to streaming).
  final String url;

  /// Absolute path to the downloaded mp3 on disk.
  final String filePath;
  final int sizeBytes;
  final int savedAtMs;

  /// Same identity scheme as `AudioTrack.id` so the two map 1:1.
  String get id => '$reciterId-$moshafName-$surahNumber';

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'surahName': surahName,
    'reciterId': reciterId,
    'reciterName': reciterName,
    'moshafName': moshafName,
    'url': url,
    'filePath': filePath,
    'sizeBytes': sizeBytes,
    'savedAtMs': savedAtMs,
  };

  factory DownloadItem.fromJson(Map<String, dynamic> json) => DownloadItem(
    surahNumber: json['surahNumber'] as int,
    surahName: json['surahName'] as String,
    reciterId: json['reciterId'] as int,
    reciterName: json['reciterName'] as String,
    moshafName: json['moshafName'] as String,
    url: json['url'] as String,
    filePath: json['filePath'] as String,
    sizeBytes: (json['sizeBytes'] as num).toInt(),
    savedAtMs: (json['savedAtMs'] as num).toInt(),
  );

  @override
  List<Object> get props => [id];
}
