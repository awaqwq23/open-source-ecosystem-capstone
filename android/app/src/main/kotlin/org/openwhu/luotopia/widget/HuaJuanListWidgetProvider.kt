package org.openwhu.luotopia.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import org.openwhu.luotopia.MainActivity
import org.openwhu.luotopia.R
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
            val sizeTier = resolveLargeWidgetTier(appWidgetManager.getAppWidgetOptions(widgetId))
            val content = buildWidgetContentLines(payload, sizeTier)
            val views = RemoteViews(context.packageName, R.layout.widget_huajuan_list).apply {
                setTextViewText(R.id.widget_list_title, payload.title)
                setTextViewText(R.id.widget_list_subtitle, payload.subtitle)
                setTextViewText(R.id.widget_list_status, payload.statusTag)
                setTextViewText(R.id.widget_list_content, content)
                setTextViewText(R.id.widget_list_timestamp, payload.timestamp)
                setViewVisibility(
                    R.id.widget_list_subtitle,
                    if (sizeTier == WidgetSizeTier.S) View.GONE else View.VISIBLE,
                )
                setViewVisibility(
                    R.id.widget_list_status,
                    if (sizeTier == WidgetSizeTier.S || payload.statusTag.isBlank()) View.GONE else View.VISIBLE,
                )
                setViewVisibility(
                    R.id.widget_list_timestamp,
                    if (sizeTier == WidgetSizeTier.L && payload.timestamp.isNotBlank()) View.VISIBLE else View.GONE,
                )
                setInt(
                    R.id.widget_list_content,
                    "setMaxLines",
                    when (sizeTier) {
                        WidgetSizeTier.S -> 4
                        WidgetSizeTier.M -> 6
                        WidgetSizeTier.L -> 10
                    },
                )

                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                    context,
                    MainActivity::class.java,
                    Uri.parse("luotopia://app/?source=home_widget"),
                )
                setOnClickPendingIntent(R.id.widget_list_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
