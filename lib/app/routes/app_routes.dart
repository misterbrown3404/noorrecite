/// Named route constants for GetX navigation (project_rule.md §3.3 —
/// "Navigation exclusively through named routes").
abstract final class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  /// The tabbed main shell (Home/Quran/Audio/Saved/Profile).
  static const main = '/main';

  // Pushed (non-tab) destinations.
  static const audioPlayer = '/audio-player';
  static const reciters = '/reciters';
  static const dailyReflection = '/daily-reflection';
  static const reflectionsList = '/reflections';
  static const addReflection = '/reflections/add';
  static const downloadCenter = '/download-center';
  static const statistics = '/statistics';
  static const ayahReader = '/ayah-reader';
  static const search = '/search';
  static const settings = '/settings';
}
