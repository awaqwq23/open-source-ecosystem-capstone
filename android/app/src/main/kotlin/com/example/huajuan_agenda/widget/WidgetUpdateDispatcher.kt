package com.example.huajuan_agenda.widget

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent

object WidgetUpdateDispatcher {
    fun refreshAll(context: Context) {
        refreshReceiver(context, HuaJuanAiEntryWidgetReceiver::class.java)
        refreshReceiver(context, HuaJuanQuickCreateWidgetReceiver::class.java)
        refreshReceiver(context, HuaJuanAgendaListWidgetReceiver::class.java)
        refreshReceiver(context, HuaJuanWeekGridWidgetReceiver::class.java)
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
