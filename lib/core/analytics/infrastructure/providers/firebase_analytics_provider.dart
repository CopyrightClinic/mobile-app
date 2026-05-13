import 'package:firebase_analytics/firebase_analytics.dart';

import '../mapping/analytics_dispatch_mapper.dart';
import 'analytics_provider.dart';

final class FirebaseAnalyticsProvider implements AnalyticsProvider {
  FirebaseAnalyticsProvider({
    required FirebaseAnalytics analytics,
    required bool enabled,
  }) : _analytics = analytics,
       _enabled = enabled;

  final FirebaseAnalytics _analytics;
  final bool _enabled;

  @override
  String get id => 'firebase_analytics';

  @override
  bool get isEnabled => _enabled;

  @override
  bool hasMappedWork(MappedAnalyticsWork work) => work.firebase != null;

  @override
  Future<void> dispatch(MappedAnalyticsWork work) async {
    if (!_enabled) return;
    final emit = work.firebase;
    if (emit == null) return;
    await emit(_analytics);
  }
}
