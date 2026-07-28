import 'package:quran/quran.dart' as quran;

import '../../domain/entities/ayah.dart';

class AyahModel extends Ayah {
  const AyahModel({
    required super.surahId,
    required super.number,
    required super.arabic,
    required super.translation,
  });

  /// Builds an ayah straight from the offline `quran` package data
  /// (Saheeh International translation — the app default).
  factory AyahModel.fromQuran(int surahId, int verse) => AyahModel(
        surahId: surahId,
        number: verse,
        arabic: quran.getVerse(surahId, verse),
        translation: quran.getVerseTranslation(
          surahId,
          verse,
          translation: quran.Translation.enSaheeh,
        ),
      );
}
