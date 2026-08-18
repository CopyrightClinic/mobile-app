abstract interface class AnalyticsPlatformService {
  bool get isEnabled;

  Future<void> logEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  });
}
