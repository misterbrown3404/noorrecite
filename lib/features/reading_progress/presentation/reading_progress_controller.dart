import 'package:get/get.dart';
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
