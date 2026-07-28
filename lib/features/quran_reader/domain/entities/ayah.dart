import 'package:equatable/equatable.dart';

/// A single verse within a surah. Text and translation are served offline from
/// the bundled `quran` package, so no network snapshot is involved.
class Ayah extends Equatable {
  const Ayah({
    required this.surahId,
    required this.number,
    required this.arabic,
    required this.translation,
  });

  final int surahId;
  final int number;
  final String arabic;
  final String translation;

  @override
  List<Object> get props => [surahId, number];
}
