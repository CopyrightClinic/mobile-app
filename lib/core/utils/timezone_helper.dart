import 'package:flutter_native_timezone_latest/flutter_native_timezone_latest.dart';

import '../constants/app_strings.dart';
import '../utils/logger/logger.dart';

class TimezoneHelper {
  static const String _fallbackTimezone = 'UTC';

  static Future<String> getUserTimezone() async {
    try {
      final String timezone = await FlutterNativeTimezoneLatest.getLocalTimezone();
      Log.i(TimezoneHelper, 'User timezone detected: $timezone');
      return timezone;
    } catch (e) {
      Log.e(TimezoneHelper, '${AppStrings.failedToGetTimezone}: $e');
      return _fallbackTimezone;
    }
  }
  static String get fallbackTimezone => _fallbackTimezone;
}
