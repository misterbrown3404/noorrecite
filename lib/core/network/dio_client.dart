import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  DioClient._();

  static Dio get instance => _instance;

  static final Dio _instance = () {
    final dio = Dio(
      BaseOptions(
        // Canonical host: the apex domain 301-redirects to www, so target it
        // directly to avoid an extra redirect hop on every request.
        baseUrl: 'https://www.mp3quran.net/api/v3/',
        // Tighter than the old 30s: reference lists are small, and cached data
        // is served instantly meanwhile, so a fast failure beats a long hang.
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 12),
        // gzip shrinks the reciters/suwar payloads substantially on the wire.
        headers: {
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip',
        },
        // Reuse decoded JSON maps without a second parse pass.
        responseType: ResponseType.json,
      ),
    );

    // Retry once on transient connectivity blips before surfacing a failure —
    // covers flaky mobile networks without user-visible errors.
    dio.interceptors.add(_RetryInterceptor(dio));

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(responseBody: false));
    }
    return dio;
  }();
}

/// Retries idempotent GET requests once on connection/timeout errors after a
/// short backoff. Deliberately conservative: a single retry, GETs only.
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);
  final Dio _dio;

  static const _retryableTypes = {
    DioExceptionType.connectionError,
    DioExceptionType.connectionTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.sendTimeout,
  };

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra['retried'] == true;
    final isGet = options.method.toUpperCase() == 'GET';

    if (isGet && !alreadyRetried && _retryableTypes.contains(err.type)) {
      options.extra['retried'] = true;
      await Future<void>.delayed(const Duration(milliseconds: 400));
      try {
        final response = await _dio.fetch<dynamic>(options);
        return handler.resolve(response);
      } catch (_) {
        // Fall through to the original error below.
      }
    }
    handler.next(err);
  }
}
