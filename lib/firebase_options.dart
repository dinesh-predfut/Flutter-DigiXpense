// lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  /// Returns the correct FirebaseOptions for the current platform
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  /// Android configuration
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBdKmgqfV9dqNj84VAL6GqhXfMpqLneCt0',
    appId: '1:681028483669:android:28c51bfa3610b72fee32dc',
    messagingSenderId: '681028483669',
    projectId: 'test-4aca4',
    storageBucket: 'YOUR_STORAGE_BUCKET', 
  );

  /// iOS configuration
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_IOS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET', // optional
    iosBundleId: 'YOUR_IOS_BUNDLE_ID', // required for iOS
    androidClientId: 'YOUR_IOS_CLIENT_ID', // optional
    iosClientId: 'YOUR_IOS_CLIENT_ID', // optional
  );

  /// Web configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_WEB_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET', // optional
    authDomain: 'YOUR_PROJECT.firebaseapp.com', // required for web
    measurementId: 'YOUR_MEASUREMENT_ID', // optional
  );

  /// macOS configuration (optional)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR_MACOS_API_KEY',
    appId: 'YOUR_MACOS_APP_ID',
    messagingSenderId: 'YOUR_MACOS_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET', // optional
  );
}
