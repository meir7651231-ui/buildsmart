package com.kiosk.video

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Wraps the ambient light sensor and exposes a debounced boolean:
 *   true  → current lux is >= threshold for at least DEBOUNCE_MS
 *   false → current lux is <  threshold for at least DEBOUNCE_MS
 *
 * The debounce prevents the video from stuttering when someone briefly
 * shadows the sensor with their hand.
 */
class LightSensorManager(context: Context) : SensorEventListener {

    private val sensorManager =
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    private val lightSensor: Sensor? =
        sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT)

    @Volatile private var threshold: Float = SettingsStore.DEFAULT_LIGHT_THRESHOLD

    /** Latest raw lux reading (informational; not debounced). */
    private val _lux = MutableStateFlow(0f)
    val lux: StateFlow<Float> = _lux.asStateFlow()

    /**
     * Debounced above/below-threshold state.
     * Fail-open: if the device has no light sensor at all, report "bright"
     * so the video still plays instead of a forever-black screen.
     */
    private val _isBrightEnough = MutableStateFlow(lightSensor == null)
    val isBrightEnough: StateFlow<Boolean> = _isBrightEnough.asStateFlow()

    private var pendingState: Boolean? = null
    private var pendingSinceMs: Long = 0
    private val DEBOUNCE_MS = 1500L    // 1.5 seconds

    fun start() {
        lightSensor?.let {
            sensorManager.registerListener(
                this,
                it,
                SensorManager.SENSOR_DELAY_NORMAL   // ~200 ms
            )
        }
    }

    fun stop() {
        sensorManager.unregisterListener(this)
    }

    fun setThreshold(t: Float) {
        threshold = t
    }

    override fun onSensorChanged(event: SensorEvent) {
        if (event.sensor.type != Sensor.TYPE_LIGHT) return
        val lux = event.values.firstOrNull() ?: return
        _lux.value = lux

        val desired = lux >= threshold
        val now = System.currentTimeMillis()

        if (desired == _isBrightEnough.value) {
            // already in the right state — reset any pending change
            pendingState = null
            return
        }
        if (pendingState != desired) {
            pendingState = desired
            pendingSinceMs = now
            return
        }
        if (now - pendingSinceMs >= DEBOUNCE_MS) {
            _isBrightEnough.value = desired
            pendingState = null
        }
    }

    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) { /* ignore */ }
}
