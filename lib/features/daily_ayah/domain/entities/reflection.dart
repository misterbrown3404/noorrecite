/// A user's personal reflection note on a specific verse, persisted on-device.
/// One reflection per verse — keyed by [surahId]-[ayahNumber].
class Reflection {
  Reflection({
    required this.surahId,
    required this.ayahNumber,
    required this.reference,
    required this.note,
    required this.savedAtMs,
  });

  final int surahId;
  final int ayahNumber;
  final String reference;
  final String note;
  final int savedAtMs;

  /// Stable per-verse key used both as the storage map key and for lookups.
  String get verseKey => '$surahId-$ayahNumber';

  factory Reflection.fromJson(Map<String, dynamic> json) => Reflection(
        surahId: json['surahId'] as int,
        ayahNumber: json['ayahNumber'] as int,
        reference: json['reference'] as String? ?? '',
        note: json['note'] as String? ?? '',
        savedAtMs: json['savedAtMs'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'ayahNumber': ayahNumber,
        'reference': reference,
        'note': note,
        'savedAtMs': savedAtMs,
      };
}
