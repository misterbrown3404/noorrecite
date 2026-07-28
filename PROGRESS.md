# QariVerse — Progress & Handoff

> Living document for cross-session / cross-model continuity. Update this as work
> proceeds so any AI (or human) can resume without re-deriving context.
>
> **Last updated:** 2026-07-26

---

## 1. What this project is

**QariVerse** (package name `noorrecite`) — a Flutter Quran audio/reading app.
Offline-first, serverless-first. Design language: **"Ethereal Sanctuary"**
(glassmorphism + soft neumorphism, emerald/gold Material-3 palette, bi-scriptual
typography).

### Authoritative references (read these first)
- **`project_rule.md`** — the engineering blueprint (789 lines). Offline-first
  (Isar = source of truth) + serverless-first (Supabase). Clean Architecture +
  Feature-First. NOTE: its §9.1 color palette (#0F5C4A) is **superseded** by
  DESIGN.md per user decision.
- **`assets/stitch_qariverse_ai_quran_experience/qariverse/DESIGN.md`** — the
  **authoritative design system**. M3 tokens (primary `#006a39`, secondary/teal
  `#006b5f`, tertiary/gold `#805200`, surface `#f7f9fb`, error `#ba1a1a`),
  typography scale, spacing, component specs.
- **`assets/stitch_qariverse_ai_quran_experience/<screen>/code.html` + `screen.png`**
  — 19 Stitch-generated mockups. Each screen folder has HTML + PNG reference.

### Locked decisions (do not re-litigate without user)
| Decision | Choice |
|---|---|
| Color palette | Follow **DESIGN.md** (emerald `#006a39`), NOT project_rule §9.1 |
| Fonts | **google_fonts** package — Amiri (Arabic), Literata (headings), Inter (body) |
| Mockup images | **Downloaded & bundled locally** into `assets/images/` (28 files) |
| Animations | **Native Flutter** (AnimationController / implicit), NO Lottie |

---

## 2. Current state — DONE ✅

The **UI layer is complete and verified**: all 13 screens built, themed, wired
with real design images and native animations.

- `flutter analyze` → **No issues found!**
- `flutter test` → **All tests passed!**

### Design system / core (`lib/core/`)
- `theme/app_theme.dart` — `AppTheme.light()`, `AppColors`, `AppTypography`
  (headlineLg, headlineLgMobile, bodyEn, bodyEnSm, bodyAr, displayAr, titleLg,
  labelCaps, labelSemibold), `AppSpacing` (xs/sm/md/lg/xl/xxl/margin +
  screenPadding/cardInsets), `AppRadii` (sm/cardRadius/pillRadius/xl/full),
  `AppShadows` (card/inset/neumorphic/primaryGlow/goldGlow).
- `widgets/widgets.dart` — barrel export of the component library:
  app_buttons (GlowPrimaryButton, GhostGlassButton), ayah_card, empty_state,
  error_state_view, floating_nav_dock, geometric_background, glass_card,
  neu_button (NeuIconButton, NeuInsetField), pill_tag, section_header,
  surah_ornament_number, **animations**, app_header (AppHeader, HeaderIconAction).
- `widgets/animations.dart` — **native animation widgets** (see §4).
- `constants/app_assets.dart` — `AppAssets` central asset-path catalogue.
- `mock/mock_data.dart` + `mock/mock_models.dart` — temporary presentation data
  (MockSurah, MockReciter, MockBookmark, MockAyahRef, Revelation enum).
  **These are placeholders** — to be replaced by real domain entities + repos.

### App shell (`lib/app/`)
- `app.dart` — `QariVerseApp` (GetMaterialApp, named routes, splash initial).
- `main_shell.dart` — `MainShell` (5-tab IndexedStack + FloatingNavDock:
  Home·Quran·Audio·Saved·Profile) + `MainShellController`.
- `design_gallery_page.dart` — component catalogue for visual QA.
- `routes/app_routes.dart` + `routes/app_pages.dart` — GetX route defs.
- `lib/main.dart` — `void main() => runApp(const QariVerseApp());`

### Screens built (all in `lib/features/<f>/presentation/pages/`)
| Feature | Page | Image(s) wired | Animation(s) |
|---|---|---|---|
| onboarding | splash_page | splashQuran tile | Floating, PulseGlow, FadeInUp |
| onboarding | onboarding_page | discover/reflect/velvet | Floating, animated dots |
| auth | auth_page | mosque sunset (ShaderMask bleed) | — |
| home | home_page | mosque hero, avatar, reciter portraits | — |
| quran_reader | quran_list_page | fatiha-page hero | Shimmer (progress) |
| reciters | reciters_page | portrait per card | — |
| bookmarks | bookmarks_page | quran-on-cushion hero | — |
| audio_player | audio_player_page | quran-on-velvet artwork | AnimatedWaveform |
| daily_ayah | daily_reflection_page | lanterns (top ShaderMask bleed) | — |
| downloads | download_center_page | Mishary portrait | Shimmer (download bar) |
| statistics | statistics_page | — | PulseGlow (flame), Shimmer (bar) |
| profile | profile_page | avatar | — |
| premium | premium_page | gold ornament hero | Floating, Shimmer (annual card) |

### Smoke test
- `test/widget_test.dart` — boots `QariVerseApp`, asserts splash shows
  'QariVerse' + 'BISMILLAH', then drains the splash 2200ms nav Timer before
  teardown (avoids `!timersPending` assertion).

---

## 3. Bundled assets

`assets/images/` — 28 JPGs downloaded from the Stitch CDN, keyed
`<screen>__<n>.jpg`. Mapped to semantic names in `AppAssets`. Registered in
`pubspec.yaml`. Manifest of original URLs was at `/tmp/img_manifest.txt`
(regenerate from mockup HTML if needed).

---

## 4. Animation inventory — full spec (authoritative)

The complete animation taxonomy for QariVerse, in 4 tiers by complexity /
implementation style. **Status legend:** ✅ built · 🟡 partial · ⏳ not started.

### Tier 1 — Core Visual Effects (CSS/JS-equivalent, native Flutter)
The "living" feel: smooth transitions + ambient motion.

| Effect | Status | Where | Implementation notes |
|---|---|---|---|
| **Ambient Glow Aura** — slow radial-gradient pulse, meditative | ✅ | Splash + Home (`GeometricBackground(showAura: true)`) | `_AmbientAura` in `geometric_background.dart` — an 8s breathing `RadialGradient` layer behind the star pattern. Off by default; opt in per screen. |
| **Hero Parallax** — silhouettes move at different scroll speeds for depth | ⏳ | Home dashboard, Audio player | Needs a scroll-driven `Transform.translate` tied to `ScrollController` offset; images already bundled. |
| **Micro-Interactions** — 0.98× scale-down + deeper shadow on tap | ✅ | GlassCard, GlowPrimaryButton, GhostGlassButton, NeuIconButton | `PressableScale` (GestureDetector + `AnimatedScale`, 0.98×) wraps all tappable surfaces. Inert when `onTap == null`. |
| **Shimmer Loading States** — gold-tinted linear sweep while fetching | ✅ | Reciters (skeleton cards on first load) | `Shimmer` gained a `highlight` colour param; `SkeletonBox` (+ `.circle`) uses a gold tint. Reciters page is now stateful with a simulated 900ms fetch → 4 skeleton cards, wired to swap for the real repo flag. |

### Tier 2 — Branded Motion (animated SVG-equivalent)
Vector motion for crisp storytelling.

| Effect | Status | Where | Implementation notes |
|---|---|---|---|
| **Pulsing Quran Icon** — "breathing" glow expand/contract | ✅ | Splash (centerpiece) | `Floating` + `PulseGlow` on the quran tile. Refine to icon-specific breathing if desired. |
| **Cloud-to-Device Download** — data flowing into a device silhouette | ⏳ | Onboarding-Listen, Download Center | Custom `AnimationController` path animation or `flutter_svg` + animated `CustomPainter`. |
| **Audio Waveform** — reactive frequency visualization | 🟡 | Audio Player | `AnimatedWaveform` built (synthetic phase-shifted bars). Make it react to real audio amplitude once audio engine lands. |
| **Floating Lanterns / Crescent** — gentle decorative float | 🟡 | Auth ✅ (static lantern image via ShaderMask), Empty States ⏳ | Wrap the decorative art in `Floating`; add to `empty_state` widget. |

### Tier 3 — Procedural & Advanced Effects (fragment shaders)
Reserved for premium moments. **None built yet** — these need `.frag` shaders
registered under `flutter:` → `shaders:` in pubspec + `FragmentProgram`.

| Effect | Status | Where | Implementation notes |
|---|---|---|---|
| **Ethereal Light Rays** — moving light shafts behind open Quran | ⏳ | Onboarding-Reflect | Fragment shader; animate a `uTime` uniform via a ticker. |
| **Fluid Wave Player** — liquid emerald flow shifting with audio | ⏳ | Audio Player background | Fragment shader driven by `uTime` + audio amplitude uniform. |

### Tier 4 — Progress & Achievement (component logic)

| Effect | Status | Where | Implementation notes |
|---|---|---|---|
| **Linear Surah Progress** — ease-in-out fill | ✅ | Home, Full Quran, Statistics, Download Center | `AnimatedProgressBar` (`TweenAnimationBuilder`, 0→value, `Curves.easeInOut`, pill-clipped). Replaced the static `LinearProgressIndicator`s; composes under `Shimmer` where the sheen was already applied. |
| **Streak Counter fire glow** — celebrate 14-day streak | ✅ | Statistics | `PulseGlow` on the flame icon. |

### Built widgets (in `lib/core/widgets/animations.dart`)
`Floating` (float), `PulseGlow` (aura-pulse), `FadeInUp` (entrance),
`AnimatedWaveform` (wave), `Shimmer` (progress-shimmer/shimmer sweep, now with a
`highlight` colour param), `PressableScale` (0.98× tap feedback), `SkeletonBox`
(+ `.circle`, gold shimmer loading blocks), `AnimatedProgressBar` (ease-in-out
fill). Plus `_AmbientAura` inside `geometric_background.dart`.

### To build next (animation backlog, roughly by value/effort)
1. ~~`PressableScale` micro-interaction wrapper~~ ✅ applied to GlassCard + all buttons.
2. ~~Full-screen **Ambient Glow Aura** layer in `GeometricBackground`~~ ✅ (home + splash opt in).
3. ~~**Skeleton + gold Shimmer** loading states~~ ✅ (reciters). Extend to downloads/other lists when they gain real fetches.
4. ~~**Linear progress** ease-in-out fills~~ ✅ (`AnimatedProgressBar`).
5. **Hero Parallax** on scroll (home, audio player) — needs `ScrollController`.
6. **Floating** decorative art in empty states.
7. **Cloud-to-Device** SVG/painter animation (onboarding-listen, downloads).
8. Tier 3 **shaders** (light rays, fluid wave) — last, most premium; requires
   real audio amplitude for the fluid player to be meaningful.

---

## App Store Production Preparation (2026-07-26)

### iOS Configuration Changes

| File | Change | Reason |
|---|---|---|
| `ios/Runner.xcodeproj/project.pbxproj` | Bundle ID `com.example.noorrecite` → `com.noorrecite.app` | `com.example.*` rejected by App Store Review |
| `ios/Runner.xcodeproj/project.pbxproj` | Test target bundle ID `com.example.noorrecite.RunnerTests` → `com.noorrecite.RunnerTests` | Consistency with new app bundle ID |
| `ios/Runner/Info.plist` | Added `NSLocationWhenInUseUsageDescription` | Required for `geolocator` prayer times feature |
| `ios/Runner/Info.plist` | Added `NSLocationAlwaysAndWhenInUseUsageDescription` | Required for `geolocator` prayer times feature |
| `ios/Runner/Info.plist` | Added `UIRequiresFullScreen` = `true` | Portrait-focused Quran app; prevents split-view on iPad |
| `ios/Flutter/Release.xcconfig` | Added `DART_OBFUSCATION=true`, `TRACK_WIDGET_CREATION=false`, `TREE_SHAKE_ICONS=true` | Production release optimizations |

### Bug Fixes

| File | Change | Reason |
|---|---|---|
| `lib/features/home/presentation/controllers/prayer_times_controller.dart:53` | `CalculationMethod.muslim_world_league()` → `CalculationMethod.muslim_world_league.getParameters()` | adhan 2.0.0+1 API change: `getParameters()` returns `CalculationParameters` |
| `lib/features/home/presentation/controllers/prayer_times_controller.dart:93` | `prayerTimes` → `allPrayerTimes` | Field name typo — `allPrayerTimes` is the actual field name |

### Verification

- `flutter analyze` — 7 issues (all info/warning, 0 errors)
- `flutter test` — All tests passed!

### Remaining Manual Steps for App Store Submission

1. **Code Signing**: Create an App Store distribution certificate and provisioning profile in the Apple Developer Portal. Configure in Xcode (Signing & Capabilities) or via Fastlane Match.
2. **App Store Connect**: Create the app listing, upload screenshots, write description, set pricing.
3. **Privacy Policy URL**: Required by App Store — provide a URL in App Store Connect.
4. **App Review Guidelines**: Ensure no placeholder content, placeholder data, or placeholder functionality remains. Replace hardcoded mock data ("Ahmad" user, "12 Shawwal, 1445 AH") with real data sources.
5. **Version Bump**: Update `pubspec.yaml` `version` field and `ios/Flutter/Generated.xcconfig` `FLUTTER_BUILD_NAME`/`FLUTTER_BUILD_NUMBER` before submission.

The app is currently a **UI-complete shell on mock data**. To make it real,
follow `project_rule.md` architecture. Feature folders already have empty
`data/domain/presentation` scaffolding (see `lib/features/*/`).

### Suggested order
1. **Foundation / DI & storage**
   - `core/storage` — Isar setup (source of truth).
   - `core/di` — get_it registration.
   - `core/network` — Dio + interceptors; `core/config` — env/Supabase config.
   - `core/error` — Failure/Exception types (fpdart Either).
2. **Data layer for Quran** — surah/ayah entities, Isar collections, repository
   (bundle Quran text as seed asset for offline-first). Replace `MockData.surahs`.
3. **Audio** — just_audio (or audio_service) integration; reciter audio sources;
   download manager backing the download_center UI.
4. **Auth + sync** — Supabase auth; `core/sync` for bookmark/progress sync.
5. **Reciters / bookmarks / daily ayah / tafsir / search / settings / statistics**
   — wire each feature's domain+data, replace remaining mock usage.
6. **Wire controllers + bindings** — GetX controllers per feature
   (folders exist), replace stateless mock rendering with reactive state.
7. **Remaining animations** — work the Tier-by-Tier backlog in §4
   ("To build next"). Micro-interactions + ambient aura + loading skeletons
   first; shaders (Tier 3) last.
8. **Testing** — unit tests for repos/usecases; widget tests per screen.

### Known placeholders to remove when real data lands
- `lib/core/mock/` (mock_data.dart, mock_models.dart) — entire folder.
- Hardcoded strings in screens (prayer times, streaks, "Ahmad", etc.).

---

## 6. Conventions / gotchas

- **Match surrounding code style** — comment density, naming, idiom.
- Screens are currently `StatelessWidget` rendering `MockData` directly. When
  wiring state, introduce GetX controllers (bindings folders already exist).
- `withValues(alpha:)` is used (not deprecated `withOpacity`).
- Bracket balance: several screens use `Stack`/`Shimmer`/`ShaderMask` wrappers —
  when editing those (auth, daily_reflection, premium), watch closing parens.
- Repeating animations use **tickers**, not Dart `Timer`s, so they don't trip
  test teardown. Only the splash nav `Timer` needed draining in the smoke test.
- Run `flutter analyze` + `flutter test` after edits (analyze ~170s cold).

---

## 7. Verification commands

```bash
flutter analyze          # expect: No issues found!
flutter test             # expect: All tests passed!
flutter run              # launch on device/emulator
```
