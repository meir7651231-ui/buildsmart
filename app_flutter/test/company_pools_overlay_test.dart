// Completion round — the last pour-in pipes, two-world proven. Own file ON
// PURPOSE: kDivePool is a top-level LAZY final that latches its universe on
// first access — this isolate installs the overlay first, exactly the real
// app's order (hydrate pre-runApp), so the latch proof is real.
//
//   a. game pools: with a company catalog live, kDivePool IS the imported
//      list (identity); the AI-hub raw pins ride the mirror in both worlds;
//   b. complements: dims['מוצרים משלימים'] resolves in file order, drops
//      unknown skus honestly.

import 'package:buildsmart/data/catalog_source.dart';
import 'package:buildsmart/data/company_categories.dart'
    show companyComplementsFor;
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/word_finder/dive_pool.dart'
    show kDivePool;
import 'package:buildsmart/screens/ai_hub_screen.dart' show AIHubScreen;
import 'package:buildsmart/state/app_profile.dart';
import 'package:flutter_test/flutter_test.dart';

LipskeyCatalogProduct _p(String sku, {Map<String, dynamic>? dims}) =>
    LipskeyCatalogProduct(
      sku: sku,
      nameHe: 'מוצר $sku',
      nameEn: '',
      categoryHe: 'ברזים',
      categoryEn: '',
      categoryEmoji: '🚰',
      page: 0,
      brand: '',
      dims: dims,
    );

void main() {
  tearDown(() => setCompanyCatalog(null));

  test('a · kDivePool latches the company overlay (identity, real app order)',
      () {
    final list = [_p('P1'), _p('P2')];
    setCompanyCatalog(list);
    expect(identical(kDivePool, resolvedCatalogProducts), isTrue,
        reason: 'overlay-first: the games run on the company catalog');
    expect(kDivePool.length, 2);
  });

  test('a · AI-hub price/plan/analytics tiles follow the raw-shell mirror '
      '(two worlds)', () {
    final raw = rawShellForProfile(kAppProfile);
    for (final id in ['alt', 'plan', 'analytics']) {
      expect(AIHubScreen.visibleToolIds.contains(id), !raw,
          reason: 'demo shows $id; the raw shell must not claim price/plan '
              'tools it has no data for');
    }
  });

  test('b · complements resolve in file order, unknown skus drop honestly',
      () {
    final pool = [_p('A'), _p('B'), _p('C')];
    final host = _p('H', dims: {'מוצרים משלימים': 'C|X-404|A'});
    final got = companyComplementsFor(host, pool);
    expect(got.map((p) => p.sku).toList(), ['C', 'A']);
    expect(identical(got.first, pool[2]), isTrue);
    expect(companyComplementsFor(_p('N'), pool), isEmpty);
  });
}
