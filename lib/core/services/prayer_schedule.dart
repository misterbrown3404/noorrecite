import 'package:adhan/adhan.dart' as adhan;
import 'package:hijri/hijri_calendar.dart';

/// The same calculation settings are used by the UI and local reminders.
class PrayerSchedule {
  PrayerSchedule._(
    this.today,
    this.next,
    this.current,
    this.afterSunrise,
    this.hijriDate,
    this.refreshAt,
  );
  final List<PrayerTimeInfo> today;
  final PrayerTimeInfo next;

  /// Most recent prayer start, including yesterday's Isha before Fajr.
  final PrayerTimeInfo current;
  final bool afterSunrise;
  final String hijriDate;
  final DateTime refreshAt;

  static List<PrayerTimeInfo> times(double lat, double lng, DateTime date) {
    final params = adhan.CalculationMethod.muslim_world_league.getParameters()
      ..madhab = adhan.Madhab.shafi;
    final p = adhan.PrayerTimes(
      adhan.Coordinates(lat, lng),
      adhan.DateComponents.from(date),
      params,
    );
    return [
          ('Fajr', p.fajr),
          ('Sunrise', p.sunrise),
          ('Dhuhr', p.dhuhr),
          ('Asr', p.asr),
          ('Maghrib', p.maghrib),
          ('Isha', p.isha),
        ]
        .map(
          (e) => PrayerTimeInfo(
            name: e.$1,
            time: e.$2,
            isNext: false,
            timeRemaining: e.$2.difference(date),
          ),
        )
        .toList();
  }

  factory PrayerSchedule.at(double lat, double lng, DateTime now) {
    final today = times(lat, lng, now);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final next = [...today, ...times(lat, lng, tomorrow)]
        .firstWhere((p) => p.name != 'Sunrise' && p.time.isAfter(now))
        .copyWith(isNext: true);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final current = [
      ...times(lat, lng, yesterday),
      ...today,
    ].lastWhere((p) => p.name != 'Sunrise' && !p.time.isAfter(now));
    final sunrise = today.firstWhere((p) => p.name == 'Sunrise').time;
    final maghrib = today.firstWhere((p) => p.name == 'Maghrib').time;
    // Advance the Islamic calendar at local sunset.
    final hijri = HijriCalendar.fromDate(
      now.isBefore(maghrib) ? now : tomorrow,
    );
    return PrayerSchedule._(
      today.map((p) => p.time == next.time ? next : p).toList(),
      next,
      current,
      current.name == 'Fajr' && !now.isBefore(sunrise),
      '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} AH',
      now.isBefore(sunrise) && sunrise.isBefore(next.time)
          ? sunrise
          : next.time,
    );
  }

  /// Don't replay missed prayers after the app has been asleep for hours.
  static bool shouldAnnounce(PrayerTimeInfo prayer, DateTime now) {
    final late = now.difference(prayer.time);
    return prayer.name != 'Sunrise' &&
        !late.isNegative &&
        late < const Duration(minutes: 1);
  }
}

class PrayerTimeInfo {
  PrayerTimeInfo({
    required this.name,
    required this.time,
    required this.isNext,
    required this.timeRemaining,
  });
  final String name;
  final DateTime time;
  final bool isNext;
  final Duration timeRemaining;
  String get formattedTime {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    return '$hour:${time.minute.toString().padLeft(2, '0')} ${time.hour >= 12 ? 'PM' : 'AM'}';
  }

  PrayerTimeInfo copyWith({
    String? name,
    DateTime? time,
    bool? isNext,
    Duration? timeRemaining,
  }) => PrayerTimeInfo(
    name: name ?? this.name,
    time: time ?? this.time,
    isNext: isNext ?? this.isNext,
    timeRemaining: timeRemaining ?? this.timeRemaining,
  );
}
