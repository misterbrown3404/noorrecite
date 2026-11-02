package com.nurehub.qariverse

import android.app.Activity
import android.app.AlertDialog
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.os.Build
import android.os.Bundle

/** Launcher shortcut for adding a widget without starting the Flutter engine. */
class WidgetPickerActivity : Activity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val manager = AppWidgetManager.getInstance(this)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O ||
            !manager.isRequestPinAppWidgetSupported
        ) {
            showManualInstructions()
            return
        }
        val providers = arrayOf(
            DailyAyahWidget::class.java,
            PrayerTimesWidget::class.java,
            ReadingStreakWidget::class.java
        )
        AlertDialog.Builder(this)
            .setTitle(R.string.widget_picker_title)
            .setItems(R.array.widget_picker_names) { _, index ->
                val accepted = manager.requestPinAppWidget(
                    ComponentName(this, providers[index]), null, null
                )
                if (accepted) finish() else showManualInstructions()
            }
            .setNegativeButton(android.R.string.cancel) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }

    private fun showManualInstructions() {
        AlertDialog.Builder(this)
            .setTitle(R.string.shortcut_add_widget)
            .setMessage(R.string.widget_picker_manual)
            .setPositiveButton(android.R.string.ok) { _, _ -> finish() }
            .setOnCancelListener { finish() }
            .show()
    }
}
