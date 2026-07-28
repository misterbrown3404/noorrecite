import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../../domain/entities/last_read.dart';
import '../../domain/entities/surah.dart';
import '../../domain/usecases/get_suwar.dart';

/// Filter tabs shown above the surah grid. Order matches
/// `QuranListPage._filters`.
enum SurahFilter { all, juz, makki, madani, bookmarks }

class SurahController extends GetxController {
  SurahController(this._getSuwar, this._storage);
  final GetSuwar _getSuwar;
  final LocalStorageService _storage;

  final suwar = <Surah>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  /// Active surah-grid filter chip.
  final filter = SurahFilter.all.obs;

  /// Active search query; filters [filteredSuwar] by name or id.
  final searchQuery = ''.obs;

  /// Most recently opened surah, restored from local storage on startup.
  final Rxn<LastRead> lastRead = Rxn<LastRead>();

  void setFilter(SurahFilter value) => filter.value = value;

  /// Returns [suwar] narrowed by both the active [filter] and [searchQuery].
  List<Surah> get filteredSuwar {
    final results = List<Surah>.from(suwar);

    // Apply filter.
    final filtered = _applyFilter(results);

    // Apply search.
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      return filtered
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.id.toString() == query ||
                s.revelationLabel.toLowerCase().contains(query),
          )
          .toList();
    }

    return filtered;
  }

  List<Surah> _applyFilter(List<Surah> source) {
    switch (filter.value) {
      case SurahFilter.all:
        return source;
      case SurahFilter.juz:
        return source;
      case SurahFilter.makki:
        return source
            .where((s) => s.type == RevelationType.makkah)
            .toList();
      case SurahFilter.madani:
        return source
            .where((s) => s.type == RevelationType.madina)
            .toList();
      case SurahFilter.bookmarks:
        if (!Get.isRegistered<BookmarksController>()) return source;
        final saved = Get.find<BookmarksController>()
            .bookmarks
            .map((b) => b.surahId)
            .toSet();
        return source.where((s) => saved.contains(s.id)).toList();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _restoreLastRead();
    fetchSuwar();
  }

  void _restoreLastRead() {
    final saved = _storage.readJson(StorageKeys.lastRead);
    if (saved != null) {
      try {
        lastRead.value = LastRead.fromJson(saved);
      } catch (_) {
        // Corrupt snapshot — start clean.
      }
    }
  }

  /// Records [surah] as the last-opened surah and persists it locally.
  Future<void> markOpened(Surah surah, {int ayah = 1}) async {
    final entry = LastRead(
      surahId: surah.id,
      surahName: surah.name,
      pageStart: surah.startPage,
      pageEnd: surah.endPage,
      ayah: ayah,
      savedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    lastRead.value = entry;
    await _storage.writeJson(StorageKeys.lastRead, entry.toJson());
  }

  Future<void> fetchSuwar() async {
    isLoading(true);
    error('');
    final result = await _getSuwar();
    result.fold(
      (f) => error(f.message),
      (data) => suwar.assignAll(data),
    );
    isLoading(false);
  }
}
