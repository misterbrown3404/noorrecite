import 'package:get/get.dart';

import '../../domain/entities/reciter.dart';
import '../../domain/usecases/get_reciters.dart';

class ReciterController extends GetxController {
  ReciterController(this._getReciters);
  final GetReciters _getReciters;

  final reciters = <Reciter>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  /// Raw text from the search field. UI writes to this on every keystroke;
  /// [_debouncedQuery] is what the filtered list actually reads.
  final searchQuery = ''.obs;

  /// Debounced, normalized (trimmed + lowercased) query. Updated ~300ms after
  /// the user stops typing so we don't re-filter the whole directory on every
  /// keystroke.
  final _debouncedQuery = ''.obs;

  /// Lowercased reciter names, index-aligned with [reciters], precomputed once
  /// per load so filtering never calls `toLowerCase()` per keystroke per item.
  final _searchIndex = <String>[];

  List<Reciter> get filteredReciters {
    final q = _debouncedQuery.value;
    if (q.isEmpty) return reciters;
    final source = reciters;
    final result = <Reciter>[];
    for (var i = 0; i < source.length; i++) {
      if (i < _searchIndex.length && _searchIndex[i].contains(q)) {
        result.add(source[i]);
      }
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    debounce(
      searchQuery,
      (String q) => _debouncedQuery.value = q.trim().toLowerCase(),
      time: const Duration(milliseconds: 300),
    );
    fetchReciters();
  }

  Future<void> fetchReciters() async {
    isLoading(true);
    error('');
    final result = await _getReciters();
    result.fold(
      (f) => error(f.message),
      (data) {
        reciters.assignAll(data);
        _searchIndex
          ..clear()
          ..addAll(data.map((r) => r.name.toLowerCase()));
      },
    );
    isLoading(false);
  }
}
