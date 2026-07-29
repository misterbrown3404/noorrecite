import 'package:get/get.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/utils/app_mappers.dart';

/// Popular mp3quran.net language codes → display names.
const Map<String, String> kSupportedLanguages = {
  'eng': 'English',
  'ara': 'العربية',
  'fra': 'Français',
  'urd': 'اردو',
  'ind': 'Bahasa Indonesia',
  'mly': 'Bahasa Melayu',
  'tur': 'Türkçe',
  'rus': 'Русский',
};

class SettingsController extends GetxController {
  SettingsController(this._storage);

  final LocalStorageService _storage;

  final notificationsEnabled = true.obs;
  final dailyReflectionReminder = false.obs;
  final themeMode = 'system'.obs;
  final offlineMode = false.obs;
  /// mp3quran language code, e.g. 'eng', 'ara'.
  final language = 'eng'.obs;

  @override
  void onInit() {
    super.onInit();
    _restore();
  }

  void _restore() {
    final saved = _storage.readJson(StorageKeys.settings);
    if (saved == null) return;
    notificationsEnabled.value =
        (saved['notificationsEnabled'] as bool?) ?? notificationsEnabled.value;
    dailyReflectionReminder.value =
        (saved['dailyReflectionReminder'] as bool?) ?? dailyReflectionReminder.value;
    themeMode.value = (saved['themeMode'] as String?) ?? themeMode.value;
    offlineMode.value = (saved['offlineMode'] as bool?) ?? offlineMode.value;
    language.value = (saved['language'] as String?) ?? language.value;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    notificationsEnabled.value = value;
    await _persist();
    final ns = NotificationService.instance;
    if (value) await ns.requestPermission();
    await ns.syncPrayerSchedule(
      enabled: value,
      lat: _storage.read<double>(StorageKeys.lastLat),
      lng: _storage.read<double>(StorageKeys.lastLng),
    );
  }

  Future<void> setDailyReflectionReminder(bool value) async {
    dailyReflectionReminder.value = value;
    await _persist();
    final ns = NotificationService.instance;
    if (value) {
      await ns.requestPermission();
      await ns.scheduleDailyReflection();
    } else {
      await ns.cancelDailyReflection();
    }
  }

  Future<void> setThemeMode(String value) async {
    themeMode.value = value;
    await _persist();
    Get.changeThemeMode(AppMappers.themeModeFromString(value));
  }

  Future<void> setOfflineMode(bool value) async {
    offlineMode.value = value;
    await _persist();
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await _persist();
    // Update app locale so RTL languages (Arabic, Urdu) flip layout.
    Get.updateLocale(AppMappers.localeFromCode(code));
  }

  Future<void> _persist() => _storage.writeJson(StorageKeys.settings, {
        'notificationsEnabled': notificationsEnabled.value,
        'dailyReflectionReminder': dailyReflectionReminder.value,
        'themeMode': themeMode.value,
        'offlineMode': offlineMode.value,
        'language': language.value,
      });
}