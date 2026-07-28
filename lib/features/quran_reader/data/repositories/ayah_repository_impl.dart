import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/repositories/ayah_repository.dart';
import '../datasources/ayah_local_datasource.dart';

class AyahRepositoryImpl implements AyahRepository {
  AyahRepositoryImpl(this._local);
  final AyahLocalDataSource _local;

  @override
  Future<Either<Failure, List<Ayah>>> getAyat(int surahId) async {
    try {
      final ayat = await _local.getAyat(surahId);
      return Right(ayat);
    } catch (e) {
      // Source is on-device/offline — any failure is a local read issue.
      return Left(CacheFailure(e.toString()));
    }
  }
}
