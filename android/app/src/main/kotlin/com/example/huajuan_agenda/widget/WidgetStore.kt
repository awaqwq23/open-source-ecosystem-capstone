package com.example.huajuan_agenda.widget

import android.content.Context

object WidgetStore {
    private const val PREFS_NAME = "huajuan_widget_store"
    private const val KEY_PAYLOAD_V3 = "payload_v3"
    private const val KEY_PAYLOAD_V2 = "payload_v2"

    fun savePayload(context: Context, payload: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_PAYLOAD_V3, payload)
            .apply()
    }

    fun readPayload(context: Context): String {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        return prefs.getString(KEY_PAYLOAD_V3, null)
            ?: prefs.getString(KEY_PAYLOAD_V2, "")
            .orEmpty()
    }
}
