import java.util.Properties
import java.io.FileInputStream
import java.nio.charset.StandardCharsets

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

val dotenvProperties = Properties()
val dotenvFile = rootProject.projectDir.parentFile?.resolve(".env")
if (dotenvFile != null && dotenvFile.exists()) {
    dotenvFile.reader(StandardCharsets.UTF_8).use { dotenvProperties.load(it) }
}
fun envString(name: String): String = dotenvProperties.getProperty(name)?.trim()?.removeSurrounding("\"").orEmpty()

android {
    namespace = "com.cassius.copyrightclinic"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    defaultConfig {
        applicationId = "com.cassius.copyrightclinic"
        minSdk = 29
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        ndk {
            abiFilters.add("arm64-v8a")
            // abiFilters.add("armeabi-v7a")
        }

        val facebookAppId = envString("META_APP_ID")
        val facebookClientToken = envString("META_CLIENT_TOKEN")
        resValue("string", "facebook_app_id", facebookAppId)
        resValue("string", "facebook_client_token", facebookClientToken)
        resValue("string", "fb_login_protocol_scheme", "fb$facebookAppId")
        resValue("string", "facebook_app_name", "Copyright Clinic")
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
        release {
            signingConfig = if (keystorePropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    bundle {
        abi {
            enableSplit = true
        }
        language {
            enableSplit = false
        }
        density {
            enableSplit = true
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// Zoom SDK 6.5.10 is compiled against Compose foundation 1.6.x and calls
// HorizontalPager-xYaah8o (Dp/SnapFlingBehavior signature). foundation 1.7.0 renamed
// that method (HorizontalPager-oI3XNZo: TargetedFlingBehavior + SnapPosition), so any
// transitive bump to 1.7.x makes Zoom's video-effects screen die with NoSuchMethodError.
// Stripe 21.6.0 and lifecycle 2.10.0 need compose runtime >= 1.7 (Composer.startReplaceGroup),
// so only the foundation group is held back -- runtime/ui stay at their resolved versions.
configurations.all {
    resolutionStrategy {
        force(
            "androidx.compose.foundation:foundation:1.6.8",
            "androidx.compose.foundation:foundation-android:1.6.8",
            "androidx.compose.foundation:foundation-layout:1.6.8",
            "androidx.compose.foundation:foundation-layout-android:1.6.8"
        )
    }
}

dependencies {
    implementation("androidx.compose.foundation:foundation:1.6.8")
    // Material3 1.2.1 has the SheetState API Zoom SDK 6.5.10 was built against
    implementation("androidx.compose.material3:material3:1.2.1")
    
    // Coil image loading library (required by Zoom SDK for waiting room UI)
    implementation("io.coil-kt:coil-compose:2.5.0")
    implementation("io.coil-kt:coil-gif:2.5.0")
    
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.multidex:multidex:2.0.1")
    // Downgraded to 6.5.10 for better Compose compatibility
    implementation("us.zoom.meetingsdk:zoomsdk:6.5.10")
    implementation("com.github.tiktok:tiktok-business-android-sdk:1.5.0")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
}

flutter {
    source = "../.."
}
