import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/bookmark.dart';

/// Owns the user's saved ayahs. Persists to local storage and exposes reactive
/// lists so the Saved tab and any add/remove affordance stay in sync.
///
/// Registered as a permanent singleton (GetIt + GetX) since bookmarks are
/// toggled from multiple screens, not just the Saved tab.
class BookmarksController extends GetxController {
  BookmarksController(this._storage);

  final LocalStorageService _storage;

  final bookmarks = <Bookmark>[].obs;

  /// Favorited subset, newest first — backs the "favorites" filter.
  List<Bookmark> get favorites => bookmarks.where((b) => b.isFavorite).toList();

  int get count => bookmarks.length;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    try {
      final raw = _storage.readJsonList(StorageKeys.bookmarks);
      final items = raw.map(Bookmark.fromJson).toList()
        ..sort((a, b) => b.savedAtMs.compareTo(a.savedAtMs));
      bookmarks.assignAll(items);
    } catch (_) {
      // Corrupt store — start empty rather than crash.
      bookmarks.clear();
    }
  }

  bool isBookmarked(int surahId, int ayah) =>
      bookmarks.any((b) => b.surahId == surahId && b.ayah == ayah);

  Future<void> add(Bookmark bookmark) =>
      _commit([bookmark, ...bookmarks.where((b) => b.id != bookmark.id)]);

  Future<void> remove(String id) =>
      _commit(bookmarks.where((b) => b.id != id).toList());

  Future<void> _commit(List<Bookmark> next) async {
    await _storage.writeJsonList(
      StorageKeys.bookmarks,
      next.map((b) => b.toJson()).toList(),
    );
    bookmarks.assignAll(next);
  }

  /// Adds [bookmark] if absent, removes it if already saved. Returns the new
  /// saved state (true = now bookmarked).
  Future<bool> toggle(Bookmark bookmark) async {
    if (isBookmarked(bookmark.surahId, bookmark.ayah)) {
      await remove(bookmark.id);
      return false;
    }
    await add(bookmark);
    return true;
  }

  Future<void> toggleFavorite(String id) async {
    final index = bookmarks.indexWhere((b) => b.id == id);
    if (index < 0) return;
    final current = bookmarks[index];
    final next = bookmarks.toList();
    next[index] = current.copyWith(isFavorite: !current.isFavorite);
    await _commit(next);
  }
}
