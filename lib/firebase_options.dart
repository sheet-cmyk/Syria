import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBL3JZzAqpQg8W4OzPwOqeuLt-UKzK9joA',
    appId: '1:1022310524811:android:ca7372cb81154fa630b18e',
    messagingSenderId: '1022310524811',
    projectId: 'syria2026',
    storageBucket: 'syria2026.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCpx-sVRlswYoEMz1X224iVmxJ4b0GxRMk',
    appId: '1:1022310524811:ios:da8ff73b0950544e30b18e',
    messagingSenderId: '1022310524811',
    projectId: 'syria2026',
    storageBucket: 'syria2026.firebasestorage.app',
    iosBundleId: 'com.hussein.syria',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDf6MYo4rB4fN2coCsbSYromCH0JEeeAas',
    appId: '1:1022310524811:web:ed18c6c5e8e02b5330b18e',
    messagingSenderId: '1022310524811',
    projectId: 'syria2026',
    authDomain: 'syria2026.firebaseapp.com',
    storageBucket: 'syria2026.firebasestorage.app',
  );
}
