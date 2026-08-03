// Gate-124 (GATE_REGISTRY · Fittings-3D · "GA-safe-by-default") — the catalog-3D
// fittings engine ships DORMANT. Every `kFittingEngine*` flag resolves to its SAFE
// default (OFF) in a build with no `--dart-define`, so the whole `features/fittings/`
// graph is tree-shaken out and the shipped demo/production build is BYTE-IDENTICAL to
// today. Nothing here arms anything — it LOCKS the "off" state (keystone R2:
// אינסטלציה byte-identical).
//
//   (A) RUNTIME const-fold — the flags are `bool.fromEnvironment` compile-consts.
//       Under `flutter test` (no --dart-define) each folds to its absent-define
//       default, so asserting the imported const IS asserting the shipped value:
//         • kFittingEngine       (FITTING_ENGINE)        == false
//         • kFittingEngine3d     (FITTING_ENGINE_3D)     == false
//         • kFittingEngineIntel  (FITTING_ENGINE_INTEL)  == false
//
//   (B) SELF-MAINTAINING closed-set — a source scan of fitting_flags.dart for every
//       `const bool kFittingEngine… = bool.fromEnvironment(...)`. EVERY such flag MUST
//       appear in the asserted set (A). A future fittings flag added without a
//       default-OFF assertion here trips this gate — the safety net cannot rot.
//
//   (C) anti-vacuous — the scan is proven non-empty (finds the known flags).
import 'dart:io';

import 'package:buildsmart/features/fittings/fitting_flags.dart';
import 'package:flutter_test/flutter_test.dart';

const String _flagSource = 'lib/features/fittings/fitting_flags.dart';

const Set<String> _assertedFittingFlags = <String>{
  'kFittingEngine',
  'kFittingEngine3d',
  'kFittingEngineIntel',
};

void main() {
  group('Gate-124 · Fittings-3D — safe-by-default (dormant, byte-identical)', () {
    test('(A) every fittings flag folds to its SAFE default (OFF) in a no-define build',
        () {
      expect(kFittingEngine, isFalse,
          reason: 'FITTING_ENGINE (core engine/plan) must default OFF',);
      expect(kFittingEngine3d, isFalse,
          reason: 'FITTING_ENGINE_3D (layout/geometry/render) must default OFF',);
      expect(kFittingEngineIntel, isFalse,
          reason: 'FITTING_ENGINE_INTEL (routing/AI) must default OFF',);
    });

    test('(B) closed-set — no fittings flag exists that this gate does not cover',
        () {
      final def = RegExp(
        r'const\s+bool\s+(kFittingEngine\w*)\s*=\s*bool\.fromEnvironment',
      );
      final f = File(_flagSource);
      expect(f.existsSync(), isTrue, reason: 'flag source missing: $_flagSource');
      final discovered = <String>{
        for (final m in def.allMatches(f.readAsStringSync())) m.group(1)!,
      };

      expect(discovered, isNotEmpty,
          reason: 'flag scan found nothing — regex/path drifted',);
      expect(discovered, containsAll(_assertedFittingFlags),
          reason: 'a known fittings flag vanished from the source',);

      final unGated = discovered.difference(_assertedFittingFlags);
      expect(unGated, isEmpty,
          reason: 'un-gated fittings flag(s) — add a default-OFF assertion in '
              'part (A) of gate_124: $unGated',);
    });
  });
}
