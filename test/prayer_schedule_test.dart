import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/core/services/prayer_schedule.dart';

void main() {
  test('current prayer changes at its start and Fajr ends at sunrise', () {
    final times = PrayerSchedule.times(6.5244, 3.3792, DateTime(2026, 10, 25));
    for (final prayer in times.where((p) => p.name != 'Sunrise')) {
      final schedule = PrayerSchedule.at(6.5244, 3.3792, prayer.time);
      expect(schedule.current.name, prayer.name);
      expect(schedule.current.time, prayer.time);
      expect(schedule.next.time.isAfter(prayer.time), isTrue);
    }
    final fajr = PrayerSchedule.at(6.5244, 3.3792, times.first.time);
    expect(fajr.afterSunrise, isFalse);
    expect(fajr.refreshAt, times[1].time);
    final sunrise = PrayerSchedule.at(6.5244, 3.3792, times[1].time);
    expect(sunrise.current.name, 'Fajr');
    expect(sunrise.afterSunrise, isTrue);
    expect(sunrise.next.name, 'Dhuhr');
  });
  test(
    'before Fajr retains previous Isha and Hijri date advances at sunset',
    () {
      final date = DateTime(2026, 10, 25);
      final times = PrayerSchedule.times(6.5244, 3.3792, date);
      final beforeFajr = PrayerSchedule.at(
        6.5244,
        3.3792,
        times.first.time.subtract(const Duration(seconds: 1)),
      );
      expect(beforeFajr.current.name, 'Isha');
      expect(
        beforeFajr.current.time,
        PrayerSchedule.times(6.5244, 3.3792, DateTime(2026, 10, 24)).last.time,
      );
      final sunset = times.firstWhere((p) => p.name == 'Maghrib').time;
      final before = PrayerSchedule.at(
        6.5244,
        3.3792,
        sunset.subtract(const Duration(seconds: 1)),
      );
      final after = PrayerSchedule.at(6.5244, 3.3792, sunset);
      expect(after.hijriDate, isNot(before.hijriDate));
      final midnight = PrayerSchedule.at(
        6.5244,
        3.3792,
        DateTime(2026, 10, 26),
      );
      expect(midnight.hijriDate, after.hijriDate);
    },
  );
  test('sunrise is displayed but never selected as next prayer', () {
    final times = PrayerSchedule.times(6.5244, 3.3792, DateTime(2026, 10, 25));
    final fajr = times.first;
    final schedule = PrayerSchedule.at(
      6.5244,
      3.3792,
      fajr.time.add(const Duration(minutes: 1)),
    );
    expect(schedule.today.any((p) => p.name == 'Sunrise'), isTrue);
    expect(schedule.next.name, 'Dhuhr');
  });
  test('after Isha uses next date astronomical Fajr, not today plus 24h', () {
    final date = DateTime(2026, 3, 20);
    final today = PrayerSchedule.times(40.7, 3.3792, date);
    final now = today.last.time.add(const Duration(minutes: 1));
    final expected = PrayerSchedule.times(
      40.7,
      3.3792,
      DateTime(now.year, now.month, now.day + 1),
    ).first.time;
    final schedule = PrayerSchedule.at(40.7, 3.3792, now);
    expect(schedule.next.time, expected);
    expect(schedule.next.name, 'Fajr');
    expect(
      schedule.next.time,
      isNot(today.first.time.add(const Duration(days: 1))),
    );
  });
  test(
    'midnight and year rollover give a future prayer on the correct day',
    () {
      final now = DateTime(2026, 12, 31, 23, 59);
      final schedule = PrayerSchedule.at(6.5244, 3.3792, now);
      expect(schedule.next.time.isAfter(now), isTrue);
      expect(schedule.next.time.year, 2027);
      expect(schedule.next.time.day, 1);
    },
  );
  test('missed prayers are not announced hours later', () {
    final time = DateTime(2026, 10, 25, 12);
    final prayer = PrayerTimeInfo(
      name: 'Dhuhr',
      time: time,
      isNext: true,
      timeRemaining: Duration.zero,
    );
    expect(PrayerSchedule.shouldAnnounce(prayer, time), isTrue);
    expect(
      PrayerSchedule.shouldAnnounce(
        prayer,
        time.add(const Duration(seconds: 30)),
      ),
      isTrue,
    );
    expect(
      PrayerSchedule.shouldAnnounce(prayer, time.add(const Duration(hours: 2))),
      isFalse,
    );
    expect(
      PrayerSchedule.shouldAnnounce(prayer.copyWith(name: 'Sunrise'), time),
      isFalse,
    );
  });
}
