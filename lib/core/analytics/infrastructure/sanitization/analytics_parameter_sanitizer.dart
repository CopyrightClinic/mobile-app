final class AnalyticsParameterSanitizer {
  AnalyticsParameterSanitizer._();

  static const int maxEventNameLength = 40;
  static const int maxStringLength = 100;
  static const int maxTikTokStringLength = 1024;

  static String normalizeEventName(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return 'custom_event';
    final sanitized = trimmed.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
    final startsWithLetter = RegExp(r'^[a-z]').hasMatch(sanitized);
    final normalized = startsWithLetter ? sanitized : 'e_$sanitized';
    if (normalized.length <= maxEventNameLength) return normalized;
    return normalized.substring(0, maxEventNameLength);
  }

  static String? stringValue(Map<String, dynamic>? parameters, String key) {
    final value = parameters?[key];
    if (value == null) return null;
    final text = value.toString().trim();
    if (text.isEmpty) return null;
    return _clip(text, maxStringLength);
  }

  static double? doubleValue(Map<String, dynamic>? parameters, String key) {
    final value = parameters?[key];
    if (value == null) return null;
    if (value is num) {
      final parsed = value.toDouble();
      if (!parsed.isFinite) return null;
      return parsed;
    }
    final parsed = double.tryParse(value.toString());
    if (parsed == null || !parsed.isFinite) return null;
    return parsed;
  }

  static int? intValue(Map<String, dynamic>? parameters, String key) {
    final value = parameters?[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  static bool? boolValue(Map<String, dynamic>? parameters, String key) {
    final value = parameters?[key];
    if (value == null) return null;
    if (value is bool) return value;
    final text = value.toString().trim().toLowerCase();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  static Map<String, Object> forFirebase(Map<String, dynamic>? parameters) {
    if (parameters == null || parameters.isEmpty) return const {};
    final output = <String, Object>{};
    for (final entry in parameters.entries) {
      final key = _normalizeKey(entry.key);
      if (key.isEmpty) continue;
      final value = _firebaseValue(entry.value);
      if (value != null) output[key] = value;
    }
    return output;
  }

  static Map<String, dynamic> forMeta(Map<String, dynamic>? parameters) {
    if (parameters == null || parameters.isEmpty) return const {};
    final output = <String, dynamic>{};
    for (final entry in parameters.entries) {
      final key = _normalizeKey(entry.key);
      if (key.isEmpty) continue;
      final value = _metaValue(entry.value);
      if (value != null) output[key] = value;
    }
    return output;
  }

  static Map<String, dynamic> forTikTokCustom(Map<String, dynamic>? parameters) {
    if (parameters == null || parameters.isEmpty) return const {};
    final output = <String, dynamic>{};
    for (final entry in parameters.entries) {
      final key = _normalizeKey(entry.key);
      if (key.isEmpty) continue;
      final value = _tikTokValue(entry.value);
      if (value != null) output[key] = value;
    }
    return output;
  }

  static String clipForTikTok(String raw) {
    return _clip(raw.trim(), maxTikTokStringLength);
  }

  static String? clipNullableForTikTok(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    return _clip(trimmed, maxTikTokStringLength);
  }

  static double finiteDouble(double raw) {
    if (!raw.isFinite) return 0;
    return raw;
  }

  static Object? _firebaseValue(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      return _clip(trimmed, maxStringLength);
    }
    if (raw is bool) return raw ? 1 : 0;
    if (raw is int) return raw;
    if (raw is double) {
      if (!raw.isFinite) return null;
      return raw;
    }
    if (raw is num) {
      final parsed = raw.toDouble();
      if (!parsed.isFinite) return null;
      return parsed;
    }
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    return _clip(text, maxStringLength);
  }

  static Object? _metaValue(Object? raw) {
    if (raw == null) return null;
    if (raw is String) {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;
      return _clip(trimmed, maxStringLength);
    }
    if (raw is bool || raw is int || raw is double) {
      if (raw is double && !raw.isFinite) return null;
      return raw;
    }
    if (raw is num) {
      final parsed = raw.toDouble();
      if (!parsed.isFinite) return null;
      return parsed;
    }
    final text = raw.toString().trim();
    if (text.isEmpty) return null;
    return _clip(text, maxStringLength);
  }

  static Object? _tikTokValue(Object? raw) {
    return _metaValue(raw);
  }

  static String _normalizeKey(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return '';
    return trimmed.replaceAll(RegExp(r'[^a-z0-9_]'), '_');
  }

  static String _clip(String value, int maxLength) {
    if (value.length <= maxLength) return value;
    return value.substring(0, maxLength);
  }
}
