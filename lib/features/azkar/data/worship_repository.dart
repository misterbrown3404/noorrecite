import 'dart:convert';
import 'package:flutter/services.dart';

String normalizeWorshipSearch(String value) => value
    .toLowerCase()
    .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '')
    .replaceAll(RegExp('[أإآ]'), 'ا')
    .replaceAll('ى', 'ي')
    .trim();

class Dhikr {
  const Dhikr({
    required this.text,
    required this.count,
    this.translation,
    this.transliteration,
    this.audio = const [],
  });
  final String? translation, transliteration;
  final List<DhikrAudio> audio;
  final String text;
  final int count;
  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
    text: json['text'] as String,
    count: json['count'] as int,
    translation: json['translation'] as String?,
    transliteration: json['transliteration'] as String?,
    audio: (json['audio_tracks'] as List? ?? [])
        .map(
          (e) => DhikrAudio(
            asset: e['asset'] as String,
            label: e['label'] as String,
          ),
        )
        .toList(),
  );
}

class DhikrAudio {
  const DhikrAudio({required this.asset, required this.label});
  final String asset, label;
}

class AzkarCategory {
  const AzkarCategory({
    required this.id,
    required this.title,
    required this.entries,
    this.englishTitle,
    this.transliteration,
  });
  final int id;
  final String title;
  final String? englishTitle, transliteration;
  final List<Dhikr> entries;
  String get displayTitle => switch (id) {
    1 => 'Morning Azkar',
    2 => 'Evening Azkar',
    3 => 'Before sleeping',
    4 => 'Waking up',
    _ => englishTitle ?? title,
  };
  factory AzkarCategory.fromJson(Map<String, dynamic> json) => AzkarCategory(
    id: json['id'] as int,
    title: json['category'] as String,
    englishTitle: json['english_title'] as String?,
    transliteration: json['transliteration'] as String?,
    entries: (json['array'] as List)
        .map((e) => Dhikr.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

class Dua {
  const Dua({
    required this.title,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.reference,
  });
  final String title, arabic, transliteration, translation, reference;
  factory Dua.fromJson(Map<String, dynamic> json) => Dua(
    title: json['title'] as String,
    arabic: json['arabic'] as String,
    transliteration: json['transliteration'] as String,
    translation: json['translation'] as String,
    reference: json['reference'] as String,
  );
  String get searchText =>
      '$title $arabic $transliteration $translation $reference';
}

class AllahName {
  const AllahName({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.meaning,
  });
  final int number;
  final String arabic, transliteration, meaning;
  factory AllahName.fromJson(Map<String, dynamic> json) => AllahName(
    number: json['number'] as int,
    arabic: json['name'] as String,
    transliteration: (json['transliteration'] as String).trim(),
    meaning: (json['en'] as Map<String, dynamic>)['meaning'] as String,
  );
  String get searchText => '$number $arabic $transliteration $meaning';
}

class WorshipRepository {
  WorshipRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;
  final AssetBundle _bundle;
  Future<dynamic> _read(String name) async =>
      jsonDecode(await _bundle.loadString('assets/azkar/$name.json'));
  Future<List<AzkarCategory>> categories() async {
    final data = await Future.wait([_read('azkar'), _read('azkar_en')]);
    final english = {for (final c in data[1]['categories'] as List) c['id']: c};
    return (data[0] as List).map((raw) {
      final category = Map<String, dynamic>.from(raw as Map);
      final translated = english[category['id']];
      if (translated == null) {
        throw const FormatException('Missing English category');
      }
      category['english_title'] = translated['title'];
      category['transliteration'] = translated['transliteration'];
      final entries = {
        for (final e in translated['entries'] as List) e['id']: e,
      };
      category['array'] = (category['array'] as List).map((rawEntry) {
        final entry = Map<String, dynamic>.from(rawEntry as Map);
        final en = entries[entry['id']];
        if (en == null || en['arabic'] != entry['text']) {
          throw const FormatException(
            'English content does not match the Arabic entry',
          );
        }
        entry['translation'] = en['translation'];
        entry['transliteration'] = en['transliteration'];
        entry['audio_tracks'] = en['audio'];
        return entry;
      }).toList();
      return AzkarCategory.fromJson(category);
    }).toList();
  }

  Future<List<Dua>> duas() async => ((await _read('dua'))['Dua'] as List)
      .map((e) => Dua.fromJson(e as Map<String, dynamic>))
      .toList();
  Future<List<AllahName>> names() async {
    final names = ((await _read('asmaAlHusna'))['data'] as List)
        .map((e) => AllahName.fromJson(e as Map<String, dynamic>))
        .toList();
    names.sort((a, b) => a.number.compareTo(b.number));
    return names;
  }
}
