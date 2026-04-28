import java.util.Properties
import org.jetbrains.kotlin.gradle.dsl.JvmTarget

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load signing properties if the key.properties file exists AND the keystore
// file it points to is actually present on disk. This allows the same project
// to be built on a developer machine with a real keystore (release-signed APK)
// and inside a Docker/CI container without the keystore (falls back to the
// debug signing config so the build still succeeds).
val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
var keystoreAvailable = false
if (keyPropertiesFile.exists()) {
    keyPropertiesFile.inputStream().use { keyProperties.load(it) }
    val storeFilePath = keyProperties.getProperty("storeFile")
    if (storeFilePath != null && file(storeFilePath).exists()) {
        keystoreAvailable = true
    } else {
        logger.warn("key.properties found but storeFile '$storeFilePath' is missing — falling back to debug signing.")
    }
}

android {
    namespace = "com.example.greffe_renale_mobile"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(JvmTarget.JVM_17)
        }
    }

    signingConfigs {
        if (keystoreAvailable) {
            create("release") {
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
                storeFile = file(keyProperties.getProperty("storeFile"))
                storePassword = keyProperties.getProperty("storePassword")
            }
        }
    }

    defaultConfig {
        applicationId = "com.example.greffe_renale_mobile"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = if (keystoreAvailable)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
