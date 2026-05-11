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

class NewItemShortcutWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = parseWidgetPayload(widgetData.getString("hj.widget.newItem.payload", null))
        appWidgetIds.forEach { widgetId ->
            val sizeTier = resolveShortcutWidgetTier(appWidgetManager.getAppWidgetOptions(widgetId))
            val subtitle = if (payload.hint.isNotBlank()) payload.hint else payload.subtitle
            val views = RemoteViews(context.packageName, R.layout.widget_new_item_shortcut)
                .apply {
                    setTextViewText(R.id.widget_new_item_title, payload.title)
                    setTextViewText(R.id.widget_new_item_subtitle, subtitle)
                    setTextViewText(R.id.widget_new_item_accent, "+")
                    setViewVisibility(
                        R.id.widget_new_item_subtitle,
                        if (subtitle.isBlank()) View.GONE else View.VISIBLE,
                    )
                    setViewVisibility(
                        R.id.widget_new_item_accent,
                        if (sizeTier == WidgetSizeTier.S) View.GONE else View.VISIBLE,
                    )
                    setInt(
                        R.id.widget_new_item_subtitle,
                        "setMaxLines",
                        if (sizeTier == WidgetSizeTier.S) 1 else 2,
                    )

                    val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java,
                        Uri.parse("luotopia://app/item-editor?showTypePicker=1&source=home_widget"),
                    )
                    setOnClickPendingIntent(R.id.widget_new_item_root, pendingIntent)
                }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
