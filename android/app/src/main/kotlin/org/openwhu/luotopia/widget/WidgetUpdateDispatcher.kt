package org.openwhu.luotopia.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent

object WidgetUpdateDispatcher {
    fun refreshAll(context: Context) {
        refreshReceiver(context, AgendaListWidgetReceiver::class.java)
    }

    private fun refreshReceiver(context: Context, clazz: Class<*>) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, clazz))
        if (ids.isEmpty()) {
            return
        }
        val intent = Intent(context, clazz).apply {
            action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
            putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        }
        context.sendBroadcast(intent)
    }
}
