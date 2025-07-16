import java.util.Properties

plugins {
    id("com.android.application")
    id("com.google.gms.google-services") // Firebase
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // Flutter
}

// Load properties from local.properties
val localProperties = Properties().apply {
    val localPropertiesFile = rootProject.file("local.properties")
    if (localPropertiesFile.exists()) {
        localPropertiesFile.reader(Charsets.UTF_8).use { load(it) }
    }
}

// Read values with fallback
val minSdkVersion = localProperties.getProperty("flutter.minSdkVersion")?.toIntOrNull() ?: 21
val targetSdkVersion = localProperties.getProperty("flutter.targetSdkVersion")?.toIntOrNull() ?: 34
val versionCode = localProperties.getProperty("versionCode")?.toIntOrNull() ?: 1
val versionName = localProperties.getProperty("versionName") ?: "1.0"

android {
    namespace = "com.shegz.celebray"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.shegz.celebray"
        minSdk = minSdkVersion
        targetSdk = targetSdkVersion
        this.versionCode = versionCode
        this.versionName = versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
