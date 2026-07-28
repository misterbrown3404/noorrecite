import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'app/app.dart';
import 'core/constants/app_assets.dart';
import 'core/di/service_locator.dart';
import 'core/services/notification_service.dart';
import 'core/storage/local_storage_service.dart';
import 'features/quran_reader/domain/usecases/get_suwar.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final results = await Future.wait([
    JustAudioBackground.init(
      androidNotificationChannelId: 'net.mp3quran.noorrecite.audio',
      androidNotificationChannelName: 'QariVerse Playback',
      androidNotificationOngoing: true,
    ),
    LocalStorageService.init(),
    NotificationService.instance.init(),
  ]);

  final storage = results[1] as LocalStorageService;

  setupDependencies(storage);
  GoogleFonts.config.allowRuntimeFetching = false;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = WidgetsBinding.instance.rootElement;
    if (context != null) {
      precacheImage(const AssetImage(AppAssets.mosqueLandscape), context);
      precacheImage(const AssetImage(AppAssets.splashQuran), context);
    }
    sl<GetSuwar>()();
  });

  runApp(const QariVerseApp());
}
