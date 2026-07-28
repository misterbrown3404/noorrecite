import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

/// Single entry point for all on-device persistence (privacy-friendly: nothing
/// leaves the device). Wraps one Hive box and exposes typed helpers.
///
/// Kept as a core primitive like [DioClient] so features depend on it via DI
/// rather than touching Hive directly.
class LocalStorageService {
  LocalStorageService._(this._box);

  static const String _boxName = 'qariverse_store';

  final Box _box;

  /// Opens Hive and the app box. Call once during app startup before use.
  static Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    final box = await Hive.openBox(_boxName);
    return LocalStorageService._(box);
  }

  // --- Primitive helpers -------------------------------------------------

  T? read<T>(String key) => _box.get(key) as T?;

  Future<void> write(String key, Object? value) => _box.put(key, value);

  Future<void> delete(String key) => _box.delete(key);

  bool has(String key) => _box.containsKey(key);

  // --- JSON helpers (for maps/lists persisted as encoded strings) --------

  Map<String, dynamic>? readJson(String key) {
    final raw = _box.get(key) as String?;
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _box.put(key, jsonEncode(value));

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _box.get(key) as String?;
    if (raw == null) return const [];
    final decoded = jsonDecode(raw) as List;
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) =>
      _box.put(key, jsonEncode(value));

  /// Deletes all data from the box.
  Future<void> clearAll() => _box.clear();
}
