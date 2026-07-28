import '../models/daily_ayah_model.dart';
import '../../domain/entities/daily_ayah.dart';

abstract interface class DailyAyahRemoteDataSource {
  Future<DailyAyah> getDailyAyah();
}

class DailyAyahRemoteDataSourceImpl implements DailyAyahRemoteDataSource {
  DailyAyahRemoteDataSourceImpl();

  @override
  Future<DailyAyah> getDailyAyah() async {
    return DailyAyahModel.forToday();
  }
}