plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.brainx.copyrightclinic"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }
    
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    defaultConfig {
        applicationId = "com.brainx.copyrightclinic"
        minSdk = 29
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        ndk {
            abiFilters.add("arm64-v8a")
            // abiFilters.add("armeabi-v7a")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
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

dependencies {
    // Downgraded Compose stack for Zoom SDK 6.5.10 video effects compatibility
    // Foundation 1.6.8 has compatible HorizontalPager API
    // Material3 1.2.1 has compatible SheetState API
    implementation("androidx.compose.runtime:runtime:1.6.8")
    implementation("androidx.compose.ui:ui:1.6.8")
    implementation("androidx.compose.foundation:foundation:1.6.8")
    implementation("androidx.compose.material3:material3:1.2.1")
    
    // Coil image loading library (required by Zoom SDK for waiting room UI)
    implementation("io.coil-kt:coil-compose:2.5.0")
    implementation("io.coil-kt:coil-gif:2.5.0")
    
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.multidex:multidex:2.0.1")
    // Downgraded to 6.5.10 for better Compose compatibility
    implementation("us.zoom.meetingsdk:zoomsdk:6.5.10")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    implementation(platform("com.google.firebase:firebase-bom:33.5.1"))
    implementation("com.google.firebase:firebase-messaging-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
}

flutter {
    source = "../.."
}
