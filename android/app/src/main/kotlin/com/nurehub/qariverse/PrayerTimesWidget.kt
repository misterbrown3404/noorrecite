package com.nurehub.qariverse

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class PrayerTimesWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_prayer_times).apply {
                setTextViewText(
                    R.id.tv_next_name,
                    widgetData.getString("widget_next_prayer", "\u2014") ?: "\u2014"
                )
                setTextViewText(
                    R.id.tv_next_time,
                    widgetData.getString("widget_next_time", "\u2014") ?: "\u2014"
                )
                setTextViewText(
                    R.id.tv_remaining,
                    widgetData.getString("widget_remaining", "\u2014") ?: "\u2014"
                )

                // Parse prayers JSON and populate individual prayer TextViews.
                val prayersJson = widgetData.getString("widget_prayers_json", null)
                val nameIds = listOf(
                    R.id.tv_fajr_name, R.id.tv_dhuhr_name, R.id.tv_asr_name,
                    R.id.tv_maghrib_name, R.id.tv_isha_name
                )
                val timeIds = listOf(
                    R.id.tv_fajr_time, R.id.tv_dhuhr_time, R.id.tv_asr_time,
                    R.id.tv_maghrib_time, R.id.tv_isha_time
                )
                val defaultNames = listOf("Fajr", "Dhuhr", "Asr", "Maghrib", "Isha")

                if (prayersJson != null) {
                    try {
                        val arr = JSONArray(prayersJson)
                        for (i in 0 until minOf(arr.length(), 5)) {
                            val obj = arr.getJSONObject(i)
                            setTextViewText(nameIds[i], obj.optString("name", defaultNames[i]))
                            setTextViewText(timeIds[i], obj.optString("time", "\u2014"))
                        }
                    } catch (_: Exception) {
                        // Fall through to defaults.
                        for (i in 0..4) {
                            setTextViewText(nameIds[i], defaultNames[i])
                            setTextViewText(timeIds[i], "\u2014")
                        }
                    }
                } else {
                    for (i in 0..4) {
                        setTextViewText(nameIds[i], defaultNames[i])
                        setTextViewText(timeIds[i], "\u2014")
                    }
                }

                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("qariverse://prayer-times")
                    )
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

