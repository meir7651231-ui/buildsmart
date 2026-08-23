// B13 / #1 — per-device directionality guidance. The generic "verify direction"
// warning is now ONE check PER directional valve, naming the valve + where it sits
// (its neighbours), so the installer can orient each one. (Full rejection of a
// backwards mount is geometrically impossible — a check valve's two ends are
// modelled identically — so the engine guides rather than enforces.)
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku) =>
    kCompatCatalog.firstWhere((q) => q.sku == sku);

List<LineCheck> _orient(List<LipskeyCatalogProduct> chain) =>
    lineComplianceChecklist(chain, 20, const {})
        .where((c) => c.label.startsWith('כיוון התקנה'))
        .toList();

void main() {
  group('B13 — per-device directionality guidance (#1)', () {
    test('a check valve gets its own check naming the valve + its neighbours', () {
      // [ball valve, check valve, sink faucet] — one directional device (the check).
      final oc = _orient([_p('77777311'), _p('77004401'), _p('77777114')]);
      expect(oc, hasLength(1));
      expect(oc.first.label, contains(_p('77004401').nameHe)); // names the valve
      expect(oc.first.why, contains('בין')); // states where it sits
      expect(oc.first.why, contains(_p('77777311').nameHe)); // upstream neighbour
      expect(oc.first.why, contains(_p('77777114').nameHe)); // downstream neighbour
    });
    test('two directional valves → two separate checks', () {
      // 77004401 (check) + 77777641 (nipple, inline) + 77004416 (אלחוזר אלכסוני).
      final oc = _orient([_p('77004401'), _p('77777641'), _p('77004416')]);
      expect(oc, hasLength(2));
    });
    test('a line with no directional device has no orientation check', () {
      expect(_orient([_p('77777311'), _p('779096G')]), isEmpty);
    });
    test('a lone directional device is still contextualised', () {
      final oc = _orient([_p('77004401')]);
      expect(oc, hasLength(1));
      expect(oc.first.why, contains('בקו'));
    });
  });
}
