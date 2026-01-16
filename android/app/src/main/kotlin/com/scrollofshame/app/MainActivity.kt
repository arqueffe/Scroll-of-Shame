package com.scrollofshame.app

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.scrollofshame.app/accessibility"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> {
                        result.success(hasUsageStatsPermission())
                    }
                    "requestPermission" -> {
                        requestUsageStatsPermission()
                        result.success(null)
                    }
                    "getCurrentApp" -> {
                        val packageName = getForegroundPackageName()
                        result.success(packageName)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun hasUsageStatsPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
            val mode = appOps.checkOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                android.os.Process.myUid(),
                packageName
            )
            return mode == AppOpsManager.MODE_ALLOWED
        }
        return false
    }

    private fun requestUsageStatsPermission() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        startActivity(intent)
    }

    private fun getForegroundPackageName(): String? {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE)
                as UsageStatsManager

            var packageName: String? = null

            // Try multiple time intervals for reliability
            val intervals = listOf(
                1000L,           // 1 second
                60000L,          // 1 minute
                3600000L,        // 1 hour
                43200000L        // 12 hours
            )

            for (interval in intervals) {
                val end = System.currentTimeMillis()
                val begin = end - interval

                val usageEvents = usageStatsManager.queryEvents(begin, end)
                val event = UsageEvents.Event()

                while (usageEvents.hasNextEvent()) {
                    usageEvents.getNextEvent(event)
                    if (event.eventType == UsageEvents.Event.MOVE_TO_FOREGROUND) {
                        packageName = event.packageName
                    }
                }

                // If we found a package, return it
                if (packageName != null) {
                    return packageName
                }
            }
        }
        return null
    }
}
