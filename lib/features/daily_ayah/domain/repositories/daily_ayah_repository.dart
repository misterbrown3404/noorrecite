import '../entities/daily_ayah.dart';

abstract interface class DailyAyahRepository {
  Future<DailyAyah> getDailyAyah();
}