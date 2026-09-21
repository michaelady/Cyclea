import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Firebase options for project **cyclea-db587** (web + Android).
///
/// Guest / local mode still works if initialization fails at runtime.
class DefaultFirebaseOptions {
  static bool get isConfigured => _configured(web) && _configured(android);

  static bool _configured(FirebaseOptions options) =>
      _looksReal(options.apiKey) &&
      _looksReal(options.appId) &&
      _looksReal(options.projectId);

  static bool _looksReal(String value) =>
      value.isNotEmpty && !value.contains('YOUR_') && value != 'unused';

  /// Web OAuth client (type 3) from the Android `google-services.json`.
  /// Used as `serverClientId` for Android Google Sign-In id tokens.
  static const String webClientId =
      '699763889491-fqjgp58darl1kg7pj096g9a15tpa30e9.apps.googleusercontent.com';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('Cyclea Phase 1 does not ship iOS Firebase options.');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS is not a Cyclea target.');
      case TargetPlatform.windows:
        throw UnsupportedError('Windows is not a Cyclea target.');
      case TargetPlatform.linux:
        throw UnsupportedError('Linux desktop is not a Cyclea target.');
      default:
        throw UnsupportedError('Unsupported platform for Firebase.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC_OGmFEcXzz0nw44mVHyQyc7l623rUF0E',
    appId: '1:699763889491:web:f33fe1db1ef79995af3da6',
    messagingSenderId: '699763889491',
    projectId: 'cyclea-db587',
    authDomain: 'cyclea-db587.firebaseapp.com',
    storageBucket: 'cyclea-db587.firebasestorage.app',
    measurementId: 'G-49XVLKL9RR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC8qXV5JTRpSE9mWAE6dc9zBTDPSkE5eY4',
    appId: '1:699763889491:android:5febfd34b8ffbae8af3da6',
    messagingSenderId: '699763889491',
    projectId: 'cyclea-db587',
    storageBucket: 'cyclea-db587.firebasestorage.app',
  );
}
