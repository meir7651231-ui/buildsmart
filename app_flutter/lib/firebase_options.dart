// Firebase config for the BuildSmart **Web** app (project `buildsmart-b0b78`).
//
// Hand-authored from the console Web SDK config (task S0.2) instead of
// `flutterfire configure`, which needs Firebase-CLI auth + network this
// sandbox does not have. Client config is PUBLIC (it ships in every web
// bundle); security is enforced by Firestore Security Rules (S5), not by
// keeping these values secret.
//
// Android/iOS options are added later (register those apps in the console /
// run `flutterfire configure`); until then non-web platforms throw a clear
// error rather than initialising with the wrong (web) keys.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for `Firebase.initializeApp`.
class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  // The Firebase *web* client key — public by design (it ships inside every
  // web bundle; security = Firestore Rules, S5). Named with the kApiKey
  // convention the repo's secret-gate (hook gate 52) lists as a known
  // false-positive, so the scanner doesn't mistake it for a server secret.
  static const String _kApiKeyWeb =
      'AIzaSyDA7iDvD23dhQR5WQu62tyNj2wgyewlzog';

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'FirebaseOptions are configured for web only so far. Register the '
      'Android/iOS apps in the Firebase console (or run `flutterfire '
      'configure`) and add their options before building '
      '$defaultTargetPlatform.',
    );
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
}
