import java.util.Properties
import java.io.FileInputStream
plugins {
    id("com.android.application")
    id("kotlin-android")
    // F1 — apply the Google Services plugin so google-services.json is read and
    // the Firebase config is wired into the app at build time. Must come after
    // the Android & Kotlin plugins and before the Flutter Gradle plugin.
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) { keystoreProperties.load(FileInputStream(keystorePropertiesFile)) }
android {
    namespace = "com.buildsmart.buildsmart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    compileOptions { sourceCompatibility = JavaVersion.VERSION_11; targetCompatibility = JavaVersion.VERSION_11; isCoreLibraryDesugaringEnabled = true }
    kotlinOptions { jvmTarget = JavaVersion.VERSION_11.toString() }
    defaultConfig {
        applicationId = "com.buildsmart.buildsmart"
        // cloud_functions (+ modern Firebase plugins) require Android minSdk 23;
        // Flutter's default (21) fails processReleaseMainManifest at manifest merge.
        minSdk = 23
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                storeFile = file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
            }
        }
    }
    buildTypes {
        release { signingConfig = if (keystorePropertiesFile.exists()) signingConfigs.getByName("release") else signingConfigs.getByName("debug") }
    }
}
flutter { source = "../.." }

// F5 — flutter_local_notifications (Android notification channels) requires Java 8+
// core-library desugaring. AGP 8.9.1 supports desugar_jdk_libs 2.1.x.
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
