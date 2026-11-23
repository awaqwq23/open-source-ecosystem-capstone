package org.openwhu.luotopia

import android.app.Activity
import android.content.Intent
import android.os.Handler
import android.os.Looper
import android.os.CancellationSignal
import android.provider.OpenableColumns
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicReference
import java.util.concurrent.atomic.AtomicBoolean

/** Read a user-selected package without trusting provider size or MIME suffixes. */
class PluginPackagePicker(private val activity: Activity) {
    private val handler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()
    private val stream = AtomicReference<InputStream?>(null)
    private val cancelled = AtomicBoolean(false)
    private val activeSignal = AtomicReference<CancellationSignal?>(null)
    private var pending: MethodChannel.Result? = null
    private var reading = false
    private var disposed = false
    private var quarantined = false

    fun pick(result: MethodChannel.Result) {
        if (quarantined) {
            result.error("IMPORT_TIMEOUT", "文件读取已超时，请重启应用后选择本地文件", null)
            return
        }
        if (disposed || pending != null || reading) {
            result.error("RESOURCE_LIMIT_EXCEEDED", "请等待上一次文件读取结束", null)
            return
        }
        pending = result
        try {
            activity.startActivityForResult(Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
                addCategory(Intent.CATEGORY_OPENABLE)
                type = "*/*"
                putExtra(Intent.EXTRA_LOCAL_ONLY, true)
                putExtra(Intent.EXTRA_MIME_TYPES, arrayOf("application/zip", "application/octet-stream"))
            }, REQUEST)
        } catch (_: Exception) {
            pending = null
            result.error("INVALID_PACKAGE", "无法打开文件选择器", null)
        }
    }

    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST || pending == null) return false
        val result = pending!!
        val uri = data?.data
        if (resultCode != Activity.RESULT_OK || uri == null) {
            pending = null
            result.success(null)
            return true
        }
        reading = true
        cancelled.set(false)
        val signal = CancellationSignal()
        activeSignal.set(signal)
        val timeout = Runnable {
            if (pending === result) {
                cancelled.set(true)
                // A provider may ignore cancellation. Keep at most one stalled
                // reader, rather than allocating another thread on every retry.
                quarantined = true
                pending = null
                result.error("IMPORT_TIMEOUT", "文件读取已超时，请重启应用后选择本地文件", null)
                cancelRead()
            }
        }
        handler.postDelayed(timeout, 15_000)
        executor.execute {
            var bytes: ByteArray? = null
            var code: String? = null
            try {
                val resolver = activity.contentResolver
                resolver.query(uri, arrayOf(OpenableColumns.SIZE), null, null, null, signal)?.use { cursor ->
                    if (cursor.moveToFirst() && !cursor.isNull(0) && cursor.getLong(0) > MAX_BYTES) {
                        throw PackageTooLarge()
                    }
                }
                if (cancelled.get()) throw IllegalStateException()
                resolver.openAssetFileDescriptor(uri, "r", signal).use { descriptor ->
                    val input = descriptor?.createInputStream() ?: throw IllegalArgumentException()
                    input.use {
                        stream.set(input)
                        val output = ByteArrayOutputStream()
                        val buffer = ByteArray(8192)
                        while (true) {
                            if (cancelled.get()) throw IllegalStateException()
                            val count = input.read(buffer)
                            if (count < 0) break
                            if (output.size() + count > MAX_BYTES) throw PackageTooLarge()
                            output.write(buffer, 0, count)
                        }
                        bytes = output.toByteArray()
                    }
                }
            } catch (_: PackageTooLarge) {
                code = "PACKAGE_LIMIT_EXCEEDED"
            } catch (_: Exception) {
                code = "INVALID_PACKAGE"
            } finally {
                stream.set(null)
                activeSignal.compareAndSet(signal, null)
                handler.post {
                    handler.removeCallbacks(timeout)
                    reading = false
                    if (pending === result) {
                        pending = null
                        val error = code
                        if (error == null) result.success(bytes)
                        else result.error(error, if (error == "PACKAGE_LIMIT_EXCEEDED") "插件包超过 5 MiB" else "无法读取插件文件", null)
                    }
                }
            }
        }
        return true
    }

    fun dispose() {
        disposed = true
        cancelled.set(true)
        pending?.error("IMPORT_CANCELLED", "文件选择已关闭", null)
        pending = null
        cancelRead()
        executor.shutdownNow()
    }

    private fun cancelRead() {
        val input = stream.getAndSet(null)
        val signal = activeSignal.getAndSet(null)
        if (input == null && signal == null) return
        Thread {
            try { signal?.cancel() } catch (_: Exception) {}
            try { input?.close() } catch (_: Exception) {}
        }.apply { isDaemon = true; start() }
    }

    private class PackageTooLarge : Exception()
    companion object {
        private const val REQUEST = 42107
        private const val MAX_BYTES = 5 * 1024 * 1024
    }
}
