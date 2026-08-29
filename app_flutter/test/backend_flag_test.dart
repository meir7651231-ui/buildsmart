// Guards the LIVE default of the backend master switch (`backend.dart`). The
// repository providers route to their `_firebase` impls only when
// [useFirebaseBackend] is true; this test pins that default to FALSE so the
// demo/`_local` path stays the shipped behaviour until the backend is
// explicitly enabled (Firestore deployed + Rules live + seeded).
//
// The test suite never calls `Firebase.initializeApp`, so `Firebase.apps` is
// empty here — exactly the condition that must keep the app on `_local`. With
// no `--dart-define=USE_FIREBASE_BACKEND` the compile-time flag is false too,
// so both factors of the AND are off. (A green run here is the permanent
// backstop against the live web blank-screen bug: Firebase initialised on web
// must NOT, by itself, flip the repos onto an empty deny-all Firestore.)
import 'package:buildsmart/data/repositories/backend.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('useFirebaseBackend is OFF without Firebase — demo/_local is the default',
      () {
    // No dart-define in the test run → the compile-time flag is false.
    expect(kUseFirebaseBackendFlag, isFalse);
    // Firebase is not initialised in tests → the live switch stays off, so
    // every repository provider resolves to its `_local` impl.
    expect(useFirebaseBackend, isFalse);
  });

  // Studio Pillar 5 · step 51 — the dormant openers stay OFF/empty by default,
  // so the whole Phase-4 server path is compiler-inert until explicitly enabled.
  test('Studio server flags default OFF/empty (step 51 — byte-identical)', () {
    expect(kStudioLive, isFalse);
    expect(kCatalogServerSearch, isFalse);
    expect(kCatalogBaseUrl, isEmpty);
    // Compound getter ANDs with the backend switch (off in tests either way).
    expect(useCatalogServerSearch, isFalse);
  });
}
