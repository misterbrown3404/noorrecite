import 'package:get/get.dart';

import '../../core/di/service_locator.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController(sl()));
  }
}
