import 'package:adhan/adhan.dart' as adhan;
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

import 'adhan_audio_service.dart';

/// Schedules and cancels local notifications for prayer times and daily
/// reflection. Fully offline — uses adhan for prayer calculations and
/// flutter_local_notifications for delivery. No network required.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Channel id is versioned: an Android notification channel's sound is fixed
  // at creation and immutable afterward, so switching to the adhan sound
  // requires a fresh id. Bump the suffix if the sound/behaviour changes again.
  static const _prayerChannelId = 'prayer_times_adhan_v1';
  static const _legacyPrayerChannelId = 'prayer_times';
  static const _reflectionChannelId = 'daily_reflection';
  static const _reflectionId = 100;

  /// Notification payload marking a prayer-time alert; tapping it plays the
  /// full adhan. Format: `adhan:<PrayerName>`.
  static const _adhanPayload = 'adhan';

  static const _prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const _prayerBaseIds = {
    'Fajr': 1,
    'Dhuhr': 2,
    'Asr': 3,
    'Maghrib': 4,
    'Isha': 5,
  };

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    try {
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    await _setupAndroidChannels();

    // If the app was cold-started by tapping a prayer notification, play the
    // adhan now (the tap callback above only fires while the app is alive).
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      _handlePayload(launch!.notificationResponse?.payload);
    }
    _initialized = true;
  }

  /// Explicitly (re)create the Android prayer channel with the adhan sound on
  /// the alarm stream, so it plays at full length and is audible even when the
  /// app is closed. Deletes the legacy default-sound channel if it lingers.
  Future<void> _setupAndroidChannels() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return; // iOS / other platforms
    await android.deleteNotificationChannel(channelId: _legacyPrayerChannelId);
    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        _prayerChannelId,
        'Prayer Times',
        description: 'Adhan prayer time reminders',
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('adhan'),
        playSound: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  /// Foreground/tap handler: plays the full adhan when a prayer notification is
  /// opened. Runs in the main isolate, so it can reach app singletons.
  static void _onNotificationResponse(NotificationResponse response) {
    _handlePayload(response.payload);
  }

  static void _handlePayload(String? payload) {
    if (payload != null && payload.startsWith(_adhanPayload)) {
      AdhanAudioService.instance.play();
    }
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  NotificationDetails get _prayerDetails => NotificationDetails(
        android: AndroidNotificationDetails(
          _prayerChannelId,
          'Prayer Times',
          channelDescription: 'Adhan prayer time reminders',
          importance: Importance.max,
          priority: Priority.max,
          // Play the bundled adhan from res/raw/adhan.mp3. The Android system
          // plays this even when the app is fully closed — no background isolate
          // needed. Channel sound is immutable after first creation; the channel
          // id is versioned so a sound change takes effect on reinstall/clear.
          sound: const RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          enableVibration: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          // iOS caps notification sounds at ~30s; full adhan plays in-app
          // via AdhanAudioService when the notification is tapped.
        ),
      );

  NotificationDetails get _reflectionDetails => NotificationDetails(
        android: AndroidNotificationDetails(
          _reflectionChannelId,
          'Daily Reflection',
          channelDescription: 'Daily Quran reflection reminder',
          importance: Importance.defaultImportance,
        ),
        iOS: const DarwinNotificationDetails(presentAlert: true),
      );

  /// Schedule prayer-time notifications for the next 7 days using [lat]/[lng].
  Future<void> schedulePrayerNotifications(double lat, double lng) async {
    await cancelPrayerNotifications();
    final coords = adhan.Coordinates(lat, lng);
    final params = adhan.CalculationMethod.muslim_world_league.getParameters()
      ..madhab = adhan.Madhab.shafi;
    final now = tz.TZDateTime.now(tz.local);

    for (var day = 0; day < 7; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final pt = adhan.PrayerTimes(
        coords,
        adhan.DateComponents(date.year, date.month, date.day),
        params,
      );
      final times = {
        'Fajr': pt.fajr,
        'Dhuhr': pt.dhuhr,
        'Asr': pt.asr,
        'Maghrib': pt.maghrib,
        'Isha': pt.isha,
      };
      for (final name in _prayerNames) {
        final time = times[name]!;
        final scheduled = tz.TZDateTime.from(time, tz.local);
        if (scheduled.isBefore(now)) continue;
        final id = (_prayerBaseIds[name] ?? 0) + day * 10;
        try {
          await _plugin.zonedSchedule(
            id: id,
            title: 'Time for $name',
            body: "It's time for $name prayer",
            scheduledDate: scheduled,
            notificationDetails: _prayerDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: '$_adhanPayload:$name',
          );
        } catch (e) {
          // Defensive: if the Android channel sound is missing (fresh build
          // before the raw resource was added), scheduling throws a
          // PlatformException. Log it but don't crash — prayer times still
          // show in the UI, and a full rebuild will fix the notification sound.
          // The app binary must be rebuilt after adding res/raw/adhan.mp3.
          debugPrint('Failed to schedule $name notification: $e');
        }
      }
    }
  }

  Future<void> cancelPrayerNotifications() async {
    for (var day = 0; day < 7; day++) {
      for (final id in _prayerBaseIds.values) {
        await _plugin.cancel(id: id + day * 10);
      }
    }
  }

  /// Reconcile the scheduled prayer notifications with the current settings and
  /// location. Safe to call on every app open and location refresh — this is
  /// what keeps a rolling 7-day window fresh (the old code only scheduled once,
  /// when the settings toggle was flipped, so alerts silently stopped after a
  /// week or when the user moved).
  Future<void> syncPrayerSchedule({
    required bool enabled,
    double? lat,
    double? lng,
  }) async {
    if (enabled && lat != null && lng != null) {
      await schedulePrayerNotifications(lat, lng);
    } else {
      await cancelPrayerNotifications();
    }
  }

  /// Schedule a daily reflection reminder at 8:00 AM every day.
  Future<void> scheduleDailyReflection() async {
    await cancelDailyReflection();
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    await _plugin.zonedSchedule(
      id: _reflectionId,
      title: 'Daily Reflection',
      body: 'Your daily ayah is ready — take a moment to reflect.',
      scheduledDate: scheduled,
      notificationDetails: _reflectionDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReflection() => _plugin.cancel(id: _reflectionId);
}
