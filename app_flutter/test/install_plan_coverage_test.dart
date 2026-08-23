// Coverage for the connection-planning engine's rich outputs (research gap
// TEST-1): buildInstallation's plan — items, quantities, zones, gaps, and
// auto-compliance — was barely asserted (pathfinder had tests; the *plan
// assembly* did not). These lock its core contract on known-connectable supply
// pairs (each verified to have a path in audit40_test cases 1/3/9).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((p) => p.sku == sku);

void main() {
  group('buildInstallation — plan coverage (TEST-1)', () {
    // Known-connectable supply pairs (green in audit40 cases 1/3/9).
    // Each pair is ONE draw-off tap (terminal) + an in-line part — a physically
    // valid line. (Was: ברז גן → ברז כיור, two taps in series — itself invalid,
    // now rejected by the terminal rule; replaced with ball-valve → faucet.)
    const pairs = [
      ['779096G', '77778071'], // קיסר (ברז) → פקק נחושת ½" (פקק = קצה-קו inline)
      ['77777313', '779096G'], // ברז מעבר 1" → קיסר ½" (שסתום inline → ברז-קצה)
      ['77777104', '77777114'], // מופה נחושת ½" → ברז כיור ½"
    ];

    test('connectable anchors → complete plan · anchors present · real qty', () {
      for (final pr in pairs) {
        final a = _p(pr[0]), b = _p(pr[1]);
        final plan = buildInstallation([a, b], tempC: 20, autoCompliance: true);
        expect(plan.gaps, isEmpty,
            reason: '${a.nameHe}→${b.nameHe} should connect (audit40 path exists)');
        expect(plan.isComplete, isTrue);
        final skus = plan.items.map((p) => p.sku).toList();
        expect(skus, containsAll([a.sku, b.sku]));
        expect(plan.items.length, greaterThanOrEqualTo(2));
        // Zone-tagging completeness (a real contract, not the tautological
        // `zones.isNotEmpty`): the union of every zone's SKUs must equal the
        // plan's item set exactly — no item left unzoned, no phantom SKU in a
        // zone. Fails if the zone map ever drops/duplicates an item.
        final zonedSkus = plan.zones.values.expand((e) => e).toSet();
        expect(zonedSkus, equals(skus.toSet()),
            reason: 'every item must be tagged into a zone, and zones must '
                'reference only real plan items (${a.nameHe}→${b.nameHe})');
      }
    });

    test('auto-compliance closes every critical check (criticalOpen == 0)', () {
      for (final pr in pairs) {
        final a = _p(pr[0]), b = _p(pr[1]);
        final plan = buildInstallation([a, b], tempC: 20, autoCompliance: true);
        expect(plan.criticalOpen(20), 0,
            reason: 'auto-compliance must leave no open critical item for '
                '${a.nameHe}→${b.nameHe}');
      }
    });

    test('auto-compliance is load-bearing on a hot line (raw critical > 0 → 0)',
        () {
      // Proves the `criticalOpen == 0` check above is NOT vacuous: a HOT supply
      // line without compliance must carry open critical items (anti-scald TMTV /
      // PRV / isolation), and compliance must close every one of them.
      final a = _p('779096G'), b = _p('77778071');
      final raw = buildInstallation([a, b], tempC: 60);
      final comp = buildInstallation([a, b], tempC: 60, autoCompliance: true);
      expect(raw.criticalOpen(60), greaterThan(0),
          reason: 'a hot supply line with no compliance must have open critical '
              'items — otherwise the ==0 assertion proves nothing');
      expect(comp.criticalOpen(60), 0,
          reason: 'auto-compliance must close every critical on the hot line');
    });

    test('autoCompliance injects safety items vs. the raw plan', () {
      final a = _p('779096G'), b = _p('77778071');
      final raw = buildInstallation([a, b], tempC: 60);
      final comp = buildInstallation([a, b], tempC: 60, autoCompliance: true);
      expect(comp.items.length, greaterThan(raw.items.length),
          reason: 'auto-compliance inserts real safety items into the chain');
    });
  });
}
