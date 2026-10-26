import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.nurehub.qariverse"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.nurehub.qariverse"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

       signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Release artifacts must use the developer-owned upload key.
            signingConfig = signingConfigs.getByName("release")
        }
    }

    dependencies {
        "coreLibraryDesugaring"("com.android.tools:desugar_jdk_libs:2.1.5")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Fail with a useful message instead of a late signing NullPointerException.
gradle.taskGraph.whenReady {
    if (allTasks.any { it.name == "signReleaseBundle" || it.name == "validateSigningRelease" }) {
        val required = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")
        check(keystorePropertiesFile.exists() && required.all { !keystoreProperties.getProperty(it).isNullOrBlank() }) {
            "Release signing is not configured. Copy android/key.properties.example to android/key.properties and configure your upload keystore locally."
        }
    }
}
