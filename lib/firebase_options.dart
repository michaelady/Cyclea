import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Template Firebase options. Replace placeholder values (or regenerate with
/// FlutterFire CLI) to enable Google Sign-In + Cloud Firestore sync.
///
/// Guest / local mode works without changing this file.
class DefaultFirebaseOptions {
  static bool get isConfigured {
    try {
      final options = currentPlatform;
      return _looksReal(options.apiKey) &&
          _looksReal(options.appId) &&
          _looksReal(options.projectId);
    } catch (_) {
      return false;
    }
  }

  static bool _looksReal(String value) =>
      value.isNotEmpty && !value.contains('YOUR_') && value != 'unused';

  static String? get webClientId {
    const id = 'YOUR_WEB_OAUTH_CLIENT_ID.apps.googleusercontent.com';
    return _looksReal(id) ? id : null;
  }

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
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  );
}
