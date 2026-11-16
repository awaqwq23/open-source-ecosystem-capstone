package org.openwhu.luotopia.widget

import android.content.Context

object WidgetStore {
    private const val PREFS_NAME = "luotopia_widget_store"
    private const val KEY_SNAPSHOT_V1 = "snapshot_v1"
    private const val KEY_PAYLOAD_V3 = "payload_v3"
    private const val KEY_PAYLOAD_V2 = "payload_v2"

    fun saveSnapshot(context: Context, snapshot: String) {
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_SNAPSHOT_V1, snapshot)
            .apply()
    }

    fun readSnapshot(context: Context): String {
        return context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .getString(KEY_SNAPSHOT_V1, "")
            .orEmpty()
    }

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
