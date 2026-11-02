# QariVerse Home Screen Widgets — Setup Guide

Three widgets are implemented: **Daily Ayah** (4×2), **Prayer Times** (4×2), and **Reading Streak** (2×2).

---

## 1. Install the Dart package

After the `home_widget: ^0.7.0` dependency was added to `pubspec.yaml`, run:

```bash
flutter pub get
```

---

## 2. Android

No extra Gradle steps are required. The Kotlin receiver files and manifest entries are already in place:

| File | Purpose |
|---|---|
| `android/.../DailyAyahWidget.kt` | Reads SharedPreferences, renders Daily Ayah widget |
| `android/.../PrayerTimesWidget.kt` | Renders Prayer Times widget |
| `android/.../ReadingStreakWidget.kt` | Renders Reading Streak widget |
| `android/.../res/xml/widget_*_info.xml` | Widget metadata (size, update period) |
| `android/.../res/layout/widget_*.xml` | RemoteViews layouts |
| `android/.../res/drawable/widget_background.xml` | Violet→teal gradient background |
| `android/.../res/drawable/widget_gold_background.xml` | Gold gradient (streak widget) |

Build and install as normal (`flutter run` or `flutter build apk`).

---

## 3. iOS — Manual Xcode Steps

> **Important:** Xcode Widget Extension targets cannot be added by file creation alone.  
> The steps below must be done once in Xcode.

### a. Add the Widget Extension target

1. Open `ios/Runner.xcworkspace` in Xcode.
2. **File → New → Target → Widget Extension**.
3. Set:
   - **Product Name**: `QariVerseWidgets`
   - **Bundle Identifier**: `com.noorrecite.app.widgets`
   - **Language**: Swift
   - Uncheck **Include Configuration Intent**
4. Click **Finish**. When prompted "Activate scheme?", click **Activate**.

### b. Replace the auto-generated Swift file

1. In the Project Navigator, delete the auto-generated `QariVerseWidgets.swift` (move to Trash).
2. Drag `ios/QariVerseWidgets/QariVerseWidgets.swift` into the `QariVerseWidgets` group.
3. Confirm **"Add to target: QariVerseWidgets"** is checked.

### c. Add App Group capability — Runner target

1. Select the **Runner** target → **Signing & Capabilities** tab.
2. Click **+ Capability** → **App Groups**.
3. Add group: `group.com.noorrecite.app`.

### d. Add App Group capability — QariVerseWidgets target

1. Select the **QariVerseWidgets** target → **Signing & Capabilities** tab.
2. Click **+ Capability** → **App Groups**.
3. Add the same group: `group.com.noorrecite.app`.

### e. Set Swift Language Version

1. Select the **QariVerseWidgets** target → **Build Settings**.
2. Search for **Swift Language Version** and set it to **Swift 5**.

### f. Embed the extension in Runner

1. Select the **Runner** target → **General** tab.
2. Scroll to **Frameworks, Libraries, and Embedded Content** (or **Embed App Extensions**).
3. Click **+** and select **QariVerseWidgets.appex**.
4. Ensure it is set to **Embed & Sign**.

---

## 4. Testing the Widgets

**Android**
1. Install the app on a device or emulator (API 26+).
2. Long-press the home screen → tap **"Widgets"** (or **"+"**).
3. Search for **QariVerse** and place any widget.

**iOS**
1. Build and run on a real device (iOS 16+).
2. Long-press the home screen → tap **"+"** in the top-left.
3. Search for **QariVerse** and add a widget.

---

## 5. Data Refresh Notes

- **Android**: `updatePeriodMillis` enforces a minimum of 30 minutes between system-triggered updates. Data is also pushed immediately whenever the user opens the app (via `WidgetService.pushXxx()`).
- **iOS**: WidgetKit enforces its own refresh budget (~15 min minimum). The widget always shows the latest data written by the app on the next system-scheduled refresh.
- Widget data is stored in **SharedPreferences / App Group UserDefaults**, completely separate from the app's AES-encrypted Hive storage.


## Launcher access

Long-press the Qari Verse app icon and choose **Add widget**. The native chooser
lists Daily Ayah, Prayer Times and Reading Streak, then requests the launcher's
standard pin confirmation. On launchers without widget pinning support, it
explains how to use Home screen → Widgets. Android 7.0 users use that manual
path because app shortcuts require Android 7.1 or later.

The generic Widgets entry in an app icon menu is controlled by the launcher;
provider registration does not force that entry to appear. All three providers
were confirmed registered on the connected Redmi 8A (Android 10). Widget XML
also supplies previewLayout for Android 12+ picker previews.
