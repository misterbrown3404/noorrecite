import 'package:get/get.dart';

import '../../domain/entities/daily_ayah.dart';
import '../../domain/usecases/get_daily_ayah.dart';

class DailyAyahController extends GetxController {
  DailyAyahController(this._getDailyAyah);
  final GetDailyAyah _getDailyAyah;

  final dailyAyah = Rxn<DailyAyah>();
  final isLoading = true.obs;
  final error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDailyAyah();
  }

  Future<void> fetchDailyAyah() async {
    isLoading(true);
    error('');
    final result = await _getDailyAyah();
    result.fold(
      (f) => error(f.message),
      (data) => dailyAyah.value = data,
    );
    isLoading(false);
  }
}