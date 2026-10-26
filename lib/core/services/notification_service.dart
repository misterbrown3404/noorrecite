import 'permission_requests.dart';
import 'prayer_schedule.dart';
import 'package:get/get.dart';
import '../../app/routes/app_routes.dart';
import '../../features/azkar/data/worship_repository.dart';
import 'package:flutter/services.dart';
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
  final reminderStatus = ValueNotifier<String>('Reminders not checked yet');
  final pendingPrayerCount = ValueNotifier<int>(0);
  Future<void> _syncWork = Future.value();

  // Channel id is versioned: an Android notification channel's sound is fixed
  // at creation and immutable afterward, so switching to the adhan sound
  // requires a fresh id. Bump the suffix if the sound/behaviour changes again.
  static const _prayerChannelId = 'prayer_times_adhan_v2';
  // Old channel ids to clean up. A channel's sound is immutable after creation,
  // so each sound change ships a NEW id and retires the previous one here.
  static const _legacyPrayerChannelIds = [
    'prayer_times',
    'prayer_times_adhan_v1',
  ];
  static const _reflectionChannelId = 'daily_reflection';
  static const _reflectionId = 100;
  static String? _pendingDestination;

  static Future<void> openPendingReminder() async {
    final payload = _pendingDestination;
    if (payload == null || Get.key.currentState == null) return;
    _pendingDestination = null;
    if (payload == 'daily_ayah') {
      Get.toNamed(AppRoutes.dailyReflection);
    } else if (payload.startsWith('azkar:')) {
      final categories = await WorshipRepository().categories();
      final id = payload == 'azkar:morning' ? 1 : 2;
      Get.toNamed(
        AppRoutes.azkarCategory,
        arguments: categories.firstWhere((category) => category.id == id),
      );
    }
  }

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
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      debugPrint('Failed to set local timezone: $e');
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: ios,
        macOS: ios,
      ),
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
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return; // iOS / other platforms
    for (final id in _legacyPrayerChannelIds) {
      await android.deleteNotificationChannel(channelId: id);
    }
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
    } else if (payload == 'daily_ayah' ||
        (payload?.startsWith('azkar:') ?? false)) {
      _pendingDestination = payload;
      openPendingReminder();
    }
  }

  Future<bool> requestPermission({bool requestExactAlarm = false}) =>
      PermissionRequests.run(
        () => _requestPermission(requestExactAlarm: requestExactAlarm),
      );

  Future<bool> _requestPermission({bool requestExactAlarm = false}) async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final notif = await android.requestNotificationsPermission() ?? false;
      if (notif && requestExactAlarm) {
        await android.requestExactAlarmsPermission();
      }
      return notif;
    }
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            sound: true,
            badge: true,
          ) ??
          false;
    }
    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    return await macos?.requestPermissions(
          alert: true,
          sound: true,
          badge: true,
        ) ??
        false;
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
    macOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    ),
    iOS: const DarwinNotificationDetails(
      presentAlert: true,
      presentSound: false,
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
    macOS: const DarwinNotificationDetails(presentAlert: true),
  );

  /// Schedule prayer-time notifications for the next 7 days using [lat]/[lng].
  Future<void> schedulePrayerNotifications(double lat, double lng) async {
    await cancelPrayerNotifications();
    var scheduledCount = 0;
    var failures = 0;
    var inexact = false;
    final now = tz.TZDateTime.now(tz.local);

    for (var day = 0; day < 7; day++) {
      final date = DateTime.now().add(Duration(days: day));
      final times = {
        for (final prayer in PrayerSchedule.times(lat, lng, date))
          prayer.name: prayer.time,
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
          scheduledCount++;
        } catch (_) {
          // If exact alarm permission is denied by user/OS, fall back to inexact
          // so the notification still triggers near prayer time.
          try {
            await _plugin.zonedSchedule(
              id: id,
              title: 'Time for $name',
              body: "It's time for $name prayer",
              scheduledDate: scheduled,
              notificationDetails: _prayerDetails,
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              payload: '$_adhanPayload:$name',
            );
            scheduledCount++;
            inexact = true;
          } catch (e) {
            failures++;
            debugPrint('Failed to schedule $name notification: $e');
          }
        }
      }
      for (final entry in [
        ('Fajr', 'morning', 200),
        ('Maghrib', 'evening', 201),
      ]) {
        final when = tz.TZDateTime.from(
          times[entry.$1]!.add(const Duration(minutes: 10)),
          tz.local,
        );
        if (!when.isAfter(now)) continue;
        try {
          final approximate = await _scheduleWorship(
            id: entry.$3 + day * 2,
            title: entry.$2 == 'morning' ? 'Morning Azkar' : 'Evening Azkar',
            body: 'Take a moment for remembrance.',
            when: when,
            payload: 'azkar:${entry.$2}',
          );
          inexact = inexact || approximate;
        } catch (_) {
          failures++;
        }
      }
    }
    pendingPrayerCount.value = scheduledCount;
    reminderStatus.value = failures > 0
        ? '$scheduledCount reminders scheduled; $failures failed. Try refreshing.'
        : inexact
        ? '$scheduledCount reminders scheduled · approximate timing (exact alarms unavailable)'
        : '$scheduledCount prayer reminders + morning/evening Azkar scheduled for the next 7 days';
  }

  Future<void> cancelPrayerNotifications() async {
    pendingPrayerCount.value = 0;
    for (var day = 0; day < 7; day++) {
      await _plugin.cancel(id: 200 + day * 2);
      await _plugin.cancel(id: 201 + day * 2);
      for (final id in _prayerBaseIds.values) {
        await _plugin.cancel(id: id + day * 10);
      }
    }
  }

  /// Reconcile the scheduled prayer notifications with the current settings and
  /// location. Safe to call on every app open and location refresh — this is
  /// what keeps a rolling 7-day window fresh.
  Future<bool> syncPrayerSchedule({
    required bool enabled,
    double? lat,
    double? lng,
    bool requestExactAlarm = false,
  }) {
    final operation = _syncWork.then((_) async {
      try {
        if (!_initialized) await init();
        if (!enabled) {
          await cancelPrayerNotifications();
          reminderStatus.value = 'Prayer reminders are off';
          return false;
        }
        if (!await requestPermission(requestExactAlarm: requestExactAlarm)) {
          await cancelPrayerNotifications();
          reminderStatus.value =
              'Notifications are blocked. Enable them in system settings.';
          return false;
        }
        if (lat == null || lng == null) {
          reminderStatus.value =
              'Location is needed before reminders can be scheduled';
          return true;
        }
        await schedulePrayerNotifications(lat, lng);
        return true;
      } catch (e) {
        reminderStatus.value = 'Couldn’t schedule reminders. Please try again.';
        rethrow;
      }
    });
    _syncWork = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<bool> scheduleTestReminder() async {
    if (!_initialized) await init();
    if (!await requestPermission(requestExactAlarm: true)) return false;
    final when = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
    try {
      await _plugin.zonedSchedule(
        id: 998,
        title: 'Prayer reminder test',
        body: 'Your prayer reminder is working. Tap to preview the adhan.',
        scheduledDate: when,
        notificationDetails: _prayerDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'adhan:Test',
      );
    } catch (_) {
      await _plugin.zonedSchedule(
        id: 998,
        title: 'Prayer reminder test',
        body: 'Your prayer reminder is working. Tap to preview the adhan.',
        scheduledDate: when,
        notificationDetails: _prayerDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'adhan:Test',
      );
    }
    return true;
  }

  /// Returns true when the OS only permits approximate delivery.
  Future<bool> _scheduleWorship({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
    required String payload,
    bool daily = false,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _reflectionDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: daily ? DateTimeComponents.time : null,
        payload: payload,
      );
      return false;
    } catch (_) {
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: _reflectionDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: daily ? DateTimeComponents.time : null,
        payload: payload,
      );
      return true;
    }
  }

  Future<void> scheduleDailyReflection() async {
    if (!_initialized) await init();
    await cancelDailyReflection();
    if (!await requestPermission()) return;
    final now = tz.TZDateTime.now(tz.local);
    for (final hour in [9, 18]) {
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
      if (!when.isAfter(now)) {
        when = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, hour);
      }
      await _scheduleWorship(
        id: hour == 9 ? _reflectionId : 101,
        title: 'Daily Ayah',
        body: 'Your daily ayah is ready — take a moment to reflect.',
        when: when,
        payload: 'daily_ayah',
        daily: true,
      );
    }
  }

  Future<void> cancelDailyReflection() async {
    await _plugin.cancel(id: _reflectionId);
    await _plugin.cancel(id: 101);
  }

  // ---------------------------------------------------------------------------
  // TEMPORARY — manual adhan test. Remove before Play Store upload.
  // A notification channel's sound is immutable after creation, so a stale
  // channel from an earlier build silently swallows the adhan. To sidestep that
  // entirely, this test creates a BRAND-NEW uniquely-named channel every run and
  // fires on it — so what you hear reflects the current code, not a cached
  // channel. If this is silent, the cause is the device (alarm-stream volume or
  // Do Not Disturb), not the app: the adhan plays on the alarm stream.
  //
  // Returns a short human-readable diagnostic (alarm volume + DND state) so a
  // silent adhan can be attributed to the device at a glance.
  // ---------------------------------------------------------------------------
  static const _audioDiagChannel = MethodChannel(
    'com.nurehub.qariverse/audio_diag',
  );

  Future<String> debugFireAdhanNow() async {
    await requestPermission();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Unique id => guaranteed fresh channel that carries the adhan sound.
    final testChannelId = 'adhan_test_${DateTime.now().millisecondsSinceEpoch}';
    if (android != null) {
      await android.createNotificationChannel(
        AndroidNotificationChannel(
          testChannelId,
          'Adhan Test',
          description: 'Temporary channel for manually testing the adhan sound',
          importance: Importance.max,
          sound: const RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
    }

    await _plugin.show(
      id: 999,
      title: 'Test — Adhan',
      body: 'You should hear the adhan now (plays on the alarm volume stream).',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          testChannelId,
          'Adhan Test',
          channelDescription:
              'Temporary channel for manually testing the adhan sound',
          importance: Importance.max,
          priority: Priority.max,
          sound: const RawResourceAndroidNotificationSound('adhan'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
        ),
      ),
      payload: '$_adhanPayload:Test',
    );

    // Also play the bundled asset in-app as a belt-and-suspenders check. On
    // Android this is a no-op (see AdhanAudioService); on iOS it plays the full
    // adhan, since iOS caps notification sounds at ~30s.
    await AdhanAudioService.instance.play();

    return _debugAudioDiagnostics();
  }

  /// Reads the device's alarm-stream volume and Do Not Disturb state via the
  /// native platform channel (Android only). Used purely for the debug adhan
  /// test to explain a silent adhan. Never throws.
  Future<String> _debugAudioDiagnostics() async {
    try {
      final result = await _audioDiagChannel.invokeMapMethod<String, dynamic>(
        'getAudioDiagnostics',
      );
      if (result == null) return 'Diagnostics unavailable on this platform.';
      final vol = result['alarmVolume'];
      final max = result['alarmMax'];
      final dnd = result['dndFilter'];
      final muted = (vol is int && vol == 0);
      final buffer = StringBuffer()
        ..writeln('Alarm volume: $vol / $max${muted ? '  ⚠ MUTED' : ''}')
        ..write('Do Not Disturb: $dnd');
      if (muted) {
        buffer.write(
          '\n\nTurn UP the alarm volume — the adhan is silent '
          'because the alarm stream is at 0.',
        );
      } else if (dnd is String && dnd.contains('None')) {
        buffer.write(
          '\n\nDND is set to total silence — it is blocking the '
          'adhan. Turn DND off or allow alarms.',
        );
      }
      return buffer.toString();
    } on PlatformException catch (e) {
      return 'Diagnostics error: ${e.message}';
    } catch (_) {
      return 'Diagnostics unavailable.';
    }
  }
}
