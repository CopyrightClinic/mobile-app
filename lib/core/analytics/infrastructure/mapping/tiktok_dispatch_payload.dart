final class TikTokDispatchPayload {
  TikTokDispatchPayload._();

  static const int maxStringCodeUnits = 1024;

  static String clip(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return '';
    if (t.length <= maxStringCodeUnits) return t;
    return t.substring(0, maxStringCodeUnits);
  }

  static String? clipNullable(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    if (t.length <= maxStringCodeUnits) return t;
    return t.substring(0, maxStringCodeUnits);
  }

  static double finiteValue(double raw) {
    if (!raw.isFinite) return 0;
    return raw;
  }

  static Map<String, dynamic> stringAttributes(Map<String, String> attributes) {
    final out = <String, dynamic>{};
    for (final MapEntry(:key, :value) in attributes.entries) {
      final k = key.trim();
      if (k.isEmpty) continue;
      out[k] = clip(value);
    }
    return out;
  }
}
