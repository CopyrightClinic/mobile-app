import 'package:flutter/material.dart';
import '../../../constants/app_strings.dart';
import '../../../constants/image_constants.dart';
import '../../../../config/theme/app_theme.dart';

enum CardBrand {
  visa,
  mastercard,
  amex,
  discover,
  unknown;

  static CardBrand fromString(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return CardBrand.visa;
      case 'mastercard':
        return CardBrand.mastercard;
      case 'amex':
      case 'american express':
        return CardBrand.amex;
      case 'discover':
        return CardBrand.discover;
      default:
        return CardBrand.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case CardBrand.visa:
        return AppStrings.visa;
      case CardBrand.mastercard:
        return AppStrings.mastercard;
      case CardBrand.amex:
        return AppStrings.amex;
      case CardBrand.discover:
        return AppStrings.discover;
      case CardBrand.unknown:
        return 'Unknown';
    }
  }

  String? get imagePath {
    switch (this) {
      case CardBrand.visa:
        return ImageConstants.visa;
      case CardBrand.mastercard:
        return ImageConstants.mastercard;
      case CardBrand.amex:
      case CardBrand.discover:
      case CardBrand.unknown:
        return null;
    }
  }

  Color get brandColor {
    switch (this) {
      case CardBrand.visa:
        return AppTheme.primary;
      case CardBrand.mastercard:
        return AppTheme.red;
      case CardBrand.amex:
        return AppTheme.secondary;
      case CardBrand.discover:
        return AppTheme.orange;
      case CardBrand.unknown:
        return AppTheme.darkTextSecondary;
    }
  }

  String get abbreviatedText {
    switch (this) {
      case CardBrand.visa:
        return 'VISA';
      case CardBrand.mastercard:
        return 'MC';
      case CardBrand.amex:
        return 'AMEX';
      case CardBrand.discover:
        return 'DISC';
      case CardBrand.unknown:
        return 'CARD';
    }
  }
}
