package com.example.huajuan_agenda.widget

import org.json.JSONObject

data class WidgetPayload(
    val title: String,
    val subtitle: String,
    val content: String,
)

fun parseWidgetPayload(raw: String?): WidgetPayload {
    if (raw.isNullOrBlank()) {
        return WidgetPayload("", "", "")
    }
    return try {
        val json = JSONObject(raw)
        WidgetPayload(
            title = json.optString("title"),
            subtitle = json.optString("subtitle"),
            content = json.optString("content"),
        )
    } catch (_: Throwable) {
        WidgetPayload("", "", "")
    }
}
