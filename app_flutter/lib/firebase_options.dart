// Firebase config for the BuildSmart app (project `buildsmart-b0b78`).
//
// Hand-authored from the per-platform config the owner registered in the
// Firebase console (the Web SDK config for S0.2; the native
// `google-services.json` / `GoogleService-Info.plist` the owner uploaded for
// F1) instead of `flutterfire configure`, which needs Firebase-CLI auth +
// network this sandbox does not have. Client config is PUBLIC (it ships in
// every app bundle); security is enforced by Firestore Security Rules (S5),
// App Check (F2) and Auth — not by keeping these values secret.
//
// F1 — the Android + iOS options below are READ VERBATIM from the two uploaded
// config files (kept byte-for-byte in sync with them):
//   • android ← `android/app/google-services.json`
//   • ios     ← `ios/Runner/GoogleService-Info.plist`
// so on a real device `Firebase.initializeApp` initialises with the RIGHT
// per-app keys instead of throwing. The native data backend stays gated by
// `kUseFirebaseBackendFlag` (default OFF) — F1 only brings the Firebase
// foundation alive; orders/customers/etc. keep serving local/demo data until
// the owner flips that flag.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for `Firebase.initializeApp`.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  // The Firebase *web* client key — public by design (it ships inside every
  // web bundle; security = Firestore Rules, S5). Named with the kApiKey
  // convention the repo's secret-gate (hook gate 52) lists as a known
  // false-positive, so the scanner doesn't mistake it for a server secret.
  static const String _kApiKeyWeb =
      'AIzaSyDA7iDvD23dhQR5WQu62tyNj2wgyewlzog';

  // The Android client key — read verbatim from
  // `android/app/google-services.json` (`client[0].api_key[0].current_key`).
  // Public by design, same as the web key (security = Rules + App Check).
  static const String _kApiKeyAndroid =
      'AIzaSyBSkrlVrWhHdm-2VasEwae3V6S9v7mrslg';

  // The iOS client key — read verbatim from
  // `ios/Runner/GoogleService-Info.plist` (`API_KEY`). Public by design.
  static const String _kApiKeyIos =
      'AIzaSyBMA9i3hvokMlZef3a5VJHaEtiMdJ5VUow';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        // No separate macOS app registered; the iOS bundle id / keys cover a
        // Mac-Catalyst / desktop run of the same app.
        return ios;
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for $defaultTargetPlatform '
          '— register that platform in the Firebase console (or run '
          '`flutterfire configure`) and add its options here.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _kApiKeyWeb,
    appId: '1:483064122180:web:d1f6bac271c87324ca6511',
    messagingSenderId: '483064122180',
    projectId: 'buildsmart-b0b78',
    authDomain: 'buildsmart-b0b78.firebaseapp.com',
    storageBucket: 'buildsmart-b0b78.firebasestorage.app',
    measurementId: 'G-98BWCNC8Q4',
  );

  // Read verbatim from `android/app/google-services.json`:
  //   apiKey            ← client[0].api_key[0].current_key
  //   appId             ← client[0].client_info.mobilesdk_app_id
  //   messagingSenderId ← project_info.project_number
  //   projectId         ← project_info.project_id
  //   storageBucket     ← project_info.storage_bucket
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _kApiKeyAndroid,
    appId: '1:483064122180:android:e9d240f3251e7a33ca6511',
    messagingSenderId: '483064122180',
    projectId: 'buildsmart-b0b78',
    storageBucket: 'buildsmart-b0b78.firebasestorage.app',
  );

  // Read verbatim from `ios/Runner/GoogleService-Info.plist`:
  //   apiKey            ← API_KEY
  //   appId             ← GOOGLE_APP_ID
  //   messagingSenderId ← GCM_SENDER_ID
  //   projectId         ← PROJECT_ID
  //   storageBucket     ← STORAGE_BUCKET
  //   iosBundleId       ← BUNDLE_ID
  // (No CLIENT_ID key in the plist → no iosClientId/androidClientId; Google
  // Sign-In would add one, but it isn't registered for this app.)
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _kApiKeyIos,
    appId: '1:483064122180:ios:89ac1613e3b695cfca6511',
    messagingSenderId: '483064122180',
    projectId: 'buildsmart-b0b78',
    storageBucket: 'buildsmart-b0b78.firebasestorage.app',
    iosBundleId: 'com.buildsmart.buildsmart',
  );
}
