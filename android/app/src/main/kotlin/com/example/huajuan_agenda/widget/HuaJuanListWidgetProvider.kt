package com.example.huajuan_agenda.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import com.example.huajuan_agenda.MainActivity
import com.example.huajuan_agenda.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class HuaJuanListWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = parseWidgetPayload(widgetData.getString("hj.widget.list.payload", null))
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_huajuan_list).apply {
                setTextViewText(R.id.widget_list_title, payload.title)
                setTextViewText(R.id.widget_list_subtitle, payload.subtitle)
                setTextViewText(R.id.widget_list_content, payload.content)

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("huajuan://app/list?source=home_widget"),
                )
                setOnClickPendingIntent(R.id.widget_list_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
