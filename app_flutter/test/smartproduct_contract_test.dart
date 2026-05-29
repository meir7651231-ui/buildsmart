// SmartProduct ↔ catalog data contract (Roadmap Phase 1, Step 5).
// The smart-tree card and the catalog must stay linked: every SmartBrand.sku is
// a real catalog SKU. This is the foundation the unification (steps 1–4) builds
// on — if a brand points at a missing SKU the merged card would 404.
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The unified catalog (Lipskey + Polyroll) is the single source of truth.
  final catalogSkus = {for (final p in kCatalogProducts) p.sku};

  test('every SmartBrand.sku is a real catalog SKU', () {
    final missing = <String>[];
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        if (b.sku != null && !catalogSkus.contains(b.sku)) {
          missing.add('${sp.key} → "${b.name}" (sku ${b.sku})');
        }
      }
    }
    if (missing.isNotEmpty) {
      print('SmartBrands pointing at a missing catalog SKU:');
      for (final m in missing) print('  ✗ $m');
    }
    expect(missing, isEmpty,
        reason: '${missing.length} brand(s) reference a SKU not in the catalog');
  });

  test('every SmartProduct has at least one brand and a resolvable recommended brand',
      () {
    final bad = <String>[];
    for (final sp in kSmartProducts) {
      if (sp.brands.isEmpty) {
        bad.add('${sp.key}: no brands');
        continue;
      }
      // recBrand must not throw and must be in the list.
      final rec = sp.recBrand;
      if (!sp.brands.contains(rec)) bad.add('${sp.key}: recBrand not in list');
    }
    expect(bad, isEmpty, reason: bad.join(' · '));
  });

  test('bidirectional bridge round-trips (step 3)', () {
    var checked = 0;
    for (final sp in kSmartProducts) {
      for (final b in sp.brands) {
        if (b.sku == null) continue;
        // brand → catalog product
        final prod = catalogProductForBrand(b);
        expect(prod, isNotNull, reason: 'no catalog product for ${b.sku}');
        expect(prod!.sku, b.sku);
        // catalog product → SmartProduct (reverse) must resolve to a product
        // that lists this SKU.
        final back = smartProductForSku(prod.sku);
        expect(back, isNotNull, reason: 'no SmartProduct for ${prod.sku}');
        expect(back!.brands.any((x) => x.sku == prod.sku), isTrue);
        checked++;
      }
    }
    expect(checked, greaterThan(200));
  });

  test('coverage report (informational)', () {
    var products = 0, brands = 0, withSku = 0, withSpec = 0, withImage = 0;
    for (final sp in kSmartProducts) {
      products++;
      for (final b in sp.brands) {
        brands++;
        if (b.sku != null) {
          withSku++;
          if (kVerifiedSpecs.containsKey(b.sku)) withSpec++;
        }
        if (b.imageAsset != null) withImage++;
      }
    }
    print('SmartProducts: $products · brands: $brands');
    print('brands with sku:   $withSku/$brands');
    print('  …of which verified-spec: $withSpec/$withSku');
    print('brands with image: $withImage/$brands');
    // Always passes — this is a baseline snapshot, not a gate.
    expect(products, greaterThan(0));
  });
}
