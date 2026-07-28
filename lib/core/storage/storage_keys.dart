/// Central registry of local-storage keys so features never collide.
abstract final class StorageKeys {
  // Audio / continue-listening
  static const String lastPlayback = 'last_playback';
  static const String preferredReciterId = 'preferred_reciter_id';

  /// Cached track durations, keyed by AudioTrack.id → duration in ms.
  static const String audioDurations = 'audio_durations';

  // Quran / continue-reading
  static const String lastRead = 'last_read';

  // Collections
  static const String bookmarks = 'bookmarks';
  static const String favorites = 'favorites';
  static const String downloads = 'downloads';

  // Settings
  static const String settings = 'app_settings';

  /// Whether the user has finished (or skipped) onboarding. When true, the
  /// splash skips straight to the main shell so onboarding shows only once.
  static const String onboardingComplete = 'onboarding_complete';

  // Statistics
  static const String statistics = 'statistics';

  // Last known GPS coordinates — used to compute prayer times instantly on
  // startup without waiting for a fresh GPS fix.
  static const String lastLat = 'last_lat';
  static const String lastLng = 'last_lng';

  // Daily reflection notes, keyed per verse (see reflectionNote()).
  static String reflectionNote(String dayKey) => 'reflection_$dayKey';

  /// Enumerable collection of saved reflections (JSON list), so the
  /// reflections list can render real entries with reference + timestamp.
  static const String reflections = 'reflections';
}
