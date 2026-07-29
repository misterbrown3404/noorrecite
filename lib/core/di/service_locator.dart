import 'package:get/get.dart';
import 'package:get_it/get_it.dart';

import '../../features/audio_player/presentation/controllers/audio_controller.dart';
import '../../features/bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../../features/daily_ayah/data/datasources/daily_ayah_remote_datasource.dart';
import '../../features/daily_ayah/data/repositories/daily_ayah_repository_impl.dart';
import '../../features/daily_ayah/domain/repositories/daily_ayah_repository.dart';
import '../../features/daily_ayah/domain/usecases/get_daily_ayah.dart';
import '../../features/daily_ayah/presentation/controllers/daily_ayah_controller.dart';
import '../../features/daily_ayah/presentation/controllers/reflections_controller.dart';
import '../../features/downloads/data/services/download_file_service.dart';
import '../../features/downloads/presentation/controllers/download_controller.dart';
import '../../features/settings/presentation/controllers/settings_controller.dart';
import '../../features/quran_reader/data/datasources/ayah_local_datasource.dart';
import '../../features/quran_reader/data/datasources/surah_remote_datasource.dart';
import '../../features/quran_reader/data/repositories/ayah_repository_impl.dart';
import '../../features/quran_reader/data/repositories/surah_repository_impl.dart';
import '../../features/quran_reader/domain/repositories/ayah_repository.dart';
import '../../features/quran_reader/domain/repositories/surah_repository.dart';
import '../../features/quran_reader/domain/usecases/get_ayat.dart';
import '../../features/quran_reader/domain/usecases/get_suwar.dart';
import '../../features/reciters/data/datasources/reciter_remote_datasource.dart';
import '../../features/reciters/data/repositories/reciter_repository_impl.dart';
import '../../features/reciters/domain/repositories/reciter_repository.dart';
import '../../features/reciters/domain/usecases/get_reciters.dart';
import '../../features/reciters/presentation/controllers/reciter_controller.dart';
import '../../features/home/presentation/controllers/prayer_times_controller.dart';
import '../network/connectivity_controller.dart';
import '../network/dio_client.dart';
import '../storage/local_storage_service.dart';

/// Service locator for the **infrastructure and domain layers only**:
/// storage, data sources, repositories, use cases, and stateless services.
///
/// Presentation-layer controllers live exclusively in GetX (`Get.put` /
/// `Get.find`) — see [_registerControllers]. Keeping each type in exactly one
/// container removes the old dual-registration hazard where `sl<T>()` and
/// `Get.find<T>()` could resolve to different instances.
final sl = GetIt.instance;

void setupDependencies(LocalStorageService storage) {
  // --- Core primitives ---------------------------------------------------
  sl.registerSingleton<LocalStorageService>(storage);

  // --- Data sources (Dio injected, not reached for globally) -------------
  sl.registerLazySingleton<ReciterRemoteDataSource>(
    () => ReciterRemoteDataSourceImpl(DioClient.instance),
  );
  sl.registerLazySingleton<SurahRemoteDataSource>(
    () => SurahRemoteDataSourceImpl(DioClient.instance),
  );
  sl.registerLazySingleton<AyahLocalDataSource>(
    () => AyahLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<DailyAyahRemoteDataSource>(
    () => DailyAyahRemoteDataSourceImpl(),
  );

  // --- Repositories ------------------------------------------------------
  sl.registerLazySingleton<ReciterRepository>(
    () => ReciterRepositoryImpl(sl(), storage),
  );
  sl.registerLazySingleton<SurahRepository>(
    () => SurahRepositoryImpl(sl(), storage),
  );
  sl.registerLazySingleton<AyahRepository>(() => AyahRepositoryImpl(sl()));
  sl.registerLazySingleton<DailyAyahRepository>(
    () => DailyAyahRepositoryImpl(sl()),
  );

  // --- Use cases ---------------------------------------------------------
  sl.registerLazySingleton(() => GetReciters(sl()));
  sl.registerLazySingleton(() => GetSuwar(sl()));
  sl.registerLazySingleton(() => GetAyat(sl()));
  sl.registerLazySingleton(() => GetDailyAyah(sl()));

  // --- Stateless services ------------------------------------------------
  sl.registerLazySingleton(() => DownloadFileService(DioClient.instance));

  _registerControllers(storage);
}

/// Permanent GetX controllers. These are the app-wide singletons that must
/// survive navigation; screen-scoped controllers are created by their route
/// bindings instead.
void _registerControllers(LocalStorageService storage) {
  // Connectivity first: it powers the app-wide offline banner and drives an
  // opportunistic re-fetch of network screens the moment signal returns.
  Get.put(ConnectivityController(), permanent: true);

  // Downloads first: the audio controller prefers a downloaded local file over
  // the remote stream, so this must exist before playback starts.
  Get.put(DownloadController(storage, sl<DownloadFileService>()),
      permanent: true);

  // Audio — permanent so playback survives navigation between the player and tabs.
  Get.put(AudioController(storage), permanent: true);

  // Bookmarks — ayahs are saved from multiple screens, not just the Saved tab.
  Get.put(BookmarksController(storage), permanent: true);

  // Settings — preferences are read app-wide.
  Get.put(SettingsController(storage), permanent: true);

  // Reciters — shown on both Home ("Popular Reciters") and the Reciters page.
  Get.put(ReciterController(sl<GetReciters>()), permanent: true);

  // Prayer Times — Home tab.
  Get.put(PrayerTimesController(storage), permanent: true);

  // Daily Ayah — Home daily ayah card.
  Get.put(DailyAyahController(sl<GetDailyAyah>()), permanent: true);

  // Reflections — read/written from daily-reflection, add-reflection, and list.
  Get.put(ReflectionsController(storage), permanent: true);
}
