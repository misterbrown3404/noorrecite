import 'package:dio/dio.dart';

import 'crash_reporter.dart';
import 'failures.dart';

/// Translates raw exceptions into safe, user-friendly [Failure]s. Centralises
/// the rule that raw `e.toString()` (Dart type errors, stack traces, internal
/// SDK text) is NEVER shown to users, and reports server/unknown errors to the
/// crash sink so silent production failures become observable.
abstract final class FailureMapper {
  static Failure fromException(Object error, [StackTrace? stack]) {
    if (error is DioException) return _fromDio(error, stack);
    if (error is DataFormatException) {
      CrashReporter.instance.recordError(error, stack, reason: 'data format');
      return const ServerFailure(
        'We received an unexpected response. Please try again.',
      );
    }
    CrashReporter.instance.recordError(error, stack, reason: 'unhandled');
    return const ServerFailure('Something went wrong. Please try again.');
  }

  static Failure _fromDio(DioException e, StackTrace? stack) {
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.transformTimeout:
        return const NetworkFailure(
          'Connection problem. Check your internet and try again.',
        );
      case DioExceptionType.badResponse:
        final code = e.response?.statusCode;
        if (code != null && code >= 500) {
          CrashReporter.instance.recordError(e, stack, reason: 'server $code');
          return const ServerFailure(
            'Our servers are having trouble. Please try again shortly.',
          );
        }
        return const ServerFailure('Unable to load content. Please try again.');
      case DioExceptionType.cancel:
        return const ServerFailure('Request cancelled.');
      case DioExceptionType.badCertificate:
        CrashReporter.instance.recordError(e, stack, reason: 'bad cert');
        return const NetworkFailure('Secure connection failed.');
      case DioExceptionType.unknown:
        CrashReporter.instance.recordError(e, stack, reason: 'dio unknown');
        return const NetworkFailure(
          'Connection problem. Check your internet and try again.',
        );
    }
  }
}
