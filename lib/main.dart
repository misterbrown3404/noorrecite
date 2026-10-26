import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app.dart';
import 'core/constants/app_assets.dart';
import 'core/di/service_locator.dart';
import 'core/error/crash_reporter.dart';
import 'core/services/notification_service.dart';
import 'core/storage/local_storage_service.dart';
import 'features/quran_reader/domain/usecases/get_suwar.dart';

Future<void> main() async {
  // Single error boundary for the whole app: uncaught async errors and Flutter
  // framework errors are routed to the (vendor-neutral) crash sink instead of
  // vanishing. Swap CrashReporter.instance for Crashlytics/Sentry to light this
  // up in production — no other code changes needed.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      LicenseRegistry.addLicense(() async* {
        final credits = await rootBundle.loadString(
          'assets/images/reciter_credits.txt',
        );
        yield LicenseEntryWithLineBreaks(['Reciter portraits'], credits);
      });

      FlutterError.onError = CrashReporter.instance.recordFlutterError;

      // Each init is isolated so a single failure (e.g. a corrupt Hive box or a
      // platform-channel hiccup) degrades that subsystem instead of bricking
      // launch with a white screen.
      final storage = await _initStorage();
      await _initAudioBackground();
      await _initNotifications();

      setupDependencies(storage);
      GoogleFonts.config.allowRuntimeFetching = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = WidgetsBinding.instance.rootElement;
        if (context != null) {
          precacheImage(const AssetImage(AppAssets.mosqueLandscape), context);
          precacheImage(const AssetImage(AppAssets.splashQuran), context);
        }
        // Warm the surah cache; failure here is non-fatal (handled downstream).
        unawaited(
          sl<GetSuwar>()().then(
            (_) {},
            onError: (Object e, StackTrace s) {
              CrashReporter.instance.recordError(e, s, reason: 'prewarm suwar');
            },
          ),
        );
      });

      runApp(const QariVerseApp());
    },
    (error, stack) => CrashReporter.instance.recordError(
      error,
      stack,
      reason: 'uncaught zone error',
    ),
  );
}

/// Storage is required for the app to function; [LocalStorageService.init]
/// already self-heals a corrupt box, so a throw here is genuinely fatal.
Future<LocalStorageService> _initStorage() => LocalStorageService.init();

Future<void> _initAudioBackground() async {
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'net.mp3quran.noorrecite.audio',
      androidNotificationChannelName: 'QariVerse Playback',
      androidNotificationOngoing: true,
    );
  } catch (e, s) {
    CrashReporter.instance.recordError(e, s, reason: 'audio background init');
  }
}

Future<void> _initNotifications() async {
  try {
    await NotificationService.instance.init();
  } catch (e, s) {
    CrashReporter.instance.recordError(e, s, reason: 'notification init');
  }
}
