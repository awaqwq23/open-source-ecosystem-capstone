package org.openwhu.luotopia.widget

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.Locale
import java.util.TimeZone
import kotlin.math.max

data class WidgetSnapshotSettings(
    val enabled: Boolean,
    val refreshInterval: String,
    val languageCode: String,
    val darkMode: Boolean,
)

data class WidgetSnapshotItem(
    val id: String,
    val type: String,
    val title: String,
    val location: String,
    val isCompleted: Boolean,
    val manualOrder: Double,
    val createdAt: Date,
    val updatedAt: Date,
    val startAt: Date?,
    val endAt: Date?,
    val deadlineAt: Date?,
    val isAllDay: Boolean,
    val scheduleCountdownEnabled: Boolean,
    val timetableId: String,
    val accentColorLight: String,
    val accentColorDark: String,
)

data class WidgetSnapshot(
    val settings: WidgetSnapshotSettings,
    val activeTimetableId: String,
    val items: List<WidgetSnapshotItem>,
)

object WidgetSnapshotReader {
    fun read(context: Context): WidgetSnapshot? {
        val raw = WidgetStore.readSnapshot(context)
        if (raw.isBlank()) return null
        return try {
            val root = JSONObject(raw)
            if (root.optInt("version", 0) != 1) return null
            val settingsJson = root.optJSONObject("settings") ?: JSONObject()
            val timetablesJson = root.optJSONObject("timetables") ?: JSONObject()
            WidgetSnapshot(
                settings = WidgetSnapshotSettings(
                    enabled = settingsJson.optBoolean("enabled", true),
                    refreshInterval = settingsJson.optString("refreshInterval", "hour1"),
                    languageCode = settingsJson.optString("languageCode", "zh"),
                    darkMode = settingsJson.optBoolean("darkMode", false),
                ),
                activeTimetableId = timetablesJson.optString("activeTimetableId", ""),
                items = readItems(root.optJSONArray("items")),
            )
        } catch (_: Throwable) {
            null
        }
    }

    private fun readItems(array: JSONArray?): List<WidgetSnapshotItem> {
        if (array == null) return emptyList()
        val items = mutableListOf<WidgetSnapshotItem>()
        for (index in 0 until array.length()) {
            val obj = array.optJSONObject(index) ?: continue
            val type = obj.optString("type", "task")
            val startAt = parseDate(obj.optString("startAt"))
            val endAt = parseDate(obj.optString("endAt"))
            val deadlineAt = parseDate(obj.optString("deadlineAt"))
            val createdAt = parseDate(obj.optString("createdAt")) ?: Date(0L)
            if ((type == "schedule" || type == "course") && (startAt == null || endAt == null)) {
                continue
            }
            if (type == "task" && deadlineAt == null) {
                continue
            }
            items += WidgetSnapshotItem(
                id = obj.optString("id"),
                type = type,
                title = obj.optString("title"),
                location = obj.optString("location"),
                isCompleted = obj.optBoolean("isCompleted", false),
                manualOrder = obj.optDouble("manualOrder", 0.0),
                createdAt = createdAt,
                updatedAt = parseDate(obj.optString("updatedAt")) ?: createdAt,
                startAt = startAt,
                endAt = endAt,
                deadlineAt = deadlineAt,
                isAllDay = obj.optBoolean("isAllDay", false),
                scheduleCountdownEnabled = obj.optBoolean("scheduleCountdownEnabled", false),
                timetableId = obj.optString("timetableId"),
                accentColorLight = obj.optString("accentColorLight"),
                accentColorDark = obj.optString("accentColorDark"),
            )
        }
        return items
    }
}

object WidgetSnapshotModelBuilder {
    fun build(snapshot: WidgetSnapshot, now: Date = Date()): WidgetPayloadV4 {
        val zh = snapshot.settings.languageCode.lowercase(Locale.ROOT).startsWith("zh")
        val today = startOfDay(now)
        val weekSubtitle = semesterWeekLabel(snapshot, now, zh) ?: periodLabel(startOfWeek(now), zh)

        return WidgetPayloadV4(
            version = 4,
            meta = WidgetMetaModel(
                updatedLabel = if (zh) "更新于 ${formatHm(now)}" else "Updated ${formatHm(now)}",
                locale = snapshot.settings.languageCode,
                timezone = timezoneLabel(),
            ),
            agendaList = buildAgendaList(snapshot, now, today, zh, weekSubtitle),
        )
    }

    private fun buildAgendaList(
        snapshot: WidgetSnapshot,
        now: Date,
        today: Date,
        zh: Boolean,
        weekSubtitle: String,
    ): AgendaListWidgetModel {
        val myDayItems = snapshot.items.filter { isInMyDay(it, now) && !isEffectivelyCompleted(it, now) }
        val leftItems = myDayItems
            .filter { isTodayScheduleOrCourse(it, today) }
            .sortedWith(compareBy<WidgetSnapshotItem> { sortStart(it, today) }.thenBy { it.manualOrder })
        val dateLabel = if (zh) "${month(today)}月${dayOfMonth(today)}日" else "${month(today)}/${dayOfMonth(today)}"
        val leftStatusLabel =
            if (leftItems.isEmpty()) {
                if (zh) "今日无日程" else "No schedule today"
            } else {
                dateLabel
            }

        val rightItems = myDayItems
            .filter { isRightColumnItem(it, today) }
            .sortedWith(
                compareBy<WidgetSnapshotItem> { displayDay(it, today) }
                    .thenBy { sortStart(it, displayDay(it, today)) }
                    .thenBy { it.manualOrder },
            )

        return AgendaListWidgetModel(
            title = if (zh) "事项列表" else "Agenda List",
            subtitle = if (zh) "左列今日日程，右列任务备忘" else "Today schedule left, tasks and memos right",
            mode = if (leftItems.isEmpty()) "today_empty" else "today_schedule",
            leftTitle = leftStatusLabel,
            rightTitle = if (zh) "任务备忘" else "Tasks & Memos",
            leftRows = leftItems.take(40).map { toAgendaRow(it, today, zh, includeDay = false, snapshot.settings.darkMode) },
            rightRows = rightItems.take(80).map { toAgendaRow(it, displayDay(it, today), zh, includeDay = true, snapshot.settings.darkMode) },
            weekdayLabel = weekSubtitle,
            weekLabel = dateLabel,
        )
    }

    private fun isInMyDay(item: WidgetSnapshotItem, now: Date): Boolean {
        if (!isEffectivelyCompleted(item, now) &&
            (item.type == "task" || item.type == "memo" || item.scheduleCountdownEnabled)
        ) {
            return true
        }
        val start = item.startAt ?: return false
        val end = item.endAt ?: return false
        val today = startOfDay(now)
        val startDay = startOfDay(start)
        val endDay = startOfDay(end)
        return !today.before(startDay) && !today.after(endDay)
    }

    private fun isEffectivelyCompleted(item: WidgetSnapshotItem, now: Date): Boolean {
        if (item.type == "schedule") {
            val end = item.endAt
            return item.isCompleted || end?.after(now) == false
        }
        return item.isCompleted
    }

    private fun isTodayScheduleOrCourse(item: WidgetSnapshotItem, today: Date): Boolean {
        if (item.type != "course" && item.type != "schedule") {
            return false
        }
        return itemOccursInDay(item, today)
    }

    private fun isRightColumnItem(item: WidgetSnapshotItem, today: Date): Boolean {
        if (isTodayScheduleOrCourse(item, today)) {
            return false
        }
        return item.type == "task" || item.type == "memo"
    }

    private fun toAgendaRow(
        item: WidgetSnapshotItem,
        day: Date,
        zh: Boolean,
        includeDay: Boolean,
        darkMode: Boolean,
    ): AgendaListRowModel {
        val title = item.title.trim().ifEmpty { if (zh) "未命名事项" else "Untitled" }
        val timeText = buildItemTimeText(item, day, zh, includeDay)
        val compactMeta = if (item.location.isNotBlank()) "$timeText · ${item.location.trim()}" else timeText
        return AgendaListRowModel(
            id = item.id,
            title = title,
            meta = clipText(compactMeta, if (includeDay) 30 else 24),
            subText = clipText(compactMeta, if (includeDay) 30 else 24),
            typeKey = item.type,
            tag = typeLabel(item.type, zh),
            accentColor = if (darkMode) item.accentColorDark else item.accentColorLight,
        )
    }

}

fun snapshotRefreshIntervalMinutes(value: String): Long {
    return when (value) {
        "minutes30" -> 30L
        "hours3" -> 180L
        else -> 60L
    }
}

private fun typeLabel(type: String, zh: Boolean): String {
    return when (type) {
        "schedule" -> if (zh) "日程" else "Schedule"
        "memo" -> if (zh) "备忘" else "Memo"
        "course" -> if (zh) "课程" else "Course"
        else -> if (zh) "任务" else "Task"
    }
}

private fun buildItemTimeText(item: WidgetSnapshotItem, day: Date, zh: Boolean, includeDay: Boolean): String {
    if (item.type == "memo") {
        return if (zh) "备忘" else "Memo"
    }
    if (item.type == "task") {
        val deadline = item.deadlineAt ?: return if (zh) "任务" else "Task"
        val text = formatHm(deadline)
        return if (includeDay) "${month(deadline)}/${dayOfMonth(deadline)} $text" else text
    }
    if (item.isAllDay) {
        val text = if (zh) "全天" else "All day"
        return if (includeDay) "${month(day)}/${dayOfMonth(day)} $text" else text
    }
    val itemStart = item.startAt ?: day
    val itemEnd = item.endAt ?: itemStart
    val dayStart = startOfDay(day)
    val dayEnd = addDays(dayStart, 1)
    val start = if (itemStart.before(dayStart)) dayStart else itemStart
    val end = if (itemEnd.after(dayEnd)) dayEnd else itemEnd
    val range = "${formatHm(start)}-${formatHm(end)}"
    return if (includeDay) "${month(day)}/${dayOfMonth(day)} $range" else range
}

private fun itemOccursInDay(item: WidgetSnapshotItem, day: Date): Boolean {
    val start = item.startAt ?: return false
    val end = item.endAt ?: return false
    val dayStart = startOfDay(day)
    val dayEnd = addDays(dayStart, 1)
    return end.after(dayStart) && start.before(dayEnd)
}

private fun displayDay(item: WidgetSnapshotItem, fallback: Date): Date {
    return when (item.type) {
        "task" -> startOfDay(item.deadlineAt ?: fallback)
        "memo" -> fallback
        else -> startOfDay(item.startAt ?: fallback)
    }
}

private fun sortStart(item: WidgetSnapshotItem, day: Date): Date {
    val dayStart = startOfDay(day)
    return when (item.type) {
        "task" -> item.deadlineAt ?: dayStart
        "memo" -> addMinutes(dayStart, 23 * 60 + 59)
        else -> {
            val start = item.startAt ?: dayStart
            if (start.before(dayStart)) dayStart else start
        }
    }
}

private fun semesterWeekLabel(snapshot: WidgetSnapshot, now: Date, zh: Boolean): String? {
    val courses = snapshot.items.filter { it.type == "course" && it.timetableId.isNotBlank() }
    if (courses.isEmpty()) return null
    val targetId = if (snapshot.activeTimetableId.isNotBlank()) {
        snapshot.activeTimetableId
    } else {
        courses.map { it.timetableId }.toSet().singleOrNull() ?: return null
    }
    val firstDay = courses
        .filter { it.timetableId == targetId }
        .mapNotNull { it.startAt?.let(::startOfDay) }
        .minOrNull()
        ?: return null
    val weekOneMonday = startOfWeek(firstDay)
    val nowMonday = startOfWeek(now)
    val weekIndex = ((nowMonday.time - weekOneMonday.time) / (7L * 24L * 60L * 60L * 1000L)).toInt() + 1
    if (weekIndex <= 0) return null
    return if (zh) "第${weekIndex}周" else "Week $weekIndex"
}

private fun periodLabel(weekStart: Date, zh: Boolean): String {
    val weekEnd = addDays(weekStart, 6)
    return if (zh) {
        if (month(weekStart) == month(weekEnd)) {
            "${month(weekStart)}月第${weekOfMonth(weekStart)}周"
        } else {
            "${year(weekStart)}年第${weekOfYear(weekStart)}周"
        }
    } else {
        if (month(weekStart) == month(weekEnd)) {
            "Week ${weekOfMonth(weekStart)} of ${englishMonth(weekStart)}"
        } else {
            "Week ${weekOfYear(weekStart)} of ${year(weekStart)}"
        }
    }
}

private fun parseDate(value: String): Date? {
    val normalized = value.trim()
    if (normalized.isEmpty()) return null
    val patterns = listOf("yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd")
    for (pattern in patterns) {
        val parsed = runCatching {
            SimpleDateFormat(pattern, Locale.US).parse(normalized.take(pattern.length))
        }.getOrNull()
        if (parsed != null) return parsed
    }
    return null
}

private fun startOfDay(date: Date): Date {
    return calendar(date).apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
    }.time
}

private fun startOfWeek(date: Date): Date {
    val cal = calendar(startOfDay(date))
    cal.firstDayOfWeek = Calendar.MONDAY
    while (cal.get(Calendar.DAY_OF_WEEK) != Calendar.MONDAY) {
        cal.add(Calendar.DAY_OF_MONTH, -1)
    }
    return cal.time
}

private fun addDays(date: Date, days: Int): Date = calendar(date).apply { add(Calendar.DAY_OF_MONTH, days) }.time

private fun addMinutes(date: Date, minutes: Int): Date = calendar(date).apply { add(Calendar.MINUTE, minutes) }.time

private fun calendar(date: Date): Calendar = Calendar.getInstance().apply { time = date }

private fun formatHm(date: Date): String = SimpleDateFormat("HH:mm", Locale.US).format(date)

private fun timezoneLabel(): String {
    val offset = TimeZone.getDefault().rawOffset
    val sign = if (offset < 0) "-" else "+"
    val totalMinutes = kotlin.math.abs(offset) / 60000
    val hours = (totalMinutes / 60).toString().padStart(2, '0')
    val minutes = (totalMinutes % 60).toString().padStart(2, '0')
    return "UTC$sign$hours:$minutes"
}

private fun clipText(value: String, maxChars: Int): String {
    val normalized = value.trim().replace("\\s+".toRegex(), " ")
    if (normalized.length <= maxChars) return normalized
    return normalized.take(max(1, maxChars - 1)) + "…"
}

private fun year(date: Date): Int = calendar(date).get(Calendar.YEAR)
private fun month(date: Date): Int = calendar(date).get(Calendar.MONTH) + 1
private fun dayOfMonth(date: Date): Int = calendar(date).get(Calendar.DAY_OF_MONTH)
private fun weekOfMonth(date: Date): Int = calendar(date).get(Calendar.WEEK_OF_MONTH)
private fun weekOfYear(date: Date): Int = calendar(date).get(Calendar.WEEK_OF_YEAR)
private fun englishMonth(date: Date): String = SimpleDateFormat("MMMM yyyy", Locale.US).format(date)
