import 'package:tiktok_events_sdk/tiktok_events_sdk.dart';

final class AnalyticsCurrencyCodec {
  const AnalyticsCurrencyCodec._();

  static String normalizeIso4217(String raw) {
    final trimmed = raw.trim().toUpperCase();
    if (trimmed.length == 3) return trimmed;
    return 'USD';
  }

  static CurrencyCode? toTikTokCurrency(String iso4217) {
    return CurrencyCode.fromString(normalizeIso4217(iso4217));
  }
}
