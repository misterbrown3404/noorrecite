import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../features/audio_player/presentation/controllers/audio_controller.dart';
import '../error/crash_reporter.dart';

/// Adhan uses the app's single background player and restores Quran playback
/// state, paused, when it ends. No competing AudioPlayer is created.
class AdhanAudioService {
  AdhanAudioService._();
  static final instance = AdhanAudioService._();
  final isPlaying = ValueNotifier<bool>(false);
  final error = ValueNotifier<String>('');
  bool _pending = false;
  StreamSubscription<PlayerState>? _completion;
  StreamSubscription<PlayerException>? _errors;

  Future<void> play() async {
    if (!Get.isRegistered<AudioController>()) {
      _pending = true;
      return;
    }
    _pending = false;
    error.value = '';
    await _completion?.cancel();
    await _errors?.cancel();
    final audio = Get.find<AudioController>();
    try {
      await audio.playAudioPreview(
        'assets/audio/adhan.mp3',
        'Adhan',
        owner: 'adhan',
        artist: 'QariVerse',
        album: 'Prayer reminder',
      );
      isPlaying.value = true;
      _completion = audio.player.playerStateStream.listen((state) {
        isPlaying.value =
            audio.isAdhanPreview &&
            state.playing &&
            state.processingState != ProcessingState.completed;
        if (!audio.isAdhanPreview ||
            state.processingState == ProcessingState.completed) {
          unawaited(stop());
        }
      });
      _errors = audio.player.errorStream.listen((event) {
        error.value = 'Couldn’t play the adhan. Please try again.';
        unawaited(stop());
      });
    } catch (e, s) {
      error.value = 'Couldn’t play the adhan. Please try again.';
      CrashReporter.instance.recordError(e, s, reason: 'adhan play');
      await stop();
    }
  }

  void playPending() {
    if (_pending) unawaited(play());
  }

  Future<void> stop() async {
    _pending = false;
    await _completion?.cancel();
    await _errors?.cancel();
    _completion = null;
    _errors = null;
    isPlaying.value = false;
    if (Get.isRegistered<AudioController>()) {
      try {
        await Get.find<AudioController>().endAudioPreview(owner: 'adhan');
      } catch (e, s) {
        CrashReporter.instance.recordError(e, s, reason: 'restore after adhan');
      }
    }
  }
}
