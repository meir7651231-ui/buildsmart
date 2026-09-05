package com.kiosk.video

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.floatPreferencesKey
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "kiosk_settings")

/**
 * Persistent settings.
 *
 * All fields have safe defaults so the app works out of the box.
 */
class SettingsStore(private val context: Context) {

    private val KEY_LIGHT_THRESHOLD = floatPreferencesKey("light_threshold")
    private val KEY_PIN            = stringPreferencesKey("admin_pin")
    private val KEY_ALWAYS_ON      = booleanPreferencesKey("always_on") // ignore light sensor

    val lightThreshold: Flow<Float> = context.dataStore.data.map {
        it[KEY_LIGHT_THRESHOLD] ?: DEFAULT_LIGHT_THRESHOLD
    }

    val adminPin: Flow<String> = context.dataStore.data.map {
        it[KEY_PIN] ?: DEFAULT_PIN
    }

    val alwaysOn: Flow<Boolean> = context.dataStore.data.map {
        it[KEY_ALWAYS_ON] ?: false
    }

    suspend fun setLightThreshold(v: Float) {
        context.dataStore.edit { it[KEY_LIGHT_THRESHOLD] = v.coerceIn(1f, 10_000f) }
    }
    suspend fun setPin(pin: String) {
        context.dataStore.edit { it[KEY_PIN] = pin }
    }
    suspend fun setAlwaysOn(on: Boolean) {
        context.dataStore.edit { it[KEY_ALWAYS_ON] = on }
    }

    companion object {
        const val DEFAULT_LIGHT_THRESHOLD = 120f  // lux
        const val DEFAULT_PIN = "0000" // ⚠️ PIN ברירת-מחדל הוחלף בחילוץ — המקורי נחשף בהיסטוריה; להגדיר PIN חדש לפני פריסה
    }
}
