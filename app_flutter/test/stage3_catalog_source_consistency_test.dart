// STAGE-3.1 — list ↔ bridge ↔ search read the SAME catalog source.
//
// The latent bug this pins against: the SKU bridge (related_info._skuIndex)
// and the fuzzy-search default were hardcoded to kCatalogProducts (the v1
// list) while list surfaces read resolvedCatalogProducts (the CATALOG_SOURCE-
// aware getter) — so under CATALOG_SOURCE=v2 the 789 new Huliot products
// appeared in lists but never resolved by SKU (barcode / cart-line reopen /
// BOM) and never surfaced in search. After the stage-3.1 un-pinning all three
// read resolvedCatalogProducts.
//
// Under the define-less test build v1 == kCatalogProducts, so these pass
// today AND become load-bearing the day v2 (or any swapped catalog profile)
// is active: every listed product must resolve through the bridge.

import 'dart:io';

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/related_info.dart';
import 'package:flutter_test/flutter_test.dart';

/// Files SANCTIONED to reference `kCatalogProducts` in CODE (not comments):
/// the source-definition/infra layer, the plumbing-engine fixtures, the
/// brand-scoped Lipskey screen (a deliberate careful-item — brand subset ≠
/// unified list), and the in-app QA harness. Every OTHER file must read
/// `resolvedCatalogProducts` (the CATALOG_SOURCE-aware getter) — a new direct
/// read fails this sweep and forces a conscious decision.
const Set<String> kSanctionedRawReaders = {
  'lib/data/catalog_source.dart', // the getter's own definition
  'lib/data/polyroll_catalog.dart', // the const's definition
  'lib/data/fitting_image_overrides.dart', // image-override build (v1 keyed)
  'lib/data/repositories/authored_products_firebase.dart',
  'lib/data/repositories/catalog_local.dart',
  'lib/data/repositories/catalog_migration.dart',
  'lib/data/repositories/catalog_paged.dart', // bundled fallback layer
  'lib/data/repositories/catalog_repository.dart',
  'lib/data/repositories/catalog_slice.dart',
  'lib/data/repositories/catalog_sync.dart',
  'lib/data/repositories/search_local.dart',
  'lib/domain/seeds/plumbing_trade_seed.dart', // trade-fixture layer
  'lib/features/ring_dive/plain_dive.dart', // dive pools (engine unions)
  'lib/features/word_finder/dive_pool.dart',
  'lib/logic/pressure_drop.dart', // kCompatCatalog engine layer
  'lib/screens/lipskey_brand_screen.dart', // brand-scoped careful item
  'lib/test_harness/tests/catalog.dart', // in-app QA of the bundle
  'lib/test_harness/tests/dsync.dart',
};

void main() {
  test('every product in the ACTIVE catalog resolves through the SKU bridge',
      () {
    final missing = <String>[];
    for (final p in resolvedCatalogProducts) {
      if (catalogProductForSku(p.sku) == null) missing.add(p.sku);
    }
    expect(missing, isEmpty,
        reason: 'listed-but-unresolvable products = the v2 latent bug: '
            'barcode/cart-reopen/BOM die on them');
  });

  test('closed-set sweep: only sanctioned infra reads kCatalogProducts in CODE',
      () {
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (kSanctionedRawReaders.contains(f.path)) continue;
      // Comment-only mentions are fine — scan non-comment lines only.
      final code = f
          .readAsLinesSync()
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');
      if (code.contains('kCatalogProducts')) offenders.add(f.path);
    }
    expect(offenders, isEmpty,
        reason: 'a new direct kCatalogProducts read bypasses the ACTIVE '
            'catalog source — use resolvedCatalogProducts, or sanction the '
            'file here with a reason');
  });

  test('the bridge resolves to the SAME object the list shows', () {
    // Sample the head/middle/tail — identity, not just equality, since both
    // sides must share one source (no forked copies drifting).
    final list = resolvedCatalogProducts;
    if (list.isEmpty) {
      // clean/empty-catalog profile: identity sampling is vacuous on [] —
      // the sweep + every-product-resolves tests above still run (over 0).
      markTestSkipped('empty-catalog profile — nothing to sample');
      return;
    }
    for (final p in [list.first, list[list.length ~/ 2], list.last]) {
      expect(identical(catalogProductForSku(p.sku), p), isTrue,
          reason: 'bridge and list must share one source object');
    }
  });
}
