import 'package:flutter/foundation.dart';

import '../domain/analytics_events.dart';
import '../infrastructure/sanitization/analytics_parameter_sanitizer.dart';
import '../infrastructure/services/analytics_platform_service.dart';
import '../infrastructure/services/firebase_analytics_service.dart';
import '../infrastructure/services/meta_analytics_service.dart';
import '../infrastructure/services/tiktok_analytics_service.dart';
import 'analytics_install_gate.dart';

final class AnalyticsManager {
  AnalyticsManager({
    required FirebaseAnalyticsService firebase,
    required TikTokAnalyticsService tiktok,
    required MetaAnalyticsService meta,
    required AnalyticsInstallGate installGate,
  }) : _platforms = <AnalyticsPlatformService>[firebase, tiktok, meta],
       _installGate = installGate;

  final List<AnalyticsPlatformService> _platforms;
  final AnalyticsInstallGate _installGate;
  bool _installBootstrapScheduled = false;

  Future<void> bootstrapLifecycleSignals() async {
    if (_installBootstrapScheduled) {
      if (!kReleaseMode) {
        debugPrint(
          '[analytics] bootstrap_lifecycle skipped (already_scheduled)',
        );
      }
      return;
    }
    _installBootstrapScheduled = true;
    final shouldEmitInstall = await _installGate.consumeFirstInstallSlot();
    if (!kReleaseMode) {
      debugPrint(
        '[analytics] bootstrap_lifecycle first_install_event=$shouldEmitInstall',
      );
    }
    if (shouldEmitInstall) {
      await logEvent(AnalyticsEvents.appInstall);
    }
    await logEvent(
      AnalyticsEvents.appOpen,
      parameters: const <String, dynamic>{'from_background': false},
    );
  }

  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    final normalized = AnalyticsParameterSanitizer.normalizeEventName(eventName);
    if (!kReleaseMode) {
      debugPrint('[analytics] log_event name=$normalized');
    }
    for (final platform in _platforms) {
      if (!platform.isEnabled) {
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] log_event_skip name=$normalized platform=${platform.runtimeType}',
          );
        }
        continue;
      }
      try {
        await platform.logEvent(normalized, parameters: parameters);
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] log_event_ok name=$normalized platform=${platform.runtimeType}',
          );
        }
      } catch (error, stack) {
        if (!kReleaseMode) {
          debugPrint(
            '[analytics] log_event_error name=$normalized platform=${platform.runtimeType} error=$error',
          );
          debugPrintStack(
            stackTrace: stack,
            label: '[analytics] log_event_error',
          );
        }
      }
    }
  }
}
