import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../../../reciters/domain/entities/reciter.dart';
import '../../../reciters/domain/usecases/get_reciters.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/entities/surah.dart';
import '../../domain/usecases/get_ayat.dart';
import 'surah_controller.dart';

/// Screen-scoped controller for the ayah reader. Receives the target [Surah]
/// via `Get.arguments`, loads its verses from the offline source, and can hand
/// off to the audio player.
class AyahController extends GetxController {
  AyahController(this._getAyat, this._getReciters);

  final GetAyat _getAyat;
  final GetReciters _getReciters;

  final ayat = <Ayah>[].obs;
  final isLoading = true.obs;
  final error = ''.obs;

  /// The surah being read, passed as the route argument.
  final Rxn<Surah> surah = Rxn<Surah>();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Surah) {
      surah.value = arg;
      // The reader is the real "open" action — keep last-read in sync. This
      // controller is lazily created during the reader page's build, and
      // markOpened mutates an observable other widgets watch; defer it past the
      // current frame so we don't call markNeedsBuild() mid-build.
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Get.find<SurahController>().markOpened(arg);
      });
      fetchAyat(arg.id);
    } else {
      isLoading(false);
      error('No surah selected.');
    }
  }

  Future<void> fetchAyat(int surahId) async {
    isLoading(true);
    error('');
    final result = await _getAyat(surahId);
    result.fold(
      (f) => error(f.message),
      (data) => ayat.assignAll(data),
    );
    isLoading(false);
  }

  /// Resolves a reciter (preferred if set, else the first available) and starts
  /// playback of the current surah, then opens the full player.
  Future<void> playSurah() async {
    final current = surah.value;
    if (current == null) return;

    final audio = Get.find<AudioController>();
    final result = await _getReciters();
    result.fold(
      (f) => error(f.message),
      (reciters) {
        if (reciters.isEmpty) {
          error('No reciters available.');
          return;
        }
        final preferredId = audio.preferredReciterId;
        final reciter = reciters.firstWhere(
          (r) => r.id == preferredId,
          orElse: () => reciters.first,
        );
        _launch(audio, reciter, current);
      },
    );
  }

  void _launch(AudioController audio, Reciter reciter, Surah current) {
    audio.playReciter(
      reciter,
      startSurahNumber: current.id,
      surahNames: {current.id: current.name},
    );
    Get.toNamed(AppRoutes.audioPlayer);
  }
}
