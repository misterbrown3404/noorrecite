import 'package:get/get.dart';

import '../../core/di/service_locator.dart';
import '../../features/quran_reader/presentation/controllers/ayah_controller.dart';

// ReciterController is a permanent singleton (see service_locator.dart) shared
// by the Home tab and the Reciters page, so it needs no per-route binding.

class AyahReaderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AyahController(sl()));
  }
}
