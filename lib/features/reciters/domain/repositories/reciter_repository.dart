import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/reciter.dart';

abstract interface class ReciterRepository {
  Future<Either<Failure, List<Reciter>>> getReciters({String language});
}
