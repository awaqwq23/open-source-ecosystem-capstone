package com.example.huajuan_agenda.widget

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
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
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.text.TextAlign
import androidx.glance.unit.ColorProvider
import com.example.huajuan_agenda.MainActivity
import com.example.huajuan_agenda.R
import kotlin.math.max

class HuaJuanAiEntryWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = HuaJuanAiEntryWidget()
}

class HuaJuanQuickCreateWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = HuaJuanQuickCreateWidget()
}

class HuaJuanAgendaListWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = HuaJuanAgendaListWidget()
}

class HuaJuanWeekGridWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = HuaJuanWeekGridWidget()
}

private class HuaJuanAiEntryWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(72.dp, 72.dp),
            DpSize(156.dp, 72.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            CardShell(clickUri = WidgetDeepLinkFactory.ai()) {
                Text(
                    text = payload.aiEntry.title,
                    style = titleStyle(),
                    maxLines = 1,
                )
                Spacer(modifier = GlanceModifier.height(6.dp))
                Text(
                    text = payload.aiEntry.subtitle,
                    style = secondaryStyle(),
                    maxLines = 2,
                )
                if (payload.meta.updatedLabel.isNotBlank()) {
                    Spacer(modifier = GlanceModifier.height(6.dp))
                    Text(
                        text = payload.meta.updatedLabel,
                        style = tertiaryStyle(),
                        maxLines = 1,
                    )
                }
            }
        }
    }
}

private class HuaJuanQuickCreateWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(72.dp, 72.dp),
            DpSize(156.dp, 72.dp),
            DpSize(72.dp, 156.dp),
            DpSize(72.dp, 240.dp),
            DpSize(72.dp, 324.dp),
            DpSize(72.dp, 408.dp),
            DpSize(72.dp, 492.dp),
            DpSize(156.dp, 156.dp),
            DpSize(240.dp, 156.dp),
            DpSize(156.dp, 240.dp),
            DpSize(240.dp, 240.dp),
            DpSize(324.dp, 240.dp),
            DpSize(240.dp, 324.dp),
            DpSize(324.dp, 324.dp),
            DpSize(408.dp, 324.dp),
            DpSize(324.dp, 408.dp),
            DpSize(492.dp, 72.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            CardShell(clickUri = WidgetDeepLinkFactory.createChooser()) {
                QuickCreateContent(span = span, model = payload.quickCreate)
            }
        }
    }
}

private class HuaJuanAgendaListWidget : GlanceAppWidget() {
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
            val maxRows = max(4, span.cols * span.rows)
            CardShell(clickUri = WidgetDeepLinkFactory.list()) {
                Text(text = payload.agendaList.title, style = titleStyle(), maxLines = 1)
                Text(text = payload.agendaList.subtitle, style = tertiaryStyle(), maxLines = 1)
                Spacer(modifier = GlanceModifier.height(8.dp))
                AgendaRowsPanel(rows = payload.agendaList.rows, maxRows = maxRows)
            }
        }
    }
}

private class HuaJuanWeekGridWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(240.dp, 156.dp),
            DpSize(324.dp, 156.dp),
            DpSize(324.dp, 240.dp),
            DpSize(408.dp, 240.dp),
            DpSize(408.dp, 324.dp),
            DpSize(492.dp, 324.dp),
            DpSize(492.dp, 408.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            val dayCount = max(3, minOf(7, span.cols + 1))
            val lineBudget = max(1, span.rows - 1)
            CardShell(clickUri = WidgetDeepLinkFactory.homeWeek(payload.weekGrid.weekStartIso)) {
                Text(text = payload.weekGrid.title, style = titleStyle(), maxLines = 1)
                Text(text = payload.weekGrid.subtitle, style = tertiaryStyle(), maxLines = 1)
                Spacer(modifier = GlanceModifier.height(8.dp))
                WeekGridPanel(
                    days = payload.weekGrid.days.take(dayCount),
                    perDayLines = lineBudget,
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
private fun QuickCreateContent(
    span: WidgetSpan,
    model: QuickCreateWidgetModel,
) {
    if (span.cols == 1 && span.rows == 1) {
        QuickCreateButton(
            text = "+",
            clickUri = WidgetDeepLinkFactory.createChooser(),
            compact = false,
        )
        return
    }

    if ((span.cols == 1 && span.rows == 2) || (span.cols == 2 && span.rows == 1)) {
        QuickCreateButton(
            text = model.newItemLabel,
            clickUri = WidgetDeepLinkFactory.createChooser(),
            compact = false,
        )
        return
    }

    if ((span.cols == 1 && span.rows == 3) || (span.cols == 3 && span.rows == 1)) {
        TrioButtons(model = model, compact = true)
        return
    }

    if ((span.cols == 1 && span.rows >= 4) || (span.rows == 1 && span.cols >= 4)) {
        Text(text = model.title, style = titleStyle(), maxLines = 1)
        Spacer(modifier = GlanceModifier.height(6.dp))
        TrioButtons(model = model, compact = true)
        return
    }

    if (span.cols == 2 && span.rows == 2) {
        QuadButtons(model = model)
        return
    }

    if (span.cols == 3 && span.rows == 2) {
        TrioButtons(model = model, compact = false)
        return
    }

    if (span.cols == 2 && span.rows == 3) {
        Text(text = model.title, style = titleStyle(), maxLines = 1)
        Spacer(modifier = GlanceModifier.height(6.dp))
        TrioButtons(model = model, compact = true)
        return
    }

    if (span.cols == 3 && span.rows == 3) {
        QuickCreateLine(icon = "日", text = model.scheduleLabel, clickUri = WidgetDeepLinkFactory.createSchedule())
        QuickCreateLine(icon = "任", text = model.taskLabel, clickUri = WidgetDeepLinkFactory.createTask())
        QuickCreateLine(icon = "备", text = model.memoLabel, clickUri = WidgetDeepLinkFactory.createMemo())
        return
    }

    Text(text = model.title, style = titleStyle(), maxLines = 1)
    Spacer(modifier = GlanceModifier.height(6.dp))
    TrioButtons(model = model, compact = false)
}

@Composable
private fun TrioButtons(model: QuickCreateWidgetModel, compact: Boolean) {
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        QuickCreateButton(
            text = model.scheduleLabel,
            clickUri = WidgetDeepLinkFactory.createSchedule(),
            compact = compact,
        )
        Spacer(modifier = GlanceModifier.width(4.dp))
        QuickCreateButton(
            text = model.taskLabel,
            clickUri = WidgetDeepLinkFactory.createTask(),
            compact = compact,
        )
        Spacer(modifier = GlanceModifier.width(4.dp))
        QuickCreateButton(
            text = model.memoLabel,
            clickUri = WidgetDeepLinkFactory.createMemo(),
            compact = compact,
        )
    }
}

@Composable
private fun QuadButtons(model: QuickCreateWidgetModel) {
    Column(modifier = GlanceModifier.fillMaxSize()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            QuickCreateButton(
                text = "+",
                clickUri = WidgetDeepLinkFactory.createChooser(),
                compact = false,
            )
            Spacer(modifier = GlanceModifier.width(4.dp))
            QuickCreateButton(
                text = model.scheduleLabel,
                clickUri = WidgetDeepLinkFactory.createSchedule(),
                compact = true,
            )
        }
        Spacer(modifier = GlanceModifier.height(4.dp))
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            QuickCreateButton(
                text = model.taskLabel,
                clickUri = WidgetDeepLinkFactory.createTask(),
                compact = true,
            )
            Spacer(modifier = GlanceModifier.width(4.dp))
            QuickCreateButton(
                text = model.memoLabel,
                clickUri = WidgetDeepLinkFactory.createMemo(),
                compact = true,
            )
        }
    }
}

@Composable
private fun QuickCreateLine(icon: String, text: String, clickUri: String) {
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        Box(
            modifier = GlanceModifier
                .width(22.dp)
                .background(ColorProvider(R.color.widget_badge_bg))
                .padding(vertical = 4.dp),
            contentAlignment = Alignment.Center,
        ) {
            Text(text = icon, style = bodyStrongStyle(), maxLines = 1)
        }
        Spacer(modifier = GlanceModifier.width(6.dp))
        QuickCreateButton(
            text = text,
            clickUri = clickUri,
            compact = false,
        )
    }
    Spacer(modifier = GlanceModifier.height(4.dp))
}

@Composable
private fun QuickCreateButton(
    text: String,
    clickUri: String,
    compact: Boolean,
    modifier: GlanceModifier = GlanceModifier,
) {
    val context = LocalContext.current
    val action = actionStartActivity(buildDeepLinkIntent(context, clickUri))
    Box(
        modifier = modifier
            .background(ColorProvider(R.color.widget_badge_bg))
            .clickable(action)
            .padding(horizontal = 6.dp, vertical = 6.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = text,
            style = TextStyle(
                color = ColorProvider(R.color.widget_badge_text),
                fontWeight = FontWeight.Medium,
                fontSize = if (compact) 11.sp else 12.sp,
                textAlign = TextAlign.Center,
            ),
            maxLines = 1,
        )
    }
}

@Composable
private fun AgendaRowsPanel(rows: List<AgendaListRowModel>, maxRows: Int) {
    if (rows.isEmpty()) {
        Text(text = "暂无事项", style = secondaryStyle(), maxLines = 1)
        return
    }
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        rows.take(maxRows).forEach { row ->
            Text(text = row.tag, style = tertiaryStyle(), maxLines = 1)
            Text(text = row.title, style = bodyStrongStyle(), maxLines = 1)
            if (row.meta.isNotBlank()) {
                Text(text = row.meta, style = bodyStyle(), maxLines = 1)
            }
            Spacer(modifier = GlanceModifier.height(4.dp))
        }
    }
}

@Composable
private fun WeekGridPanel(days: List<WeekDayWidgetModel>, perDayLines: Int) {
    if (days.isEmpty()) {
        Text(text = "暂无事项", style = secondaryStyle(), maxLines = 1)
        return
    }

    Row(modifier = GlanceModifier.fillMaxWidth()) {
        days.forEach { day ->
            Column(
                modifier = GlanceModifier
                    .padding(horizontal = 2.dp),
            ) {
                Text(text = day.weekdayLabel, style = tertiaryStyle(), maxLines = 1)
                Text(text = day.dateLabel, style = bodyStrongStyle(), maxLines = 1)
                Spacer(modifier = GlanceModifier.height(2.dp))
                day.items.take(perDayLines).forEach { line ->
                    Text(text = line, style = bodyStyle(), maxLines = 1)
                }
            }
        }
    }
}

private object WidgetDeepLinkFactory {
    fun ai(): String = "huajuan://app/ai?focusInput=1&source=widget"

    fun createChooser(): String = "huajuan://app/item-editor/flow?showTypePicker=1&source=widget"

    fun createSchedule(): String = "huajuan://app/item-editor/flow?presetType=schedule&source=widget"

    fun createTask(): String = "huajuan://app/item-editor/flow?presetType=task&source=widget"

    fun createMemo(): String = "huajuan://app/item-editor/flow?presetType=memo&source=widget"

    fun list(): String = "huajuan://app/list?source=widget"

    fun homeWeek(weekStartIso: String): String {
        return if (weekStartIso.isBlank()) {
            "huajuan://app/?source=widget"
        } else {
            "huajuan://app/?source=widget&weekStart=${Uri.encode(weekStartIso)}"
        }
    }
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
        fontSize = 14.sp,
    )
}

private fun bodyStrongStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Medium,
        fontSize = 12.sp,
    )
}

private fun bodyStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontSize = 11.sp,
    )
}

private fun secondaryStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_secondary),
        fontSize = 12.sp,
    )
}

private fun tertiaryStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_tertiary),
        fontSize = 10.sp,
    )
}
