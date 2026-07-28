import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/surah_model.dart';
import '../../domain/entities/surah.dart';

abstract interface class SurahRemoteDataSource {
  Future<List<Surah>> getSuwar({String language = 'eng'});
}

class SurahRemoteDataSourceImpl implements SurahRemoteDataSource {
  final Dio _dio = DioClient.instance;

  @override
  Future<List<Surah>> getSuwar({String language = 'eng'}) async {
    final response = await _dio.get(
      ApiEndpoints.suwar,
      queryParameters: {'language': language},
    );
    final list = response.data['suwar'] as List;
    // Explicit <Surah> element type so the runtime list is List<Surah>, not
    // List<SurahModel> — avoids reified-generic mismatches downstream.
    return list
        .map<Surah>((e) => SurahModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
