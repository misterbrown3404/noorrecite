import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/reciter.dart';
import '../repositories/reciter_repository.dart';

class GetReciters {
  const GetReciters(this._repository);
  final ReciterRepository _repository;

  Future<Either<Failure, List<Reciter>>> call({String language = 'eng'}) =>
      _repository.getReciters(language: language);
}
