package com.shegz.celebray

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class CelebrayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val title = widgetData.getString("widget_title", "Next up") ?: "Next up"
        val upcomingJson = widgetData.getString("upcoming_json", "[]") ?: "[]"

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.celebray_widget)
            views.setTextViewText(R.id.widget_title, title)

            try {
                val array = JSONArray(upcomingJson)
                val line1 = if (array.length() > 0) formatLine(array.getJSONObject(0)) else "Add celebrations in Celebray"
                val line2 = if (array.length() > 1) formatLine(array.getJSONObject(1)) else ""
                val line3 = if (array.length() > 2) formatLine(array.getJSONObject(2)) else ""

                views.setTextViewText(R.id.widget_line_1, line1)
                views.setTextViewText(R.id.widget_line_2, line2)
                views.setTextViewText(R.id.widget_line_3, line3)
            } catch (_: Exception) {
                views.setTextViewText(R.id.widget_line_1, "Open Celebray to sync")
                views.setTextViewText(R.id.widget_line_2, "")
                views.setTextViewText(R.id.widget_line_3, "")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun formatLine(item: org.json.JSONObject): String {
        val eventTitle = item.optString("title", "")
        val daysLabel = item.optString("daysLabel", "")
        return if (daysLabel.isNotEmpty()) "$eventTitle · $daysLabel" else eventTitle
    }
}
