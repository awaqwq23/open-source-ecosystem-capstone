package com.example.huajuan_agenda.widget

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

data class WidgetMetaModel(
    val updatedLabel: String,
    val locale: String,
    val timezone: String,
)

data class AiEntryWidgetModel(
    val title: String,
    val subtitle: String,
)

data class QuickCreateWidgetModel(
    val title: String,
    val newItemLabel: String,
    val scheduleLabel: String,
    val taskLabel: String,
    val memoLabel: String,
)

data class AgendaListRowModel(
    val id: String,
    val title: String,
    val meta: String,
    val subText: String,
    val typeKey: String,
    val tag: String,
)

data class AgendaListWidgetModel(
    val title: String,
    val subtitle: String,
    val mode: String,
    val leftTitle: String,
    val rightTitle: String,
    val leftRows: List<AgendaListRowModel>,
    val rightRows: List<AgendaListRowModel>,
)

data class WeekDayWidgetModel(
    val dateLabel: String,
    val weekdayLabel: String,
    val items: List<String>,
)

data class WeekGridWidgetModel(
    val title: String,
    val subtitle: String,
    val weekStartIso: String,
    val days: List<WeekDayWidgetModel>,
)

data class WidgetPayloadV4(
    val version: Int,
    val meta: WidgetMetaModel,
    val aiEntry: AiEntryWidgetModel,
    val quickCreate: QuickCreateWidgetModel,
    val agendaList: AgendaListWidgetModel,
    val weekGrid: WeekGridWidgetModel,
)

object WidgetPayloadReader {
    fun read(context: Context): WidgetPayloadV4 {
        val raw = WidgetStore.readPayload(context)
        if (raw.isBlank()) {
            return fallback()
        }
        return try {
            val root = JSONObject(raw)
            val version = root.optInt("version", 0)
            if (version != 4) {
                return fallback()
            }

            val metaJson = root.optJSONObject("meta") ?: JSONObject()
            val aiJson = root.optJSONObject("aiEntry") ?: JSONObject()
            val quickCreateJson = root.optJSONObject("quickCreate") ?: JSONObject()
            val agendaListJson = root.optJSONObject("agendaList") ?: JSONObject()
            val weekGridJson = root.optJSONObject("weekGrid") ?: JSONObject()

            WidgetPayloadV4(
                version = 4,
                meta = WidgetMetaModel(
                    updatedLabel = metaJson.optString("updatedLabel", ""),
                    locale = metaJson.optString("languageCode", "zh"),
                    timezone = metaJson.optString("timezone", ""),
                ),
                aiEntry = AiEntryWidgetModel(
                    title = aiJson.optString("title", "AI 快速进入"),
                    subtitle = aiJson.optString("subtitle", "点击打开 AI 页面"),
                ),
                quickCreate = QuickCreateWidgetModel(
                    title = quickCreateJson.optString("title", "快速创建事项"),
                    newItemLabel = quickCreateJson.optString("newItemLabel", "新建事项"),
                    scheduleLabel = quickCreateJson.optString("scheduleLabel", "日程"),
                    taskLabel = quickCreateJson.optString("taskLabel", "任务"),
                    memoLabel = quickCreateJson.optString("memoLabel", "备忘"),
                ),
                agendaList = AgendaListWidgetModel(
                    title = agendaListJson.optString("title", "事项列表"),
                    subtitle = agendaListJson.optString("subtitle", "暂无数据"),
                    mode = agendaListJson.optString("mode", "today_future"),
                    leftTitle = agendaListJson.optString("leftTitle", "今天"),
                    rightTitle = agendaListJson.optString("rightTitle", "今天之后"),
                    leftRows = readAgendaRows(agendaListJson.optJSONArray("leftRows")),
                    rightRows = readAgendaRows(agendaListJson.optJSONArray("rightRows")),
                ),
                weekGrid = WeekGridWidgetModel(
                    title = weekGridJson.optString("title", "周视图"),
                    subtitle = weekGridJson.optString("subtitle", "本周总览"),
                    weekStartIso = weekGridJson.optString("weekStartIso", ""),
                    days = readWeekDays(weekGridJson.optJSONArray("days")),
                ),
            )
        } catch (_: Throwable) {
            fallback()
        }
    }

    private fun readAgendaRows(array: JSONArray?): List<AgendaListRowModel> {
        if (array == null) {
            return emptyList()
        }
        val rows = mutableListOf<AgendaListRowModel>()
        for (index in 0 until array.length()) {
            val obj = array.optJSONObject(index) ?: continue
            val title = obj.optString("title").trim()
            if (title.isEmpty()) {
                continue
            }
            rows += AgendaListRowModel(
                id = obj.optString("id", ""),
                title = title,
                meta = obj.optString("meta", ""),
                subText = obj.optString("subText", obj.optString("meta", "")),
                typeKey = obj.optString("typeKey", "task"),
                tag = obj.optString("tag", ""),
            )
        }
        return rows
    }

    private fun readWeekDays(array: JSONArray?): List<WeekDayWidgetModel> {
        if (array == null) {
            return emptyList()
        }
        val days = mutableListOf<WeekDayWidgetModel>()
        for (index in 0 until array.length()) {
            val obj = array.optJSONObject(index) ?: continue
            val lines = mutableListOf<String>()
            val itemsArray = obj.optJSONArray("items")
            if (itemsArray != null) {
                for (itemIndex in 0 until itemsArray.length()) {
                    val line = itemsArray.optString(itemIndex).trim()
                    if (line.isNotEmpty()) {
                        lines += line
                    }
                }
            }
            days += WeekDayWidgetModel(
                dateLabel = obj.optString("dateLabel", ""),
                weekdayLabel = obj.optString("weekdayLabel", ""),
                items = lines,
            )
        }
        return days
    }

    private fun fallback(): WidgetPayloadV4 {
        return WidgetPayloadV4(
            version = 4,
            meta = WidgetMetaModel(
                updatedLabel = "",
                locale = "zh",
                timezone = "",
            ),
            aiEntry = AiEntryWidgetModel(
                title = "AI 快速进入",
                subtitle = "点击打开 AI 页面",
            ),
            quickCreate = QuickCreateWidgetModel(
                title = "快速创建事项",
                newItemLabel = "新建事项",
                scheduleLabel = "日程",
                taskLabel = "任务",
                memoLabel = "备忘",
            ),
            agendaList = AgendaListWidgetModel(
                title = "事项列表",
                subtitle = "暂无事项",
                mode = "today_future",
                leftTitle = "今天",
                rightTitle = "今天之后",
                leftRows = emptyList(),
                rightRows = emptyList(),
            ),
            weekGrid = WeekGridWidgetModel(
                title = "周视图",
                subtitle = "本周总览",
                weekStartIso = "",
                days = emptyList(),
            ),
        )
    }
}
