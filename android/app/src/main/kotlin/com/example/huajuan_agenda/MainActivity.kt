package com.example.huajuan_agenda

import android.os.Bundle
import android.os.SystemClock
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.example.huajuan_agenda.widget.WidgetStore
import com.example.huajuan_agenda.widget.WidgetUpdateDispatcher
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var startupElapsedRealtimeNanos: Long = 0L

    override fun onCreate(savedInstanceState: Bundle?) {
        startupElapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()
        super.onCreate(savedInstanceState)
    }

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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "huajuan/startup_timing",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getStartupTiming" -> {
                    result.success(
                        mapOf(
                            "androidStartElapsedRealtimeNanos" to startupElapsedRealtimeNanos,
                            "androidNowElapsedRealtimeNanos" to SystemClock.elapsedRealtimeNanos(),
                        ),
                    )
                }

                else -> result.notImplemented()
            }
        }
    }
}
