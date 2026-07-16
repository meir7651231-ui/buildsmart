package com.kiosk.video

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.os.Process
import android.os.UserManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import kotlinx.coroutines.launch

/**
 * Hidden owner-only settings.
 *   - Light threshold (lux)
 *   - Always-on (bypass sensor)
 *   - Admin PIN
 *   - Return to kiosk
 *   - Uninstall / release Device Owner (advanced)
 */
class SettingsActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val settings = SettingsStore(applicationContext)

        setContent {
            MaterialTheme {
                SettingsScreen(
                    settings = settings,
                    onBackToKiosk = {
                        startActivity(Intent(this, MainActivity::class.java).apply {
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)
                        })
                        finish()
                    },
                    onReleaseDeviceOwner = { releaseDeviceOwner() }
                )
            }
        }
    }

    private fun releaseDeviceOwner() {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val admin = ComponentName(this, KioskDeviceAdminReceiver::class.java)
        try {
            if (dpm.isDeviceOwnerApp(packageName)) {
                for (r in arrayOf(
                    UserManager.DISALLOW_DEBUGGING_FEATURES,
                    UserManager.DISALLOW_USB_FILE_TRANSFER,
                    UserManager.DISALLOW_SAFE_BOOT,
                    UserManager.DISALLOW_ADD_USER
                )) {
                    try { dpm.clearUserRestriction(admin, r) } catch (_: Throwable) {}
                }
                dpm.clearDeviceOwnerApp(packageName)
            }
        } catch (_: Throwable) { /* nothing we can do */ }
        // Force-quit so the user sees a clean state
        Process.killProcess(Process.myPid())
    }
}

@OptIn(androidx.compose.material3.ExperimentalMaterial3Api::class)
@Composable
private fun SettingsScreen(
    settings: SettingsStore,
    onBackToKiosk: () -> Unit,
    onReleaseDeviceOwner: () -> Unit
) {
    val scope = rememberCoroutineScope()

    val currentThreshold by settings.lightThreshold
        .collectAsStateWithLifecycle(initialValue = SettingsStore.DEFAULT_LIGHT_THRESHOLD)
    val currentPin by settings.adminPin
        .collectAsStateWithLifecycle(initialValue = SettingsStore.DEFAULT_PIN)
    val currentAlwaysOn by settings.alwaysOn
        .collectAsStateWithLifecycle(initialValue = false)

    var thresholdField by remember { mutableStateOf(currentThreshold.toInt().toString()) }
    var pinField       by remember { mutableStateOf(currentPin) }
    var alwaysOn       by remember { mutableStateOf(currentAlwaysOn) }

    // Sync local state when DataStore emits (first collection).
    LaunchedEffect(currentThreshold) { thresholdField = currentThreshold.toInt().toString() }
    LaunchedEffect(currentPin)       { pinField = currentPin }
    LaunchedEffect(currentAlwaysOn)  { alwaysOn = currentAlwaysOn }

    Scaffold(
        topBar = { TopAppBar(title = { Text("הגדרות קיוסק") }) }
    ) { pad ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(pad)
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            Text("סף אור להפעלת הסרטון (lux)")
            OutlinedTextField(
                value = thresholdField,
                onValueChange = { thresholdField = it.filter { c -> c.isDigit() }.take(5) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )

            Text("קוד PIN לגישה למסך זה")
            OutlinedTextField(
                value = pinField,
                onValueChange = { pinField = it.take(32) },
                keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                singleLine = true,
                modifier = Modifier.fillMaxWidth()
            )

            androidx.compose.foundation.layout.Row(verticalAlignment = Alignment.CenterVertically) {
                Switch(checked = alwaysOn, onCheckedChange = { alwaysOn = it })
                Spacer(Modifier.height(0.dp))
                Text("  ניגון קבוע (התעלם מחיישן האור)")
            }

            Button(
                onClick = {
                    val t = thresholdField.toFloatOrNull()
                        ?: SettingsStore.DEFAULT_LIGHT_THRESHOLD
                    scope.launch {
                        settings.setLightThreshold(t)
                        settings.setPin(if (pinField.length >= 4) pinField else SettingsStore.DEFAULT_PIN)
                        settings.setAlwaysOn(alwaysOn)
                    }
                },
                modifier = Modifier.fillMaxWidth()
            ) { Text("שמור") }

            Spacer(Modifier.height(8.dp))

            Button(
                onClick = onBackToKiosk,
                modifier = Modifier.fillMaxWidth()
            ) { Text("חזרה לניגון") }

            Spacer(Modifier.height(24.dp))

            Text("מתקדם — לשימוש הבעלים בלבד:")
            Button(
                onClick = onReleaseDeviceOwner,
                modifier = Modifier.fillMaxWidth()
            ) { Text("שחרר Device Owner (יצירת פירוק סופי)") }
        }
    }
}
