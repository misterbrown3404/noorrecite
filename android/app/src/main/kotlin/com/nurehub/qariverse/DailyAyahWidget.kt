package com.nurehub.qariverse

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class DailyAyahWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_daily_ayah).apply {
                setTextViewText(
                    R.id.tv_ayah_arabic,
                    widgetData.getString(
                        "widget_ayah_arabic",
                        "\u0628\u0650\u0633\u0652\u0645\u0650 \u0627\u0644\u0644\u0651\u064e\u0647\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0652\u0645\u064e\u0670\u0646\u0650 \u0627\u0644\u0631\u0651\u064e\u062d\u0650\u064a\u0645\u0650"
                    ) ?: ""
                )
                setTextViewText(
                    R.id.tv_translation,
                    widgetData.getString(
                        "widget_ayah_translation",
                        "In the name of Allah, the Entirely Merciful, the Especially Merciful."
                    ) ?: ""
                )
                setTextViewText(
                    R.id.tv_ref,
                    widgetData.getString("widget_ayah_ref", "Al-Fatiha 1:1") ?: ""
                )
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("qariverse://daily-reflection")
                    )
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

