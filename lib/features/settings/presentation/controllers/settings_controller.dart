import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';

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
    Get.changeThemeMode(_themeModeFromString(value));
  }

  Future<void> setOfflineMode(bool value) async {
    offlineMode.value = value;
    await _persist();
  }

  Future<void> setLanguage(String code) async {
    language.value = code;
    await _persist();
    // Update app locale so RTL languages (Arabic, Urdu) flip layout.
    final locale = _localeFromCode(code);
    Get.updateLocale(locale);
  }

  Future<void> _persist() => _storage.writeJson(StorageKeys.settings, {
        'notificationsEnabled': notificationsEnabled.value,
        'dailyReflectionReminder': dailyReflectionReminder.value,
        'themeMode': themeMode.value,
        'offlineMode': offlineMode.value,
        'language': language.value,
      });

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light': return ThemeMode.light;
      case 'dark':  return ThemeMode.dark;
      default:      return ThemeMode.system;
    }
  }

  Locale _localeFromCode(String code) {
    switch (code) {
      case 'ara': return const Locale('ar');
      case 'fra': return const Locale('fr');
      case 'urd': return const Locale('ur');
      case 'ind': return const Locale('id');
      case 'mly': return const Locale('ms');
      case 'tur': return const Locale('tr');
      case 'rus': return const Locale('ru');
      default:    return const Locale('en');
    }
  }
}