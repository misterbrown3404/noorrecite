import 'package:equatable/equatable.dart';

/// A single playable item: one surah recited by one reciter (one moshaf).
class AudioTrack extends Equatable {
  const AudioTrack({
    required this.surahNumber,
    required this.surahName,
    required this.reciterId,
    required this.reciterName,
    required this.moshafName,
    required this.url,
  });

  final int surahNumber;
  final String surahName;
  final int reciterId;
  final String reciterName;
  final String moshafName;
  final String url;

  /// Stable id used by the audio playlist (unique per surah+reciter+moshaf).
  String get id => '$reciterId-$moshafName-$surahNumber';

  Map<String, dynamic> toJson() => {
    'surahNumber': surahNumber,
    'surahName': surahName,
    'reciterId': reciterId,
    'reciterName': reciterName,
    'moshafName': moshafName,
    'url': url,
  };

  factory AudioTrack.fromJson(Map<String, dynamic> json) => AudioTrack(
    surahNumber: json['surahNumber'] as int,
    surahName: json['surahName'] as String,
    reciterId: json['reciterId'] as int,
    reciterName: json['reciterName'] as String,
    moshafName: json['moshafName'] as String,
    url: json['url'] as String,
  );

  @override
  List<Object> get props => [id];
}
