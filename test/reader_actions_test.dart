import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:qari_verse/core/storage/local_storage_service.dart';
import 'package:qari_verse/features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import 'package:qari_verse/features/reading_progress/presentation/reading_progress_controller.dart';
import 'package:qari_verse/features/quran_reader/domain/entities/ayah.dart';
import 'package:qari_verse/features/quran_reader/domain/entities/surah.dart';
import 'package:qari_verse/features/quran_reader/domain/usecases/get_ayat.dart';
import 'package:qari_verse/features/quran_reader/presentation/controllers/ayah_controller.dart';
import 'package:qari_verse/features/quran_reader/presentation/pages/ayah_reader_page.dart';

class _Storage implements LocalStorageService {
  List<Map<String, dynamic>> saved = [];
  bool fail = false;
  @override
  List<Map<String, dynamic>> readJsonList(String key) => saved;
  @override
  Map<String, dynamic>? readJson(String key) => null;
  @override
  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    if (fail) throw Exception('disk unavailable');
    saved = value;
  }

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _UnusedAyat implements GetAyat {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Reader extends AyahController {
  _Reader() : super(_UnusedAyat());
  @override
  void onInit() {
    super.onInit();
    error('');
    surah.value = const Surah(
      id: 1,
      name: 'Al-Fatihah',
      startPage: 1,
      endPage: 1,
      type: RevelationType.makkah,
      juz: 1,
    );
    ayat.assignAll([
      const Ayah(
        surahId: 1,
        number: 1,
        arabic: 'بسم الله',
        translation: 'In the name of Allah',
      ),
    ]);
    isLoading(false);
  }
}

void main() {
  testWidgets(
    'reader bookmarks persist, read state changes, and preferences work',
    (tester) async {
      final storage = _Storage();
      final bookmarks = Get.put(BookmarksController(storage));
      Get.put(ReadingProgressController(storage));
      Get.put<AyahController>(_Reader());
      addTearDown(Get.reset);
      await tester.pumpWidget(
        GetMaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: child!,
          ),
          home: const AyahReaderPage(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byTooltip('Bookmark verse'));
      await tester.tap(find.byTooltip('Bookmark verse'));
      await tester.pumpAndSettle();
      expect(bookmarks.isBookmarked(1, 1), isTrue);
      expect(storage.saved.length, 1);
      expect(find.byIcon(LucideIcons.bookmarkCheck), findsOneWidget);
      await tester.tap(find.byTooltip('Remove bookmark'));
      await tester.pumpAndSettle();
      expect(storage.saved, isEmpty);
      storage.fail = true;
      await tester.tap(find.byTooltip('Bookmark verse'));
      await tester.pumpAndSettle();
      expect(bookmarks.isBookmarked(1, 1), isFalse);
      expect(
        find.text('Could not save bookmark. Please try again.'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Mark verse read'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Marked read'), findsOneWidget);
      expect(find.byIcon(LucideIcons.circleCheck), findsOneWidget);
      await tester.tap(find.byTooltip('Reading preferences'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      Get.back();
      await tester.pumpAndSettle();
      expect(find.text('In the name of Allah'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
