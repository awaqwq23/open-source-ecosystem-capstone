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

class HuaJuanNewItemShortcutWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = parseWidgetPayload(widgetData.getString("hj.widget.newItem.payload", null))
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.widget_huajuan_new_item_shortcut)
                .apply {
                    setTextViewText(R.id.widget_new_item_title, payload.title)
                    setTextViewText(R.id.widget_new_item_subtitle, payload.subtitle)

                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("huajuan://app/item-editor?showTypePicker=1&source=home_widget"),
                    )
                    setOnClickPendingIntent(R.id.widget_new_item_root, pendingIntent)
                }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
