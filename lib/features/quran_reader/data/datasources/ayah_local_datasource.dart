import 'package:quran/quran.dart' as quran;

import '../../domain/entities/ayah.dart';
import '../models/ayah_model.dart';

abstract interface class AyahLocalDataSource {
  Future<List<Ayah>> getAyat(int surahId);
}

/// Serves ayah text + translation from the bundled `quran` package. All data is
/// const/offline, so there is no I/O — the [Future] just satisfies the repo
/// contract and keeps the call site uniform with the network-backed sources.
class AyahLocalDataSourceImpl implements AyahLocalDataSource {
  @override
  Future<List<Ayah>> getAyat(int surahId) async {
    final count = quran.getVerseCount(surahId);
    return List<Ayah>.generate(
      count,
      (i) => AyahModel.fromQuran(surahId, i + 1),
    );
  }
}
