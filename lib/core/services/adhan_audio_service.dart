import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import '../error/crash_reporter.dart';

/// Plays the full adhan (call to prayer) audio on demand.
///
/// Uses its own [AudioPlayer], separate from the Quran [AudioController], so the
/// adhan never disturbs the user's Quran queue, lock-screen controls, or saved
/// playback position.
///
/// Why in-app playback (both platforms): a notification's channel/attachment
/// sound is capped by the OS at ~30s, and the adhan clip is ~2 minutes — so the
/// notification sound alone can never play the full call to prayer. Worse, on
/// Android the channel sound routes to the ALARM stream, so if the alarm slider
/// is at 0 the user gets vibrate-only. Playing here through an [AudioPlayer] on
/// the media stream plays the clip in full and is audible on the media volume
/// the user actually hears.
///
/// The prayer notification itself stays as the lightweight at-time alert; this
/// service plays the full adhan when a prayer is reached in the foreground or
/// the notification is tapped ([NotificationService] routes 'adhan' payloads
/// here).
///
/// IMPORTANT: `just_audio_background` is initialized process-globally in
/// `main.dart`, which makes it wrap *every* [AudioPlayer] in the app — including
/// this one. Under that wrapper a source loaded without a `MediaItem` tag throws
/// on load, so the source here MUST carry a tag even though the adhan doesn't
/// need lock-screen transport controls. This is why a plain `setAsset` was
/// silent: the untagged load threw and the failure was swallowed.
///
/// Fully offline — the adhan ships as a bundled asset. If playback fails, the
/// error is reported (not swallowed) so it's diagnosable, and the prayer
/// notification still works as a reminder.
class AdhanAudioService {
  AdhanAudioService._();
  static final AdhanAudioService instance = AdhanAudioService._();

  /// Bundled adhan audio. Drop an mp3 at this path (see assets/audio/README).
  static const _adhanAsset = 'assets/audio/adhan.mp3';

  AudioPlayer? _player;

  /// Play the adhan from the start on all platforms. Any in-progress adhan is
  /// stopped first so overlapping prayer events don't stack audio.
  Future<void> play() async {
    try {
      await _player?.dispose();

      // Route to the media stream at an audible level (mirrors the Quran
      // player's session), so the adhan isn't gated by the alarm-volume slider
      // the way the notification channel sound is.
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      final player = AudioPlayer();
      _player = player;

      // The tag is REQUIRED: `just_audio_background` is initialized globally in
      // main.dart, so an untagged source throws on load. The adhan doesn't need
      // transport controls, but the MediaItem must be present.
      await player.setAudioSource(
        AudioSource.asset(
          _adhanAsset,
          tag: MediaItem(id: 'adhan', title: 'Adhan', album: 'Qari Verse'),
        ),
      );
      await player.play();
    } catch (e, s) {
      // Previously swallowed silently, which is exactly why the missing-tag
      // failure was invisible. Report it (the prayer notification still alerts
      // the user) instead of hiding it.
      CrashReporter.instance.recordError(e, s, reason: 'adhan play');
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
