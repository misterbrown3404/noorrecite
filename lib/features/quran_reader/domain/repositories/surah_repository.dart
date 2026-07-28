import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/surah.dart';

abstract interface class SurahRepository {
  Future<Either<Failure, List<Surah>>> getSuwar({String language});
}
