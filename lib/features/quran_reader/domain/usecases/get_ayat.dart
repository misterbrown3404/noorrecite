import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ayah.dart';
import '../repositories/ayah_repository.dart';

class GetAyat {
  const GetAyat(this._repository);
  final AyahRepository _repository;

  Future<Either<Failure, List<Ayah>>> call(int surahId) =>
      _repository.getAyat(surahId);
}
