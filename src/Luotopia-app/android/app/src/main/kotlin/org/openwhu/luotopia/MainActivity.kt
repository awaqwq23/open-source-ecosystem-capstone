package org.openwhu.luotopia

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.openwhu.luotopia.widget.WidgetRefreshScheduler
import org.openwhu.luotopia.widget.WidgetStore
import org.openwhu.luotopia.widget.WidgetUpdateDispatcher
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private lateinit var pluginPicker: PluginPackagePicker

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        pluginPicker = PluginPackagePicker(this)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "luotopia/plugin_import")
            .setMethodCallHandler { call, result ->
                if (call.method == "pick" && call.arguments == null) pluginPicker.pick(result)
                else result.notImplemented()
            }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "luotopia/widget_sync",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "syncWidgets" -> {
                    val data = call.arguments as? Map<*, *>
                    if (data == null) {
                        result.error("invalid_args", "syncWidgets payload missing", null)
                        return@setMethodCallHandler
                    }
                    val json = JSONObject(data as Map<*, *>)
                    val renderedPayload = json.optJSONObject("renderedPayload") ?: json
                    WidgetStore.savePayload(applicationContext, renderedPayload.toString())
                    json.optJSONObject("snapshot")?.let { snapshot ->
                        WidgetStore.saveSnapshot(applicationContext, snapshot.toString())
                    }
                    WidgetRefreshScheduler.apply(applicationContext)
                    WidgetUpdateDispatcher.refreshAll(applicationContext)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (::pluginPicker.isInitialized && pluginPicker.onActivityResult(requestCode, resultCode, data)) return
        super.onActivityResult(requestCode, resultCode, data)
    }

    override fun onDestroy() {
        if (::pluginPicker.isInitialized) pluginPicker.dispose()
        super.onDestroy()
    }
}
