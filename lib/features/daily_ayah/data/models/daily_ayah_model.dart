import 'package:quran/quran.dart' as quran;

import '../../domain/entities/daily_ayah.dart';

class DailyAyahModel {
  static DailyAyah forToday() {
    final now = DateTime.now();
    final seed = now.year * 10000 + now.month * 100 + now.day;
    final totalSurahs = quran.totalSurahCount;
    final surahId = (seed % totalSurahs) + 1;
    final ayahCount = quran.getVerseCount(surahId);
    final ayahNumber = (seed % ayahCount) + 1;
    return DailyAyah(
      surahId: surahId,
      ayahNumber: ayahNumber,
      arabic: quran.getVerse(surahId, ayahNumber),
      translation: quran.getVerseTranslation(
        surahId,
        ayahNumber,
        translation: quran.Translation.enSaheeh,
      ),
      reference: '${quran.getSurahName(surahId)} $surahId:$ayahNumber',
    );
  }
}