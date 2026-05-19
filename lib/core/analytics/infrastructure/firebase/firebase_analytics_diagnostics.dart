import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import '../../../../config/app_config/config.dart';

final class FirebaseAnalyticsDiagnostics {
  const FirebaseAnalyticsDiagnostics._();

  static const _androidPackage = 'com.cassius.copyrightclinic';

  static Future<void> logStartupState({
    required FirebaseAnalytics analytics,
    required bool collectionEnabled,
  }) async {
    if (kReleaseMode) return;
    debugPrint(
      '[analytics][firebase] collection_enabled=$collectionEnabled '
      '(ANALYTICS_FIREBASE_ENABLED=${Config.analyticsFirebaseEnabled})',
    );
    try {
      final appInstanceId = await analytics.appInstanceId;
      debugPrint(
        '[analytics][firebase] app_instance_id=${appInstanceId ?? 'null'}',
      );
    } catch (error) {
      debugPrint('[analytics][firebase] app_instance_id_error=$error');
    }
    _logDebugViewInstructions();
  }

  static void _logDebugViewInstructions() {
    if (Platform.isAndroid) {
      debugPrint(
        '[analytics][firebase] DebugView (Android): run before launching the app:\n'
        '  adb shell setprop debug.firebase.analytics.app $_androidPackage\n'
        'Disable with:\n'
        '  adb shell setprop debug.firebase.analytics.app .none.',
      );
    } else if (Platform.isIOS) {
      debugPrint(
        '[analytics][firebase] DebugView (iOS): add launch argument '
        '-FIRAnalyticsDebugEnabled in Xcode → Runner scheme → Run → Arguments.',
      );
    }
    debugPrint(
      '[analytics][firebase] Console: Firebase → Analytics → DebugView '
      '(near real-time). Standard dashboards: up to 24h delay.',
    );
  }
}
