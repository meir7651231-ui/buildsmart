package com.kiosk.video

import android.app.admin.DeviceAdminReceiver
import android.content.Context
import android.content.Intent

/**
 * Device Admin receiver. Once the package is promoted to Device Owner
 * (via ADB — see README), this receiver is what actually holds the
 * device-owner privileges, allowing MainActivity to whitelist itself
 * for Lock Task mode without asking the user each time.
 */
class KioskDeviceAdminReceiver : DeviceAdminReceiver() {

    override fun onEnabled(context: Context, intent: Intent) {
        super.onEnabled(context, intent)
    }
}
