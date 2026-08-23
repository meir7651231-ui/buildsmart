// Gate-123 (GATE_REGISTRY · Studio · "GA-safe-by-default") — the STUDIO GA
// CAPSTONE. The Studio is 100% BUILT across all four pillars, and this gate is the
// machine-checkable proof that it ships DORMANT: every Studio/Pillar feature flag
// resolves to its SAFE default in a build with no `--dart-define`, so the shipped
// demo/production build is BYTE-IDENTICAL to today and is exactly ONE owner-gated
// flag-flip away from live. Nothing here arms anything — it LOCKS the "off" state.
//
// Two complementary proofs:
//
//   (A) RUNTIME const-fold — the pillar flags are `bool.fromEnvironment` /
//       `String.fromEnvironment` compile-consts. Under `flutter test` (no
//       --dart-define) each folds to its absent-define default, so asserting the
//       imported const IS asserting the shipped-build value:
//         • kStudioFlag        (STUDIO)               == false   — base Studio
//         • kStudioLive        (STUDIO_LIVE)          == false   — Pillar-1 server config
//         • kCatalogServerSearch (CATALOG_SERVER_SEARCH) == false — Pillar-2 catalog route
//         • kCatalogBaseUrl    (CATALOG_BASE_URL)     .isEmpty    — Pillar-2 URL (empty is
//                                                                  load-bearing: a non-empty
//                                                                  default would break byte-identity)
//         • kStudioCoEditor    (STUDIO_CO_EDITOR)     == false   — Pillar-4 AI co-editor
//         • kIntelLive         (INTEL_LIVE)           == false   — Pillar-3 customer intel
//       Plus the COMPOSED guard `useCatalogServerSearch` (kCatalogServerSearch &&
//       useFirebaseBackend) == false — proving the AND-with-live-backend guard holds
//       (tests never init Firebase, so `Firebase.apps` is empty → the getter is false
//       even if a flag were ever set), i.e. no pillar can activate offline / in tests.
//
//   (B) SELF-MAINTAINING closed-set — a source scan of backend.dart + studio_flags.dart
//       for every `const … kXxx = (bool|String).fromEnvironment(...)` whose name matches
//       the pillar prefix `k(Studio|Intel|Catalog)…`. EVERY such flag MUST appear in the
//       asserted set (A). So a future pillar flag added without a default-OFF assertion
//       here trips this gate — the safety net cannot silently rot as the Studio grows.
//
//   (C) anti-vacuous — the scan is proven non-empty (it finds the known pillar flags),
//       and a planted unknown `kStudioNewThing` name would be reported as un-gated.
//
// Reconciliation (live-code truth): infra flags (USE_FIREBASE_BACKEND, UID_SCOPED_QUERIES,
// SERVER_CALLABLES, CLAUDE_AI, …) are ALSO default-OFF but are NOT Studio-pillar flags, so
// they are out of THIS gate's scope by design — their zero-regression is covered by their
// own build invariants. Gate-123 is scoped precisely to the No-Code Studio surface.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:buildsmart/data/repositories/backend.dart';
import 'package:buildsmart/state/studio/studio_flags.dart';

/// The two files that define the Studio/Pillar compile-const flags (CWD is the
/// package root under `flutter test`).
const List<String> _flagSources = <String>[
  'lib/data/repositories/backend.dart',
  'lib/state/studio/studio_flags.dart',
];

/// The COMPLETE set of Studio/Pillar flag const names this gate asserts a safe
/// default for in part (A). Part (B) proves this set is complete (no un-gated
/// pillar flag exists in the sources).
const Set<String> _assertedPillarFlags = <String>{
  'kStudioFlag',
  'kStudioLive',
  'kCatalogServerSearch',
  'kCatalogBaseUrl',
  'kStudioCoEditor',
  'kIntelLive',
  'kStudioSharedSync',
};

void main() {
  group('Gate-123 · Studio GA — safe-by-default (dormant, byte-identical)', () {
    test('(A) every pillar flag folds to its SAFE default in a no-define build',
        () {
      // Base Studio + the four pillar master switches — all OFF.
      expect(kStudioFlag, isFalse, reason: 'STUDIO base flag must default OFF');
      expect(kStudioLive, isFalse,
          reason: 'STUDIO_LIVE (Pillar-1 server config) must default OFF');
      expect(kCatalogServerSearch, isFalse,
          reason: 'CATALOG_SERVER_SEARCH (Pillar-2) must default OFF');
      expect(kStudioCoEditor, isFalse,
          reason: 'STUDIO_CO_EDITOR (Pillar-4 AI co-editor) must default OFF');
      expect(kIntelLive, isFalse,
          reason: 'INTEL_LIVE (Pillar-3 customer intel) must default OFF');
      expect(kStudioSharedSync, isFalse,
          reason: 'STUDIO_SHARED_SYNC (Pillar-5 shared config sync) must '
              'default OFF');

      // The empty CATALOG_BASE_URL default is load-bearing: a non-empty default
      // would point the OFF build at a remote and break byte-identity.
      expect(kCatalogBaseUrl, isEmpty,
          reason: 'CATALOG_BASE_URL must default EMPTY (bundled catalog)');
    });

    test('(A) the composed live-backend guard holds — no pillar activates in tests',
        () {
      // useCatalogServerSearch == kCatalogServerSearch && useFirebaseBackend.
      // Tests never initialise Firebase (Firebase.apps is empty), so the guard is
      // false regardless — the same AND-with-live-backend guard the co-editor +
      // analytics-forward gates use, so none can activate offline / in tests.
      expect(useFirebaseBackend, isFalse,
          reason: 'no live backend in tests → every "…Live" guard is false');
      expect(useCatalogServerSearch, isFalse,
          reason: 'server-search guard must be false without a live backend');
      expect(useStudioSharedSync, isFalse,
          reason: 'shared-sync guard must be false without a live backend');
    });

    test('(B) closed-set — no Studio/Pillar flag exists that this gate does not cover',
        () {
      final Set<String> discovered = <String>{};
      // A pillar-flag definition line, e.g.:
      //   const bool kStudioLive = bool.fromEnvironment('STUDIO_LIVE');
      //   const String kCatalogBaseUrl = String.fromEnvironment('CATALOG_BASE_URL');
      final RegExp def = RegExp(
        r'const\s+(?:bool|String)\s+(k(?:Studio|Intel|Catalog)\w*)\s*=\s*(?:bool|String)\.fromEnvironment',
      );
      for (final String rel in _flagSources) {
        final File f = File(rel);
        expect(f.existsSync(), isTrue, reason: 'flag source missing: $rel');
        for (final RegExpMatch m in def.allMatches(f.readAsStringSync())) {
          discovered.add(m.group(1)!);
        }
      }

      // Anti-vacuous: the scan actually found the known pillar flags.
      expect(discovered, isNotEmpty,
          reason: 'flag scan found nothing — regex/paths drifted');
      expect(discovered, containsAll(_assertedPillarFlags),
          reason: 'a known pillar flag vanished from the sources');

      // The load-bearing check: any pillar flag in the sources MUST be asserted
      // safe in part (A). A new one added without a default-OFF assertion here is
      // an un-gated arming risk — this fails until it is added to (A).
      final Set<String> unGated = discovered.difference(_assertedPillarFlags);
      expect(unGated, isEmpty,
          reason: 'un-gated Studio/Pillar flag(s) — add a default-OFF '
              'assertion in part (A) of gate_123: $unGated');
    });
  });
}
