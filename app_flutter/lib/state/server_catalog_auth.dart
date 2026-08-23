// GO-LIVE (server catalog) — guest anonymous auth.
//
// The seeded catalog/inventory collections are read-gated on `isSignedIn()`
// (firestore.rules), but the app lets people browse as a GUEST (no login). So when
// `useServerCatalog` is on, a guest must be signed in ANONYMOUSLY for the server
// catalog to load. This is the pure decision behind that: sign in only when there is
// no user yet (never disturb a real logged-in session).
//
// The call site (main.dart bootstrap) is gated on `useServerCatalog` — a const-folding
// getter that is false in the demo build — so this whole path is dead-code / dormant
// today and only activates once the owner ships USE_FIREBASE_BACKEND + CATALOG_BASE_URL.

/// Ensure a guest is signed in (anonymously) so the server catalog can be read.
///
/// [hasUser] — is anyone signed in right now (real OR anonymous)? When true this is a
/// no-op: a real login must never be replaced by an anonymous session.
/// [signInAnon] — performs the anonymous sign-in (a thin `FirebaseAuth` call at the
/// real call site; a fake in tests).
Future<void> ensureAnonAuthForServerCatalog({
  required bool hasUser,
  required Future<void> Function() signInAnon,
}) async {
  if (hasUser) return;
  await signInAnon();
}
