import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/core/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  const timezone = MethodChannel('flutter_timezone');
  var permission = false;
  var rejectExact = false;
  final scheduled = <Map<dynamic, dynamic>>[];
  final attempted = <int>{};
  setUpAll(() {
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, (_) async => 'Africa/Lagos');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'requestNotificationsPermission') {
            return permission;
          }
          if (call.method == 'requestExactAlarmsPermission' ||
              call.method == 'initialize') {
            return true;
          }
          if (call.method == 'getNotificationAppLaunchDetails') {
            return <String, dynamic>{'notificationLaunchedApp': false};
          }
          if (call.method == 'zonedSchedule') {
            final arguments = call.arguments as Map;
            final id = arguments['id'] as int;
            if (rejectExact && attempted.add(id)) {
              throw PlatformException(code: 'exact_alarms_not_permitted');
            }
            scheduled.add(arguments);
          }
          return null;
        });
  });
  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(timezone, null);
  });
  setUp(() {
    scheduled.clear();
    attempted.clear();
    rejectExact = false;
  });
  test('denied notification permission does not schedule prayers', () async {
    permission = false;
    final allowed = await NotificationService.instance.syncPrayerSchedule(
      enabled: true,
      lat: 6.5244,
      lng: 3.3792,
    );
    expect(allowed, isFalse);
    expect(scheduled, isEmpty);
    expect(
      NotificationService.instance.reminderStatus.value,
      contains('blocked'),
    );
  });
  test(
    'schedules five prayers per day with unique IDs and no sunrise',
    () async {
      permission = true;
      await NotificationService.instance.syncPrayerSchedule(
        enabled: true,
        lat: 6.5244,
        lng: 3.3792,
      );
      expect(
        scheduled
            .where((e) => e['payload'].toString().startsWith('adhan:'))
            .length,
        inInclusiveRange(30, 35),
      );
      expect(scheduled.map((e) => e['id']).toSet().length, scheduled.length);
      expect(
        scheduled.every((e) => !e['title'].toString().contains('Sunrise')),
        isTrue,
      );
      expect(
        NotificationService.instance.pendingPrayerCount.value,
        scheduled
            .where((e) => e['payload'].toString().startsWith('adhan:'))
            .length,
      );
    },
  );
  test(
    'exact alarm denial falls back and reports approximate timing',
    () async {
      permission = true;
      rejectExact = true;
      await NotificationService.instance.syncPrayerSchedule(
        enabled: true,
        lat: 6.5244,
        lng: 3.3792,
      );
      expect(
        scheduled
            .where((e) => e['payload'].toString().startsWith('adhan:'))
            .length,
        inInclusiveRange(30, 35),
      );
      expect(
        NotificationService.instance.reminderStatus.value,
        contains('approximate'),
      );
    },
  );
  test('daily ayah repeats at 9 AM and 6 PM with distinct IDs', () async {
    permission = true;
    await NotificationService.instance.scheduleDailyReflection();
    expect(scheduled.length, 2);
    expect(scheduled.map((e) => e['id']).toSet(), {100, 101});
    expect(
      scheduled
          .map((e) => DateTime.parse(e['scheduledDateTime'] as String).hour)
          .toSet(),
      {9, 18},
    );
    expect(scheduled.every((e) => e['payload'] == 'daily_ayah'), isTrue);
    expect(
      scheduled.every((e) => e['matchDateTimeComponents'] != null),
      isTrue,
    );
  });
  test('Azkar is scheduled ten minutes after Fajr and Maghrib', () async {
    permission = true;
    await NotificationService.instance.syncPrayerSchedule(
      enabled: true,
      lat: 6.5244,
      lng: 3.3792,
    );
    final azkar = scheduled
        .where((e) => e['payload'].toString().startsWith('azkar:'))
        .toList();
    expect(azkar.length, inInclusiveRange(12, 14));
    for (final reminder in azkar) {
      final day = ((reminder['id'] as int) - 200) ~/ 2;
      final morning = reminder['payload'] == 'azkar:morning';
      final prayers = scheduled.where(
        (e) => e['id'] == day * 10 + (morning ? 1 : 4),
      );
      if (prayers.isEmpty) continue; // Today's prayer can have already passed.
      final prayerTime = DateTime.parse(
        prayers.single['scheduledDateTime'] as String,
      );
      final azkarTime = DateTime.parse(reminder['scheduledDateTime'] as String);
      expect(azkarTime.difference(prayerTime), const Duration(minutes: 10));
    }
  });
  test('turning reminders off clears the schedule status', () async {
    await NotificationService.instance.syncPrayerSchedule(enabled: false);
    expect(scheduled, isEmpty);
    expect(NotificationService.instance.pendingPrayerCount.value, 0);
    expect(NotificationService.instance.reminderStatus.value, contains('off'));
  });
}
