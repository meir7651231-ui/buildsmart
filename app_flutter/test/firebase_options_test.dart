// F1 — native Firebase wiring (lib/firebase_options.dart).
//
// PROVED HERE (the F1 contract — Firebase initialises on a real device):
//   1. DefaultFirebaseOptions.currentPlatform returns the `android` options for
//      TargetPlatform.android and the `ios` options for TargetPlatform.iOS /
//      macOS — NO `UnsupportedError` thrown (the old web-only stub threw on
//      every non-web platform, so `Firebase.initializeApp` failed on device and
//      the app ran entirely on the local/demo path).
//   2. The web branch is UNCHANGED (kIsWeb is false in the test VM, so we pin
//      the const `web` options directly): same apiKey/appId/projectId as S0.2.
//   3. The android/ios FirebaseOptions match the two config files the owner
//      uploaded — read VERBATIM here from `android/app/google-services.json` and
//      `ios/Runner/GoogleService-Info.plist` so this test fails the moment
//      firebase_options.dart drifts from the real config (or vice-versa).
//   4. A genuinely-unsupported platform (linux/windows/fuchsia) still throws a
//      clear UnsupportedError.
//
// The selection is a pure getter driven by `defaultTargetPlatform`, so BOTH
// mobile platforms are asserted WITHOUT initialising Firebase (the suite never
// touches Firebase — same discipline as app_check_providers_test.dart /
// backend_flag_test.dart). We drive the platform with
// `debugDefaultTargetPlatformOverride` and always restore it in a finally.
//
// MUTATION-VERIFY: break the android projectId (or the android/ios branch of
// currentPlatform) → the matching expectation turns RED; restoring is GREEN.
import 'dart:convert';
import 'dart:io';

import 'package:buildsmart/firebase_options.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, debugDefaultTargetPlatformOverride;
import 'package:flutter_test/flutter_test.dart';

/// Run [body] as if the app were running on [platform], always restoring the
/// override afterwards (so one test can't leak its platform into the next).
T _asPlatform<T>(TargetPlatform platform, T Function() body) {
  final previous = debugDefaultTargetPlatformOverride;
  debugDefaultTargetPlatformOverride = platform;
  try {
    return body();
  } finally {
    debugDefaultTargetPlatformOverride = previous;
  }
}

void main() {
  // The single project the whole app is registered under (S0.2 web + F1 native).
  const projectId = 'buildsmart-b0b78';
  const senderId = '483064122180';
  const storageBucket = 'buildsmart-b0b78.firebasestorage.app';
  const bundleId = 'com.buildsmart.buildsmart';

  group('F1 — currentPlatform mapping (no UnsupportedError on mobile)', () {
    test('android → the android FirebaseOptions', () {
      final opts = _asPlatform(
        TargetPlatform.android,
        () => DefaultFirebaseOptions.currentPlatform,
      );
      expect(opts, same(DefaultFirebaseOptions.android));
      expect(opts.projectId, projectId);
    });

    test('iOS → the ios FirebaseOptions', () {
      final opts = _asPlatform(
        TargetPlatform.iOS,
        () => DefaultFirebaseOptions.currentPlatform,
      );
      expect(opts, same(DefaultFirebaseOptions.ios));
      expect(opts.projectId, projectId);
    });

    test('macOS → reuses the ios FirebaseOptions (no separate Mac app)', () {
      final opts = _asPlatform(
        TargetPlatform.macOS,
        () => DefaultFirebaseOptions.currentPlatform,
      );
      expect(opts, same(DefaultFirebaseOptions.ios));
    });

    test('a genuinely-unsupported platform still throws a clear error', () {
      for (final p in const [
        TargetPlatform.linux,
        TargetPlatform.windows,
        TargetPlatform.fuchsia,
      ]) {
        expect(
          () => _asPlatform(p, () => DefaultFirebaseOptions.currentPlatform),
          throwsA(isA<UnsupportedError>()),
          reason: '$p has no registered Firebase app',
        );
      }
    });
  });

  group('F1 — android options match android/app/google-services.json', () {
    // Read the file the owner uploaded so this test breaks if the Dart const
    // and the real config ever disagree (in either direction).
    final json = jsonDecode(
      File('android/app/google-services.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final projectInfo = json['project_info'] as Map<String, dynamic>;
    final client0 = (json['client'] as List).first as Map<String, dynamic>;
    final clientInfo = client0['client_info'] as Map<String, dynamic>;
    final apiKey0 = (client0['api_key'] as List).first as Map<String, dynamic>;

    const android = DefaultFirebaseOptions.android;

    test('apiKey ← client[0].api_key[0].current_key', () {
      expect(android.apiKey, apiKey0['current_key']);
    });
    test('appId ← client[0].client_info.mobilesdk_app_id', () {
      expect(android.appId, clientInfo['mobilesdk_app_id']);
      // The exact id the owner registered (belt-and-suspenders).
      expect(android.appId, '1:483064122180:android:e9d240f3251e7a33ca6511');
    });
    test('messagingSenderId ← project_info.project_number', () {
      expect(android.messagingSenderId, projectInfo['project_number']);
      expect(android.messagingSenderId, senderId);
    });
    test('projectId ← project_info.project_id', () {
      expect(android.projectId, projectInfo['project_id']);
      expect(android.projectId, projectId);
    });
    test('storageBucket ← project_info.storage_bucket', () {
      expect(android.storageBucket, projectInfo['storage_bucket']);
      expect(android.storageBucket, storageBucket);
    });
    test('the package_name in the json is the app id', () {
      final androidClientInfo =
          clientInfo['android_client_info'] as Map<String, dynamic>;
      expect(androidClientInfo['package_name'], bundleId);
    });
  });

  group('F1 — ios options match ios/Runner/GoogleService-Info.plist', () {
    // Tiny ad-hoc plist reader (avoids a new dependency): pull each <key>…</key>
    // followed by its <string>…</string> value. Good enough for this flat dict.
    final plistText =
        File('ios/Runner/GoogleService-Info.plist').readAsStringSync();
    String plist(String key) {
      final m = RegExp(
        '<key>${RegExp.escape(key)}</key>\\s*<string>(.*?)</string>',
        dotAll: true,
      ).firstMatch(plistText);
      expect(m, isNotNull, reason: 'plist key "$key" not found');
      return m!.group(1)!.trim();
    }

    const ios = DefaultFirebaseOptions.ios;

    test('apiKey ← API_KEY', () {
      expect(ios.apiKey, plist('API_KEY'));
    });
    test('appId ← GOOGLE_APP_ID', () {
      expect(ios.appId, plist('GOOGLE_APP_ID'));
      expect(ios.appId, '1:483064122180:ios:89ac1613e3b695cfca6511');
    });
    test('messagingSenderId ← GCM_SENDER_ID', () {
      expect(ios.messagingSenderId, plist('GCM_SENDER_ID'));
      expect(ios.messagingSenderId, senderId);
    });
    test('projectId ← PROJECT_ID', () {
      expect(ios.projectId, plist('PROJECT_ID'));
      expect(ios.projectId, projectId);
    });
    test('storageBucket ← STORAGE_BUCKET', () {
      expect(ios.storageBucket, plist('STORAGE_BUCKET'));
      expect(ios.storageBucket, storageBucket);
    });
    test('iosBundleId ← BUNDLE_ID', () {
      expect(ios.iosBundleId, plist('BUNDLE_ID'));
      expect(ios.iosBundleId, bundleId);
    });
  });

  group('F1 — web options UNCHANGED (S0.2, byte-identical)', () {
    test('web keeps the S0.2 web client config', () {
      const web = DefaultFirebaseOptions.web;
      expect(web.apiKey, 'AIzaSyDA7iDvD23dhQR5WQu62tyNj2wgyewlzog');
      expect(web.appId, '1:483064122180:web:d1f6bac271c87324ca6511');
      expect(web.messagingSenderId, senderId);
      expect(web.projectId, projectId);
      expect(web.authDomain, 'buildsmart-b0b78.firebaseapp.com');
      expect(web.storageBucket, storageBucket);
      expect(web.measurementId, 'G-98BWCNC8Q4');
    });

    test('all three platforms share one project (single Firebase backend)', () {
      expect(DefaultFirebaseOptions.web.projectId, projectId);
      expect(DefaultFirebaseOptions.android.projectId, projectId);
      expect(DefaultFirebaseOptions.ios.projectId, projectId);
      // ...but each carries its OWN appId (distinct per-platform registration).
      expect(
        {
          DefaultFirebaseOptions.web.appId,
          DefaultFirebaseOptions.android.appId,
          DefaultFirebaseOptions.ios.appId,
        }.length,
        3,
      );
    });
  });
}
