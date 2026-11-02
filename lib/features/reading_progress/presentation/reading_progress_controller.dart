import 'dart:async';

import 'package:get/get.dart';
import '../../../core/services/widget_service.dart';
import '../../../core/storage/local_storage_service.dart';
import '../domain/reading_progress.dart';

class ReadingProgressController extends GetxController {
  ReadingProgressController(this.storage) {
    progress.value = ReadingProgress.fromJson(
      storage.readJson('reading_progress_v1') ?? {},
    );
  }
  final LocalStorageService storage;
  final progress = ReadingProgress().obs;
  Future<void> markRead(int surah, int verse) async {
    final next = progress.value.mark(surah, verse, DateTime.now());
    await storage.writeJson('reading_progress_v1', next.toJson());
    progress.value = next;
    try {
      final now = DateTime.now();
      unawaited(
        WidgetService.pushReadingStreak(
          streak: next.streak(now),
          todayCount: next.count(now),
          dailyGoal: next.dailyGoal,
          lastSurah: 'Surah $surah',
        ),
      );
    } catch (_) {
      // Widget update errors are non-fatal; silently discard.
    }
  }

  Future<void> setGoal(int goal) async {
    final next = ReadingProgress(
      dailyGoal: goal.clamp(1, 100),
      days: progress.value.days,
    );
    await storage.writeJson('reading_progress_v1', next.toJson());
    progress.value = next;
  }
}
