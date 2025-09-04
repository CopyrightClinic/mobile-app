import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';
import 'di.dart' as di;
import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview/device_preview.dart';
import 'core/constants/language_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.init();

  Stripe.publishableKey = const String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: 'pk_test_51S3XrHE3O1wM3Mv5LDXTzeM8ehEHvrwedIyQVJNEbcNjk46CdEPiwdpYgyrpI9a24Nn7PrlKd8SHoGuCzudPHFlL00A97Ix1CI',
  );
  await Stripe.instance.applySettings();

  HydratedBloc.storage = await HydratedStorage.build(storageDirectory: HydratedStorageDirectory((await getTemporaryDirectory()).path));
  runApp(
    DevicePreview(
      enabled: false,
      builder:
          (context) => EasyLocalization(
            supportedLocales: SupportedLanguage.supportedLocales,
            path: 'assets/translations',
            fallbackLocale: SupportedLanguage.fallbackLocale,
            child: const MyApp(),
          ),
    ),
  );
}
