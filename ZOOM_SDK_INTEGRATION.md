# Zoom SDK Integration Guide

This document provides comprehensive instructions for integrating the Zoom Meeting SDK into the Copyright Clinic Flutter application for both Android and iOS platforms.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Android Integration](#android-integration)
4. [iOS Integration](#ios-integration)
5. [Flutter Implementation](#flutter-implementation)
6. [Troubleshooting](#troubleshooting)
7. [Important Notes](#important-notes)

---

## Overview

The Copyright Clinic app uses native Zoom Meeting SDK integration for video consultations between users and attorneys. The integration is implemented using platform channels to communicate between Flutter and native code.

### SDK Versions

- **Android**: Zoom Meeting SDK v6.5.10
- **iOS**: Zoom Meeting SDK v6.6.0

### Architecture

- **Method Channel**: `com.example.zoom` - For method calls (init, join, leave, etc.)
- **Event Channel**: `com.example.zoom/events` - For streaming meeting status updates
- **Native Bridges**: 
  - Android: `ZoomBridge.kt`
  - iOS: `ZoomBridge.swift`

---

## Prerequisites

Before integrating the Zoom SDK, ensure you have:

1. **Zoom Developer Account**: Sign up at [marketplace.zoom.us](https://marketplace.zoom.us)
2. **Zoom App Credentials**: Create a Meeting SDK app and obtain JWT credentials
3. **Minimum Platform Requirements**:
   - Android: API Level 29 (Android 10.0) or higher
   - iOS: iOS 13.0 or higher
4. **Development Environment**:
   - Flutter SDK 3.7.2+
   - Android Studio with NDK v27.0.12077973
   - Xcode 14.0+ (for iOS development)

---

## Android Integration

### Step 1: Update `build.gradle.kts` (App Level)

File: `android/app/build.gradle.kts`

```kotlin
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
        minSdk = 29  // Zoom SDK requires minimum API 29
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        
        ndk {
            abiFilters.add("arm64-v8a")
            // Optional: Uncomment for 32-bit support
            // abiFilters.add("armeabi-v7a")
        }
    }

    buildTypes {
        release {
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
    
    // Zoom Meeting SDK
    implementation("us.zoom.meetingsdk:zoomsdk:6.5.10")

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

**Important Notes**:
- `minSdk = 29`: Zoom SDK v6.5.10 requires minimum API level 29
- Compose libraries are downgraded to ensure compatibility with Zoom SDK
- Coil libraries are required for Zoom's waiting room UI
- `multiDexEnabled = true` is required due to method count limits

### Step 2: Create ZoomBridge.kt

File: `android/app/src/main/kotlin/com/brainx/copyrightclinic/ZoomBridge.kt`

The ZoomBridge.kt file is already implemented in the project. It handles:
- SDK initialization with JWT authentication
- Joining/leaving meetings
- Meeting state change events
- Error handling and status reporting

### Step 3: Update MainActivity.kt

File: `android/app/src/main/kotlin/com/brainx/copyrightclinic/MainActivity.kt`

Ensure the MainActivity extends `FlutterFragmentActivity` (required by Zoom SDK):

```kotlin
class MainActivity : FlutterFragmentActivity() {
    private val ZOOM_CHANNEL = "com.example.zoom"
    private val ZOOM_EVENT_CHANNEL = "com.example.zoom/events"
    private var zoomBridge: ZoomBridge? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val zoomMethodChannel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            ZOOM_CHANNEL
        )
        val zoomEventChannel = EventChannel(
            flutterEngine.dartExecutor.binaryMessenger, 
            ZOOM_EVENT_CHANNEL
        )

        zoomBridge = ZoomBridge(this, zoomMethodChannel, zoomEventChannel)

        zoomMethodChannel.setMethodCallHandler { call, result ->
            zoomBridge?.handleMethodCall(call, result)
        }
    }
}
```

### Step 4: Configure ProGuard Rules

File: `android/app/proguard-rules.pro`

Add the following rules to prevent ProGuard from obfuscating Zoom SDK classes:

```proguard
# Zoom SDK
-keep class us.zoom.** { *; }
-keep interface us.zoom.** { *; }
-dontwarn us.zoom.**
```

### Step 5: Update AndroidManifest.xml

File: `android/app/src/main/AndroidManifest.xml`

Add required permissions:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

---

## iOS Integration

### **CRITICAL: Large File Issue**

The iOS Zoom SDK contains large binary files that **cannot be pushed directly to Git** due to GitHub's file size limits (100MB). The SDK files are included in `.gitignore`:

```
ios/ZoomSDK/
```

### Step 1: Download Zoom iOS SDK

1. Visit [Zoom iOS SDK Download Page](https://developers.zoom.us/docs/meeting-sdk/ios/get-started/install/)
2. Download Zoom Meeting SDK for iOS v6.6.0
3. Extract the downloaded ZIP file

### Step 2: Manual SDK Installation

After cloning the repository, **EACH DEVELOPER MUST**:

1. Create the ZoomSDK directory:
   ```bash
   mkdir -p ios/ZoomSDK
   ```

2. Copy the following frameworks from the downloaded SDK to `ios/ZoomSDK/`:
   - `MobileRTC.xcframework`
   - `MobileRTCResources.bundle`
   - `MobileRTCScreenShare.xcframework`
   - `zoomcml.xcframework`

3. Your directory structure should look like:
   ```
   ios/
   ├── ZoomSDK/
   │   ├── MobileRTC.xcframework/
   │   ├── MobileRTCResources.bundle/
   │   ├── MobileRTCScreenShare.xcframework/
   │   └── zoomcml.xcframework/
   ├── Runner/
   └── ZoomBridge.swift
   ```

### Step 3: Link Frameworks in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the Runner project in the Project Navigator
3. Select the Runner target
4. Go to "General" tab
5. Under "Frameworks, Libraries, and Embedded Content":
   - Click the "+" button
   - Click "Add Other..." → "Add Files..."
   - Navigate to `ios/ZoomSDK/`
   - Select all four frameworks/bundles
   - Set "Embed" to "Embed & Sign" for all

### Step 4: Update Info.plist

File: `ios/Runner/Info.plist`

Add required permissions and configurations:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for video meetings</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for audio in meetings</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Photo library access for sharing images in meetings</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Bluetooth access for audio devices</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Bluetooth access for audio devices</string>
```

### Step 5: Update Podfile

File: `ios/Podfile`

Ensure minimum iOS version:

```ruby
platform :ios, '13.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

### Step 6: Create ZoomBridge.swift

File: `ios/ZoomBridge.swift`

The ZoomBridge.swift file is already implemented in the project. It handles:
- SDK initialization with JWT authentication
- Meeting service integration
- Meeting state change delegates
- Error handling and event streaming

### Step 7: Update AppDelegate.swift

File: `ios/Runner/AppDelegate.swift`

Initialize ZoomBridge in the AppDelegate:

```swift
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var zoomBridge: ZoomBridge?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController

        let zoomMethodChannel = FlutterMethodChannel(
            name: "com.example.zoom", 
            binaryMessenger: controller.binaryMessenger
        )
        let zoomEventChannel = FlutterEventChannel(
            name: "com.example.zoom/events", 
            binaryMessenger: controller.binaryMessenger
        )

        zoomBridge = ZoomBridge(
            methodChannel: zoomMethodChannel, 
            eventChannel: zoomEventChannel
        )

        zoomMethodChannel.setMethodCallHandler { 
            [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.zoomBridge?.handleMethodCall(call, result: result)
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### Step 8: Build Settings Configuration

In Xcode, configure the following build settings:

1. **Runner Target → Build Settings**:
   - Set "Enable Bitcode" to **NO**
   - Set "Always Embed Swift Standard Libraries" to **YES**
   - Add to "Other Linker Flags": `-ObjC`

2. **Build Phases**:
   - Ensure all Zoom frameworks are listed in "Embed Frameworks"
   - Ensure "Copy Bundle Resources" includes `MobileRTCResources.bundle`

---

## Flutter Implementation

### Zoom Feature Structure

```
lib/features/zoom/
├── data/
│   ├── datasources/
│   │   └── zoom_remote_data_source.dart
│   ├── models/
│   │   ├── zoom_meeting_credentials_model.dart
│   │   └── zoom_meeting_credentials_model.g.dart
│   └── repositories/
│       └── zoom_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── zoom_meeting_credentials_entity.dart
│   ├── repositories/
│   │   └── zoom_repository.dart
│   └── usecases/
│       └── get_meeting_credentials_usecase.dart
└── presentation/
    ├── bloc/
    │   ├── zoom_bloc.dart
    │   ├── zoom_event.dart
    │   └── zoom_state.dart
    └── widgets/
        └── zoom_connection_dialog.dart
```

### Platform Channel Setup

The platform channels are already configured in the Flutter code. Here's a reference:

```dart
class ZoomPlatform {
  static const MethodChannel _methodChannel = MethodChannel('com.example.zoom');
  static const EventChannel _eventChannel = EventChannel('com.example.zoom/events');

  // Initialize Zoom SDK
  Future<Map<String, dynamic>> initZoom(String jwt) async {
    final result = await _methodChannel.invokeMethod('initZoom', {
      'jwt': jwt,
    });
    return Map<String, dynamic>.from(result);
  }

  // Join meeting
  Future<Map<String, dynamic>> joinMeeting({
    required String meetingNumber,
    required String displayName,
    String? passcode,
  }) async {
    final result = await _methodChannel.invokeMethod('joinMeeting', {
      'meetingNumber': meetingNumber,
      'displayName': displayName,
      'passcode': passcode ?? '',
    });
    return Map<String, dynamic>.from(result);
  }

  // Leave meeting
  Future<Map<String, dynamic>> leaveMeeting() async {
    final result = await _methodChannel.invokeMethod('leaveMeeting');
    return Map<String, dynamic>.from(result);
  }

  // Listen to meeting events
  Stream<Map<String, dynamic>> get onMeetingStatus {
    return _eventChannel.receiveBroadcastStream().map(
      (event) => Map<String, dynamic>.from(event),
    );
  }
}
```

### JWT Token Generation

The app requires a JWT token to initialize the Zoom SDK. The token must be generated from your backend server using your Zoom SDK credentials.

**Backend Implementation Example (Node.js)**:

```javascript
const jwt = require('jsonwebtoken');

function generateZoomJWT(sdkKey, sdkSecret) {
  const iat = Math.floor(Date.now() / 1000);
  const exp = iat + (60 * 60 * 2); // Token expires in 2 hours
  
  const payload = {
    appKey: sdkKey,
    iat: iat,
    exp: exp,
    tokenExp: exp
  };
  
  return jwt.sign(payload, sdkSecret);
}
```

---

## Troubleshooting

### Android Issues

#### Issue: Build fails with "Duplicate class" error
**Solution**: Ensure you're using the correct Compose library versions as specified in the gradle file. Zoom SDK v6.5.10 has compatibility issues with newer Compose versions.

#### Issue: Meeting UI doesn't appear
**Solution**: 
1. Verify MainActivity extends `FlutterFragmentActivity`
2. Check that all permissions are granted at runtime
3. Ensure SDK is initialized before joining meeting

#### Issue: App crashes on joining meeting
**Solution**: 
1. Check ProGuard rules are correctly configured
2. Verify NDK is installed (v27.0.12077973)
3. Ensure `multiDexEnabled = true` in build.gradle

### iOS Issues

#### Issue: "ZoomSDK frameworks not found" build error
**Solution**: 
1. Verify you've manually copied all SDK frameworks to `ios/ZoomSDK/`
2. Check that frameworks are properly linked in Xcode
3. Ensure "Embed & Sign" is selected for all frameworks

#### Issue: App crashes immediately after joining meeting
**Solution**:
1. Verify all frameworks are set to "Embed & Sign" (not "Do Not Embed")
2. Check that "Always Embed Swift Standard Libraries" is set to YES
3. Ensure minimum deployment target is iOS 13.0

#### Issue: "Failed to initialize SDK" error
**Solution**:
1. Verify JWT token is valid and not expired
2. Check internet connectivity
3. Ensure domain is set to "zoom.us" in initialization

### Common Issues (Both Platforms)

#### Issue: "Invalid JWT token" error
**Solution**:
1. Verify your Zoom SDK credentials are correct
2. Check token generation logic on your backend
3. Ensure token hasn't expired (default: 2 hours)
4. Verify `appKey` in JWT payload matches your SDK Key

#### Issue: Meeting status events not received
**Solution**:
1. Verify EventChannel is properly set up
2. Check that listeners are registered before joining meeting
3. Ensure stream is being listened to in Flutter code

---

## Important Notes

### For New Developers

1. **iOS SDK Setup is Manual**: The iOS Zoom SDK files are NOT included in the repository. You MUST download and install them manually following the steps in the iOS Integration section.

2. **Git Ignore**: `ios/ZoomSDK/` is in `.gitignore`. Never try to commit these files to git.

3. **SDK Versions**: Always use the exact SDK versions specified in this document to ensure compatibility.

4. **Testing**: Test video calls on real devices. Zoom SDK may not work properly on simulators/emulators.

5. **Credentials**: Obtain your own Zoom SDK credentials from [marketplace.zoom.us](https://marketplace.zoom.us). Never commit credentials to the repository.

### Version Compatibility

| Component | Android Version | iOS Version |
|-----------|----------------|-------------|
| Zoom SDK | 6.5.10 | 6.6.0 |
| Min OS | Android 10 (API 29) | iOS 13.0 |
| Compile SDK | 35 | - |
| Target SDK | 35 | - |
| NDK | 27.0.12077973 | - |

### Additional Resources

- [Zoom Android SDK Documentation](https://developers.zoom.us/docs/meeting-sdk/android/)
- [Zoom iOS SDK Documentation](https://developers.zoom.us/docs/meeting-sdk/ios/)
- [Zoom SDK Sample Apps](https://github.com/zoom/meetingsdk-sample-android)
- [Zoom Developer Forum](https://devforum.zoom.us/)

---

## Setup Checklist

Use this checklist when setting up the project on a new machine:

### Android Setup
- [ ] Install Android Studio with NDK v27.0.12077973
- [ ] Verify `android/app/build.gradle.kts` has correct Zoom SDK dependency
- [ ] Verify MainActivity extends `FlutterFragmentActivity`
- [ ] Check ProGuard rules are configured
- [ ] Run `flutter pub get`
- [ ] Build and test on a physical device

### iOS Setup
- [ ] Install Xcode 14.0+
- [ ] Download Zoom iOS SDK v6.6.0 from Zoom's website
- [ ] Create `ios/ZoomSDK/` directory
- [ ] Copy all 4 frameworks/bundles to `ios/ZoomSDK/`
- [ ] Open `ios/Runner.xcworkspace` in Xcode
- [ ] Link all frameworks with "Embed & Sign"
- [ ] Verify Info.plist has required permissions
- [ ] Run `cd ios && pod install`
- [ ] Build and test on a physical device

### Flutter Setup
- [ ] Run `flutter pub get`
- [ ] Verify Zoom feature implementation in `lib/features/zoom/`
- [ ] Configure backend to generate JWT tokens
- [ ] Test initialization, join, and leave meeting flows
- [ ] Test meeting events and status updates

---

**Last Updated**: December 2025  
**Zoom SDK Versions**: Android 6.5.10, iOS 6.6.0  
**Maintained By**: Development Team

