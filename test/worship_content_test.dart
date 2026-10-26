import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/features/azkar/data/worship_repository.dart';
import 'package:qari_verse/features/azkar/presentation/pages/allah_names_page.dart';
import 'package:qari_verse/features/azkar/presentation/pages/azkar_category_page.dart';

class _NamesRepository extends WorshipRepository {
  _NamesRepository(this.items);
  final List<AllahName> items;
  @override
  Future<List<AllahName>> names() async => items;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('bundled worship collections parse completely', () async {
    final repository = WorshipRepository();
    final names = await repository.names();
    expect(names.map((e) => e.number), List.generate(99, (i) => i + 1));
    for (final name in names) {
      expect(name.arabic, isNotEmpty);
      expect(name.meaning, isNotEmpty);
      expect(name.transliteration, isNotEmpty);
    }
    final categories = await repository.categories();
    expect(categories.length, 133);
    expect(categories.map((e) => e.id).toSet().length, 133);
    expect(categories.expand((e) => e.entries).length, 291);
    expect(categories.first.title, 'أذكار الصباح');
    expect(categories[1].title, 'أذكار المساء');
    for (final category in categories) {
      expect(category.entries, isNotEmpty);
      expect(category.englishTitle, isNotEmpty);
      expect(category.transliteration, isNotEmpty);
      for (final entry in category.entries) {
        expect(entry.text, isNotEmpty);
        expect(entry.translation, isNotEmpty);
        for (final track in entry.audio) {
          expect(File(track.asset).existsSync(), isTrue, reason: track.asset);
        }
        expect(entry.count, greaterThanOrEqualTo(0));
      }
    }
    final morning = categories.first.entries[2];
    expect(morning.transliteration, contains('Morning:'));
    expect(morning.transliteration, contains('Evening:'));
    expect(
      morning.audio.map((e) => e.asset),
      containsAll([
        'assets/audio/azkar_audio/opendua-audio-hisn-v0.0.2/OD-077-1.mp3',
        'assets/audio/azkar_audio/opendua-audio-hisn-v0.0.2/OD-077-2.mp3',
      ]),
    );
    final safa = categories.firstWhere((c) => c.id == 119).entries.first;
    expect(safa.audio.length, 3);
    expect(safa.translation, contains('defeated the allied forces'));
    final duas = await repository.duas();
    expect(duas, isNotEmpty);
    for (final dua in duas) {
      expect(dua.arabic, isNotEmpty);
      expect(dua.translation, isNotEmpty);
      expect(dua.reference, isNotEmpty);
    }
  });
  test('Arabic search ignores diacritics and alef variations', () {
    expect(normalizeWorshipSearch('الرَّحْمَنُ'), 'الرحمن');
    expect(normalizeWorshipSearch('أذكار'), 'اذكار');
  });
  testWidgets('99 Names supports meaning, Arabic and empty searches', (
    tester,
  ) async {
    final names = await tester.runAsync(() => WorshipRepository().names());
    await tester.pumpWidget(
      MaterialApp(home: AllahNamesPage(repository: _NamesRepository(names!))),
    );
    await tester.pumpAndSettle();
    expect(find.text('99 of 99'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Beneficent');
    await tester.pumpAndSettle();
    expect(find.text('1 of 99'), findsOneWidget);
    expect(find.text('Ar Rahmaan'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'الرحمن');
    await tester.pumpAndSettle();
    expect(find.text('1 of 99'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'zzzzzz');
    await tester.pumpAndSettle();
    expect(
      find.text('No matches. Try another name or phrase.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('reader can hide English and pronunciation independently', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AzkarCategoryPage(
          category: AzkarCategory(
            id: 1,
            title: 'أذكار',
            englishTitle: 'Remembrance',
            entries: [
              Dhikr(
                text: 'الحمد لله',
                count: 1,
                translation: 'All praise is for Allah.',
                transliteration: 'Al-hamdu lillah',
                audio: [DhikrAudio(asset: 'test.mp3', label: 'Morning')],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('All praise is for Allah.'), findsOneWidget);
    expect(find.text('Al-hamdu lillah'), findsOneWidget);
    expect(find.text('Listen · Morning'), findsOneWidget);
    await tester.tap(find.text('English meaning'));
    await tester.pumpAndSettle();
    expect(find.text('All praise is for Allah.'), findsNothing);
    expect(find.text('Al-hamdu lillah'), findsOneWidget);
    await tester.tap(find.text('Pronunciation'));
    await tester.pumpAndSettle();
    expect(find.text('Al-hamdu lillah'), findsNothing);
    expect(find.text('الحمد لله'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('category counters preserve independent entries and undo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AzkarCategoryPage(
          category: AzkarCategory(
            id: 1,
            title: 'أذكار',
            entries: [
              Dhikr(text: 'الحمد لله', count: 3),
              Dhikr(text: 'سبحان الله', count: 1),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Count: 0 · Tap to count').first);
    await tester.pump();
    expect(find.text('Count: 1 · Tap to count'), findsOneWidget);
    expect(find.text('Count: 0 · Tap to count'), findsOneWidget);
    await tester.tap(find.text('Undo last tap'));
    await tester.pump();
    expect(find.text('Count: 0 · Tap to count'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
