package com.example.huajuan_agenda.widget

import org.json.JSONArray
import org.json.JSONObject

data class AiWidgetModel(
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

data class ListWidgetModel(
    val title: String,
    val subtitle: String,
    val rows: List<String>,
)

data class WeekListWidgetModel(
    val title: String,
    val subtitle: String,
    val rows: List<String>,
)

data class WeekGridWidgetModel(
    val title: String,
    val subtitle: String,
    val headers: List<String>,
    val cells: List<String>,
    val rows: List<String>,
)

data class WidgetBundleModel(
    val ai: AiWidgetModel,
    val quickCreate: QuickCreateWidgetModel,
    val list: ListWidgetModel,
    val weekList: WeekListWidgetModel,
    val weekGrid: WeekGridWidgetModel,
    val updatedLabel: String,
)

object WidgetPayloadReader {
    fun read(context: android.content.Context): WidgetBundleModel {
        val raw = WidgetStore.readPayload(context)
        if (raw.isBlank()) {
            return fallback()
        }
        return try {
            val root = JSONObject(raw)
            val meta = root.optJSONObject("meta") ?: JSONObject()
            val ai = root.optJSONObject("ai") ?: JSONObject()
            val quickCreate = root.optJSONObject("quickCreate") ?: JSONObject()
            val list = root.optJSONObject("list") ?: JSONObject()
            val weekList = root.optJSONObject("weekList") ?: JSONObject()
            val weekGrid = root.optJSONObject("weekGrid") ?: JSONObject()

            WidgetBundleModel(
                ai = AiWidgetModel(
                    title = ai.optString("title", "AI"),
                    subtitle = ai.optString("subtitle", ""),
                ),
                quickCreate = QuickCreateWidgetModel(
                    title = quickCreate.optString("title", "快速创建事项"),
                    newItemLabel = quickCreate.optString("newItemLabel", "新建事项"),
                    scheduleLabel = quickCreate.optString("scheduleLabel", "日程"),
                    taskLabel = quickCreate.optString("taskLabel", "任务"),
                    memoLabel = quickCreate.optString("memoLabel", "备忘"),
                ),
                list = ListWidgetModel(
                    title = list.optString("title", "事项列表"),
                    subtitle = list.optString("subtitle", ""),
                    rows = toStringList(list.optJSONArray("rows")),
                ),
                weekList = WeekListWidgetModel(
                    title = weekList.optString("title", "周视图（列表版）"),
                    subtitle = weekList.optString("subtitle", ""),
                    rows = toStringList(weekList.optJSONArray("rows")),
                ),
                weekGrid = WeekGridWidgetModel(
                    title = weekGrid.optString("title", "周视图（表格版）"),
                    subtitle = weekGrid.optString("subtitle", ""),
                    headers = toStringList(weekGrid.optJSONArray("headers")),
                    cells = toStringList(weekGrid.optJSONArray("cells")),
                    rows = toStringList(weekGrid.optJSONArray("rows")),
                ),
                updatedLabel = meta.optString("updatedLabel", ""),
            )
        } catch (_: Throwable) {
            fallback()
        }
    }

    private fun toStringList(array: JSONArray?): List<String> {
        if (array == null) {
            return emptyList()
        }
        val result = mutableListOf<String>()
        for (index in 0 until array.length()) {
            val value = array.optString(index).trim()
            if (value.isNotEmpty()) {
                result.add(value)
            }
        }
        return result.toList()
    }

    private fun fallback(): WidgetBundleModel {
        return WidgetBundleModel(
            ai = AiWidgetModel(
                title = "AI 快速入口",
                subtitle = "点击打开 AI 页面",
            ),
            quickCreate = QuickCreateWidgetModel(
                title = "快速创建事项",
                newItemLabel = "新建事项",
                scheduleLabel = "日程",
                taskLabel = "任务",
                memoLabel = "备忘",
            ),
            list = ListWidgetModel(
                title = "事项列表",
                subtitle = "暂无数据",
                rows = emptyList(),
            ),
            weekList = WeekListWidgetModel(
                title = "周视图（列表版）",
                subtitle = "暂无数据",
                rows = emptyList(),
            ),
            weekGrid = WeekGridWidgetModel(
                title = "周视图（表格版）",
                subtitle = "暂无数据",
                headers = listOf("一", "二", "三", "四", "五", "六", "日"),
                cells = listOf("0", "0", "0", "0", "0", "0", "0"),
                rows = emptyList(),
            ),
            updatedLabel = "",
        )
    }
}
