import 'dart:async';

import '../../../di.dart';
import 'analytics_manager.dart';

void logAnalytics(
  String eventName, {
  Map<String, dynamic>? parameters,
}) {
  unawaited(
    sl<AnalyticsManager>().logEvent(eventName, parameters: parameters),
  );
}
