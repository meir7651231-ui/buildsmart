// Roadmap step 22 — the "build my line" button feeds anchors to
// buildInstallation. The button is canvas UI (can't be driven reliably in a
// web test), so guard the engine call path the button uses.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('single anchor → plan contains exactly that product', () {
    final p = kLipskeyCatalog.firstWhere((x) => compatibleProductsFor(x).isNotEmpty);
    final plan = buildInstallation([p], autoCompliance: true, tempC: 60);
    expect(plan.items.map((e) => e.sku), contains(p.sku));
    expect(plan.quantities[p.sku], greaterThanOrEqualTo(1));
  });

  test('two connectable anchors → both appear, quantities are positive', () {
    LipskeyCatalogProduct? a;
    LipskeyCatalogProduct? b;
    for (final p in kLipskeyCatalog) {
      final c = compatibleProductsFor(p);
      if (c.isNotEmpty) {
        a = p;
        b = c.first;
        break;
      }
    }
    expect(a, isNotNull);
    final plan = buildInstallation([a!, b!], autoCompliance: true, tempC: 60);
    final skus = plan.items.map((e) => e.sku).toSet();
    expect(skus, contains(a.sku));
    expect(skus, contains(b.sku));
    for (final q in plan.quantities.values) {
      expect(q, greaterThan(0));
    }
  });
}
