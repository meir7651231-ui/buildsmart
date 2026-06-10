import 'package:firebase_core/firebase_core.dart' show Firebase;

/// Master switch for the LIVE Firebase backend. Repository providers route to
/// their `_firebase` impls only when this is true; otherwise everything stays
/// on the in-memory/demo `_local` path the app shipped with.
///
/// Default OFF: the live web build serves demo data even though S0 initialises
/// Firebase, until the backend is explicitly enabled (Firestore deployed +
/// Rules live + seeded). Flip on at build time:
///   flutter build web --dart-define=USE_FIREBASE_BACKEND=true
/// Tests never initialise Firebase, so they stay on `_local` regardless.
const bool kUseFirebaseBackendFlag =
    bool.fromEnvironment('USE_FIREBASE_BACKEND');

/// True only when the flag is set AND Firebase actually initialised.
bool get useFirebaseBackend =>
    kUseFirebaseBackendFlag && Firebase.apps.isNotEmpty;
