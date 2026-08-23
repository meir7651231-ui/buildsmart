// B1 hardening for the connection-planning engine.
//
//  1. kBspInchToMm — the bore engine (install_engine), the pressure-drop
//     estimator (pressure_drop) and the spec sheet (related_info) used to each
//     keep a hand-copied BSP inch→mm clone. Three copies that must stay in
//     lockstep is exactly how a real divergence (a wrong/typo'd entry in one of
//     them) sneaks in. They now share ONE const; this locks its contract.
//
//  2. insertAt guard (P2.6) — _autoAddCompliance.insertAt computed
//     `position.clamp(1, items.length - 1)`. On a 1-item line that is
//     `clamp(1, 0)`, and Dart's clamp throws ArgumentError when lowerLimit >
//     upperLimit — a hard crash of
//     `buildInstallation([oneSupplyProduct], autoCompliance: true)`. A guard now
//     returns early. The first test below THROWS if that guard is removed, so it
//     is a genuine regression gate, not a happy-path smoke test.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku);

void main() {
  group('kBspInchToMm — single bore-size source of truth', () {
    test('exact BSP inch→mm table (9 standard sizes, forward-slash keys)', () {
      expect(kBspInchToMm, {
        '1/4': 8, '3/8': 10, '1/2': 15, '3/4': 20,
        '1': 25, '1-1/4': 32, '1-1/2': 40, '2': 50, '2-1/2': 65,
      });
      // Keys must be forward-slash inch strings — catches a '1\4'-style typo
      // (0x5C = backslash) creeping back into the single source.
      for (final k in kBspInchToMm.keys) {
        expect(k.runes.contains(0x5C), isFalse, reason: 'backslash in key "$k"');
      }
      expect(kBspInchToMm['1/2'], 15);
      expect(kBspInchToMm['1/4'], 8);
    });
  });

  group('insertAt guard — sub-2-item line must not crash (P2.6)', () {
    test('buildInstallation([oneSupplyProduct], autoCompliance) returnsNormally',
        () {
      final solo = _p('779096G'); // קיסר ½" — a supply connector, not a shutoff
      late InstallationPlan plan;
      expect(
        () => plan =
            buildInstallation([solo], tempC: 60, autoCompliance: true),
        returnsNormally,
      );
      // Guard returned early instead of clamp(1, 0)-crashing: the lone anchor
      // survives and no compliance part was forced into a slotless chain.
      expect(plan.items.length, 1);
      expect(plan.items.single.sku, '779096G');
    });

    test('a 2-item supply line still receives compliance (guard not over-broad)',
        () {
      final a = _p('779096G');
      final b = _p('77778071');
      final raw = buildInstallation([a, b], tempC: 60);
      final comp = buildInstallation([a, b], tempC: 60, autoCompliance: true);
      expect(comp.items.length, greaterThan(raw.items.length),
          reason: 'guard must only skip <2-item chains, not block real '
              'compliance insertion on a normal line');
    });
  });
}
