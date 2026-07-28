import 'package:get/get.dart';

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/reflection.dart';

/// Owns the user's saved reflections: a reactive, enumerable collection backed
/// by local storage. Kept as a permanent singleton so the daily-reflection
/// screen, the "add reflection" screen, and the full list all read and write
/// the same source of truth.
class ReflectionsController extends GetxController {
  ReflectionsController(this._storage);

  final LocalStorageService _storage;

  /// Newest first, so the list renders most-recent reflections at the top.
  final reflections = <Reflection>[].obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final raw = _storage.readJsonList(StorageKeys.reflections);
    final items = raw.map(Reflection.fromJson).toList()
      ..sort((a, b) => b.savedAtMs.compareTo(a.savedAtMs));
    reflections.assignAll(items);
  }

  /// The saved note for a verse, or null if none exists.
  Reflection? forVerse(int surahId, int ayahNumber) {
    final key = '$surahId-$ayahNumber';
    for (final r in reflections) {
      if (r.verseKey == key) return r;
    }
    return null;
  }

  /// Create or update the reflection for a verse. An empty note removes it.
  /// Also mirrors the note into the legacy per-verse key so any code still
  /// reading [StorageKeys.reflectionNote] stays consistent.
  Future<void> save({
    required int surahId,
    required int ayahNumber,
    required String reference,
    required String note,
    required int savedAtMs,
  }) async {
    final trimmed = note.trim();
    if (trimmed.isEmpty) {
      await remove(surahId, ayahNumber);
      return;
    }

    final key = '$surahId-$ayahNumber';
    reflections.removeWhere((r) => r.verseKey == key);
    reflections.add(Reflection(
      surahId: surahId,
      ayahNumber: ayahNumber,
      reference: reference,
      note: trimmed,
      savedAtMs: savedAtMs,
    ));
    reflections.sort((a, b) => b.savedAtMs.compareTo(a.savedAtMs));

    await _persist();
    await _storage.write(StorageKeys.reflectionNote(key), trimmed);
  }

  /// Delete the reflection for a verse (both the collection and legacy key).
  Future<void> remove(int surahId, int ayahNumber) async {
    final key = '$surahId-$ayahNumber';
    reflections.removeWhere((r) => r.verseKey == key);
    await _persist();
    await _storage.delete(StorageKeys.reflectionNote(key));
  }

  Future<void> _persist() => _storage.writeJsonList(
        StorageKeys.reflections,
        reflections.map((r) => r.toJson()).toList(),
      );
}
