import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:qari_verse/core/storage/local_storage_service.dart';
import 'package:qari_verse/features/reading_progress/domain/reading_progress.dart';
import 'package:qari_verse/features/reading_progress/presentation/reading_progress_controller.dart';
import 'package:qari_verse/features/reading_progress/presentation/reading_statistics_page.dart';

class _Storage implements LocalStorageService {
  @override
  Map<String, dynamic>? readJson(String key) => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('statistics uses recorded history and fits a narrow phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    addTearDown(Get.reset);
    final controller = Get.put(ReadingProgressController(_Storage()));
    final now = DateTime.now();
    controller.progress.value = ReadingProgress()
        .mark(1, 1, now)
        .mark(1, 2, now)
        .mark(1, 1, DateTime(now.year, now.month, now.day - 1));
    await tester.pumpWidget(
      const GetMaterialApp(home: ReadingStatisticsPage()),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 day streak'), findsOneWidget);
    expect(find.text('2 unique verses marked read'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Last 7 days'), 200);
    expect(find.text('3 verses marked read'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
