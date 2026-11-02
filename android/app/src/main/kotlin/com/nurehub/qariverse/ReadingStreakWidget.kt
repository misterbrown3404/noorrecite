package com.nurehub.qariverse

import android.appwidget.AppWidgetManager
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ReadingStreakWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: android.content.SharedPreferences
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_reading_streak).apply {
                val streak = widgetData.getInt("widget_streak", 0)
                val todayCount = widgetData.getInt("widget_today_count", 0)
                val dailyGoal = widgetData.getInt("widget_daily_goal", 10)
                val lastSurah = widgetData.getString("widget_last_surah", "") ?: ""

                setTextViewText(R.id.tv_streak_count, streak.toString())
                setTextViewText(R.id.tv_today, "$todayCount")
                setTextViewText(R.id.tv_goal, "$dailyGoal")
                setTextViewText(R.id.tv_last_surah, lastSurah)

                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("qariverse://main")
                    )
                )
            }
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}

