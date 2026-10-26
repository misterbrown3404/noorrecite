# QariVerse redesign

Direction: modern expressive, with violet primary actions, mint/lime highlights,
layered rounded surfaces, Inter headings, and Amiri Quran text.

## Implemented

- Shared palette, typography, cards, navigation, theme defaults, and background.
- Rebuilt onboarding with localized slides and animated geometric illustrations.
- Updated settings, reciters, downloads, and reflections with shared feature headers.
- Home reading journey with configurable daily verse goals and reading streaks.
- Quran library with lazy rendering, name/number search, actual juz filtering,
  revelation filters, saved-surah filtering, and last-reading entry.
- Reader with adjustable Arabic size, translation toggle, hide/reveal practice,
  bookmarks, and explicit verse completion saved locally.
- Saved listening queues as named playlists, with playback and deletion.
- Sleep timer and persistent mini-player across the main tabs.
- Accessible native audio scrubber and scrollable player layout.
- Audio queue and reciter picker extracted from the player page.
- Fixed playback resume waiting for the entire track and position saves being
  indefinitely postponed by frequent stream events.
- Hidden tabs suspend animation tickers. Entrance/press/floating/glow/shimmer
  effects honor reduced-motion settings.
- iOS location usage description for the existing prayer-times feature.

Reading progress counts unique verses explicitly marked read on each local
calendar day. Reopening a surah does not create progress. A streak counts days
with at least one marked verse; the daily goal is a separate target. Practice
mode does not assess recitation accuracy. The last-reading tile opens the surah
and displays the last marked verse; automatic scrolling to that verse is not
implemented. Playlists preserve audio references, not downloaded files.

## Structure

- `features/reading_progress/domain`: pure calendar/progress rules.
- `features/reading_progress/presentation`: persistence controller and goal UI.
- `features/playlists/presentation`: saved queue management and selection UI.
- Existing infrastructure/domain dependency injection remains in GetIt;
  presentation controllers remain in GetX.

## Validation

Flutter analysis, existing helper tests, reading progress regressions, narrow
phone navigation, reduced-motion widget behavior, and iOS simulator launch.

## Remaining scope

This is a substantial redesign of the core experience, not a complete rewrite
of every existing subsystem. Supporting screens use the shared visual system; some retain their existing
content organization and controllers. Full localization of new UI copy, complete
screen-by-screen dark-mode/accessibility review, verse-timed audio repetition,
playlist track editing/reordering, automatic reader position restoration, and
physical-device/background-audio validation remain future work.

## Home: prayer and remembrance

- Moved prayer times to the top of Home, with a live countdown, location loading/error states, and a full daily schedule destination.
- Added a lavender Azkar card and a dedicated remembrance screen with four Arabic phrases, transliterations, meanings, independent session counters, haptic feedback, and confirmed reset. Counts last while the screen remains open.
- Added original bundled mosque and prayer-bead SVGs in `assets/illustrations/`, animated with slow float/sway in Flutter. Motion respects reduced-motion settings and tab ticker visibility.
- Kept Quran reading, listening, reading progress, reflection, and reciters beneath the new daily worship section.
- Validation: narrow-phone worship card layouts, location states, countdown rendering, counter switching/reset, and existing navigation/reduced-motion widget tests.

## Prayer reliability and headers

- Added a shared rounded app bar with a subtitle and accessible back button; updated the global app-bar theme and prayer/worship library headers.
- UI and reminder scheduling now share `PrayerSchedule`. Sunrise remains a marker, never the next prayer. Tomorrow's Fajr is calculated for tomorrow's date. The controller refreshes on date rollover and app resume and avoids replaying prayers missed while inactive.
- Location refresh is serialized and awaited. Saved coordinates and the device's last fix remain available when GPS fails. The prayer page displays location provenance, refresh status, and settings recovery actions. macOS now declares location usage and sandbox location/network access.
- Denied notification permission cancels prayer alerts instead of scheduling anyway. Scheduling is serialized, reports errors and exact-alarm fallback, and exposes the scheduled count. Automatic refresh no longer opens Android exact-alarm settings.
- Full in-app adhan uses the existing audio player, including notification cold-launch handling, rather than creating a second player rejected by just_audio_background. Quran queue/position are restored paused afterward. Android foreground prayer alerts rely on the scheduled notification to avoid duplicate adhan playback.
- Prayer page includes a reminder test (about 10 seconds), adhan preview/stop, and settings links. iOS uses its notification sound in the background; tapping the alert opens full adhan playback.
- Validation: 21 regression tests pass, including prayer boundaries, location failure/permissions, native-channel notification scheduling mocks, and existing worship/UI tests. Flutter analysis is clean. Physical-device GPS, audible playback, Focus/DND, and locked-screen delivery still require device testing.
