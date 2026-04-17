package com.example.huajuan_agenda.widget

import android.appwidget.AppWidgetManager
import android.os.Bundle
import kotlin.math.max
import kotlin.math.min

enum class WidgetSizeTier {
    S,
    M,
    L,
}

fun resolveLargeWidgetTier(options: Bundle): WidgetSizeTier {
    val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
    val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
    return when {
        minWidth >= 340 || minHeight >= 260 -> WidgetSizeTier.L
        minWidth > 0 && minHeight > 0 && (minWidth < 230 || minHeight < 150) -> WidgetSizeTier.S
        else -> WidgetSizeTier.M
    }
}

fun resolveShortcutWidgetTier(options: Bundle): WidgetSizeTier {
    val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 0)
    val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 0)
    return if (minWidth >= 180 || minHeight >= 100) WidgetSizeTier.M else WidgetSizeTier.S
}

fun buildWidgetContentLines(
    payload: WidgetPayload,
    tier: WidgetSizeTier,
): String {
    val maxItems = when (tier) {
        WidgetSizeTier.S -> 3
        WidgetSizeTier.M -> 5
        WidgetSizeTier.L -> 8
    }
    val maxChars = when (tier) {
        WidgetSizeTier.S -> 24
        WidgetSizeTier.M -> 34
        WidgetSizeTier.L -> 48
    }

    val rows = if (payload.items.isNotEmpty()) {
        payload.items
    } else {
        payload.content
            .lineSequence()
            .map { WidgetItemPayload(it, "") }
            .toList()
    }

    if (rows.isEmpty()) {
        return payload.hint
    }

    return rows
        .take(maxItems)
        .joinToString("\n") { row ->
            val marker = markerForState(row.state)
            val trimmed = clampText(row.text, maxChars)
            "$marker $trimmed"
        }
}

private fun markerForState(state: String): String {
    return when (state) {
        "done" -> "✓"
        "overdue" -> "!"
        "in_progress" -> "→"
        "busy" -> "●"
        "idle" -> "○"
        else -> "•"
    }
}

private fun clampText(value: String, maxChars: Int): String {
    val normalized = value.trim().replace("\\s+".toRegex(), " ")
    if (normalized.length <= maxChars) {
        return normalized
    }
    val safeLength = max(1, min(normalized.length, maxChars - 1))
    return normalized.take(safeLength) + "…"
}
