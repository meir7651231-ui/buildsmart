// T3 DoD guard (PLAN-contractor-completion §T3): catalog ⋮ "סרוק תוכנית" —
// each of the 4 plan types scans to cart lines (one per detected zone item) at
// the cheapest partner-store offer. Data verbatim from kPlanTypes (proto §9).
import 'package:buildsmart/data/contractor_seeds.dart';
import 'package:buildsmart/screens/contractor_tools_sheets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scan plan → cart (T3)', () {
    test('all 4 plan types are active (each scans to >=1 cart line)', () {
      expect(kPlanTypes, hasLength(4));
      for (final p in kPlanTypes) {
        final lines = scanPlanCartLines(p);
        expect(lines, isNotEmpty, reason: '${p.label} must scan to items');
        // one cart line per detected zone item that carries store offers.
        final withStores = p.zones.fold<int>(
            0, (s, z) => s + z.items.where((it) => it.stores.isNotEmpty).length);
        expect(lines.length, withStores);
      }
    });

    test('every cart line takes the cheapest store offer; qty 1', () {
      for (final p in kPlanTypes) {
        final byName = {
          for (final z in p.zones)
            for (final it in z.items) it.name: it,
        };
        for (final l in scanPlanCartLines(p)) {
          final it = byName[l.productName]!;
          final cheapest =
              it.stores.map((s) => s.price).reduce((a, b) => a < b ? a : b);
          expect(l.brandPrice, cheapest,
              reason: 'cart line must use the cheapest store');
          expect(l.productQty, 1);
          expect(l.productKey, startsWith('scan:'));
        }
      }
    });

    test('plumbing אסלה → cheapest אבן קיסר 740 (verbatim §9b)', () {
      final plumbing = kPlanTypes.firstWhere((p) => p.key == 'plumbing');
      final toilet = scanPlanCartLines(plumbing)
          .firstWhere((l) => l.productName.contains('אסלה'));
      expect(toilet.brandName, 'אבן קיסר');
      expect(toilet.brandPrice, 740);
    });
  });
}
