# Android release audit — 2026-10-26

Status: NOT approved for Play production upload.

## Evidence

- Application ID: `com.nurehub.qariverse`; version: `1.0.0+2`.
- Installed Flutter defaults and first merged release manifest target Android API 36.
- Initial full automated suite: 42 passing tests, including bookmark save/remove/error handling and reader preferences.
- First release bundle build compiled Dart/native code but failed at `:app:signReleaseBundle`. `android/key.properties` is absent. No valid signed upload artifact produced.
- Added `android/key.properties.example` and explicit signing validation. No key or password generated or exposed.
- Initial release's arm64-v8a/x86_64 native ELF LOAD segments meet >=16 KB alignment: libflutter, libapp, libdartjni, libdatastore_shared_counter. Final bundle packaging and runtime on 16 KB devices still need verification.
- Android API 37 emulator is available; no physical Android device was listed.

## Changes made

- Removed `USE_EXACT_ALARM`; retained user-granted `SCHEDULE_EXACT_ALARM` and existing approximate fallback.
- Removed unused purchases_flutter dependency, which introduced billing permission despite no purchase flow.
- Added the missing named Offline route used by Saved.
- Replaced the generic Buy Me a Coffee homepage link with `mailto:annurdevelopers@gmail.com`.
- Corrected reset copy: local record clearing does not remove downloaded audio files. Remove downloads in Offline first; restart after clearing records.
- With owner authorization, removed 151 portraits with unverified redistribution rights from app assets and mappings. They are archived under `docs/release/excluded_portraits/` outside Flutter's asset bundle. Unmapped reciters use neutral avatars. Kept 30 portraits with recorded licenses; retained updated attribution and source metadata.
- Drafted privacy-policy and store-listing materials. These are not published or submitted.

## Release blockers / owner input

1. Configure the developer-owned upload keystore locally. Protect and back up the key; use Play App Signing. Do not send passwords in chat. Run `flutter build appbundle --release` after configuration.
2. Developer name confirmed: annur-hub. Supply public privacy-policy URL. Support email confirmed: annurdevelopers@gmail.com. Publish the reviewed policy and expose it in Settings before submission.
3. Confirm bundled Adhan, Quran translations, other bundled photography, and streaming/download audio rights. OpenDua recordings have a separate audio license; https://opendua.org/licence/audio was inaccessible during audit, so redistribution permission is NOT verified. The text CC BY license does not cover audio.
4. Review all 30 retained portrait license obligations (including attribution and share-alike where applicable). Source metadata alone is not legal clearance.
5. Complete Data Safety, content rating, target audience, ads/app access and foreground media playback declarations in Play Console. No account sign-in exists in inspected code. Do not claim zero data handling without evaluating IP/request logs and device geocoding providers.
6. Perform the device test matrix below, verify final signed bundle, and review Play pre-launch results.

## Device acceptance matrix (not completed)

- Fresh install: splash/onboarding/skip, returning launch, no startup crash.
- API 33+ notifications denied/granted; location disabled/denied/permanently denied/approximate; cached prayer times.
- Daily Ayah 09:00/18:00 local; Azkar Fajr+10/Maghrib+10; prayer reminders after screen lock, reboot, timezone change, and app termination. Seven-day prayer/Azkar horizon requires reopening; no indefinite background replenishment.
- Playback: start/pause/next, locked-screen media controls, headphones, audio focus/phone interruption, reciter switching, sleep timer.
- Download/cancel/delete/play offline; airplane mode; storage-full errors; interrupted downloads.
- Bookmark/remove/favorite and reading progress survive restart; reflections save/share.
- Light/dark, Arabic RTL, 200% font scale, TalkBack, narrow screen and tablet.
- 16 KB emulator/device plus final APK ZIP alignment; current ELF checks alone do not prove whole-app compatibility.

## Official references checked

- Target API policy: https://support.google.com/googleplay/android-developer/answer/11926878
- Exact alarm restrictions: https://support.google.com/googleplay/android-developer/answer/16558241
- Privacy/Data Safety: https://support.google.com/googleplay/android-developer/answer/18258653
- Native page sizes: https://developer.android.com/guide/practices/page-sizes
- New personal developer accounts: https://support.google.com/googleplay/android-developer/answer/14151465 (where applicable, 12 testers continuously opted in for 14 days before applying for production access).

## Latest owner information

Developer: annur-hub. Support: annurdevelopers@gmail.com. Existing signing key reported misplaced; determine Play App Signing enrollment and upload-key reset eligibility before generating any replacement. No signing identity changed. Post-cleanup full suite: 42 tests passed.

## Emulator and final follow-up

- Rebuilt debug APK installed and Flutter engine launched on API 37 emulator. APK asset inspection found zero of the 151 excluded portraits. Debug merged manifest targets API 36 and contains neither BILLING nor USE_EXACT_ALARM.
- Emulator system was unhealthy: `am_anr` recorded phone, System UI, GMS and other system apps failing startup; this is NOT evidence of a QariVerse ANR. Debug logs showed substantial frame delays, so startup/performance is not signed off.
- App logs exposed simultaneous location/notification permission requests. Added a shared sequential permission queue and a regression test; permission, location, and reminder tests passed (11 targeted tests). The original full suite passed 42 tests after asset/dependency cleanup; the new queue test brings total coverage to 43 tests across these runs.
- Policy draft developer identity updated to annur-hub, support annurdevelopers@gmail.com. Public policy hosting URL remains missing.
- No Play upload performed. No signing key generated or replaced. A final signed release must be rebuilt after key recovery/reset and reviewed before upload.
