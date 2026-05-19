import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

final class FirebaseManualOptions {
  FirebaseManualOptions._();

  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) return android;
    if (Platform.isIOS) return ios;

    throw UnsupportedError(
      'Firebase options are not configured for ${Platform.operatingSystem}.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC-1b46Pk_VFRcrP4zQaMl0oTQuC4M7j3Q',
    appId: '1:782784944283:android:5e4a184f8510f03957ce3e',
    messagingSenderId: '782784944283',
    projectId: 'copyright-clinic-c9d36',
    storageBucket: 'copyright-clinic-c9d36.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYt2yl6rgIaguP7TV-fREJfexwOUQsOg4',
    appId: '1:782784944283:ios:79cfdcf5d1c30d3557ce3e',
    messagingSenderId: '782784944283',
    projectId: 'copyright-clinic-c9d36',
    storageBucket: 'copyright-clinic-c9d36.firebasestorage.app',
    iosBundleId: 'com.cassius.copyrightclinic',
  );
}
