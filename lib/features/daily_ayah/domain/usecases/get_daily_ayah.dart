import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/daily_ayah.dart';
import '../repositories/daily_ayah_repository.dart';

class GetDailyAyah {
  GetDailyAyah(this._repository);
  final DailyAyahRepository _repository;

  Future<Either<Failure, DailyAyah>> call() async {
    try {
      final ayah = await _repository.getDailyAyah();
      return right(ayah);
    } catch (e) {
      return left(ServerFailure('Failed to fetch daily ayah'));
    }
  }
}