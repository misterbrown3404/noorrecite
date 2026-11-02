import 'dart:io';
import 'dart:convert';
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
    expect(categories.expand((e) => e.entries).length, 287);
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
    final evening = categories[1].entries[2];
    expect(morning.transliteration, contains('Morning:'));
    expect(morning.transliteration, isNot(contains('Evening:')));
    expect(evening.transliteration, contains('Evening:'));
    expect(evening.transliteration, isNot(contains('Morning:')));
    expect(morning.text, startsWith('أَصْبَحْنَا'));
    expect(evening.text, startsWith('أَمْسَيْنَا'));
    expect(morning.audio.single.asset, endsWith('OD-077-1.mp3'));
    expect(evening.audio.single.asset, endsWith('OD-077-2.mp3'));
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
  test(
    'morning and evening select matching content and audio throughout',
    () async {
      final categories = await WorshipRepository().categories();
      final generated = jsonDecode(
        File('assets/azkar/azkar_en.json').readAsStringSync(),
      );
      final source = jsonDecode(
        File('assets/azkar/catalogue.json').readAsStringSync(),
      );
      final catalogue = {
        for (final e in source['entries']) e['sourceReference']: e,
      };
      for (final id in [1, 2]) {
        final category = categories.firstWhere((c) => c.id == id);
        final period = id == 1 ? 'morning' : 'evening';
        final opposite = id == 1 ? 'Evening:' : 'Morning:';
        final mapped = (generated['categories'] as List).firstWhere(
          (c) => c['id'] == id,
        );
        final expected = (mapped['entries'] as List)
            .where((e) => e['applicable'] != false)
            .toList();
        expect(category.entries.length, id == 1 ? 23 : 21);
        final refs = expected.map((e) => e['source_reference']).toSet();
        expect(refs.contains('97'), id == 2);
        for (final ref in ['93', '94', '95']) {
          expect(refs.contains(ref), id == 1);
        }
        for (var i = 0; i < expected.length; i++) {
          final entry = category.entries[i];
          final raw = expected[i];
          expect(entry.translation, isNot(contains(opposite)));
          expect(entry.transliteration ?? '', isNot(contains(opposite)));
          final variants =
              catalogue[raw['source_reference']]['variations'] as List? ?? [];
          final matching = variants.where((v) => v['id'] == period);
          if (matching.isNotEmpty) {
            final steps = matching.single['steps'] as List;
            final recitations = steps.where((s) => s['type'] == 'recitation');
            final arabic = recitations
                .expand((s) => s['items'])
                .map((i) => i['dua']['arabic'])
                .join('\n\n');
            expect(entry.text, arabic);
            final recordings = recitations.expand((s) => s['recordings'] ?? []);
            expect(
              entry.audio.map((a) => a.asset.split('/').last),
              recordings.map((r) => r['url'].split('/').last),
            );
          }
        }
      }
    },
  );
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
