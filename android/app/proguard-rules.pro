# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Stripe SDK ProGuard rules
-keep class com.stripe.android.** { *; }
-keep interface com.stripe.android.** { *; }
-dontwarn com.stripe.android.**

# Stripe Push Provisioning specific rules
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep interface com.stripe.android.pushProvisioning.** { *; }
-dontwarn com.stripe.android.pushProvisioning.**

# Keep all React Native Stripe SDK classes
-keep class com.reactnativestripesdk.** { *; }
-keep interface com.reactnativestripesdk.** { *; }
-dontwarn com.reactnativestripesdk.**

# Additional Stripe related rules
-keep class com.stripe.android.model.** { *; }
-keep class com.stripe.android.view.** { *; }
-keep class com.stripe.android.core.** { *; }

# Keep all classes that might be referenced by Stripe
-keepclassmembers class * {
    @com.stripe.android.model.StripeJsonUtils$* *;
}

# Retrofit and OkHttp rules (used by Stripe)
-keepattributes Signature, InnerClasses, EnclosingMethod
-keepattributes RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement
-dontwarn javax.annotation.**
-dontwarn kotlin.Unit
-dontwarn retrofit2.KotlinExtensions
-dontwarn retrofit2.KotlinExtensions$*
-if interface * { @retrofit2.http.* <methods>; }
-keep,allowobfuscation interface <1>

# Gson rules (used by Stripe)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Google Play Core rules (ignore missing classes for deferred components)
-dontwarn com.google.android.play.core.**
-ignorewarnings

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.embedding.** { *; }
