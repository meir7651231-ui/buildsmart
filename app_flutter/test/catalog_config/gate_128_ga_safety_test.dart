// Gate-128 (GATE_REGISTRY · CATALOG-CONFIG) — locks `kCatalogConfig` to its SAFE
// default (OFF) in a no-`--dart-define` build, so the standalone full-screen ROUTE
// (`CatalogConfigScreen.route`) stays gated + no unclassified flag arms.
// ⚠️ NOTE (owner "תדליק"): the HOME SECTION now renders `CatalogConfigScreen` LIVE,
// independent of this flag — so `features/catalog_config/` is no longer tree-shaken
// and the home is NOT byte-identical. This gate now covers only the flag default
// (the route) + the closed-set, NOT whole-feature dormancy.
//
//   (A) RUNTIME const-fold — the flag is a `bool.fromEnvironment` compile-const;
//       under `flutter test` (no --dart-define) it folds to its absent default.
//   (B) SELF-MAINTAINING closed-set — a scan of catalog_config_flags.dart for every
//       `const bool k… = bool.fromEnvironment(...)`; each MUST be asserted OFF here.
import 'dart:io';

import 'package:buildsmart/features/catalog_config/catalog_config_flags.dart';
import 'package:flutter_test/flutter_test.dart';

const String _flagSource = 'lib/features/catalog_config/catalog_config_flags.dart';

const Set<String> _assertedFlags = <String>{'kCatalogConfig'};

void main() {
  group('Gate-128 · CATALOG-CONFIG — safe-by-default (dormant, byte-identical)', () {
    test('(A) the flag folds to its SAFE default (OFF) in a no-define build', () {
      expect(kCatalogConfig, isFalse,
          reason: 'CATALOG_CONFIG must default OFF (catalog stays byte-identical)',);
    });

    test('(B) closed-set — no catalog_config flag exists that this gate misses', () {
      final def = RegExp(r'const\s+bool\s+(k\w*)\s*=\s*bool\.fromEnvironment');
      final f = File(_flagSource);
      expect(f.existsSync(), isTrue, reason: 'flag source missing: $_flagSource');
      final discovered = <String>{
        for (final m in def.allMatches(f.readAsStringSync())) m.group(1)!,
      };
      expect(discovered, isNotEmpty,
          reason: 'flag scan found nothing — regex/path drifted',);
      expect(discovered, containsAll(_assertedFlags),
          reason: 'a known catalog_config flag vanished from the source',);
      final unGated = discovered.difference(_assertedFlags);
      expect(unGated, isEmpty,
          reason: 'un-gated catalog_config flag(s) — assert OFF in part (A): $unGated',);
    });
  });
}
