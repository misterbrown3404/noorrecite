import 'package:fpdart/fpdart.dart';

import '../../../../core/error/crash_reporter.dart';
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
    } catch (e, s) {
      // Source is on-device/offline — any failure is a local read issue.
      CrashReporter.instance.recordError(e, s, reason: 'getAyat($surahId)');
      return const Left(
        CacheFailure('Could not load this surah. Please try again.'),
      );
    }
  }
}
