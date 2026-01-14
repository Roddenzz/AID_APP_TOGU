import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for this project.
///
/// Android values are taken from `google-services.json`.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
          'Firebase is not configured for web. Add web options to firebase_options.dart.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
        return desktop;
      // Add other platforms here when configs are available.
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not configured for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3QE7-I6e8PYiMDX6_JBitEnhl0piyuEc',
    appId: '1:512161913460:android:1fc61f1af8a37099434f21',
    messagingSenderId: '512161913460',
    projectId: 'profburo-255e8',
    storageBucket: 'profburo-255e8.firebasestorage.app',
  );

  /// Desktop builds reuse the Android configuration. Update when dedicated
  /// desktop Firebase config is available.
  static const FirebaseOptions desktop = FirebaseOptions(
    apiKey: 'AIzaSyB3QE7-I6e8PYiMDX6_JBitEnhl0piyuEc',
    appId: '1:512161913460:android:1fc61f1af8a37099434f21',
    messagingSenderId: '512161913460',
    projectId: 'profburo-255e8',
    storageBucket: 'profburo-255e8.firebasestorage.app',
  );
}
