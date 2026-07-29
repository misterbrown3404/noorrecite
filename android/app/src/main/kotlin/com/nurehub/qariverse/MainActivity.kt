package com.nurehub.qariverse

import android.app.NotificationManager
import android.content.Context
import android.media.AudioManager
import android.os.Build
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : AudioServiceActivity() {
    // Debug-only diagnostics for the manual adhan test: lets the Dart side read
    // the current alarm-stream volume and Do Not Disturb state so a silent adhan
    // can be attributed to the device rather than the app.
    private val channelName = "com.nurehub.qariverse/audio_diag"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getAudioDiagnostics" -> result.success(audioDiagnostics())
                    else -> result.notImplemented()
                }
            }
    }

    private fun audioDiagnostics(): Map<String, Any> {
        val audio = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val alarmVol = audio.getStreamVolume(AudioManager.STREAM_ALARM)
        val alarmMax = audio.getStreamMaxVolume(AudioManager.STREAM_ALARM)

        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val filter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            nm.currentInterruptionFilter
        } else {
            NotificationManager.INTERRUPTION_FILTER_ALL
        }
        val dndLabel = when (filter) {
            NotificationManager.INTERRUPTION_FILTER_NONE -> "None (total silence)"
            NotificationManager.INTERRUPTION_FILTER_PRIORITY -> "Priority only"
            NotificationManager.INTERRUPTION_FILTER_ALARMS -> "Alarms only"
            NotificationManager.INTERRUPTION_FILTER_ALL -> "Off (all allowed)"
            else -> "Unknown"
        }

        return mapOf(
            "alarmVolume" to alarmVol,
            "alarmMax" to alarmMax,
            "dndFilter" to dndLabel
        )
    }
}
