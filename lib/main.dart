import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'app.dart';
import 'di.dart' as di;
import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview/device_preview.dart';
import 'core/constants/language_constants.dart';
import 'config/app_config/config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait mode only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await EasyLocalization.ensureInitialized();
  await di.init();

  Stripe.publishableKey = Config.stripePublishableKey;
  Stripe.merchantIdentifier = Config.merchantIdentifier;
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
