import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/surah_model.dart';
import '../../domain/entities/surah.dart';

abstract interface class SurahRemoteDataSource {
  Future<List<Surah>> getSuwar({String language = 'eng'});
}

class SurahRemoteDataSourceImpl implements SurahRemoteDataSource {
  SurahRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Surah>> getSuwar({String language = 'eng'}) async {
    final response = await _dio.get(
      ApiEndpoints.suwar,
      queryParameters: {'language': language},
    );

    final data = response.data;
    if (data is! Map || data['suwar'] is! List) {
      throw const DataFormatException('suwar: missing "suwar" list');
    }
    final list = data['suwar'] as List;
    // Explicit <Surah> element type so the runtime list is List<Surah>, not
    // List<SurahModel> — avoids reified-generic mismatches downstream.
    return list
        .whereType<Map<String, dynamic>>()
        .map<Surah>(SurahModel.fromJson)
        .toList();
  }
}
