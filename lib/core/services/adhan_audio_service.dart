import 'dart:io' show Platform;

import 'package:just_audio/just_audio.dart';

/// Plays the full adhan (call to prayer) audio on demand.
///
/// Deliberately separate from the Quran [AudioController] and its
/// `just_audio_background` player: the adhan is a short, fire-and-forget
/// playback that must never disturb the user's Quran queue, lock-screen
/// controls, or saved playback position.
///
/// Platform split — on **Android**, the full adhan is played by the system as
/// the prayer notification's channel sound (works even when the app is closed),
/// so this in-app player is a no-op there to avoid double audio. On **iOS**,
/// notification sounds are capped at ~30s, so the full adhan is played here when
/// a prayer is reached in the foreground or the notification is tapped.
///
/// Fully offline — the adhan ships as a bundled asset. If the asset is missing,
/// [play] fails silently so the prayer notification still works as a reminder.
class AdhanAudioService {
  AdhanAudioService._();
  static final AdhanAudioService instance = AdhanAudioService._();

  /// Bundled adhan audio. Drop an mp3 at this path (see assets/audio/README).
  static const _adhanAsset = 'assets/audio/adhan.mp3';

  AudioPlayer? _player;

  /// Play the adhan from the start. No-op on Android (the notification channel
  /// sound handles playback there). Any in-progress adhan is stopped first so
  /// overlapping prayer events don't stack audio.
  Future<void> play() async {
    if (Platform.isAndroid) return; // handled by the notification channel sound
    try {
      await _player?.dispose();
      final player = AudioPlayer();
      _player = player;
      await player.setAsset(_adhanAsset);
      await player.play();
    } catch (_) {
      // Missing asset or playback failure — stay silent; the notification
      // itself already alerted the user.
    }
  }

  /// Stop and release the adhan player (e.g. user dismisses it).
  Future<void> stop() async {
    try {
      await _player?.stop();
      await _player?.dispose();
    } catch (_) {
      // ignore
    }
    _player = null;
  }
}
