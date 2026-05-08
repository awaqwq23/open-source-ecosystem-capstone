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

class HuaJuanGridWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = parseWidgetPayload(widgetData.getString("hj.widget.grid.payload", null))
        appWidgetIds.forEach { widgetId ->
            val sizeTier = resolveLargeWidgetTier(appWidgetManager.getAppWidgetOptions(widgetId))
            val content = buildWidgetContentLines(payload, sizeTier)
            val views = RemoteViews(context.packageName, R.layout.widget_huajuan_grid).apply {
                setTextViewText(R.id.widget_grid_title, payload.title)
                setTextViewText(R.id.widget_grid_subtitle, payload.subtitle)
                setTextViewText(R.id.widget_grid_status, payload.statusTag)
                setTextViewText(R.id.widget_grid_content, content)
                setTextViewText(R.id.widget_grid_timestamp, payload.timestamp)
                setViewVisibility(
                    R.id.widget_grid_subtitle,
                    if (sizeTier == WidgetSizeTier.S) View.GONE else View.VISIBLE,
                )
                setViewVisibility(
                    R.id.widget_grid_status,
                    if (sizeTier == WidgetSizeTier.S || payload.statusTag.isBlank()) View.GONE else View.VISIBLE,
                )
                setViewVisibility(
                    R.id.widget_grid_timestamp,
                    if (sizeTier == WidgetSizeTier.L && payload.timestamp.isNotBlank()) View.VISIBLE else View.GONE,
                )
                setInt(
                    R.id.widget_grid_content,
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
                setOnClickPendingIntent(R.id.widget_grid_root, pendingIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
