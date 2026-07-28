import 'package:get/get.dart';

import '../../domain/entities/reciter.dart';
import '../../domain/usecases/get_reciters.dart';

class ReciterController extends GetxController {
  ReciterController(this._getReciters);
  final GetReciters _getReciters;

  final reciters = <Reciter>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;
  final searchQuery = ''.obs;

  List<Reciter> get filteredReciters {
    if (searchQuery.value.isEmpty) return reciters;
    final q = searchQuery.value.toLowerCase();
    return reciters
        .where((r) => r.name.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchReciters();
  }

  Future<void> fetchReciters() async {
    isLoading(true);
    error('');
    final result = await _getReciters();
    result.fold(
      (f) => error(f.message),
      (data) => reciters.assignAll(data),
    );
    isLoading(false);
  }
}
