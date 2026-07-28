import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/storage/cache_envelope.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../domain/entities/reciter.dart';
import '../../domain/repositories/reciter_repository.dart';
import '../datasources/reciter_remote_datasource.dart';
import '../models/reciter_model.dart';

const _cacheKey = 'cache_reciters_eng';
const _ttl = Duration(hours: 24);

class ReciterRepositoryImpl implements ReciterRepository {
  ReciterRepositoryImpl(this._remote, this._storage);
  final ReciterRemoteDataSource _remote;
  final LocalStorageService _storage;

  @override
  Future<Either<Failure, List<Reciter>>> getReciters({
    String language = 'eng',
  }) async {
    final cached = _readCache();

    if (cached != null && !cached.isStale(_ttl)) {
      // Fresh cache — return immediately, no network call.
      return Right(cached.data);
    }

    if (cached != null) {
      // Stale-while-revalidate: return cached copy now, refresh in background.
      _refreshInBackground(language);
      return Right(cached.data);
    }

    // No cache — must wait for network.
    return _fetch(language);
  }

  CacheEnvelope<List<Reciter>>? _readCache() {
    final raw = _storage.read<String>(_cacheKey);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final envelope = CacheEnvelope.tryParse<List<dynamic>>(json);
      if (envelope == null) return null;
      // map<Reciter> so the runtime list type is genuinely List<Reciter>, not
      // the covariant List<ReciterModel> — otherwise firstWhere/orElse at the
      // call sites throw a covariance TypeError on the closure.
      final reciters = envelope.data
          .map<Reciter>((e) => ReciterModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return CacheEnvelope(data: reciters, savedAtMs: envelope.savedAtMs);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(List<Reciter> reciters) async {
    final envelope = CacheEnvelope<List<dynamic>>(
      data: reciters
          .map((r) => ReciterModel(
                id: r.id,
                name: r.name,
                letter: r.letter,
                moshaf: r.moshaf,
              ).toJson())
          .toList(),
      savedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _storage.write(_cacheKey, jsonEncode(envelope.toJson()));
  }

  Future<void> _refreshInBackground(String language) async {
    try {
      final reciters = await _remote.getReciters(language: language);
      await _writeCache(reciters);
    } catch (_) {
      // Background refresh failure is silent — stale data is still shown.
    }
  }

  Future<Either<Failure, List<Reciter>>> _fetch(String language) async {
    try {
      final reciters = await _remote.getReciters(language: language);
      await _writeCache(reciters);
      // List<Reciter>.from so the runtime type matches the declared contract
      // (see _readCache) — the remote hands back a covariant List<ReciterModel>.
      return Right(List<Reciter>.from(reciters));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        return const Left(NetworkFailure());
      }
      return Left(ServerFailure(e.message ?? 'Server error'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
