// Roadmap step 25 — safetyKitItems (pure SKU diff for engine-derived safety).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/logic/install_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty inputs → empty result', () {
    expect(safetyKitItems(const [], const []), isEmpty);
  });

  test('identical inputs → empty result (nothing added)', () {
    final items = kLipskeyCatalog.take(3).toList();
    expect(safetyKitItems(items, items), isEmpty);
  });

  test('with-compliance has one extra → returned in order', () {
    final base = kLipskeyCatalog.take(2).toList();
    final extra = kLipskeyCatalog.skip(5).first;
    final withC = [...base, extra];
    final r = safetyKitItems(withC, base);
    expect(r.length, 1);
    expect(r.first.sku, extra.sku);
  });

  test('order-preserving + de-duplicates against base', () {
    final base = kLipskeyCatalog.take(2).toList();
    final a = kLipskeyCatalog.skip(5).first;
    final b = kLipskeyCatalog.skip(7).first;
    final withC = [base[0], a, base[1], b];
    final r = safetyKitItems(withC, base).map((e) => e.sku).toList();
    expect(r, [a.sku, b.sku]);
  });

  test('integration probe — engine actually returns non-empty for at least one product',
      () {
    // Honest gate: confirms our pipeline (engine + diff) produces a real kit
    // for some catalog product, otherwise step 25 would be permanently empty.
    var ever = false;
    for (final p in kLipskeyCatalog.take(120)) {
      final mates = compatibleProductsFor(p);
      if (mates.isEmpty) continue;
      final anchors = [p, mates.first];
      final withT = buildInstallation(anchors, autoCompliance: true, tempC: 60);
      final withF =
          buildInstallation(anchors, autoCompliance: false, tempC: 60);
      if (safetyKitItems(withT.items, withF.items).isNotEmpty) {
        ever = true;
        break;
      }
    }
    expect(ever, isTrue, reason: 'engine never adds safety — kit unreachable');
  });
}
