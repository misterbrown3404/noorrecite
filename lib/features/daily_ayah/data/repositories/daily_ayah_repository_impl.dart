import '../../domain/entities/daily_ayah.dart';
import '../../domain/repositories/daily_ayah_repository.dart';
import '../datasources/daily_ayah_remote_datasource.dart';

class DailyAyahRepositoryImpl implements DailyAyahRepository {
  DailyAyahRepositoryImpl(this._remoteDataSource);
  final DailyAyahRemoteDataSource _remoteDataSource;

  @override
  Future<DailyAyah> getDailyAyah() async {
    return _remoteDataSource.getDailyAyah();
  }
}
