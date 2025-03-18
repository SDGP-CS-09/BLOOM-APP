import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';
import 'package:bloomiot/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('throws UnsupportedError for web platform', () {
      // Simulate web platform by using kIsWeb
      if (kIsWeb) {
        expect(() => DefaultFirebaseOptions.currentPlatform,
            throwsA(isA<UnsupportedError>()));
      }
    });

    test('returns correct FirebaseOptions for Android', () {
      // Simulate Android platform
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final options = DefaultFirebaseOptions.currentPlatform;

      // Check if the returned FirebaseOptions match the expected Android values
      expect(options.apiKey, 'AIzaSyCmphU4NwDnAjcyCLPglIM3ybNxXwjoZNY');
      expect(options.appId, '1:957472013508:android:7380486c849cc4e3015d91');
      expect(options.messagingSenderId, '957472013508');
      expect(options.projectId, 'bloomapp-f4a5b');
      expect(options.databaseURL,
          'https://bloomapp-f4a5b-default-rtdb.asia-southeast1.firebasedatabase.app');
      expect(options.storageBucket, 'bloomapp-f4a5b.firebasestorage.app');
    });

    test('returns correct FirebaseOptions for iOS', () {
      // Simulate iOS platform
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      final options = DefaultFirebaseOptions.currentPlatform;

      // Check if the returned FirebaseOptions match the expected iOS values
      expect(options.apiKey, 'AIzaSyDidR2gmTY2mSLgejhvmrJHMMBr_9vuXZk');
      expect(options.appId, '1:957472013508:ios:0b70a5e5a111d617015d91');
      expect(options.messagingSenderId, '957472013508');
      expect(options.projectId, 'bloomapp-f4a5b');
      expect(options.databaseURL,
          'https://bloomapp-f4a5b-default-rtdb.asia-southeast1.firebasedatabase.app');
      expect(options.storageBucket, 'bloomapp-f4a5b.firebasestorage.app');
      expect(options.iosBundleId, 'com.example.bloomiot');
    });

    test(
        'throws UnsupportedError for unsupported platforms (macOS, windows, linux)',
        () {
      // Test for macOS
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()));

      // Test for Windows
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()));

      // Test for Linux
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(() => DefaultFirebaseOptions.currentPlatform,
          throwsA(isA<UnsupportedError>()));
    });
  });
}
