import 'package:firebase_core/firebase_core.dart';

import 'firebase_manual_options.dart';

Future<FirebaseApp> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.app();
  }
  return Firebase.initializeApp(
    options: FirebaseManualOptions.currentPlatform,
  );
}
