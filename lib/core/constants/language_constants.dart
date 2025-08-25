import 'package:flutter/material.dart';

enum SupportedLanguage {
  english('en', 'US', 'English');

  const SupportedLanguage(this.languageCode, this.countryCode, this.displayName);

  final String languageCode;
  final String countryCode;
  final String displayName;

  Locale get locale => Locale(languageCode, countryCode);

  String get fullCode => '${languageCode}_$countryCode';

  String get code => languageCode;

  String get country => countryCode;

  String get name => displayName;

  static List<Locale> get supportedLocales => SupportedLanguage.values.map((lang) => lang.locale).toList();

  static Locale get fallbackLocale => SupportedLanguage.english.locale;

  static SupportedLanguage? fromLocale(Locale locale) {
    try {
      return SupportedLanguage.values.firstWhere((lang) => lang.languageCode == locale.languageCode);
    } catch (e) {
      return null;
    }
  }

  static SupportedLanguage? fromCode(String languageCode) {
    try {
      return SupportedLanguage.values.firstWhere((lang) => lang.languageCode == languageCode);
    } catch (e) {
      return null;
    }
  }

  static bool isSupported(Locale locale) {
    return fromLocale(locale) != null;
  }

  @override
  String toString() => fullCode;
}

extension LocaleExtension on Locale {
  SupportedLanguage? get supportedLanguage => SupportedLanguage.fromLocale(this);

  bool get isSupported => SupportedLanguage.isSupported(this);
}
