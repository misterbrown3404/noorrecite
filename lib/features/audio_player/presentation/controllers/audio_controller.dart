import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/constants/app_assets.dart';
import '../../../../core/error/crash_reporter.dart';
import '../../../../core/services/media_artwork_service.dart';
import '../../../../core/services/adhan_audio_service.dart';
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
/// between the player and other tabs.
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

  bool _azkarPreview = false;
  String? _previewOwner;
  bool get isAzkarPreview => _previewOwner == 'azkar';
  bool get isAdhanPreview => _previewOwner == 'adhan';
  List<AudioSource>? _savedSources;
  int? _savedIndex;
  Duration _savedPosition = Duration.zero;
  double _savedSpeed = 1;
  LoopMode _savedLoop = LoopMode.off;
  bool _savedShuffle = false;
  Future<void> _previewWork = Future.value();

  Future<void> _serializePreview(Future<void> Function() operation) {
    final result = _previewWork.then((_) => operation());
    _previewWork = result.catchError((Object _, StackTrace _) {});
    return result;
  }

  /// Temporarily borrow the single background player without changing Quran state.
  Future<void> playAzkarPreview(String asset, String title) => playAudioPreview(
    asset,
    title,
    owner: 'azkar',
    artist: 'Muhammad Jumah',
    album: 'OpenDua · Hisn al-Muslim',
  );

  Future<void> playAudioPreview(
    String asset,
    String title, {
    required String owner,
    required String artist,
    required String album,
  }) => _serializePreview(() async {
    if (!_azkarPreview) {
      await _persistSession();
      _savedSources = List<AudioSource>.of(_player.audioSources);
      _savedIndex = _player.currentIndex;
      _savedPosition = _player.position;
      _savedSpeed = _player.speed;
      _savedLoop = _player.loopMode;
      _savedShuffle = _player.shuffleModeEnabled;
      _azkarPreview = true;
      _persistDebounce?.cancel();
    }
    _previewOwner = owner;
    await _player.pause();
    isPlaying.value = false;
    await _player.setLoopMode(LoopMode.off);
    await _player.setShuffleModeEnabled(false);
    await _player.setSpeed(1);
    await _player.setAudioSource(
      AudioSource.asset(
        asset,
        tag: MediaItem(id: asset, title: title, artist: artist, album: album),
      ),
    );
    unawaited(
      _player.play().catchError((Object e, StackTrace s) {
        CrashReporter.instance.recordError(e, s, reason: 'Azkar playback');
      }),
    );
  });

  Future<void> endAzkarPreview() => endAudioPreview(owner: 'azkar');

  Future<void> endAudioPreview({String? owner}) => _serializePreview(() async {
    if (!_azkarPreview || (owner != null && owner != _previewOwner)) return;
    await _player.pause();
    try {
      final sources = _savedSources ?? [];
      if (sources.isNotEmpty) {
        await _player.setAudioSources(
          sources,
          initialIndex: _savedIndex ?? 0,
          initialPosition: _savedPosition,
          preload: false,
        );
      } else {
        await _player.clearAudioSources();
      }
      await _player.setSpeed(_savedSpeed);
      await _player.setLoopMode(_savedLoop);
      await _player.setShuffleModeEnabled(_savedShuffle);
    } finally {
      _azkarPreview = false;
      _previewOwner = null;
      _savedSources = null;
      position.value = _savedPosition;
      isPlaying.value = false;
      isBuffering.value = false;
    }
  });

  Timer? _persistDebounce;
  Timer? _sleepTimer;
  final sleepMinutes = 0.obs;

  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    sleepMinutes.value = minutes;
    if (minutes <= 0) return;
    _sleepTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      sleepMinutes.value--;
      if (sleepMinutes.value <= 0) {
        timer.cancel();
        _player.pause();
      }
    });
  }

  /// In-memory mirror of the persisted duration cache, so [cachedDuration] and
  /// [_cacheDuration] don't deserialize the whole Hive string on every access
  /// (setQueue touches this once per track — 114× for a full reciter queue).
  Map<String, dynamic>? _durationCacheMemo;

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

  Map<String, dynamic> get _durationCache => _durationCacheMemo ??=
      _storage.readJson(StorageKeys.audioDurations) ?? <String, dynamic>{};

  Future<void> _cacheDuration(String trackId, Duration value) async {
    if (value <= Duration.zero) return;
    final cache = _durationCache;
    if (cache[trackId] == value.inMilliseconds) return; // no-op write
    cache[trackId] = value.inMilliseconds;
    _durationCacheMemo = cache;
    await _storage.writeJson(StorageKeys.audioDurations, cache);
  }

  @override
  void onInit() {
    super.onInit();
    _configureSession();
    _bindStreams();
  }

  @override
  void onReady() {
    super.onReady();
    AdhanAudioService.instance.playPending();
  }

  Future<void> _configureSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  void _bindStreams() {
    _player.playerStateStream.listen((state) {
      if (_azkarPreview) return;
      isPlaying.value = state.playing;
      isBuffering.value =
          state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
    });
    _player.positionStream.listen((p) {
      if (_azkarPreview) return;
      position.value = p;
      _schedulePersist();
    });
    _player.durationStream.listen((d) {
      if (_azkarPreview) return;
      duration.value = d ?? Duration.zero;
      // Persist the resolved duration so future plays (and the lock screen)
      // show total length instantly, without re-hitting the network header.
      if (d != null && d > Duration.zero) {
        final track = currentTrack;
        if (track != null) _cacheDuration(track.id, d);
      }
    });
    _player.currentIndexStream.listen((i) {
      if (_azkarPreview) return;
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

    // Fast path: the requested surah is already loaded in the live queue for
    // this same reciter/moshaf. Seek to it instead of rebuilding the playlist,
    // which would otherwise stall or mute the switch mid-play.
    if (autoPlay && !_offlineMode) {
      final existing = queue.indexWhere((t) => t.id == tracks[startIndex].id);
      if (existing >= 0) {
        await playAt(existing);
        return;
      }
    }

    await setQueue(tracks, startIndex: startIndex, autoPlay: autoPlay);
  }

  /// True when the user has enabled offline mode in settings.
  bool get _offlineMode {
    final settings = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : null;
    return settings?.offlineMode.value ?? false;
  }

  /// Resolves the playback source for [track]: a local `file://` URI when the
  /// surah has been downloaded (and still exists on disk), otherwise the remote
  /// stream URL. Falls back gracefully if the downloads feature isn't wired.
  Uri _sourceUri(AudioTrack track) {
    final downloads = Get.isRegistered<DownloadController>()
        ? Get.find<DownloadController>()
        : null;
    final item = downloads?.itemFor(track.id);
    if (item != null) return Uri.file(item.filePath);
    return Uri.parse(track.url);
  }

  /// In offline mode, a queue may only contain tracks that exist on disk.
  /// Returns the tracks that are actually playable offline.
  List<AudioTrack> _downloadedOnly(List<AudioTrack> tracks) {
    final downloads = Get.isRegistered<DownloadController>()
        ? Get.find<DownloadController>()
        : null;
    if (downloads == null) return const [];
    return tracks.where((t) => downloads.isDownloaded(t.id)).toList();
  }

  Future<void> setQueue(
    List<AudioTrack> tracks, {
    int startIndex = 0,
    Duration? initialPosition,
    bool autoPlay = true,
  }) async {
    await endAudioPreview();
    error.value = '';

    // Defensive copy. Callers sometimes pass `queue` itself (e.g. re-selecting
    // a track from the queue sheet). `RxList.assignAll` clears then re-adds, so
    // assigning a list its own backing store would empty it out before the
    // re-add reads it — the "queue suddenly empty" bug. Copying first makes the
    // source independent of the observable.
    var effectiveTracks = List<AudioTrack>.of(tracks);
    var effectiveStart = startIndex;
    if (_offlineMode) {
      final requestedId = (startIndex >= 0 && startIndex < tracks.length)
          ? tracks[startIndex].id
          : null;
      final available = _downloadedOnly(tracks);
      if (available.isEmpty) {
        queue.clear();
        error.value =
            'Offline mode is on and this surah isn\'t downloaded. Download it or turn off offline mode.';
        return;
      }
      effectiveTracks = available;
      final idx = available.indexWhere((t) => t.id == requestedId);
      effectiveStart = idx < 0 ? 0 : idx;
    }

    queue.assignAll(effectiveTracks);
    // Show the cached total length immediately (if we have one) so the scrubber
    // isn't stuck at 0:00 until the stream header resolves.
    if (effectiveStart >= 0 && effectiveStart < effectiveTracks.length) {
      duration.value =
          cachedDuration(effectiveTracks[effectiveStart].id) ?? Duration.zero;
    }
    tracks = effectiveTracks;
    startIndex = effectiveStart;

    // Resolve lock-screen / notification artwork: one bundled portrait per
    // reciter, materialized to a file URI (asset: paths aren't valid artUris).
    // Distinct assets are cached, so a 114-track single-reciter queue copies at
    // most one file. Art is optional — a null URI just omits it on the card.
    final artByAsset = <String, Uri>{};
    for (final asset in {
      for (final t in tracks)
        AppAssets.reciterImage(t.reciterId) ?? AppAssets.quranOnVelvet,
    }) {
      final uri = await MediaArtworkService.instance.uriForAsset(asset);
      if (uri != null) artByAsset[asset] = uri;
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
                  artUri:
                      artByAsset[AppAssets.reciterImage(t.reciterId) ??
                          AppAssets.quranOnVelvet],
                ),
              ),
            )
            .toList(),
        initialIndex: startIndex,
        initialPosition: initialPosition,
      );
      currentIndex.value = startIndex;
      if (autoPlay) {
        unawaited(
          _player.play().catchError((Object e, StackTrace s) {
            CrashReporter.instance.recordError(e, s, reason: 'start playback');
            error.value = "Couldn't start playback. Please try again.";
          }),
        );
      }
    } catch (e, s) {
      // Never surface raw exception text to users.
      CrashReporter.instance.recordError(e, s, reason: 'setQueue');
      error.value = 'Couldn\'t start playback. Please try again.';
    }
  }

  /// Jump to [index] within the *current* queue and play it.
  ///
  /// Re-selecting a surah that's already loaded must NOT rebuild the playlist:
  /// `setAudioSources` tears down and re-creates every source, which stalls or
  /// mutes playback mid-switch. When [index] is already in the live queue we
  /// just seek the existing playlist — instant, gapless, no rebuild. Falls back
  /// to a full [setQueue] only if the index is somehow out of range.
  Future<void> playAt(int index) async {
    if (index < 0 || index >= queue.length) return;
    try {
      currentIndex.value = index;
      duration.value = cachedDuration(queue[index].id) ?? Duration.zero;
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    } catch (e, s) {
      CrashReporter.instance.recordError(e, s, reason: 'playAt');
      // Rebuild as a last resort — copy the queue so we never feed the
      // observable its own backing list (see setQueue's defensive copy).
      await setQueue(List<AudioTrack>.of(queue), startIndex: index);
    }
  }

  /// Rebuilds the queue from the persisted [lastPlayback] snapshot and resumes
  /// from the saved position. The snapshot only stores the current track's
  /// identity, so the full queue is reconstructed from the reciter's moshaf via
  /// [playReciter]. When there is no (or an unusable) snapshot, falls back to a
  /// default session so the player is never left silent with an empty queue.
  Future<void> resumeLastSession() async {
    if (queue.isNotEmpty) return; // live session already active
    final saved = lastPlayback;
    final reciterId = saved?['reciterId'] as int?;
    final surahNumber = saved?['surahNumber'] as int?;
    final posMs = (saved?['positionMs'] as int?) ?? 0;
    if (reciterId == null || surahNumber == null) {
      await _startDefaultSession();
      return;
    }

    if (!Get.isRegistered<ReciterController>()) {
      await _startDefaultSession();
      return;
    }
    final rc = Get.find<ReciterController>();
    if (rc.reciters.isEmpty) {
      await rc.fetchReciters();
    }

    Reciter? reciter;
    for (final r in rc.reciters) {
      if (r.id == reciterId) {
        reciter = r;
        break;
      }
    }
    if (reciter == null) {
      await _startDefaultSession();
      return;
    }

    final surahNames = {
      for (final n in reciter.primaryMoshaf?.surahList ?? const <int>[])
        n: quran.getSurahName(n),
    };
    await playReciter(
      reciter,
      startSurahNumber: surahNumber,
      surahNames: surahNames,
      autoPlay: true,
    );
    if (posMs > 0) await seek(Duration(milliseconds: posMs));
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
    await endAudioPreview();
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

  // --- Persistence helpers ------------------------------------------------

  /// Debounce position saves to at most once per 5 s to avoid excessive I/O.
  void _schedulePersist() {
    // Throttle writes; resetting the timer on every position event prevented
    // continuous playback from ever saving its position.
    if (_persistDebounce?.isActive ?? false) return;
    _persistDebounce = Timer(const Duration(seconds: 5), _persistSession);
  }

  /// Persist a *slim* snapshot of the current session — just the current
  /// track's identity plus playback offset. The full queue is deliberately
  /// NOT stored: it's a deterministic function of the reciter's moshaf, so
  /// [resumeLastSession] rebuilds it from the reciter directory. This turns a
  /// ~114-track serialization (every 5 s) into a handful of fields.
  Future<void> _persistSession() async {
    if (_azkarPreview) return;
    final track = currentTrack;
    if (track == null) return;
    await Future.wait([
      _storage.writeJson(StorageKeys.lastPlayback, {
        'reciterId': track.reciterId,
        'reciterName': track.reciterName,
        'moshafName': track.moshafName,
        'surahNumber': track.surahNumber,
        'surahName': track.surahName,
        'positionMs': position.value.inMilliseconds,
      }),
      _storage.write(StorageKeys.preferredReciterId, track.reciterId),
    ]);
  }

  @override
  void onClose() {
    _persistDebounce?.cancel();
    _sleepTimer?.cancel();
    _player.dispose();
    super.onClose();
  }
}
