import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@immutable
class Config {
  const Config._();

  static String get merchantIdentifier => dotenv.env['MERCHANT_IDENTIFIER'] ?? '';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? '';
  static String get haroldApiKey => dotenv.env['HAROLD_API_KEY'] ?? '';
  static String get stripePublishableKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get stripeSecretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';
  
  static const double designScreenWidth = 375;
  static const double designScreenHeight = 812;
}
