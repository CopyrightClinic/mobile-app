import 'package:firebase_core/firebase_core.dart';

import 'firebase_manual_options.dart';

Future<FirebaseApp> ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.app();
  }
  try {
    return await Firebase.initializeApp(
      options: FirebaseManualOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      return Firebase.app();
    }
    rethrow;
  }
}
