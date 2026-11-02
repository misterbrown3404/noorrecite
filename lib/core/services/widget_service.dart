import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

/// Pushes data to home-screen widgets via the [home_widget] package.
///
/// Uses a separate SharedPreferences (Android) / App Group UserDefaults (iOS)
/// store — completely independent from the app's AES-encrypted Hive boxes.
class WidgetService {
  WidgetService._();

  static const _appGroupId = 'group.com.noorrecite.app';

  /// Call once from [main] after [setupDependencies].
  static Future<void> init() async {
    try {
      if (Platform.isIOS) {
        await HomeWidget.setAppGroupId(_appGroupId);
      }
    } catch (_) {
      // Silently degrade if widget extension / app group is unavailable.
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Daily Ayah
  // ──────────────────────────────────────────────────────────────

  static Future<void> pushDailyAyah({
    required String arabic,
    required String translation,
    required String reference,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('widget_ayah_arabic', arabic),
        HomeWidget.saveWidgetData<String>('widget_ayah_translation', translation),
        HomeWidget.saveWidgetData<String>('widget_ayah_ref', reference),
      ]);
      await HomeWidget.updateWidget(
        androidName: 'DailyAyahWidget',
        iOSName: 'DailyAyahWidget',
      );
    } catch (_) {
      // Platform channels may not be bound in tests or background states.
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Prayer Times
  // ──────────────────────────────────────────────────────────────

  static Future<void> pushPrayerTimes({
    required String nextName,
    required String nextTime,
    required String remaining,
    required List<Map<String, String>> prayers,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<String>('widget_next_prayer', nextName),
        HomeWidget.saveWidgetData<String>('widget_next_time', nextTime),
        HomeWidget.saveWidgetData<String>('widget_remaining', remaining),
        HomeWidget.saveWidgetData<String>(
          'widget_prayers_json',
          jsonEncode(prayers),
        ),
      ]);
      await HomeWidget.updateWidget(
        androidName: 'PrayerTimesWidget',
        iOSName: 'PrayerTimesWidget',
      );
    } catch (_) {
      // Platform channels may not be bound in tests or background states.
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Reading Streak
  // ──────────────────────────────────────────────────────────────

  static Future<void> pushReadingStreak({
    required int streak,
    required int todayCount,
    required int dailyGoal,
    required String lastSurah,
  }) async {
    try {
      await Future.wait([
        HomeWidget.saveWidgetData<int>('widget_streak', streak),
        HomeWidget.saveWidgetData<int>('widget_today_count', todayCount),
        HomeWidget.saveWidgetData<int>('widget_daily_goal', dailyGoal),
        HomeWidget.saveWidgetData<String>('widget_last_surah', lastSurah),
      ]);
      await HomeWidget.updateWidget(
        androidName: 'ReadingStreakWidget',
        iOSName: 'ReadingStreakWidget',
      );
    } catch (_) {
      // Platform channels may not be bound in tests or background states.
    }
  }
}

