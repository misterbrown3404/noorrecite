import 'package:flutter_test/flutter_test.dart';
import 'package:qari_verse/features/reading_progress/domain/reading_progress.dart';

void main() {
  test('reading the same verse twice counts once per day', () {
    final day = DateTime(2026, 10, 24);
    final progress = ReadingProgress()
        .mark(1, 1, day)
        .mark(1, 1, day)
        .mark(1, 2, day);
    expect(progress.count(day), 2);
    expect(progress.count(DateTime(2026, 10, 25)), 0);
  });
  test('streak survives until today is read and breaks after a missed day', () {
    final progress = ReadingProgress()
        .mark(1, 1, DateTime(2026, 10, 22))
        .mark(1, 2, DateTime(2026, 10, 23));
    expect(progress.streak(DateTime(2026, 10, 24)), 2);
    expect(progress.streak(DateTime(2026, 10, 25)), 0);
  });
  test('calendar streak crosses month and year boundaries', () {
    final progress = ReadingProgress()
        .mark(1, 1, DateTime(2025, 12, 31))
        .mark(1, 1, DateTime(2026, 1, 1));
    expect(progress.streak(DateTime(2026, 1, 1)), 2);
    final restored = ReadingProgress.fromJson(progress.toJson());
    expect(restored.streak(DateTime(2026, 1, 1)), 2);
    expect(restored.dailyGoal, 10);
  });
  test('invalid goals are bounded and malformed history is ignored', () {
    final progress = ReadingProgress.fromJson({
      'goal': -4,
      'days': {'2026-10-24': 'invalid'},
    });
    expect(progress.dailyGoal, 1);
    expect(progress.count(DateTime(2026, 10, 24)), 0);
  });
}
