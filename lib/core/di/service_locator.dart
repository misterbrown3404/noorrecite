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
//import '../../features/statistics/data/datasources/statistics_local_datasource.dart';
//import '../../features/statistics/data/repositories/statistics_repository_impl.dart';
//import '../../features/statistics/domain/repositories/statistics_repository.dart';
//import '../../features/statistics/domain/usecases/statistics_usecases.dart';
//import '../../features/statistics/presentation/controllers/statistics_controller.dart';
import '../network/dio_client.dart';
import '../storage/local_storage_service.dart';

final sl = GetIt.instance;

void setupDependencies(LocalStorageService storage) {
  // Local storage — core primitive shared across features (privacy-friendly,
  // on-device only). Registered first so datasources/controllers can depend on it.
  sl.registerSingleton<LocalStorageService>(storage);

  // Data sources
  sl.registerLazySingleton<ReciterRemoteDataSource>(
    () => ReciterRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<SurahRemoteDataSource>(
    () => SurahRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<AyahLocalDataSource>(
    () => AyahLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<DailyAyahRemoteDataSource>(
    () => DailyAyahRemoteDataSourceImpl(),
  );

  // Repositories
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

  // Use cases
  sl.registerLazySingleton(() => GetReciters(sl()));
  sl.registerLazySingleton(() => GetSuwar(sl()));
  sl.registerLazySingleton(() => GetAyat(sl()));
  sl.registerLazySingleton(() => GetDailyAyah(sl()));

  // Statistics — local datasource, repo, use cases, controller
  // sl.registerLazySingleton<StatisticsLocalDataSource>(
  //     () => StatisticsLocalDataSourceImpl(sl()));
  // sl.registerLazySingleton<StatisticsRepository>(
  //     () => StatisticsRepositoryImpl(sl()));
  // sl.registerLazySingleton(() => GetStatistics(sl()));
  // sl.registerLazySingleton(() => RecordSession(sl()));
  // sl.registerLazySingleton(() => UpdateStreak(sl()));
  // sl.registerLazySingleton(() => AddListeningTime(sl()));
  // sl.registerLazySingleton(() => UpdateSurahProgress(sl()));
  // sl.registerLazySingleton(() => UnlockAchievement(sl()));
  // sl.registerLazySingleton(() => UpdateAchievementProgress(sl()));
  // Get.put(StatisticsController(
  //   sl<GetStatistics>(),
  //   sl<RecordSession>(),
  //   sl<UpdateStreak>(),
  //   sl<AddListeningTime>(),
  //   sl<UpdateSurahProgress>(),
  //   sl<UnlockAchievement>(),
  //   sl<UpdateAchievementProgress>(),
  // ), permanent: true);

  // Downloads — permanent singleton (GetIt + GetX). Registered before the
  // audio controller so playback can prefer a downloaded local file over the
  // remote stream. The file service is a stateless I/O helper.
  sl.registerLazySingleton(() => DownloadFileService(DioClient.instance));
  final downloads = DownloadController(storage, sl<DownloadFileService>());
  sl.registerSingleton(downloads);
  Get.put(downloads, permanent: true);

  // Audio — permanent singleton registered in both GetIt and GetX so it
  // survives navigation and is accessible via Get.find<AudioController>().
  final audio = AudioController(storage);
  sl.registerSingleton(audio);
  Get.put(audio, permanent: true);

  // Bookmarks — permanent singleton (GetIt + GetX) since ayahs are saved from
  // multiple screens, not just the Saved tab.
  final bookmarks = BookmarksController(storage);
  sl.registerSingleton(bookmarks);
  Get.put(bookmarks, permanent: true);

  // Settings — permanent singleton (GetIt + GetX); preferences are read
  // app-wide.
  final settings = SettingsController(storage);
  sl.registerSingleton(settings);
  Get.put(settings, permanent: true);

  // Reciters — permanent singleton (GetX) since the directory is shown on both
  // the Home tab ("Popular Reciters") and the dedicated Reciters page. Kept in
  // GetX so both find the same instance regardless of the active route binding.
  Get.put(ReciterController(sl<GetReciters>()), permanent: true);

  // Prayer Times — permanent singleton for Home tab
  Get.put(PrayerTimesController(storage), permanent: true);

  // Daily Ayah — permanent singleton for Home daily ayah card.
  Get.put(DailyAyahController(sl<GetDailyAyah>()), permanent: true);

  // Reflections — permanent singleton (GetX); the saved-notes collection is
  // read and written from the daily-reflection, add-reflection, and list pages.
  Get.put(ReflectionsController(storage), permanent: true);
}
