import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'dart:io' show Platform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (Platform.isAndroid) {
      return android;
    }
    if (Platform.isIOS) {
      return ios;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0ptLYL5PBcI0jA2FDf-IQEKKTqJC3dQQ',
    appId: '1:1029315845779:android:7b2a13a6b008a11b4e3766',
    messagingSenderId: '1029315845779',
    projectId: 'mealplanner-9999e',
    storageBucket: 'mealplanner-9999e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0ptLYL5PBcI0jA2FDf-IQEKKTqJC3dQQ',
    appId: '1:1029315845779:ios:PLACEHOLDER_IOS_APP_ID',
    messagingSenderId: '1029315845779',
    projectId: 'mealplanner-9999e',
    storageBucket: 'mealplanner-9999e.firebasestorage.app',
    iosBundleId: 'com.example.mealPlanner',
  );
}

