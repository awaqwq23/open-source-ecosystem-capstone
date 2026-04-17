package com.example.huajuan_agenda

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.huajuan_agenda.widget.WidgetStore
import com.example.huajuan_agenda.widget.WidgetUpdateDispatcher
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "huajuan/widget_sync",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncWidgets" -> {
                    val data = call.arguments as? Map<*, *>
                    if (data == null) {
                        result.error("invalid_args", "syncWidgets payload missing", null)
                        return@setMethodCallHandler
                    }
                    val json = JSONObject(data as Map<*, *>).toString()
                    WidgetStore.savePayload(applicationContext, json)
                    WidgetUpdateDispatcher.refreshAll(applicationContext)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
