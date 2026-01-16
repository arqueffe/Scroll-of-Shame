package com.scrollofshame.app

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent
import android.util.Log

class AppMonitorAccessibilityService : AccessibilityService() {
    
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) return
        
        if (event.eventType == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
            val packageName = event.packageName?.toString()
            if (packageName != null) {
                Log.d("AppMonitor", "Foreground app: $packageName")
                // The monitoring is handled by Flutter side via polling
            }
        }
    }

    override fun onInterrupt() {
        Log.d("AppMonitor", "Service interrupted")
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        Log.d("AppMonitor", "Accessibility service connected")
    }
}
