package com.example.huajuan_agenda.widget

import android.content.Context

object WidgetStore {
    private const val PREFS_NAME = "huajuan_widget_store"
    private const val KEY_PAYLOAD = "payload_v2"

    fun savePayload(context: Context, payload: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_PAYLOAD, payload)
            .apply()
    }

    fun readPayload(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_PAYLOAD, "")
            .orEmpty()
    }
}
