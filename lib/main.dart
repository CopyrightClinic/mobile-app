import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app.dart';
import 'di.dart' as di;
import 'core/analytics/infrastructure/firebase/firebase_app_bootstrap.dart';
import 'core/services/local_notification_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview/device_preview.dart';
import 'core/constants/language_constants.dart';
import 'config/app_config/config.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await ensureFirebaseInitialized();

  // Messages carrying a `notification` block are rendered by the OS and cannot
  // hold action buttons. Data-only messages are rendered here instead, which is
  // what makes the Accept/Decline buttons available in background/terminated.
  if (message.notification != null) return;

  await LocalNotificationService().showNotification(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(
    fileName: const String.fromEnvironment(
      'DOTENV_FILENAME',
      defaultValue: '.env',
    ),
  );

  await ensureFirebaseInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  await EasyLocalization.ensureInitialized();
  await di.init();

  // Must run before the splash flow so an action/tap that launched the app from
  // a terminated state is picked up before navigation decisions are made.
  await LocalNotificationService().initialize();

  Stripe.publishableKey = Config.stripePublishableKey;
  Stripe.merchantIdentifier = Config.merchantIdentifier;
  await Stripe.instance.applySettings();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getTemporaryDirectory()).path,
    ),
  );
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
