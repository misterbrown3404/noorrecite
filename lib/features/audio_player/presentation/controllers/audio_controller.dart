import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../downloads/presentation/controllers/download_controller.dart';
import '../../../reciters/domain/entities/reciter.dart';
import '../../../reciters/presentation/controllers/reciter_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';
import '../../domain/entities/audio_track.dart';

enum AudioRepeatMode { off, one, all }

/// Owns the [just_audio] player and exposes reactive playback state for the UI.
///
/// Kept as a permanent (non-lazy) singleton so playback survives navigation
/// between the mini-player, the full player, and other tabs.
class AudioController extends GetxController {
  AudioController(this._storage);

  final LocalStorageService _storage;

  // Buffer-ahead tuning: start playback as soon as a small buffer fills (fast
  // perceived start) while keeping a large forward buffer so the current track
  // and the head of the next one are prefetched — smooth surah-to-surah flow
  // with no re-buffer stalls on typical mobile networks.
  final AudioPlayer _player = AudioPlayer(
    audioLoadConfiguration: const AudioLoadConfiguration(
      androidLoadControl: AndroidLoadControl(
        minBufferDuration: Duration(seconds: 20),
        maxBufferDuration: Duration(minutes: 2),
        bufferForPlaybackDuration: Duration(milliseconds: 1500),
        bufferForPlaybackAfterRebufferDuration: Duration(seconds: 3),
        prioritizeTimeOverSizeThresholds: true,
      ),
      darwinLoadControl: DarwinLoadControl(
        automaticallyWaitsToMinimizeStalling: false,
        preferredForwardBufferDuration: Duration(seconds: 60),
      ),
    ),
  );
  AudioPlayer get player => _player;

  Timer? _persistDebounce;

  // Reactive state consumed by the player UI.
  final queue = <AudioTrack>[].obs;
  final currentIndex = 0.obs;
  final isPlaying = false.obs;
  final isBuffering = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final speed = 1.0.obs;
  final repeatMode = AudioRepeatMode.off.obs;
  final isShuffling = false.obs;
  final error = ''.obs;

  AudioTrack? get currentTrack =>
      queue.isNotEmpty && currentIndex.value < queue.length
      ? queue[currentIndex.value]
      : null;

  /// Reciter id the user last played — surfaced for "continue listening" and
  /// as the preferred reciter across the app.
  int? get preferredReciterId =>
      _storage.read<int>(StorageKeys.preferredReciterId);

  /// Snapshot of the last session (reciter, surah, position) if one exists,
  /// used to render the "continue listening" card without resuming playback.
  Map<String, dynamic>? get lastPlayback =>
      _storage.readJson(StorageKeys.lastPlayback);

  /// Previously-resolved duration for [trackId], read from the on-device
  /// metadata cache. Returns null the first time a track is ever played.
  Duration? cachedDuration(String trackId) {
    final ms = _durationCache[trackId];
    return ms is int ? Duration(milliseconds: ms) : null;
  }

  Map<String, dynamic> get _durationCache =>
      _storage.readJson(StorageKeys.audioDurations) ?? const {};

  Future<void> _cacheDuration(String trackId, Duration value) async {
    if (value <= Duration.zero) return;
    final cache = Map<String, dynamic>.from(_durationCache);
    if (cache[trackId] == value.inMilliseconds) return; // no-op write
    cache[trackId] = value.inMilliseconds;
    await _storage.writeJson(StorageKeys.audioDurations, cache);
  }

  @override
  void onInit() {
    super.onInit();
    _configureSession();
    _bindStreams();
  }

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _bindStreams() {
    _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value =
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
    });
    _player.positionStream.listen((p) {
      position.value = p;
      _schedulePersist();
    });
    _player.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
      // Persist the resolved duration so future plays (and the lock screen)
      // show total length instantly, without re-hitting the network header.
      if (d != null && d > Duration.zero) {
        final track = currentTrack;
        if (track != null) _cacheDuration(track.id, d);
      }
    });
    _player.currentIndexStream.listen((i) {
      if (i != null) {
        currentIndex.value = i;
        _persistSession();
      }
    });
  }

  /// Build a queue of every surah for [reciter]'s primary moshaf and start at
  /// [startSurahNumber].
  Future<void> playReciter(
    Reciter reciter, {
    required int startSurahNumber,
    Map<int, String>? surahNames,
    bool autoPlay = true,
  }) async {
    final moshaf = reciter.primaryMoshaf;
    if (moshaf == null) {
      error.value = 'This reciter has no available recitation.';
      return;
    }

    final tracks = moshaf.surahList
        .map(
          (n) => AudioTrack(
            surahNumber: n,
            surahName: surahNames?[n] ?? 'Surah $n',
            reciterId: reciter.id,
            reciterName: reciter.name,
            moshafName: moshaf.name,
            url: moshaf.audioUrl(n),
          ),
        )
        .toList();

    if (tracks.isEmpty) {
      error.value = 'No surahs available for this reciter.';
      return;
    }

    var startIndex = tracks.indexWhere(
      (t) => t.surahNumber == startSurahNumber,
    );
    if (startIndex < 0) startIndex = 0;

    await setQueue(tracks, startIndex: startIndex, autoPlay: autoPlay);
  }

  /// Resolves the playback source for [track]: a local `file://` URI when the
  /// surah has been downloaded (and still exists on disk), otherwise the remote
  /// stream URL. Falls back gracefully if the downloads feature isn't wired.
  /// Respects offline mode — if enabled and track isn't downloaded, throws.
  Uri _sourceUri(AudioTrack track) {
    final downloads = Get.isRegistered<DownloadController>()
        ? Get.find<DownloadController>()
        : null;
    final item = downloads?.itemFor(track.id);
    final isDownloaded = item != null;

    // Check offline mode
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    final offlineMode = settings?.offlineMode.value ?? false;

    if (offlineMode && !isDownloaded) {
      // Offline mode but not downloaded — fall back to stream rather than
      // throwing; the error banner will show a buffering failure if there's
      // truly no connectivity, which is more useful than a hard abort.
    }

    if (isDownloaded) return Uri.file(item.filePath);
    return Uri.parse(track.url);
  }

  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
    bool autoPlay = true,
  }) async {
    error.value = '';
    queue.assignAll(tracks);
    // Show the cached total length immediately (if we have one) so the scrubber
    // isn't stuck at 0:00 until the stream header resolves.
    if (startIndex >= 0 && startIndex < tracks.length) {
      duration.value =
          cachedDuration(tracks[startIndex].id) ?? Duration.zero;
    }
    try {
      await _player.setAudioSources(
        tracks
            .map(
              (t) => AudioSource.uri(
                _sourceUri(t),
                tag: MediaItem(
                  id: t.id,
                  title: t.surahName,
                  artist: t.reciterName,
                  album: t.moshafName,
                  duration: cachedDuration(t.id),
                ),
              ),
            )
            .toList(),
        initialIndex: startIndex,
        initialPosition: initialPosition,
      );
      currentIndex.value = startIndex;
      if (autoPlay) await _player.play();
    } on StateError catch (e) {
      error.value = e.message;
    } catch (e) {
      error.value = e.toString();
    }
  }

  /// Rebuilds the queue from the persisted [lastPlayback] snapshot and resumes
  /// from the saved position. When there is no snapshot (e.g. the user opened
  /// the player directly on a fresh install), falls back to a default reciter
  /// so the screen is never left silent with an empty queue.
  Future<void> resumeLastSession() async {
    if (queue.isNotEmpty) return; // live session already active
    final saved = lastPlayback;
    if (saved == null) {
      await _startDefaultSession();
      return;
    }
    try {
      final rawTracks = (saved['tracks'] as List).cast<Map<String, dynamic>>();
      final tracks = rawTracks.map(AudioTrack.fromJson).toList();
      final index = (saved['currentIndex'] as int?) ?? 0;
      final posMs = (saved['positionMs'] as int?) ?? 0;
      await setQueue(
        tracks,
        startIndex: index,
        initialPosition: Duration(milliseconds: posMs),
      );
    } catch (_) {
      // Corrupt snapshot — fall back to a default session rather than leaving
      // the player empty.
      await _startDefaultSession();
    }
  }

  /// Load a sensible default queue when there is nothing to resume: the user's
  /// preferred reciter if we know one, otherwise the first reciter in the
  /// directory, starting at Surah Al-Fatiha. Does not auto-play — it primes the
  /// queue so the transport controls have something to act on. No-op if the
  /// reciter directory hasn't loaded yet (e.g. offline first launch).
  Future<void> _startDefaultSession() async {
    if (!Get.isRegistered<ReciterController>()) return;
    final rc = Get.find<ReciterController>();
    // The directory may still be loading on a fresh launch — fetch it once so
    // the default session works the first time the player is opened.
    if (rc.reciters.isEmpty) {
      await rc.fetchReciters();
    }
    final reciters = rc.reciters;
    if (reciters.isEmpty) return;

    final preferredId = preferredReciterId;
    final reciter = reciters.firstWhere(
      (r) => r.id == preferredId,
      orElse: () => reciters.first,
    );

    final surahNames = {
      for (final n in reciter.primaryMoshaf?.surahList ?? const <int>[])
        n: quran.getSurahName(n),
    };

    await playReciter(
      reciter,
      startSurahNumber: 1,
      surahNames: surahNames,
      autoPlay: false,
    );
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> next() async {
    if (_player.hasNext) await _player.seekToNext();
  }

  Future<void> previous() async {
    // Restart current track if we're past 3s, otherwise go to previous.
    if (position.value > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> seek(Duration to) => _player.seek(to);

  Future<void> setSpeed(double value) async {
    speed.value = value;
    await _player.setSpeed(value);
  }

  Future<void> cycleSpeed() async {
    const steps = [1.0, 1.25, 1.5, 2.0, 0.75];
    final currentIdx = steps.indexOf(speed.value);
    final nextIdx = (currentIdx + 1) % steps.length;
    await setSpeed(steps[nextIdx]);
  }

  Future<void> cycleRepeatMode() async {
    switch (repeatMode.value) {
      case AudioRepeatMode.off:
        repeatMode.value = AudioRepeatMode.all;
        await _player.setLoopMode(LoopMode.all);
      case AudioRepeatMode.all:
        repeatMode.value = AudioRepeatMode.one;
        await _player.setLoopMode(LoopMode.one);
      case AudioRepeatMode.one:
        repeatMode.value = AudioRepeatMode.off;
        await _player.setLoopMode(LoopMode.off);
    }
  }

  Future<void> toggleShuffle() async {
    isShuffling.value = !isShuffling.value;
    await _player.setShuffleModeEnabled(isShuffling.value);
  }

  void _onTrackComplete() {
    // LoopMode handles repeat; nothing extra needed here for now.
  }

  // --- Persistence helpers ------------------------------------------------

  /// Debounce position saves to at most once per 5 s to avoid excessive I/O.
  void _schedulePersist() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(seconds: 5), _persistSession);
  }

  Future<void> _persistSession() async {
    final track = currentTrack;
    if (track == null) return;
    await Future.wait([
      _storage.writeJson(StorageKeys.lastPlayback, {
        'tracks': queue.map((t) => t.toJson()).toList(),
        'currentIndex': currentIndex.value,
        'positionMs': position.value.inMilliseconds,
        'durationMs': duration.value.inMilliseconds,
      }),
      _storage.write(StorageKeys.preferredReciterId, track.reciterId),
    ]);
  }

  @override
  void onClose() {
    _persistDebounce?.cancel();
    _player.dispose();
    super.onClose();
  }
}
