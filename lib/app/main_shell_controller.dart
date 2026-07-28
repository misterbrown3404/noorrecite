import 'package:get/get.dart';

class MainShellController extends GetxController {
  final currentIndex = 0.obs;

  /// Tabs the user has actually opened. Drives lazy tab construction in
  /// [MainShell]: only visited tabs build their (often network-bound) widget
  /// trees, so app launch pays for the Home tab alone. Home (0) starts visited.
  final RxSet<int> visited = <int>{0}.obs;

  void select(int index) {
    visited.add(index);
    currentIndex.value = index;
  }
}
