package com.kiosk.video

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Launches the kiosk MainActivity right after the device boots.
 *
 * Because MainActivity is also registered with CATEGORY_HOME, once the
 * device sets us as the default launcher (via ADB / provisioning) the
 * system itself will bring us up on boot — this receiver is a safety
 * net for the "loose kiosk" case (not Device Owner).
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return
        if (action == Intent.ACTION_BOOT_COMPLETED
            || action == "android.intent.action.QUICKBOOT_POWERON"
            || action == "com.htc.intent.action.QUICKBOOT_POWERON"
        ) {
            val launch = Intent(context, MainActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
            }
            context.startActivity(launch)
        }
    }
}
