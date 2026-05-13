import 'package:facebook_app_events/facebook_app_events.dart';

import '../mapping/analytics_dispatch_mapper.dart';
import 'analytics_provider.dart';

final class MetaAnalyticsProvider implements AnalyticsProvider {
  MetaAnalyticsProvider({
    required FacebookAppEvents appEvents,
    required bool enabled,
  }) : _appEvents = appEvents,
       _enabled = enabled;

  final FacebookAppEvents _appEvents;
  final bool _enabled;

  @override
  String get id => 'meta_app_events';

  @override
  bool get isEnabled => _enabled;

  @override
  bool hasMappedWork(MappedAnalyticsWork work) => work.meta != null;

  @override
  Future<void> dispatch(MappedAnalyticsWork work) async {
    if (!_enabled) return;
    final emit = work.meta;
    if (emit == null) return;
    await emit(_appEvents);
  }
}
