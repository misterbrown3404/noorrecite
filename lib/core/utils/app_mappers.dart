import 'package:flutter/material.dart';

/// Single source of truth for mapping persisted string codes to Flutter types.
/// Previously duplicated across `app.dart` and `SettingsController`, which had
/// already begun to drift.
abstract final class AppMappers {
  /// mp3quran language code (e.g. 'ara', 'eng') → app [Locale].
  static Locale localeFromCode(String code) {
    switch (code) {
      case 'ara':
        return const Locale('ar');
      case 'fra':
        return const Locale('fr');
      case 'urd':
        return const Locale('ur');
      case 'ind':
        return const Locale('id');
      case 'mly':
        return const Locale('ms');
      case 'tur':
        return const Locale('tr');
      case 'rus':
        return const Locale('ru');
      default:
        return const Locale('en');
    }
  }

  /// Persisted theme string ('light'/'dark'/'system') → [ThemeMode].
  static ThemeMode themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
