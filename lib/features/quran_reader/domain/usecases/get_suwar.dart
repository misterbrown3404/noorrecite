import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/surah.dart';
import '../repositories/surah_repository.dart';

class GetSuwar {
  const GetSuwar(this._repository);
  final SurahRepository _repository;

  Future<Either<Failure, List<Surah>>> call({String language = 'eng'}) =>
      _repository.getSuwar(language: language);
}
