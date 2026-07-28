# Refactoring Map — QariVerse

## 1. High-Priority Refactoring (Blocks Production)

### 1.1 Bundle Identifier — `com.example.noorrecite` → `com.noorrecite.app`
- **File:** `ios/Runner.xcodeproj/project.pbxproj`
- **Lines:** 385, 564, 586 (Release/Debug/Profile configs)
- **Issue:** Default Flutter placeholder bundle ID. App Store rejects apps with `com.example.*` identifiers.
- **Fix:** Replace all occurrences of `com.example.noorrecite` with `com.noorrecite.app`.

### 1.2 Info.plist — Missing App Store Required Keys
- **File:** `ios/Runner/Info.plist`
- **Issue:** No privacy usage descriptions. iOS requires `NSLocationWhenInUseUsageDescription` since the app uses `geolocator` for prayer times. Missing `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` if any future camera/photo features are added.
- **Fix:** Add `NSLocationWhenInUseUsageDescription`, `NSLocationAlwaysAndWhenInUseUsageDescription`, and any other required keys.

### 1.3 Generated.xcconfig — Debug Settings in Release
- **File:** `ios/Flutter/Generated.xcconfig`
- **Lines:** `DART_OBFUSCATION=false`, `TRACK_WIDGET_CREATION=true`, `DEBUGGER_SUPPORTED=true`
- **Issue:** These are debug-only settings that should not be in release builds or should be overridden by the Release.xcconfig.
- **Fix:** Ensure `Release.xcconfig` overrides these properly. Consider moving debug-only settings to `Debug.xcconfig` only.

### 1.4 Provisioning / Code Signing
- **File:** `ios/Runner.xcodeproj/project.pbxproj`
- **Lines:** 349, 450, 526 (`CODE_SIGN_IDENTITY[sdk=iphoneos*] = "iPhone Developer"`)
- **Issue:** No provisioning profiles configured. App Store distribution requires a distribution certificate and App Store provisioning profile.
- **Fix:** This must be done manually in Xcode or via Fastlane Match. The project uses `CODE_SIGN_STYLE = Automatic` which requires manual setup for App Store.

### 1.5 App Icon — Missing Sizes
- **File:** `ios/Runner/Assets.xcassets/AppIcon.appiconset/Contents.json`
- **Issue:** Missing `Icon-App-20x20@1x.png` (required for iPad), `Icon-App-60x60@1x.png` (not present in Contents.json but 60x60@2x and 60x60@3x exist). The 1024px master icon exists, which is correct for App Store.
- **Fix:** Verify all required icon sizes are present. The current Contents.json covers all iOS required sizes but iPad 1x is missing from the actual files.

### 1.6 Version Number for Production
- **File:** `pubspec.yaml` (line 4), `ios/Flutter/Generated.xcconfig` (line 9), `ios/Runner.xcodeproj/project.pbxproj` (Build settings)
- **Issue:** Version `1.0.0+1` is the default. Must be bumped for App Store submission.
- **Fix:** Bump to `1.0.0+1` with `buildName: 1.0.0` and `buildNumber: 1` and update accordingly.

## 2. Code Refactoring (Improves Maintainability)

### 2.8 All Screens Standardize on `AppHeader`
- **Goal:** Consolidate all screens to use `AppHeader` from `core/widgets/app_header.dart` instead of custom header implementations.
- **Completed:** `audio_player_page.dart` — replaced custom `_topBar()` with `AppHeader(actions: [HeaderIconAction(icon: Icons.download_outlined, ...)])`.
- **Completed:** `search_page.dart` — replaced custom header row (search field + cancel button) with `AppHeader` + standalone search field below it.
- **Already using AppHeader:** `quran_list_page.dart`, `ayah_reader_page.dart`, `reciters_page.dart`, `download_center_page.dart`, `statistics_page.dart`, `bookmarks_page.dart`, `daily_reflection_page.dart`, `reflections_list_page.dart`, `settings_page.dart`, `profile_page.dart`, `home_page.dart`.

### 2.1 AudioController — Mixed Concerns (303 lines)
- **File:** `lib/features/audio_player/presentation/controllers/audio_controller.dart`
- **Issue:** Combines playback control, queue management, persistence, offline-mode checks, and navigation-dependent logic (`Get.find<DownloadController>()`) in a single 303-line controller.
- **Recommended Split:**
  - `AudioPlaybackController` — play/pause/seek/speed/repeat/shuffle
  - `AudioQueueController` — queue management, index tracking, current track
  - `AudioPersistenceHelper` — debounced position save, session restore
  - Move `_sourceUri()` offline/detected logic into the DownloadController or a dedicated `AudioSourceResolver`

### 2.2 HomePage — Massive Widget File (947 lines)
- **File:** `lib/features/home/presentation/pages/home_page.dart`
- **Issue:** 947-line file with 10+ private widget classes, hardcoded mock data, and mixed concerns (prayer times, audio, bookmarks).
- **Recommended Split:**
  - `_Greeting`, `_NextPrayerCard`, `_ContinueListeningCard`, `_DailyAyahCard`, `_PopularReciters`, `_QuickActionsGrid` → each becomes a separate file under `features/home/presentation/widgets/`
  - Extract hardcoded data (prayer times, ayah text, reciter list) to a data layer

### 2.3 service_locator.dart — Redundant Dual Registrations (113 lines)
- **File:** `lib/core/di/service_locator.dart`
- **Issue:** Controllers registered in both GetIt AND GetX (`sl.registerSingleton()` + `Get.put(..., permanent: true)`). This is redundant — the GetIt registration is never used directly for controllers that are only accessed via `Get.find()`.
- **Recommended Fix:** Remove GetIt registrations for GetX controllers. Either use GetIt exclusively for non-UI services (datasources, repos, use cases) and GetX for controllers, or use GetIt for everything with `Get.put` removed.

### 2.4 dio_client.dart — Hardcoded Base URL
- **File:** `lib/core/network/dio_client.dart`
- **Issue:** Base URL hardcoded in the singleton. Not configurable per environment.
- **Recommended Fix:** Accept base URL via constructor parameter or read from a config file/env variable.

### 2.5 app_pages.dart — Incomplete Bindings
- **File:** `lib/app/routes/app_pages.dart`
- **Issue:** Several routes lack bindings (SettingsPage, ProfilePage). `SurahController` was registered in `QuranBinding` but that binding was never applied to any route, causing "SurahController not found" errors when `QuranListPage` (a direct child of `MainShell`) called `Get.find<SurahController>()`.
- **Fix:** Moved `SurahController` registration into `MainShellBinding` and removed the now-unused `QuranBinding` from `app_bindings.dart`.

### 2.6 add_reflection_page.dart — Hardcoded Data + Unimplemented Save
- **File:** `lib/features/daily_ayah/presentation/pages/add_reflection_page.dart`
- **Issue:** 300+ ayah entries hardcoded in `_showAyahPicker()`. Save button is a TODO with no actual persistence.
- **Fix:** Replace hardcoded list with data from a domain source; implement the save action via a `ReflectionsController`.

### 2.7 prayer_times_controller.dart — Public `formatDuration`
- **File:** `lib/features/home/presentation/controllers/prayer_times_controller.dart`
- **Issue:** `formatDuration()` is a public method (line 111) but is only used within the same file's UI. Also `PrayerTimeInfo` is a public class in the controller file.
- **Fix:** Move `PrayerTimeInfo` to the domain/entities layer and make `formatDuration` private or move to a utility.