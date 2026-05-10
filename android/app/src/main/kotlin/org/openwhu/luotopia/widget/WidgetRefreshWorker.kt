package org.openwhu.luotopia.widget

import android.content.Context
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.Worker
import androidx.work.WorkerParameters
import java.util.concurrent.TimeUnit

class WidgetRefreshWorker(
    context: Context,
    params: WorkerParameters,
) : Worker(context, params) {
    override fun doWork(): Result {
        val snapshot = WidgetSnapshotReader.read(applicationContext)
        if (snapshot == null || !snapshot.settings.enabled) {
            WidgetRefreshScheduler.cancel(applicationContext)
            return Result.success()
        }
        WidgetUpdateDispatcher.refreshAll(applicationContext)
        return Result.success()
    }
}

object WidgetRefreshScheduler {
    private const val UNIQUE_WORK_NAME = "luotopia_widget_periodic_refresh"

    fun apply(context: Context) {
        val snapshot = WidgetSnapshotReader.read(context)
        if (snapshot == null || !snapshot.settings.enabled) {
            cancel(context)
            return
        }
        schedule(context, snapshotRefreshIntervalMinutes(snapshot.settings.refreshInterval))
    }

    fun cancel(context: Context) {
        WorkManager.getInstance(context).cancelUniqueWork(UNIQUE_WORK_NAME)
    }

    private fun schedule(context: Context, intervalMinutes: Long) {
        val request = PeriodicWorkRequestBuilder<WidgetRefreshWorker>(
            intervalMinutes.coerceAtLeast(30L),
            TimeUnit.MINUTES,
        ).build()
        WorkManager.getInstance(context).enqueueUniquePeriodicWork(
            UNIQUE_WORK_NAME,
            ExistingPeriodicWorkPolicy.UPDATE,
            request,
        )
    }
}
