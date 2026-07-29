import 'package:dio/dio.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/reciter_model.dart';
import '../../domain/entities/reciter.dart';

abstract interface class ReciterRemoteDataSource {
  Future<List<Reciter>> getReciters({String language = 'eng'});
}

class ReciterRemoteDataSourceImpl implements ReciterRemoteDataSource {
  ReciterRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Reciter>> getReciters({String language = 'eng'}) async {
    final response = await _dio.get(
      ApiEndpoints.reciters,
      queryParameters: {'language': language},
    );

    // Validate the shape before casting — a rate-limit/error body or an API
    // change otherwise throws an opaque TypeError surfaced as raw text.
    final data = response.data;
    if (data is! Map || data['reciters'] is! List) {
      throw const DataFormatException('reciters: missing "reciters" list');
    }
    final list = data['reciters'] as List;
    // Map with an explicit <Reciter> element type so the runtime list is
    // List<Reciter>, not List<ReciterModel> — otherwise reified-generic checks
    // (e.g. firstWhere's orElse) fail downstream.
    return list
        .whereType<Map<String, dynamic>>()
        .map<Reciter>(ReciterModel.fromJson)
        .toList();
  }
}
