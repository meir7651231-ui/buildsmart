// B10 / E7 — potable backflow protection. A garden tap / hose outlet can
// back-siphon dirty water into the potable supply; code requires a vacuum-breaker.
// No such product exists in the catalog, so the checklist surfaces the requirement
// as a WARNING (unsatisfiable, not critical) rather than silently passing.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((q) => q.sku == sku);

List<LineCheck> _checks(List<LipskeyCatalogProduct> chain) =>
    lineComplianceChecklist(chain, 20, const {});

bool _hasVacuumBreakerCheck(List<LipskeyCatalogProduct> chain) =>
    _checks(chain).any((c) => c.label.contains('שובר-ואקום'));

void main() {
  group('E7 — backflow / vacuum-breaker on garden-hose outlets', () {
    test('a garden-tap supply line is flagged for a vacuum-breaker', () {
      // ברז מעבר 1" (inline) + ברז גן ¾" → supply line with a garden outlet.
      expect(_hasVacuumBreakerCheck([_p('77777313'), _p('77777345')]), isTrue);
    });
    test('a non-garden supply line is NOT flagged', () {
      expect(_hasVacuumBreakerCheck([_p('77777313'), _p('779096G')]), isFalse);
    });
    test('the check is a WARNING and unsatisfiable (no VB product in catalog)', () {
      final vb = _checks([_p('77777313'), _p('77777345')])
          .firstWhere((c) => c.label.contains('שובר-ואקום'));
      expect(vb.severity, CheckSeverity.warning); // never critical → no criticalOpen impact
      expect(vb.satisfied, isFalse); // can't be satisfied — no SKU to add
    });
  });
}
