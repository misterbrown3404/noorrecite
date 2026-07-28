import 'package:equatable/equatable.dart';

/// A saved ayah in the user's personal collection (privacy-friendly: stored
/// only on-device).
///
/// [isFavorite] distinguishes a plain bookmark from a favorited ayah so a
/// single store can back both the bookmarks list and the favorites filter.
class Bookmark extends Equatable {
  const Bookmark({
    required this.surahId,
    required this.surahName,
    required this.ayah,
    this.arabic = '',
    this.translation = '',
    this.reference = '',
    this.note = '',
    this.isFavorite = false,
    required this.savedAtMs,
  });

  final int surahId;
  final String surahName;
  final int ayah;
  final String arabic;
  final String translation;
  final String reference;
  final String note;
  final bool isFavorite;
  final int savedAtMs;

  /// Stable identity: one bookmark per surah+ayah.
  String get id => '$surahId:$ayah';

  Bookmark copyWith({String? note, bool? isFavorite}) => Bookmark(
        surahId: surahId,
        surahName: surahName,
        ayah: ayah,
        arabic: arabic,
        translation: translation,
        reference: reference,
        note: note ?? this.note,
        isFavorite: isFavorite ?? this.isFavorite,
        savedAtMs: savedAtMs,
      );

  Map<String, dynamic> toJson() => {
        'surahId': surahId,
        'surahName': surahName,
        'ayah': ayah,
        'arabic': arabic,
        'translation': translation,
        'reference': reference,
        'note': note,
        'isFavorite': isFavorite,
        'savedAtMs': savedAtMs,
      };

  factory Bookmark.fromJson(Map<String, dynamic> json) => Bookmark(
        surahId: json['surahId'] as int,
        surahName: (json['surahName'] as String?) ?? '',
        ayah: json['ayah'] as int,
        arabic: (json['arabic'] as String?) ?? '',
        translation: (json['translation'] as String?) ?? '',
        reference: (json['reference'] as String?) ?? '',
        note: (json['note'] as String?) ?? '',
        isFavorite: (json['isFavorite'] as bool?) ?? false,
        savedAtMs: (json['savedAtMs'] as int?) ?? 0,
      );

  @override
  List<Object> get props => [id, isFavorite, note, savedAtMs];
}
