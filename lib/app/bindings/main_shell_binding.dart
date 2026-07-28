import 'package:get/get.dart';

import '../main_shell_controller.dart';
import '../../core/di/service_locator.dart';
import '../../features/quran_reader/presentation/controllers/surah_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MainShellController());
    Get.lazyPut(() => SurahController(sl(), sl()));
  }
}