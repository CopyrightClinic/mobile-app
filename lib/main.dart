import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'app.dart';
import 'di.dart' as di;
import 'package:easy_localization/easy_localization.dart';
import 'package:device_preview/device_preview.dart';
import 'core/constants/language_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await di.init();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb ? HydratedStorageDirectory.web : HydratedStorageDirectory((await getTemporaryDirectory()).path),
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
