package com.tutorsaas.tutorsaas

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * P-36 (#121): widget de pantalla de inicio.
 *
 * Pinta racha, minutos de hoy vs meta y un botón "Practicar". Los datos los
 * escribe Dart con `home_widget` (`HomeWidgetSnapshot`); este provider solo
 * los coloca. Un día distinto al guardado (o un guardado vacío) muestra el
 * estado vacío honesto: nunca ceros ni rachas de ayer.
 */
class DungeonWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val fresh = widgetData.getBoolean(KEY_HAS_DATA, false) &&
            widgetData.getString(KEY_DATE_KEY, null) == todayKey()

        val practiceIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse(PRACTICE_URI),
        )
        val homeIntent = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse(HOME_URI),
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.dungeon_widget)
            views.setOnClickPendingIntent(R.id.widget_root, homeIntent)
            views.setOnClickPendingIntent(R.id.widget_practice, practiceIntent)
            views.setTextViewText(
                R.id.widget_practice,
                widgetData.getString(KEY_PRACTICE_LABEL, null)
                    ?: context.getString(R.string.widget_practice),
            )
            if (fresh) {
                bindData(context, views, widgetData)
            } else {
                bindEmpty(context, views, widgetData)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun bindData(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        views.setViewVisibility(R.id.widget_data, View.VISIBLE)
        views.setViewVisibility(R.id.widget_empty, View.GONE)

        views.setTextViewText(
            R.id.widget_streak_days,
            widgetData.getInt(KEY_STREAK_DAYS, 0).toString(),
        )
        views.setTextViewText(
            R.id.widget_streak_label,
            widgetData.getString(KEY_STREAK_LABEL, null)
                ?: context.getString(R.string.widget_streak_label),
        )
        views.setTextViewText(
            R.id.widget_minutes_label,
            widgetData.getString(KEY_MINUTES_LABEL, null)
                ?: context.getString(R.string.widget_minutes_label),
        )
        views.setTextViewText(
            R.id.widget_minutes_value,
            widgetData.getString(KEY_MINUTES_VALUE, "").orEmpty(),
        )

        val goalDone = widgetData.getBoolean(KEY_GOAL_DONE, false)
        views.setTextColor(
            R.id.widget_minutes_value,
            if (goalDone) COLOR_GOAL_DONE else COLOR_MANA_CYAN,
        )

        val goal = widgetData.getInt(KEY_GOAL_MINUTES, 0)
        if (goal > 0) {
            val minutes = widgetData.getInt(KEY_MINUTES_TODAY, 0)
            views.setViewVisibility(R.id.widget_progress, View.VISIBLE)
            views.setProgressBar(R.id.widget_progress, goal, minutes.coerceAtMost(goal), false)
        } else {
            views.setViewVisibility(R.id.widget_progress, View.GONE)
        }
    }

    private fun bindEmpty(
        context: Context,
        views: RemoteViews,
        widgetData: SharedPreferences,
    ) {
        views.setViewVisibility(R.id.widget_data, View.GONE)
        views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
        views.setViewVisibility(R.id.widget_progress, View.GONE)
        views.setTextViewText(
            R.id.widget_empty_title,
            widgetData.getString(KEY_EMPTY_TITLE, null)
                ?: context.getString(R.string.widget_empty_title),
        )
        views.setTextViewText(
            R.id.widget_empty_body,
            widgetData.getString(KEY_EMPTY_BODY, null)
                ?: context.getString(R.string.widget_empty_body),
        )
    }

    private fun todayKey(): String =
        SimpleDateFormat(DATE_PATTERN, Locale.US).format(Date())

    companion object {
        private const val DATE_PATTERN = "yyyy-MM-dd"
        private const val PRACTICE_URI = "homeWidget://practice"
        private const val HOME_URI = "homeWidget://home"

        // Deben coincidir con HomeWidgetSnapshot (Dart).
        private const val KEY_HAS_DATA = "widget_has_data"
        private const val KEY_DATE_KEY = "widget_date_key"
        private const val KEY_STREAK_DAYS = "widget_streak_days"
        private const val KEY_STREAK_LABEL = "widget_streak_label"
        private const val KEY_MINUTES_LABEL = "widget_minutes_label"
        private const val KEY_MINUTES_VALUE = "widget_minutes_value"
        private const val KEY_MINUTES_TODAY = "widget_minutes_today"
        private const val KEY_GOAL_MINUTES = "widget_goal_minutes"
        private const val KEY_GOAL_DONE = "widget_goal_done"
        private const val KEY_PRACTICE_LABEL = "widget_practice_label"
        private const val KEY_EMPTY_TITLE = "widget_empty_title"
        private const val KEY_EMPTY_BODY = "widget_empty_body"

        private val COLOR_MANA_CYAN = Color.parseColor("#FF00E5FF")
        private val COLOR_GOAL_DONE = Color.parseColor("#FF00E676")
    }
}
