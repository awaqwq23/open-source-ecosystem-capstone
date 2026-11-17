package org.openwhu.luotopia.widget

import android.content.Context
import android.content.Intent
import android.graphics.Color as AndroidColor
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color as ComposeColor
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalContext
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import org.openwhu.luotopia.MainActivity
import org.openwhu.luotopia.R
import kotlin.math.max

class AgendaListWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = AgendaListWidget()
}

private class AgendaListWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(324.dp, 240.dp),
            DpSize(324.dp, 156.dp),
            DpSize(324.dp, 324.dp),
            DpSize(408.dp, 156.dp),
            DpSize(408.dp, 324.dp),
            DpSize(408.dp, 408.dp),
            DpSize(492.dp, 156.dp),
            DpSize(492.dp, 240.dp),
            DpSize(492.dp, 408.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            val showSubtitle = span.rows >= 4 || span.cols >= 5
            val rowBudget = resolveAgendaRowBudget(size = LocalSize.current, showSubtitle = showSubtitle)
            CardShell(clickUri = WidgetDeepLinkFactory.list()) {
                Text(text = payload.agendaList.weekdayLabel, style = topMetaPrimaryStyle(), maxLines = 1)
                Text(text = payload.agendaList.weekLabel, style = topMetaSecondaryStyle(), maxLines = 1)
                Spacer(modifier = GlanceModifier.height(8.dp))
                AgendaTwoColumnPanel(
                    model = payload.agendaList,
                    leftMaxRows = rowBudget.left,
                    rightMaxRows = rowBudget.right,
                    locale = payload.meta.locale,
                )
            }
        }
    }
}

@Composable
private fun CardShell(
    clickUri: String,
    content: @Composable () -> Unit,
) {
    val context = LocalContext.current
    val action = actionStartActivity(buildDeepLinkIntent(context, clickUri))
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(ColorProvider(R.color.widget_surface_bg))
            .clickable(action)
            .padding(12.dp),
    ) {
        Column(modifier = GlanceModifier.fillMaxSize()) {
            content()
        }
    }
}

@Composable
private fun AgendaTwoColumnPanel(
    model: AgendaListWidgetModel,
    leftMaxRows: Int,
    rightMaxRows: Int,
    locale: String,
) {
    val columnWidth = max(1f, (LocalSize.current.width.value - 1f) / 2f).dp
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .fillMaxHeight(),
    ) {
        Box(
            modifier = GlanceModifier
                .width(columnWidth)
                .fillMaxHeight()
                .padding(end = 6.dp),
            contentAlignment = Alignment.BottomStart,
        ) {
            AgendaColumnRows(
                rows = model.leftRows,
                maxRows = leftMaxRows,
                locale = locale,
                alignBottom = true,
            )
        }
        Box(
            modifier = GlanceModifier
                .width(1.dp)
                .fillMaxHeight()
                .background(ColorProvider(R.color.widget_divider)),
        ) {}
        Box(
            modifier = GlanceModifier
                .width(columnWidth)
                .fillMaxHeight()
                .padding(start = 6.dp),
            contentAlignment = Alignment.TopStart,
        ) {
            AgendaColumnRows(
                rows = model.rightRows,
                maxRows = rightMaxRows,
                locale = locale,
                alignBottom = false,
            )
        }
    }
}

@Composable
private fun AgendaColumnRows(
    rows: List<AgendaListRowModel>,
    maxRows: Int,
    locale: String,
    alignBottom: Boolean,
) {
    if (rows.isEmpty()) {
        Text(text = localizedEmptyText(locale), style = secondaryStyle(), maxLines = 1)
        return
    }
    val visibleRows = rows.take(maxRows)
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        if (alignBottom && visibleRows.size < maxRows) {
            repeat(maxRows - visibleRows.size) {
                Spacer(modifier = GlanceModifier.height(35.dp))
            }
        }
        visibleRows.forEach { row ->
            Row(modifier = GlanceModifier.fillMaxWidth()) {
                Box(
                    modifier = GlanceModifier
                        .width(5.dp)
                        .height(30.dp)
                        .cornerRadius(3.dp)
                        .background(accentColorFor(row)),
                ) {}
                Spacer(modifier = GlanceModifier.width(6.dp))
                Column(modifier = GlanceModifier.fillMaxWidth()) {
                    Text(text = row.title, style = rowTitleStyle(), maxLines = 1)
                    val subText = row.subText.ifBlank { row.meta }
                    if (subText.isNotBlank()) {
                        Text(text = subText, style = metaStyle(), maxLines = 1)
                    } else if (row.tag.isNotBlank()) {
                        Text(text = row.tag, style = tertiaryStyle(), maxLines = 1)
                    }
                }
            }
            Spacer(modifier = GlanceModifier.height(5.dp))
        }
    }
}

private object WidgetDeepLinkFactory {
    fun list(): String = "luotopia://app/?source=widget"
}

private fun buildDeepLinkIntent(context: Context, uri: String): Intent {
    return Intent(Intent.ACTION_VIEW, Uri.parse(uri), context, MainActivity::class.java).apply {
        flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
    }
}

private data class WidgetSpan(
    val cols: Int,
    val rows: Int,
)

private fun resolveSpan(size: DpSize): WidgetSpan {
    fun toCells(value: Float): Int {
        return when {
            value < 110f -> 1
            value < 190f -> 2
            value < 270f -> 3
            value < 350f -> 4
            value < 430f -> 5
            else -> 6
        }
    }

    return WidgetSpan(
        cols = toCells(size.width.value),
        rows = toCells(size.height.value),
    )
}

private fun titleStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Bold,
        fontSize = 15.sp,
    )
}

private fun bodyStrongStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Medium,
        fontSize = 13.sp,
    )
}

private fun sectionTitleStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Medium,
        fontSize = 13.sp,
    )
}

private fun rowTitleStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Bold,
        fontSize = 13.sp,
    )
}

private fun topMetaPrimaryStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_meta_highlight),
        fontWeight = FontWeight.Bold,
        fontSize = 16.sp,
    )
}

private fun topMetaSecondaryStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Medium,
        fontSize = 13.sp,
    )
}

private fun metaStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_secondary),
        fontSize = 11.sp,
    )
}

private fun secondaryStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_secondary),
        fontSize = 13.sp,
    )
}

private fun tertiaryStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_tertiary),
        fontSize = 11.sp,
    )
}

private fun accentColorFor(row: AgendaListRowModel): ColorProvider {
    val parsed = runCatching {
        val value = row.accentColor.trim()
        if (value.isBlank()) {
            null
        } else {
            ColorProvider(ComposeColor(AndroidColor.parseColor(value)))
        }
    }.getOrNull()
    if (parsed != null) {
        return parsed
    }
    return accentColorForType(row.typeKey)
}

private fun accentColorForType(typeKey: String): ColorProvider {
    return when (typeKey) {
        "schedule" -> ColorProvider(R.color.widget_accent_schedule)
        "memo" -> ColorProvider(R.color.widget_accent_memo)
        "course" -> ColorProvider(R.color.widget_accent_course)
        else -> ColorProvider(R.color.widget_accent_task)
    }
}

private data class AgendaRowBudget(
    val left: Int,
    val right: Int,
)

private fun resolveAgendaRowBudget(size: DpSize, showSubtitle: Boolean): AgendaRowBudget {
    val height = size.height.value
    val baseRows = when {
        height < 190f -> 3
        height < 270f -> 4
        height < 350f -> 5
        else -> 6
    }
    val subtitlePenalty = if (showSubtitle) 0 else 1
    val wideBonus = if (size.width.value >= 430f) 1 else 0
    val rows = (baseRows + subtitlePenalty + wideBonus).coerceIn(3, 7)
    return AgendaRowBudget(left = rows, right = rows)
}

private fun localizedEmptyText(locale: String): String {
    return if (locale.startsWith("zh", ignoreCase = true)) "暂无" else "No items"
}
