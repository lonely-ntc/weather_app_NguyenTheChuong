package com.example.weather_app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class WeatherWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            // Bọc try-catch lớn nhất có thể để tránh crash
            try {
                val views = RemoteViews(context.packageName, R.layout.widget_layout).apply {
                    
                    val city = widgetData.getString("city", "City")
                    val temp = widgetData.getString("temp", "--")
                    val desc = widgetData.getString("desc", "Updating...")

                    setTextViewText(R.id.widget_city, city)
                    setTextViewText(R.id.widget_temp, temp)
                    setTextViewText(R.id.widget_desc, desc)

                    // Xử lý JSON (Cũng bọc try-catch)
                    val hourlyJson = widgetData.getString("hourly_json", "[]")
                    if (!hourlyJson.isNullOrEmpty()) {
                        try {
                            val jsonArray = JSONArray(hourlyJson)
                            if (jsonArray.length() > 0) {
                                val item = jsonArray.getJSONObject(0)
                                setTextViewText(R.id.h1_time, "${item.optString("time")} ${item.optString("temp")}")
                            }
                            if (jsonArray.length() > 1) {
                                val item = jsonArray.getJSONObject(1)
                                setTextViewText(R.id.h2_time, "${item.optString("time")} ${item.optString("temp")}")
                            }
                            if (jsonArray.length() > 2) {
                                val item = jsonArray.getJSONObject(2)
                                setTextViewText(R.id.h3_time, "${item.optString("time")} ${item.optString("temp")}")
                            }
                        } catch (e: Exception) {
                            println("JSON Error: $e")
                        }
                    }
                }
                appWidgetManager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                println("Widget Layout Error: $e")
            }
        }
    }
}