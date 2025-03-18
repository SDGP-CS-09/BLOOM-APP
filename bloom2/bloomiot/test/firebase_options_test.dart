import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:bloomiot/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('returns correct FirebaseOptions for Android', () {
      // Simulating Android platform
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final options = DefaultFirebaseOptions.currentPlatform;

      expect(options.apiKey, 'AIzaSyCmphU4NwDnAjcyCLPglIM3ybNxXwjoZNY');
      expect(options.appId, '1:957472013508:android:7380486c849cc4e3015d91');
      expect(options.messagingSenderId, '957472013508');
      expect(options.projectId, 'bloomapp-f4a5b');
      expect(options.databaseURL,
          'https://bloomapp-f4a5b-default-rtdb.asia-southeast1.firebasedatabase.app');
      expect(options.storageBucket, 'bloomapp-f4a5b.firebasestorage.app');
    });

    test('returns correct FirebaseOptions for iOS', () {
      // Simulating iOS platform
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final options = DefaultFirebaseOptions.currentPlatform;

      expect(options.apiKey, 'AIzaSyDidR2gmTY2mSLgejhvmrJHMMBr_9vuXZk');
      expect(options.appId, '1:957472013508:ios:0b70a5e5a111d617015d91');
      expect(options.messagingSenderId, '957472013508');
      expect(options.projectId, 'bloomapp-f4a5b');
      expect(options.databaseURL,
          'https://bloomapp-f4a5b-default-rtdb.asia-southeast1.firebasedatabase.app');
      expect(options.storageBucket, 'bloomapp-f4a5b.firebasestorage.app');
      expect(options.iosBundleId, 'com.example.bloomiot');
    });

    test('throws UnsupportedError for unsupported platforms', () {
      // Simulating unsupported platforms
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()));

      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()));

      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()));
    });

    test('throws UnsupportedError for web platform', () {
      // Simulating Web platform
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()),
          skip: !kIsWeb);
    });
  });
}
