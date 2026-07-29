import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  const Failure(this.message);

  /// User-facing, already-friendly message. Never contains raw exception text.
  final String message;

  @override
  List<Object> get props => [message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

/// Thrown by data sources when a response is missing, malformed, or otherwise
/// unusable. Carries a safe developer message (never surfaced to users) and is
/// mapped to a friendly [Failure] in the repository layer.
class DataFormatException implements Exception {
  const DataFormatException([this.detail = 'Unexpected response format']);
  final String detail;

  @override
  String toString() => 'DataFormatException: $detail';
}
