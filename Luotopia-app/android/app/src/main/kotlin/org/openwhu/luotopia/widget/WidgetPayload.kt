package org.openwhu.luotopia.widget

import org.json.JSONObject

data class WidgetItemPayload(
    val text: String,
    val state: String,
)

data class WidgetPayload(
    val title: String,
    val subtitle: String,
    val content: String,
    val statusTag: String,
    val hint: String,
    val accentType: String,
    val timestamp: String,
    val items: List<WidgetItemPayload>,
)

fun parseWidgetPayload(raw: String?): WidgetPayload {
    if (raw.isNullOrBlank()) {
        return WidgetPayload("", "", "", "", "", "", "", emptyList())
    }
    return try {
        val json = JSONObject(raw)
        val parsedItems = mutableListOf<WidgetItemPayload>()
        val itemsArray = json.optJSONArray("items")
        if (itemsArray != null) {
            for (index in 0 until itemsArray.length()) {
                val itemJson = itemsArray.optJSONObject(index) ?: continue
                val text = itemJson.optString("text").trim()
                if (text.isEmpty()) {
                    continue
                }
                parsedItems.add(
                    WidgetItemPayload(
                        text = text,
                        state = itemJson.optString("state").trim(),
                    ),
                )
            }
        }
        if (parsedItems.isEmpty()) {
            val fallbackContent = json.optString("content")
            fallbackContent
                .lineSequence()
                .map { it.trim() }
                .filter { it.isNotEmpty() }
                .forEach { line ->
                    parsedItems.add(WidgetItemPayload(text = line, state = ""))
                }
        }
        WidgetPayload(
            title = json.optString("title"),
            subtitle = json.optString("subtitle"),
            content = json.optString("content"),
            statusTag = json.optString("statusTag"),
            hint = json.optString("hint"),
            accentType = json.optString("accentType"),
            timestamp = json.optString("timestamp"),
            items = parsedItems.toList(),
        )
    } catch (_: Throwable) {
        WidgetPayload("", "", "", "", "", "", "", emptyList())
    }
}
