// Unit tests for QariVerse's pure helpers.
//
// A full-app smoke test isn't meaningful here: booting `QariVerseApp` pulls in
// Hive (path_provider), flutter_secure_storage, just_audio, geolocator, and the
// local-notifications plugin — none of which are available to a plain
// `flutter test` host, so it can only ever throw. These tests instead cover the
// deterministic, plugin-free logic that the UI depends on.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qariverse/core/utils/app_mappers.dart';
import 'package:qariverse/core/utils/duration_format.dart';
import 'package:qariverse/features/home/presentation/controllers/prayer_times_controller.dart';

void main() {
  group('DurationFormat', () {
    test('hms always pads to H:MM:SS', () {
      expect(DurationFormat.hms(Duration.zero), '00:00:00');
      expect(
        DurationFormat.hms(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '01:02:03',
      );
      expect(
        DurationFormat.hms(const Duration(minutes: 5, seconds: 9)),
        '00:05:09',
      );
    });

    test('clock drops the hour segment under an hour', () {
      expect(DurationFormat.clock(const Duration(seconds: 5)), '00:05');
      expect(
        DurationFormat.clock(const Duration(minutes: 3, seconds: 7)),
        '03:07',
      );
    });

    test('clock shows hours past an hour', () {
      expect(
        DurationFormat.clock(const Duration(hours: 2, minutes: 4, seconds: 6)),
        '2:04:06',
      );
    });
  });

  group('AppMappers', () {
    test('localeFromCode maps known mp3quran codes', () {
      expect(AppMappers.localeFromCode('ara'), const Locale('ar'));
      expect(AppMappers.localeFromCode('urd'), const Locale('ur'));
      expect(AppMappers.localeFromCode('eng'), const Locale('en'));
    });

    test('localeFromCode falls back to English for unknown codes', () {
      expect(AppMappers.localeFromCode('zzz'), const Locale('en'));
    });

    test('themeModeFromString maps known values, defaults to system', () {
      expect(AppMappers.themeModeFromString('light'), ThemeMode.light);
      expect(AppMappers.themeModeFromString('dark'), ThemeMode.dark);
      expect(AppMappers.themeModeFromString('anything'), ThemeMode.system);
    });
  });

  group('PrayerTimeInfo', () {
    test('formattedTime renders 12-hour clock with AM/PM', () {
      final midnight = PrayerTimeInfo(
        name: 'Fajr',
        time: DateTime(2026, 1, 1, 0, 5),
        isNext: false,
        timeRemaining: Duration.zero,
      );
      final noon = PrayerTimeInfo(
        name: 'Dhuhr',
        time: DateTime(2026, 1, 1, 12, 0),
        isNext: false,
        timeRemaining: Duration.zero,
      );
      final evening = PrayerTimeInfo(
        name: 'Isha',
        time: DateTime(2026, 1, 1, 19, 30),
        isNext: false,
        timeRemaining: Duration.zero,
      );
      expect(midnight.formattedTime, '12:05 AM');
      expect(noon.formattedTime, '12:00 PM');
      expect(evening.formattedTime, '7:30 PM');
    });

    test('copyWith overrides only the given fields', () {
      final base = PrayerTimeInfo(
        name: 'Asr',
        time: DateTime(2026, 1, 1, 15, 0),
        isNext: false,
        timeRemaining: const Duration(minutes: 10),
      );
      final next = base.copyWith(isNext: true);
      expect(next.isNext, isTrue);
      expect(next.name, base.name);
      expect(next.time, base.time);
      expect(next.timeRemaining, base.timeRemaining);
    });
  });
}
