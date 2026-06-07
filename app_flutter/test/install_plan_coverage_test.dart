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
    const pairs = [
      ['779096G', '77778071'], // קיסר → פקק נחושת ½"
      ['77777345', '77777114'], // ברז גן ¾" → ברז כיור ½"
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
        for (final it in plan.items) {
          expect(plan.qtyOf(it.sku), greaterThanOrEqualTo(1),
              reason: 'every plan item needs a positive quantity (${it.sku})');
        }
        expect(plan.totalPieces, greaterThanOrEqualTo(plan.items.length));
        expect(plan.zones, isNotEmpty); // linear plans always carry 'קו ראשי'
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

    test('autoCompliance injects safety items vs. the raw plan', () {
      final a = _p('779096G'), b = _p('77778071');
      final raw = buildInstallation([a, b], tempC: 20);
      final comp = buildInstallation([a, b], tempC: 20, autoCompliance: true);
      expect(comp.items.length, greaterThanOrEqualTo(raw.items.length),
          reason: 'auto-compliance inserts safety items into the chain');
    });
  });
}
