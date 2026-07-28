import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/ayah.dart';

abstract interface class AyahRepository {
  Future<Either<Failure, List<Ayah>>> getAyat(int surahId);
}
