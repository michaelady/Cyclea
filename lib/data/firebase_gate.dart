import 'package:cyclea/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseGate {
  const FirebaseGate._({required this.ready});

  final bool ready;

  static const disabled = FirebaseGate._(ready: false);

  static Future<FirebaseGate> tryInit() async {
    if (!DefaultFirebaseOptions.isConfigured) {
      return disabled;
    }
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      }
      return const FirebaseGate._(ready: true);
    } catch (error, stack) {
      debugPrint('Firebase init skipped: $error\n$stack');
      return disabled;
    }
  }
}
