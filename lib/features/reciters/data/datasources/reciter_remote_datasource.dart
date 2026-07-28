import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/reciter_model.dart';
import '../../domain/entities/reciter.dart';

abstract interface class ReciterRemoteDataSource {
  Future<List<Reciter>> getReciters({String language = 'eng'});
}

class ReciterRemoteDataSourceImpl implements ReciterRemoteDataSource {
  final Dio _dio = DioClient.instance;

  @override
  Future<List<Reciter>> getReciters({String language = 'eng'}) async {
    final response = await _dio.get(
      ApiEndpoints.reciters,
      queryParameters: {'language': language},
    );
    final list = response.data['reciters'] as List;
    // Map with an explicit <Reciter> element type so the runtime list is
    // List<Reciter>, not List<ReciterModel> — otherwise reified-generic checks
    // (e.g. firstWhere's orElse) fail downstream.
    return list
        .map<Reciter>((e) => ReciterModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
