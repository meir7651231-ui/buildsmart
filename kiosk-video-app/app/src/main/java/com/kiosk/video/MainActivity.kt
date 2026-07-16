package com.kiosk.video

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.runtime.DisposableEffect
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.ui.PlayerView

/**
 * Main kiosk activity.
 *
 * Responsibilities:
 *   1. Fullscreen immersive video via ExoPlayer, seamless loop.
 *   2. Start / pause playback based on ambient light sensor.
 *   3. Keep screen on (WindowManager flag + PlayerView.setKeepScreenOn).
 *   4. Enter Lock Task mode if we're the Device Owner (true kiosk).
 *   5. Triple-tap in top-left corner → PIN dialog → exit / settings.
 */
class MainActivity : ComponentActivity() {

    private lateinit var player: ExoPlayer
    private lateinit var lightSensor: LightSensorManager
    private lateinit var settings: SettingsStore

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Keep the screen on regardless of user interaction
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        // Turn on / dismiss keyguard so the app can show up right after boot
        window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED)
        window.addFlags(WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        window.addFlags(WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)

        settings = SettingsStore(applicationContext)

        // Prepare ExoPlayer with the bundled raw video, looping forever
        player = ExoPlayer.Builder(this).build().apply {
            val uri = "android.resource://${packageName}/${R.raw.video}".toUri()
            setMediaItem(MediaItem.fromUri(uri))
            repeatMode = Player.REPEAT_MODE_ALL
            playWhenReady = false   // sensor controls this
            prepare()
        }

        lightSensor = LightSensorManager(applicationContext)

        setContent {
            KioskScreen(
                player = player,
                lightSensor = lightSensor,
                settings = settings,
                onAdminExitRequested = { exitKiosk() }
            )
        }

        // Hide status bar + nav bar (immersive). MUST run after setContent:
        // before the decor view exists, window.insetsController throws an
        // NPE on some OEM builds (Samsung/MediaTek Android 13 — SM-X133).
        goFullscreen()
    }

    override fun onStart() {
        super.onStart()
        // Try to enter lock task if we are the Device Owner
        tryStartLockTask()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        // Re-enter immersive whenever the window regains focus
        if (hasFocus) goFullscreen()
    }

    override fun onResume() {
        super.onResume()
        goFullscreen()
    }

    override fun onDestroy() {
        try {
            stopLockTask()
        } catch (_: Throwable) { /* ok */ }
        player.release()
        super.onDestroy()
    }

    /**
     * Block Back button — the whole point of a kiosk is that the user
     * can't leave. Home/Recents are handled by CATEGORY_HOME + Lock Task.
     */
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() { /* swallow */ }

    // ---------- Lock Task ----------

    private fun tryStartLockTask() {
        val dpm = getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
        val admin = ComponentName(this, KioskDeviceAdminReceiver::class.java)

        // Whitelist ourselves when we are the Device Owner
        if (dpm.isDeviceOwnerApp(packageName)) {
            dpm.setLockTaskPackages(admin, arrayOf(packageName))
        }

        // Start lock task if allowed (Device Owner OR user-whitelisted).
        // If neither → this is a no-op and we simply run "loose kiosk"
        // (fullscreen but the system Home button will still work).
        try {
            if (dpm.isLockTaskPermitted(packageName)) {
                startLockTask()
            }
        } catch (_: Throwable) {
            // some OEMs throw if not permitted — safe to ignore
        }
    }

    private fun exitKiosk() {
        try {
            stopLockTask()
        } catch (_: Throwable) { /* ok */ }
        startActivity(Intent(this, SettingsActivity::class.java))
    }

    // ---------- Immersive fullscreen ----------

    private fun goFullscreen() {
        // Defensive try/catch: on some OEM builds the insets controller is
        // unavailable until the decor view exists. onResume and
        // onWindowFocusChanged re-run this, so skipping once is harmless.
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                window.setDecorFitsSystemWindows(false)
                window.insetsController?.let {
                    it.hide(WindowInsets.Type.systemBars())
                    it.systemBarsBehavior =
                        WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                }
            } else {
                @Suppress("DEPRECATION")
                window.decorView.systemUiVisibility = (
                    View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                    or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                    or View.SYSTEM_UI_FLAG_FULLSCREEN
                    or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                )
            }
        } catch (_: Throwable) { /* decor not ready yet — retried later */ }
    }
}

/**
 * Composable that renders the fullscreen video + admin gesture zone.
 */
@androidx.annotation.OptIn(androidx.media3.common.util.UnstableApi::class)
@Composable
private fun KioskScreen(
    player: ExoPlayer,
    lightSensor: LightSensorManager,
    settings: SettingsStore,
    onAdminExitRequested: () -> Unit
) {
    val context = LocalContext.current
    val lightThreshold by settings.lightThreshold.collectAsStateWithLifecycle(
        initialValue = SettingsStore.DEFAULT_LIGHT_THRESHOLD
    )
    val alwaysOn by settings.alwaysOn.collectAsStateWithLifecycle(initialValue = false)
    val savedPin by settings.adminPin.collectAsStateWithLifecycle(initialValue = SettingsStore.DEFAULT_PIN)

    // Subscribe to the sensor
    val isBrightEnough by lightSensor.isBrightEnough.collectAsState()

    // Push threshold into sensor whenever it changes
    LaunchedEffect(lightThreshold) { lightSensor.setThreshold(lightThreshold) }

    // Start/stop sensor with composition lifecycle
    DisposableEffect(Unit) {
        lightSensor.start()
        onDispose { lightSensor.stop() }
    }

    // Play <=> stop based on sensor (or always on)
    LaunchedEffect(isBrightEnough, alwaysOn) {
        if (alwaysOn || isBrightEnough) player.play() else player.pause()
    }

    // Admin gesture: 3 taps in the top-left 80dp corner → PIN prompt
    var taps by remember { mutableStateOf(0) }
    var lastTapTs by remember { mutableStateOf(0L) }
    var showPin by remember { mutableStateOf(false) }

    Box(modifier = Modifier.fillMaxSize().background(Color.Black)) {

        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { ctx ->
                // `also` (not `apply`): inside apply the implicit PlayerView
                // receiver shadows the outer `player` variable and the view
                // would silently self-assign null → permanent black screen.
                PlayerView(ctx).also { view ->
                    view.player = player
                    view.useController = false
                    view.keepScreenOn = true
                    view.resizeMode = androidx.media3.ui.AspectRatioFrameLayout.RESIZE_MODE_ZOOM
                    view.setShowBuffering(PlayerView.SHOW_BUFFERING_NEVER)
                }
            }
        )

        // Invisible tap zone in top-left corner (80x80 dp).
        // In RTL layouts this stays at top-left of the SCREEN because
        // we don't apply the auto-mirror modifier here.
        Box(
            modifier = Modifier
                .align(Alignment.TopStart)
                .size(80.dp)
                .pointerInput(Unit) {
                    detectTapGestures(onTap = {
                        val now = System.currentTimeMillis()
                        taps = if (now - lastTapTs < 800) taps + 1 else 1
                        lastTapTs = now
                        if (taps >= 3) {
                            taps = 0
                            showPin = true
                        }
                    })
                }
        )

        if (showPin) {
            PinDialog(
                expected = savedPin,
                onDismiss = { showPin = false },
                onSuccess = {
                    showPin = false
                    onAdminExitRequested()
                }
            )
        }
    }
}

private fun String.toUri(): android.net.Uri = android.net.Uri.parse(this)
