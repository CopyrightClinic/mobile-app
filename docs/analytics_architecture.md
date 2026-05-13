# Analytics architecture

## Project fit

The app already uses **flutter_bloc**, **get_it**, **go_router**, **flutter_dotenv**, and **Firebase Core/Messaging**. Analytics extends `Config` and `di.init()` without changing navigation or domain contracts.

## Folder layout

```
lib/core/analytics/
  analytics.dart                 # Barrel exports for feature code
  application/
    analytics_initializer.dart   # ATT, Meta auto-log gating, TikTok init, bootstrap events
    analytics_manager.dart       # Single entry: track(AnalyticsEvent)
    analytics_install_gate.dart  # First-install dedupe via SharedPreferences
    analytics_debug_sink.dart    # Verbose logging in debug builds
  domain/
    analytics_event_type.dart
    analytics_event.dart         # Sealed event hierarchy (typed payloads)
    view_content_subject.dart
    registration_method.dart
    search_context.dart
    payloads/
  infrastructure/
    mapping/
      analytics_dispatch_mapper.dart  # One internal event → per-SDK lambdas
      analytics_currency_codec.dart
    providers/
      analytics_provider.dart         # Extension point for AppsFlyer, Branch, Adjust, backend
      firebase_analytics_provider.dart
      meta_analytics_provider.dart
      tiktok_analytics_provider.dart
```

New SDK: implement `AnalyticsProvider`, map inside `AnalyticsDispatchMapper` (or delegate to a dedicated mapper class), register the provider in `di.dart` only.

## Environment and secrets

| Surface | Mechanism |
| --- | --- |
| Dart / Flutter | `.env` via `flutter_dotenv`, `Config` getters, optional `--dart-define=DOTENV_FILENAME=.env.staging` |
| Android Meta | `android/app/build.gradle.kts` reads project-root `.env` and injects `resValue` strings consumed by `AndroidManifest` meta-data |
| iOS Meta | `ios/Flutter/Secrets.xcconfig` (gitignored). Copy from `ios/Flutter/Secrets.example.xcconfig` and fill `META_APP_ID`, `META_CLIENT_TOKEN`, TikTok iOS keys |

## Debugging and validation

### Firebase DebugView

1. Enable debug mode: Android `adb shell setprop debug.firebase.analytics.app <package>`; iOS add `-FIRAnalyticsDebugEnabled` launch argument in Xcode.
2. Open Firebase Console → Analytics → DebugView while the debug build runs.

### Meta Events Manager

Use Test Events in Meta Events Manager with the test device or app in development mode. Confirm delayed batching in production builds.

### TikTok Events Manager

Enable `TIKTOK_ANALYTICS_DEBUG` / verbose logs in `.env` for sandbox validation. Use TikTok’s test tools in Events Manager.

### Native logs

Filter Logcat for `FA`, `Facebook`, `TikTok` tags; Xcode console for the same SDK log tags.

## Production checklist

- [ ] `.env` populated for target environment; `APP_ENV` set to `production` for release pipelines.
- [ ] `ios/Flutter/Secrets.xcconfig` present on CI/macOS builders with real Meta and TikTok iOS values.
- [ ] Android release build reads `.env` (or CI-injected properties) so `facebook_app_id` is non-empty.
- [ ] Privacy policy and ATT copy aligned with actual data sent to Firebase, Meta, and TikTok.
- [ ] GDPR / consent: gate `setAnalyticsCollectionEnabled`, `setAutoLogAppEventsEnabled`, and TikTok `startTrack()` behind your legal consent module if required.
- [ ] Remove or scope `ANALYTICS_VERBOSE_DEBUG` in production.
- [ ] Revenue events use ISO 4217 currency and consistent `transactionId` (Stripe payment intent or server order id when available).

## Common mistakes

- Calling `FacebookAppEvents` or `FirebaseAnalytics` from widgets instead of `AnalyticsManager`.
- Mismatched currency and value on purchase events (Firebase enforces pairing on several APIs).
- Missing `JitPack` repository (TikTok Android native dependency resolution fails).
- iOS build without `Secrets.xcconfig` → empty `FacebookAppID` / URL scheme and Meta SDK instability.
- Duplicating install: only `AnalyticsInstallGate` should own first-install persistence.
