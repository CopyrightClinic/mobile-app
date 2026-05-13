import '../mapping/analytics_dispatch_mapper.dart';
import 'analytics_provider.dart';

final class TikTokAnalyticsProvider implements AnalyticsProvider {
  TikTokAnalyticsProvider({required bool enabled}) : _enabled = enabled;

  final bool _enabled;

  @override
  String get id => 'tiktok_events';

  @override
  bool get isEnabled => _enabled;

  @override
  bool hasMappedWork(MappedAnalyticsWork work) => work.tiktok != null;

  @override
  Future<void> dispatch(MappedAnalyticsWork work) async {
    if (!_enabled) return;
    final emit = work.tiktok;
    if (emit == null) return;
    await emit();
  }
}
