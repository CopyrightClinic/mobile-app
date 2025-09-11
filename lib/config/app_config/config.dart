import 'package:flutter/foundation.dart';

@immutable
class Config {
  const Config._();

  static const String merchantIdentifier = "merchant.com.copyrightclinic";
  static const String baseUrl = "https://copy-right-clinic-backend.brainxdemo.com/api/v1";

  static const String stripePublishableKey =
      "pk_test_51S3bqSGzkX8hKWt481JGZQ7T3ssDo9j8N36Y11F9CdvorpjIKBYLbtUEptxPmluRHURLyEecUxGGgFkokYuNtu4X00Q3osYq3B";
  static const String stripeSecretKey = "sk_test_51S3bqSGzkX8hKWt4AHeHlc3dFiIi1Scv2VtXR0i12lb5g4nmqQZjFRyoePdI1hLMhBvkWPKvMwVvsNKqlylwYUBf00mNKA6uMJ";
  static const double designScreenWidth = 375;
  static const double designScreenHeight = 812;
}
