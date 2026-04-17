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
import androidx.glance.LocalSize
import androidx.glance.background
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
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

class HuaJuanWeekListWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = HuaJuanWeekListWidget()
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
            CardShell(
                clickUri = "huajuan://app/ai?focusInput=1&source=widget",
            ) {
                Text(
                    text = payload.ai.title,
                    style = primaryTitleStyle(),
                    maxLines = 1,
                )
                Spacer(modifier = GlanceModifier.height(6.dp))
                Text(
                    text = payload.ai.subtitle,
                    style = secondaryStyle(),
                    maxLines = 2,
                )
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
            DpSize(240.dp, 72.dp),
            DpSize(156.dp, 156.dp),
            DpSize(240.dp, 156.dp),
            DpSize(156.dp, 240.dp),
            DpSize(240.dp, 240.dp),
            DpSize(324.dp, 240.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            CardShell(
                clickUri = "huajuan://app/item-editor?source=widget",
            ) {
                QuickCreateContent(span = span, model = payload.quickCreate)
            }
        }
    }
}

private class HuaJuanAgendaListWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(156.dp, 156.dp),
            DpSize(240.dp, 156.dp),
            DpSize(240.dp, 240.dp),
            DpSize(324.dp, 324.dp),
            DpSize(408.dp, 324.dp),
            DpSize(492.dp, 408.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            val maxLines = max(6, span.cols * span.rows * 2)
            CardShell(
                clickUri = "huajuan://app/list?source=widget",
            ) {
                Text(
                    text = payload.list.title,
                    style = primaryTitleStyle(),
                    maxLines = 1,
                )
                Text(
                    text = payload.list.subtitle,
                    style = tertiaryStyle(),
                    maxLines = 1,
                )
                Spacer(modifier = GlanceModifier.height(8.dp))
                DenseRows(rows = payload.list.rows, maxRows = maxLines)
            }
        }
    }
}

private class HuaJuanWeekListWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(156.dp, 156.dp),
            DpSize(240.dp, 156.dp),
            DpSize(240.dp, 240.dp),
            DpSize(324.dp, 324.dp),
            DpSize(408.dp, 324.dp),
            DpSize(492.dp, 408.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            val maxLines = max(8, span.cols * span.rows * 2)
            CardShell(
                clickUri = "huajuan://app/?source=widget",
            ) {
                Text(
                    text = payload.weekList.title,
                    style = primaryTitleStyle(),
                    maxLines = 1,
                )
                Text(
                    text = payload.weekList.subtitle,
                    style = tertiaryStyle(),
                    maxLines = 1,
                )
                Spacer(modifier = GlanceModifier.height(8.dp))
                DenseRows(rows = payload.weekList.rows, maxRows = maxLines)
            }
        }
    }
}

private class HuaJuanWeekGridWidget : GlanceAppWidget() {
    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(
            DpSize(156.dp, 156.dp),
            DpSize(240.dp, 156.dp),
            DpSize(240.dp, 240.dp),
            DpSize(324.dp, 324.dp),
            DpSize(408.dp, 324.dp),
            DpSize(492.dp, 408.dp),
        ),
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val payload = WidgetPayloadReader.read(context)
        provideContent {
            val span = resolveSpan(LocalSize.current)
            val maxRows = max(4, span.cols * span.rows)
            CardShell(
                clickUri = "huajuan://app/?source=widget",
            ) {
                Text(
                    text = payload.weekGrid.title,
                    style = primaryTitleStyle(),
                    maxLines = 1,
                )
                Text(
                    text = payload.weekGrid.subtitle,
                    style = tertiaryStyle(),
                    maxLines = 1,
                )
                Spacer(modifier = GlanceModifier.height(8.dp))
                WeekGridPanel(payload.weekGrid)
                Spacer(modifier = GlanceModifier.height(8.dp))
                DenseRows(rows = payload.weekGrid.rows, maxRows = maxRows)
            }
        }
    }
}

@Composable
private fun CardShell(
    clickUri: String,
    content: @Composable () -> Unit,
) {
    val context = androidx.glance.LocalContext.current
    val action = actionStartActivity(buildDeepLinkIntent(context, clickUri))
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .clickable(action)
            .padding(12.dp)
            .background(ColorProvider(R.color.widget_status_bg)),
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
        ) {
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
        Text(text = "+", style = iconTitleStyle(), maxLines = 1)
        return
    }

    if ((span.cols == 1 && span.rows == 2) || (span.cols == 2 && span.rows == 1)) {
        Text(text = model.newItemLabel, style = primaryTitleStyle(), maxLines = 1)
        return
    }

    if ((span.cols == 1 && span.rows == 3) || (span.cols == 3 && span.rows == 1)) {
        TrioRow(model = model, compact = true)
        return
    }

    if ((span.cols == 2 && span.rows == 2)) {
        QuadGrid(model = model)
        return
    }

    if (span.cols == 3 && span.rows == 2) {
        TrioRow(model = model, compact = false)
        return
    }

    if (span.cols == 2 && span.rows == 3) {
        Text(text = model.title, style = primaryTitleStyle(), maxLines = 1)
        Spacer(modifier = GlanceModifier.height(6.dp))
        TrioRow(model = model, compact = true)
        return
    }

    if (span.cols == 3 && span.rows == 3) {
        QuickCreateLine(icon = "日", text = model.scheduleLabel, uri = "huajuan://app/item-editor?presetType=schedule&source=widget")
        QuickCreateLine(icon = "任", text = model.taskLabel, uri = "huajuan://app/item-editor?presetType=task&source=widget")
        QuickCreateLine(icon = "备", text = model.memoLabel, uri = "huajuan://app/item-editor?presetType=memo&source=widget")
        return
    }

    if ((span.cols == 1 && span.rows >= 4) || (span.rows == 1 && span.cols >= 4)) {
        Text(text = model.title, style = primaryTitleStyle(), maxLines = 1)
        Spacer(modifier = GlanceModifier.height(6.dp))
        TrioRow(model = model, compact = true)
        return
    }

    Text(text = model.title, style = primaryTitleStyle(), maxLines = 1)
    Spacer(modifier = GlanceModifier.height(6.dp))
    TrioRow(model = model, compact = false)
}

@Composable
private fun WeekGridPanel(model: WeekGridWidgetModel) {
    if (model.headers.isNotEmpty()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            model.headers.take(7).forEach { header ->
                Text(
                    text = header,
                    modifier = GlanceModifier,
                    style = tertiaryStyle(),
                    maxLines = 1,
                )
            }
        }
        Spacer(modifier = GlanceModifier.height(4.dp))
    }

    if (model.cells.isNotEmpty()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            model.cells.take(7).forEach { cell ->
                Text(
                    text = cell,
                    modifier = GlanceModifier,
                    style = bodyStyle(),
                    maxLines = 2,
                )
            }
        }
    }
}

@Composable
private fun DenseRows(rows: List<String>, maxRows: Int) {
    if (rows.isEmpty()) {
        Text(
            text = "暂无数据",
            style = bodyStyle(),
            maxLines = 2,
        )
        return
    }
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        rows.take(maxRows).forEach { row ->
            Text(
                text = row,
                style = bodyStyle(),
                maxLines = 1,
            )
        }
    }
}

@Composable
private fun TrioRow(model: QuickCreateWidgetModel, compact: Boolean) {
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        QuickCreateButton(
            text = model.scheduleLabel,
            uri = "huajuan://app/item-editor?presetType=schedule&source=widget",
            modifier = GlanceModifier,
            compact = compact,
        )
        Spacer(modifier = GlanceModifier.width(4.dp))
        QuickCreateButton(
            text = model.taskLabel,
            uri = "huajuan://app/item-editor?presetType=task&source=widget",
            modifier = GlanceModifier,
            compact = compact,
        )
        Spacer(modifier = GlanceModifier.width(4.dp))
        QuickCreateButton(
            text = model.memoLabel,
            uri = "huajuan://app/item-editor?presetType=memo&source=widget",
            modifier = GlanceModifier,
            compact = compact,
        )
    }
}

@Composable
private fun QuadGrid(model: QuickCreateWidgetModel) {
    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            QuickCreateButton(
                text = "+",
                uri = "huajuan://app/item-editor?source=widget",
                modifier = GlanceModifier,
                compact = true,
            )
            Spacer(modifier = GlanceModifier.width(4.dp))
            QuickCreateButton(
                text = model.scheduleLabel,
                uri = "huajuan://app/item-editor?presetType=schedule&source=widget",
                modifier = GlanceModifier,
                compact = true,
            )
        }
        Spacer(modifier = GlanceModifier.height(4.dp))
        Row(modifier = GlanceModifier.fillMaxWidth()) {
            QuickCreateButton(
                text = model.taskLabel,
                uri = "huajuan://app/item-editor?presetType=task&source=widget",
                modifier = GlanceModifier,
                compact = true,
            )
            Spacer(modifier = GlanceModifier.width(4.dp))
            QuickCreateButton(
                text = model.memoLabel,
                uri = "huajuan://app/item-editor?presetType=memo&source=widget",
                modifier = GlanceModifier,
                compact = true,
            )
        }
    }
}

@Composable
private fun QuickCreateLine(icon: String, text: String, uri: String) {
    Row(modifier = GlanceModifier.fillMaxWidth()) {
        Text(text = icon, style = bodyStrongStyle(), maxLines = 1)
        Spacer(modifier = GlanceModifier.width(6.dp))
        QuickCreateButton(
            text = text,
            uri = uri,
            modifier = GlanceModifier,
            compact = false,
        )
    }
    Spacer(modifier = GlanceModifier.height(4.dp))
}

@Composable
private fun QuickCreateButton(
    text: String,
    uri: String,
    modifier: GlanceModifier,
    compact: Boolean,
) {
    val context = androidx.glance.LocalContext.current
    val action = actionStartActivity(buildDeepLinkIntent(context, uri))
    Box(
        modifier = modifier
            .background(ColorProvider(R.color.widget_badge_bg))
            .clickable(action)
            .padding(horizontal = 6.dp, vertical = 6.dp),
    ) {
        Text(
            text = text,
            style = TextStyle(
                color = ColorProvider(R.color.widget_badge_text),
                fontWeight = FontWeight.Medium,
                fontSize = if (compact) 11.sp else 12.sp,
            ),
            maxLines = 1,
        )
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

private fun primaryTitleStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Bold,
        fontSize = 14.sp,
    )
}

private fun iconTitleStyle(): TextStyle {
    return TextStyle(
        color = ColorProvider(R.color.widget_text_primary),
        fontWeight = FontWeight.Bold,
        fontSize = 28.sp,
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
