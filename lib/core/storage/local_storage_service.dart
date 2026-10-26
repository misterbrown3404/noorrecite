import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../error/crash_reporter.dart';

/// Single entry point for all on-device persistence (privacy-friendly: nothing
/// leaves the device). Wraps one **AES-encrypted** Hive box and exposes typed
/// helpers.
///
/// Encryption: the 256-bit box key is generated once and stored in the
/// platform keystore (Android Keychain / iOS Keychain) via
/// [FlutterSecureStorage] — never in the box itself. This protects PII such as
/// cached GPS coordinates at rest, even on rooted/jailbroken devices or via
/// forensic extraction.
///
/// Kept as a core primitive like `DioClient` so features depend on it via DI
/// rather than touching Hive directly.
class LocalStorageService {
  LocalStorageService._(this._box);

  static const String _boxName = 'qariverse_store';
  static const String _keyStorageKey = 'qariverse_hive_key';

  final Box _box;

  /// Opens Hive and the encrypted app box. Call once during app startup.
  ///
  /// Resilient to a corrupt box: if opening fails (e.g. a partial write during
  /// a crash), the box file is deleted and recreated rather than bricking the
  /// app on launch. Cached data is re-fetched; user settings reset to defaults.
  static Future<LocalStorageService> init() async {
    await Hive.initFlutter();
    final cipher = await _resolveCipher();

    try {
      final box = await Hive.openBox(_boxName, encryptionCipher: cipher);
      return LocalStorageService._(box);
    } catch (e, s) {
      // Corrupt / unreadable box (bad key, partial write). Recover by wiping
      // and recreating so the app still launches.
      CrashReporter.instance.recordError(
        e,
        s,
        reason: 'hive open failed — recreating box',
      );
      await Hive.deleteBoxFromDisk(_boxName);
      final box = await Hive.openBox(_boxName, encryptionCipher: cipher);
      return LocalStorageService._(box);
    }
  }

  /// Loads the AES key from secure storage, generating and persisting one on
  /// first run. Falls back to an unencrypted box only if the platform keystore
  /// is entirely unavailable (rare), so persistence never hard-fails.
  static Future<HiveAesCipher?> _resolveCipher() async {
    const secure = FlutterSecureStorage();
    try {
      var encoded = await secure.read(key: _keyStorageKey);
      if (encoded == null) {
        final key = Hive.generateSecureKey();
        encoded = base64Url.encode(key);
        await secure.write(key: _keyStorageKey, value: encoded);
      }
      return HiveAesCipher(base64Url.decode(encoded));
    } catch (e, s) {
      CrashReporter.instance.recordError(
        e,
        s,
        reason: 'secure key unavailable — falling back to unencrypted box',
      );
      if (kDebugMode) {
        debugPrint(
          'LocalStorageService: keystore unavailable, box unencrypted',
        );
      }
      return null;
    }
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
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (e, s) {
      CrashReporter.instance.recordError(e, s, reason: 'readJson($key)');
      return null;
    }
  }

  Future<void> writeJson(String key, Map<String, dynamic> value) =>
      _box.put(key, jsonEncode(value));

  List<Map<String, dynamic>> readJsonList(String key) {
    final raw = _box.get(key) as String?;
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.whereType<Map<String, dynamic>>().toList();
    } catch (e, s) {
      CrashReporter.instance.recordError(e, s, reason: 'readJsonList($key)');
      return const [];
    }
  }

  Future<void> writeJsonList(String key, List<Map<String, dynamic>> value) =>
      _box.put(key, jsonEncode(value));

  /// Deletes all data from the box.
  Future<void> clearAll() => _box.clear();
}
