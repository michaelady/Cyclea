import 'package:cyclea/firebase_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Cyclea Firebase web and Android options are project cyclea-db587', () {
    expect(DefaultFirebaseOptions.isConfigured, isTrue);
    expect(DefaultFirebaseOptions.web.projectId, 'cyclea-db587');
    expect(DefaultFirebaseOptions.android.projectId, 'cyclea-db587');
    expect(DefaultFirebaseOptions.web.authDomain, 'cyclea-db587.firebaseapp.com');
    expect(DefaultFirebaseOptions.web.appId, contains(':web:'));
    expect(DefaultFirebaseOptions.android.appId, contains(':android:'));
    expect(DefaultFirebaseOptions.android.apiKey, isNot(contains('YOUR_')));
    expect(DefaultFirebaseOptions.web.apiKey, isNot(contains('YOUR_')));
    expect(
      DefaultFirebaseOptions.webClientId,
      '699763889491-fqjgp58darl1kg7pj096g9a15tpa30e9.apps.googleusercontent.com',
    );
  });
}
