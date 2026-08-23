plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.kiosk.video"
    compileSdk = 34

    defaultConfig {
        applicationId = "com.kiosk.video"
        minSdk = 26           // Android 8.0 — Lock Task available from API 21, but we target modern
        targetSdk = 34        // Android 14
        versionCode = 1
        versionName = "1.0"
    }

    // Stable signing key (committed as base64; decoded by CI) so that every
    // build has the SAME signature and `adb install -r` upgrades work.
    // Falls back to the debug keystore for local Android Studio builds.
    signingConfigs {
        create("kiosk") {
            val ks = System.getenv("KIOSK_KEYSTORE")
            if (ks != null) {
                storeFile = file(ks)
                storePassword = "kioskvideo"
                keyAlias = "kiosk"
                keyPassword = "kioskvideo"
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = if (System.getenv("KIOSK_KEYSTORE") != null)
                signingConfigs.getByName("kiosk")
            else
                signingConfigs.getByName("debug")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
        // Do NOT compress the video (raw resource) — required for smooth playback
        jniLibs {
            useLegacyPackaging = false
        }
    }

    // Do not compress mp4 files inside APK so ExoPlayer can seek efficiently
    androidResources {
        noCompress += listOf("mp4", "m4v", "mkv", "webm")
    }

    lint {
        // Kiosk app, side-loaded — don't let non-critical lint block the build
        checkReleaseBuilds = false
        abortOnError = false
    }
}

dependencies {
    // Core Kotlin + Android
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")

    // Jetpack Compose
    val composeBom = platform("androidx.compose:compose-bom:2024.02.00")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.material3:material3")

    // Media3 ExoPlayer — modern replacement for old ExoPlayer
    implementation("androidx.media3:media3-exoplayer:1.2.1")
    implementation("androidx.media3:media3-ui:1.2.1")
    implementation("androidx.media3:media3-common:1.2.1")

    // DataStore (preferences for pin, threshold, etc.)
    implementation("androidx.datastore:datastore-preferences:1.0.0")
}
