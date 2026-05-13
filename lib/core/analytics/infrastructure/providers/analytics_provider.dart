import '../mapping/analytics_dispatch_mapper.dart';

abstract interface class AnalyticsProvider {
  String get id;

  bool get isEnabled;

  bool hasMappedWork(MappedAnalyticsWork work);

  Future<void> dispatch(MappedAnalyticsWork work);
}
