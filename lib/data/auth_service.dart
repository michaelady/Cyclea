import 'package:cyclea/data/firebase_gate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseNotConfiguredException implements Exception {
  const FirebaseNotConfiguredException();

  @override
  String toString() =>
      'Firebase is not configured on this build. Guest mode still works.';
}

class AuthUser {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });

  final String uid;
  final String? email;
  final String? displayName;

  factory AuthUser.fromFirebase(User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
  );
}

class AuthService {
  AuthService(
    this.gate, {
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? (gate.ready ? FirebaseAuth.instance : null),
       _googleSignIn =
           googleSignIn ??
           (kIsWeb || !gate.ready
               ? null
               : GoogleSignIn(scopes: const ['email']));

  AuthService._disabled()
    : gate = FirebaseGate.disabled,
      _auth = null,
      _googleSignIn = null;

  factory AuthService.disabled() => AuthService._disabled();

  final FirebaseGate gate;
  final FirebaseAuth? _auth;
  final GoogleSignIn? _googleSignIn;

  bool get firebaseReady => gate.ready;

  AuthUser? get currentUser {
    final user = _auth?.currentUser;
    return user == null ? null : AuthUser.fromFirebase(user);
  }

  Stream<AuthUser?> authStateChanges() {
    final auth = _auth;
    if (auth == null) return Stream<AuthUser?>.value(null);
    return auth.authStateChanges().map(
      (user) => user == null ? null : AuthUser.fromFirebase(user),
    );
  }

  Future<AuthUser?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw const FirebaseNotConfiguredException();
    }

    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});
      final credential = await auth.signInWithPopup(provider);
      final user = credential.user;
      return user == null ? null : AuthUser.fromFirebase(user);
    }

    final google = _googleSignIn ?? GoogleSignIn(scopes: const ['email']);
    final googleUser = await google.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await auth.signInWithCredential(credential);
    final user = result.user;
    return user == null ? null : AuthUser.fromFirebase(user);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // Google session may not exist in guest/web-popup flows.
    }
    await _auth?.signOut();
  }
}
