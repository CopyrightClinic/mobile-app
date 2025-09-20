import 'package:flutter/services.dart';

class SystemSpeech {
  static const MethodChannel _channel = MethodChannel('com.example.speech');

  static Future<String?> startSpeech({String? prompt, String? locale, int? maxSeconds}) async {
    try {
      final Map<String, dynamic> arguments = {};

      if (prompt != null) arguments['prompt'] = prompt;
      if (locale != null) arguments['locale'] = locale;
      if (maxSeconds != null) arguments['maxSeconds'] = maxSeconds;

      final result = await _channel.invokeMethod('startSpeech', arguments.isEmpty ? null : arguments);
      return result as String?;
    } on PlatformException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> stopSpeech() async {
    try {
      final result = await _channel.invokeMethod('stopSpeech');
      return result as String?;
    } on PlatformException catch (e) {
      return null;
    } catch (e) {
      return null;
    }
  }
}
