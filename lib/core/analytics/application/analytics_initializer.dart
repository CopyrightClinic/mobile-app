import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:tiktok_events_sdk/tiktok_events_sdk.dart';

import '../../../config/app_config/config.dart';
import '../infrastructure/firebase/firebase_analytics_diagnostics.dart';
import 'analytics_manager.dart';

String _iso8601UtcWholeSecondsZulu(DateTime utc) {
  final u = utc.toUtc();
  final y = u.year.toString().padLeft(4, '0');
  final mo = u.month.toString().padLeft(2, '0');
  final d = u.day.toString().padLeft(2, '0');
  final h = u.hour.toString().padLeft(2, '0');
  final mi = u.minute.toString().padLeft(2, '0');
  final s = u.second.toString().padLeft(2, '0');
  return '$y-$mo-${d}T$h:$mi:${s}Z';
}

final class AnalyticsInitializer {
  AnalyticsInitializer({required AnalyticsManager manager, required FacebookAppEvents meta, required FirebaseAnalytics firebaseAnalytics})
    : _manager = manager,
      _meta = meta,
      _firebaseAnalytics = firebaseAnalytics;

  final AnalyticsManager _manager;
  final FacebookAppEvents _meta;
  final FirebaseAnalytics _firebaseAnalytics;

  Future<void> initialize() async {
    await _firebaseAnalytics.setAnalyticsCollectionEnabled(Config.analyticsFirebaseEnabled);
    await FirebaseAnalyticsDiagnostics.logStartupState(analytics: _firebaseAnalytics, collectionEnabled: Config.analyticsFirebaseEnabled);
    TrackingStatus iosAttStatus = TrackingStatus.notDetermined;
    final needsAtt = Platform.isIOS && (Config.analyticsMetaEnabled || Config.analyticsTikTokEnabled);
    if (needsAtt) {
      final initial = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (initial == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
      iosAttStatus = await AppTrackingTransparency.trackingAuthorizationStatus;
    } else if (Platform.isIOS) {
      iosAttStatus = TrackingStatus.denied;
    }
    if (Config.analyticsMetaEnabled) {
      await _meta.setAutoLogAppEventsEnabled(false);
      if (Platform.isIOS) {
        await _meta.setAdvertiserTracking(enabled: iosAttStatus == TrackingStatus.authorized);
      } else {
        await _meta.setAdvertiserTracking(enabled: true);
      }
      await _meta.setAutoLogAppEventsEnabled(Config.analyticsMetaAutoLoggingEnabled);
      if (!kReleaseMode) {
        debugPrint('[analytics] Meta App Events SDK configured (autoLog=${Config.analyticsMetaAutoLoggingEnabled})');
      }
    } else if (!kReleaseMode) {
      debugPrint('[analytics] Meta App Events SDK skipped (disabled in config)');
    }
    final tiktokIosReady = Platform.isIOS && Config.tikTokIosAppleAppStoreId.isNotEmpty && Config.tikTokIosTikTokAppId.isNotEmpty;
    final tiktokAndroidReady = Platform.isAndroid && Config.tikTokAndroidAppId.isNotEmpty && Config.tikTokAndroidSdkKey.isNotEmpty;
    if (Config.analyticsTikTokEnabled && (tiktokIosReady || tiktokAndroidReady)) {
      final consentStatus = Platform.isIOS ? (iosAttStatus == TrackingStatus.authorized ? 'granted' : 'denied') : 'granted';
      await TikTokEventsSdk.initSdk(
        androidAppId: "com.cassius.copyrightclinic",
        tikTokAndroidId: Config.tikTokAndroidAppId,
        iosAppId: 'com.cassius.copyrightclinic',
        tiktokIosId: Platform.isIOS ? Config.tikTokIosTikTokAppId : '',
        isDebugMode: Config.analyticsTikTokDebug,
        logLevel: Config.analyticsTikTokVerboseLogs ? TikTokLogLevel.debug : TikTokLogLevel.info,
        androidOptions: const TikTokAndroidOptions(
          disableAutoStart: false,
          disableAutoEvents: false,
          disableInstallLogging: false,
          disableLaunchLogging: false,
          disableRetentionLogging: false,
          disableAdvertiserIDCollection: false,
        ),
        iosOptions: TikTokIosOptions(
          accessToken: Config.tikTokIosAccessTokenForSdk.isEmpty ? null : Config.tikTokIosAccessTokenForSdk,
          disableAutomaticTracking: true,
          displayAtt: false,
          externalConsentTimestamp: _iso8601UtcWholeSecondsZulu(DateTime.now().toUtc()),
          externalConsentStatus: consentStatus,
        ),
      );
      await TikTokEventsSdk.startTrack();
      if (!kReleaseMode) {
        debugPrint('[analytics] TikTok Events SDK initialized and startTrack() completed');
      }
    } else if (!kReleaseMode) {
      debugPrint('[analytics] TikTok Events SDK skipped (disabled or platform credentials incomplete)');
    }
    if (!kReleaseMode) {
      debugPrint('[analytics] initializer calling bootstrapLifecycleSignals');
    }
    await _manager.bootstrapLifecycleSignals();
  }
}
