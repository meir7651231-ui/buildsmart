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

/// A5 (launch uid-migration) — master switch for UID-SCOPED Firestore queries.
/// Default OFF: the orders listen stays the WHOLE-collection listen every
/// caller relies on today, so flipping this flag is the ONLY thing that changes
/// behaviour — with it OFF the build is BYTE-IDENTICAL to today (zero
/// regression, the A5 invariant). Flip on at build time once the rules +
/// indexes are deployed and existing docs are backfilled with storeUid/
/// courierUid:
///   flutter build web --dart-define=UID_SCOPED_QUERIES=true
/// When ON (and a uid + role are known) `ordersRepositoryProvider` scopes the
/// orders listen to what the Security Rules can prove per role:
///   • contractor → contractorUid == uid
///   • store      → the shared pool (storeUid=='' & a store-stage) ∪ own
///                  (storeUid == uid)
///   • courier    → analogous on courierUid
///   • manager/admin → no scope (the whole collection — the god view).
/// Tests never initialise Firebase, so the local path ignores this flag.
const bool kUidScopedQueries = bool.fromEnvironment('UID_SCOPED_QUERIES');
