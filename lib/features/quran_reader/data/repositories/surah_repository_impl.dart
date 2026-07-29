import 'dart:convert';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/storage/cache_envelope.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../domain/entities/surah.dart';
import '../../domain/repositories/surah_repository.dart';
import '../datasources/surah_remote_datasource.dart';
import '../models/surah_model.dart';

// Surah metadata is effectively immutable, so a long TTL keeps it fully offline
// while still picking up rare corrections on a weekly cadence.
const _ttl = Duration(days: 7);

class SurahRepositoryImpl implements SurahRepository {
  SurahRepositoryImpl(this._remote, this._storage);
  final SurahRemoteDataSource _remote;
  final LocalStorageService _storage;

  @override
  Future<Either<Failure, List<Surah>>> getSuwar({
    String language = 'eng',
  }) async {
    final cached = _readCache(language);

    if (cached != null && !cached.isStale(_ttl)) {
      return Right(cached.data);
    }

    if (cached != null) {
      // Stale-while-revalidate: serve cache now, refresh silently.
      _refreshInBackground(language);
      return Right(cached.data);
    }

    return _fetch(language);
  }

  CacheEnvelope<List<Surah>>? _readCache(String language) {
    final raw = _storage.read<String>(StorageKeys.suwarCache(language));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final envelope = CacheEnvelope.tryParse<List<dynamic>>(json);
      if (envelope == null) return null;
      final suwar = envelope.data
          .map<Surah>((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return CacheEnvelope(data: suwar, savedAtMs: envelope.savedAtMs);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String language, List<Surah> suwar) async {
    final envelope = CacheEnvelope<List<dynamic>>(
      data: suwar
          .map((s) => SurahModel(
                id: s.id,
                name: s.name,
                startPage: s.startPage,
                endPage: s.endPage,
                type: s.type,
                juz: s.juz,
              ).toJson())
          .toList(),
      savedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    await _storage.write(
      StorageKeys.suwarCache(language),
      jsonEncode(envelope.toJson()),
    );
  }

  Future<void> _refreshInBackground(String language) async {
    try {
      final suwar = await _remote.getSuwar(language: language);
      await _writeCache(language, suwar);
    } catch (_) {
      // Silent — stale data remains valid.
    }
  }

  Future<Either<Failure, List<Surah>>> _fetch(String language) async {
    try {
      final suwar = await _remote.getSuwar(language: language);
      await _writeCache(language, suwar);
      return Right(List<Surah>.from(suwar));
    } catch (e, s) {
      return Left(FailureMapper.fromException(e, s));
    }
  }
}
