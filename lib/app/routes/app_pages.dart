import '../../features/downloads/presentation/pages/download_center_page.dart';
import '../../features/reading_progress/presentation/reading_statistics_page.dart';
import '../../features/azkar/data/worship_repository.dart';
import '../../features/azkar/presentation/pages/tasbih_page.dart';
import '../../features/azkar/presentation/pages/duas_page.dart';
import '../../features/azkar/presentation/pages/allah_names_page.dart';
import '../../features/azkar/presentation/pages/azkar_category_page.dart';
import 'package:get/get.dart';
import '../../features/azkar/presentation/pages/azkar_page.dart';
import '../../features/home/presentation/pages/prayer_times_page.dart';

import '../../features/audio_player/presentation/pages/audio_player_page.dart';
import '../../features/daily_ayah/presentation/pages/add_reflection_page.dart';
import '../../features/daily_ayah/presentation/pages/daily_reflection_page.dart';
import '../../features/daily_ayah/presentation/pages/reflections_list_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/onboarding/presentation/pages/splash_page.dart';
import '../../features/quran_reader/presentation/pages/ayah_reader_page.dart';
import '../../features/reciters/presentation/pages/reciters_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../bindings/app_bindings.dart';
import '../bindings/main_shell_binding.dart';
import '../bindings/settings_binding.dart';
import '../main_shell.dart';
import 'app_routes.dart';

/// GetX route table. Presentation-only for now; bindings are added per feature
/// as controllers grow (project_rule.md §3.3).
abstract final class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.downloadCenter,
      page: () => const DownloadCenterPage(),
    ),
    GetPage(
      name: AppRoutes.statistics,
      page: () => const ReadingStatisticsPage(),
    ),
    GetPage(name: AppRoutes.duas, page: () => const DuasPage()),
    GetPage(name: AppRoutes.allahNames, page: () => const AllahNamesPage()),
    GetPage(name: AppRoutes.tasbih, page: () => const TasbihPage()),
    GetPage(
      name: AppRoutes.azkarCategory,
      page: () {
        final category = Get.arguments;
        return category is AzkarCategory
            ? AzkarCategoryPage(category: category)
            : const AzkarPage();
      },
    ),
    GetPage(name: AppRoutes.azkar, page: () => const AzkarPage()),
    GetPage(name: AppRoutes.prayerTimes, page: () => const PrayerTimesPage()),
    GetPage(name: AppRoutes.splash, page: () => const SplashPage()),
    GetPage(name: AppRoutes.onboarding, page: () => const OnboardingPage()),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainShell(),
      binding: MainShellBinding(),
    ),
    GetPage(
      name: AppRoutes.audioPlayer,
      page: () => const AudioPlayerPage(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.dailyReflection,
      page: () => const DailyReflectionPage(),
    ),
    GetPage(
      name: AppRoutes.reflectionsList,
      page: () => const ReflectionsListPage(),
    ),
    GetPage(
      name: AppRoutes.addReflection,
      page: () => const AddReflectionPage(),
    ),
    GetPage(name: AppRoutes.reciters, page: () => const RecitersPage()),
    GetPage(
      name: AppRoutes.ayahReader,
      page: () => const AyahReaderPage(),
      binding: AyahReaderBinding(),
      transition: Transition.rightToLeft,
    ),

    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsPage(),
      binding: SettingsBinding(),
    ),
  ];
}
