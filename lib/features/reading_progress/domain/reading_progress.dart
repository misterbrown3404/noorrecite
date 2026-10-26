/// Unique verses explicitly marked read, grouped by local calendar date.
class ReadingProgress {
  ReadingProgress({this.dailyGoal = 10, Map<String, Set<String>>? days})
    : days = days ?? {};
  final int dailyGoal;
  final Map<String, Set<String>> days;
  static String dayKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  int count(DateTime date) => days[dayKey(date)]?.length ?? 0;
  int streak(DateTime now) {
    var day = DateTime(now.year, now.month, now.day);
    if (count(day) == 0) day = DateTime(day.year, day.month, day.day - 1);
    var result = 0;
    while (count(day) > 0) {
      result++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return result;
  }

  ReadingProgress mark(int surah, int verse, DateTime date) {
    final updated = {
      for (final entry in days.entries) entry.key: Set<String>.of(entry.value),
    };
    (updated[dayKey(date)] ??= {}).add('$surah:$verse');
    return ReadingProgress(dailyGoal: dailyGoal, days: updated);
  }

  Map<String, dynamic> toJson() => {
    'goal': dailyGoal,
    'days': days.map((key, value) => MapEntry(key, value.toList())),
  };
  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    final raw = json['days'];
    return ReadingProgress(
      dailyGoal: (json['goal'] is int ? json['goal'] as int : 10).clamp(1, 100),
      days: raw is Map
          ? {
              for (final entry in raw.entries)
                if (entry.key is String && entry.value is List)
                  entry.key as String: (entry.value as List)
                      .whereType<String>()
                      .toSet(),
            }
          : {},
    );
  }
}
