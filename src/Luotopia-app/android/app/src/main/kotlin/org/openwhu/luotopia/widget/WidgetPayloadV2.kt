package org.openwhu.luotopia.widget

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

data class WidgetMetaModel(
    val updatedLabel: String,
    val locale: String,
    val timezone: String,
)

data class AgendaListRowModel(
    val id: String,
    val title: String,
    val meta: String,
    val subText: String,
    val typeKey: String,
    val tag: String,
    val accentColor: String,
)

data class AgendaListWidgetModel(
    val title: String,
    val subtitle: String,
    val mode: String,
    val leftTitle: String,
    val rightTitle: String,
    val leftRows: List<AgendaListRowModel>,
    val rightRows: List<AgendaListRowModel>,
    val weekdayLabel: String,
    val weekLabel: String,
)

data class WidgetPayloadV4(
    val version: Int,
    val meta: WidgetMetaModel,
    val agendaList: AgendaListWidgetModel,
)

object WidgetPayloadReader {
    fun read(context: Context): WidgetPayloadV4 {
        val snapshot = WidgetSnapshotReader.read(context)
        if (snapshot != null) {
            return WidgetSnapshotModelBuilder.build(snapshot)
        }

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
            val agendaListJson = root.optJSONObject("agendaList") ?: JSONObject()

            WidgetPayloadV4(
                version = 4,
                meta = WidgetMetaModel(
                    updatedLabel = metaJson.optString("updatedLabel", ""),
                    locale = metaJson.optString("languageCode", "zh"),
                    timezone = metaJson.optString("timezone", ""),
                ),
                agendaList = AgendaListWidgetModel(
                    title = agendaListJson.optString("title", "事项列表"),
                    subtitle = agendaListJson.optString("subtitle", "暂无数据"),
                    mode = agendaListJson.optString("mode", "today_future"),
                    leftTitle = agendaListJson.optString("leftTitle", "今天"),
                    rightTitle = agendaListJson.optString("rightTitle", "今天之后"),
                    leftRows = readAgendaRows(agendaListJson.optJSONArray("leftRows")),
                    rightRows = readAgendaRows(agendaListJson.optJSONArray("rightRows")),
                    weekdayLabel = agendaListJson.optString("weekdayLabel", "星期一"),
                    weekLabel = agendaListJson.optString("weekLabel", "第1周"),
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
                accentColor = obj.optString("accentColor", ""),
            )
        }
        return rows
    }

    private fun fallback(): WidgetPayloadV4 {
        return WidgetPayloadV4(
            version = 4,
            meta = WidgetMetaModel(
                updatedLabel = "",
                locale = "zh",
                timezone = "",
            ),
            agendaList = AgendaListWidgetModel(
                title = "事项列表",
                subtitle = "暂无事项",
                mode = "today_future",
                leftTitle = "今天",
                rightTitle = "今天之后",
                leftRows = emptyList(),
                rightRows = emptyList(),
                weekdayLabel = "星期一",
                weekLabel = "第1周",
            ),
        )
    }
}
