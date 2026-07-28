# Adhan audio

Place the call-to-prayer audio file here as:

    adhan.mp3

This file is played:
- automatically when a prayer time is reached while the app is open, and
- when the user taps a prayer-time notification (opening the app).

Requirements:
- Filename must be exactly `adhan.mp3` (referenced in
  `lib/core/services/adhan_audio_service.dart`).
- Any length is fine — it plays through the app's audio engine, not as a
  notification sound, so it is not subject to the ~30s OS notification-sound cap.
- Use a royalty-free / properly licensed recitation.

If this file is absent the app still works: the prayer notification shows as a
visual reminder, and adhan playback simply no-ops.
