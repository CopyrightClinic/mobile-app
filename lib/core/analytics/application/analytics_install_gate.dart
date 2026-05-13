import 'package:shared_preferences/shared_preferences.dart';

final class AnalyticsInstallGate {
  static const _key = 'analytics_install_event_sent_v1';

  Future<bool> consumeFirstInstallSlot() async {
    final prefs = await SharedPreferences.getInstance();
    final already = prefs.getBool(_key) ?? false;
    if (already) return false;
    await prefs.setBool(_key, true);
    return true;
  }
}
