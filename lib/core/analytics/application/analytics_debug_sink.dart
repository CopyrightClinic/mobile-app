import 'package:flutter/foundation.dart';

import '../domain/analytics_event.dart';
import '../infrastructure/mapping/analytics_dispatch_mapper.dart';
import '../../utils/logger/logger.dart';

final class AnalyticsDebugSink {
  AnalyticsDebugSink({required bool enabled}) : _enabled = enabled;

  final bool _enabled;

  bool get isEnabled => _enabled && kDebugMode;

  void onDispatch(AnalyticsEvent event, Object? error, StackTrace? stack) {
    if (!kReleaseMode && error != null) {
      debugPrint(
        '[analytics] dispatch_summary_failed type=${event.type} error=$error',
      );
      if (stack != null) {
        debugPrintStack(
          stackTrace: stack,
          label: '[analytics] dispatch_summary_failed stack',
        );
      }
    }
    if (!isEnabled) return;
    if (error != null) {
      Log.e(
        AnalyticsDebugSink,
        'analytics_failed type=${event.type} $error',
        stack,
      );
      return;
    }
    Log.d(
      AnalyticsDebugSink,
      'analytics_dispatch type=${event.type} mapped=${_describe(event)}',
    );
  }

  String _describe(AnalyticsEvent event) {
    final mapped = AnalyticsDispatchMapper.map(event);
    return 'firebase=${mapped.firebase != null} meta=${mapped.meta != null} tiktok=${mapped.tiktok != null}';
  }
}
