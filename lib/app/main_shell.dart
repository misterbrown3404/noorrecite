import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/widgets/widgets.dart';
import 'main_shell_controller.dart';
import '../../features/audio_player/presentation/pages/audio_player_page.dart';
import '../../features/bookmarks/presentation/pages/bookmarks_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/downloads/presentation/pages/download_center_page.dart';
import '../../features/quran_reader/presentation/pages/quran_list_page.dart';

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  /// Builders (not instances) so an unvisited tab costs nothing until opened.
  static final List<Widget Function()> _tabs = [
    () => HomePage(),
    () => QuranListPage(),
    () => AudioPlayerPage(),
    () => BookmarksPage(),
    () => DownloadCenterPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainShellController>();
    return Scaffold(
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            for (var i = 0; i < _tabs.length; i++)
              // Lazily materialize a tab only after its first visit; keep it in
              // the tree afterward so IndexedStack preserves its state/scroll.
              controller.visited.contains(i)
                  ? _tabs[i]()
                  : const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => FloatingNavDock(
          items: FloatingNavDock.mainTabs,
          currentIndex: controller.currentIndex.value,
          onTap: controller.select,
        ),
      ),
    );
  }
}
