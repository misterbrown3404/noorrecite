import 'package:equatable/equatable.dart';

/// The most recently opened surah, persisted locally for "continue reading".
///
/// Ayah-level position is stored for forward compatibility with a future
/// reader screen; today only the surah is tracked (defaults to ayah 1).
class LastRead extends Equatable {
  const LastRead({
    required this.surahId,
    required this.surahName,
    required this.pageStart,
    required this.pageEnd,
    this.ayah = 1,
    required this.savedAtMs,
  });

  final int surahId;
  final String surahName;
  final int pageStart;
  final int pageEnd;
  final int ayah;
  final int savedAtMs;

  /// Standard Madani mushaf length; used to express reading position.
  static const int mushafPages = 604;

  /// Rough position through the mushaf (0..1) based on the surah's last page.
  double get mushafProgress => (pageEnd / mushafPages).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'surahName': surahName,
        'pageStart': pageStart,
        'pageEnd': pageEnd,
        'ayah': ayah,
        'savedAtMs': savedAtMs,
      };

  factory LastRead.fromJson(Map<String, dynamic> json) => LastRead(
        surahId: json['surahId'] as int,
        surahName: json['surahName'] as String,
        pageStart: json['pageStart'] as int,
        pageEnd: json['pageEnd'] as int,
        ayah: (json['ayah'] as int?) ?? 1,
        savedAtMs: (json['savedAtMs'] as int?) ?? 0,
      );

  @override
  List<Object> get props => [surahId, ayah, savedAtMs];
}
