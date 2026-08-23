// C4.2 + C4.3 + C4.4 — supplier onboarding pipeline (SPEC-catalog-to-server).
//
// Proves the pure logic behind the (dormant) supplier form: validation gates a submit,
// facets auto-suggest by reusing the catalog getters, and a draft becomes a catalog
// product doc (no price — R1-6) + a store inventory row. Fake repo (toDoc is pure).

import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/catalog_slice.dart'
    show c1SliceProducts;
import 'package:buildsmart/data/repositories/supplier_onboarding.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = FirebaseAuthoredProductsRepository();

  group('C4.2 — validation', () {
    test('a complete draft is OK', () {
      const d = SupplierDraft(
        storeId: 'ahim_cohen',
        sku: 'NEW-1',
        nameHe: 'ברז חדש',
        categoryHe: 'ברזים',
        price: 42,
        stock: 5,
      );
      final v = validateDraft(d, const <String>{});
      expect(v.ok, isTrue);
      expect(v.errors, isEmpty);
    });

    test('missing required fields + negative price/stock → errors', () {
      const d = SupplierDraft(
        storeId: '',
        sku: '',
        nameHe: '',
        categoryHe: '',
        price: -1,
        stock: -3,
      );
      final v = validateDraft(d, const <String>{});
      expect(v.ok, isFalse);
      expect(v.errors.length, greaterThanOrEqualTo(5));
    });

    test('a duplicate SKU is a WARNING (update), not an error', () {
      const d = SupplierDraft(
        storeId: 's1',
        sku: '118220',
        nameHe: 'מסעף',
        categoryHe: 'מסעפים',
      );
      final v = validateDraft(d, {'118220'});
      expect(v.ok, isTrue, reason: 'a dup is allowed — it updates');
      expect(v.warnings, isNotEmpty);
    });
  });

  group('C4.3 — facet suggestion reuses the catalog getters (faithful)', () {
    test('suggestFacets(draft) == the product own getters, for real products', () {
      for (final p in c1SliceProducts()) {
        final draft = SupplierDraft(
          storeId: 's1',
          sku: p.sku,
          nameHe: p.nameHe,
          nameEn: p.nameEn,
          categoryHe: p.categoryHe,
          categoryEn: p.categoryEn,
          categoryEmoji: p.categoryEmoji,
          brand: p.brand,
          dims: p.dims,
        );
        final s = suggestFacets(draft);
        expect(s.type, p.productType, reason: '${p.sku} type');
        expect(s.gender, p.connectionGender, reason: '${p.sku} gender');
        expect(s.method, p.connectionMethod, reason: '${p.sku} method');
        expect(s.sizes, p.connectionSizes, reason: '${p.sku} sizes');
      }
    });
  });

  group('C4.4 — pipeline: draft → product doc + inventory row', () {
    test('product doc is toDoc-shaped and carries NO price (R1-6)', () {
      const d = SupplierDraft(
        storeId: 'ahim_cohen',
        sku: 'NEW-9',
        nameHe: 'מתאם',
        categoryHe: 'מתאמים',
        price: 30,
        stock: 4,
      );
      final doc = draftToProductDoc(d, repo);
      expect(doc['sku'], 'NEW-9');
      expect(doc['nameHe'], 'מתאם');
      expect(doc.containsKey('price'), isFalse);
    });

    test('inventory row carries price+stock; null price → no row', () {
      const withPrice = SupplierDraft(
        storeId: 'ahim_cohen',
        sku: 'NEW-9',
        nameHe: 'מתאם',
        categoryHe: 'מתאמים',
        price: 30,
        stock: 4,
        updatedAt: '2026-07-14T00:00:00Z',
      );
      final inv = draftToInventory(withPrice)!;
      expect(inv.storeId, 'ahim_cohen');
      expect(inv.sku, 'NEW-9');
      expect(inv.price, 30);
      expect(inv.stock, 4);
      expect(inv.docId, 'ahim_cohen_NEW-9');

      const noPrice = SupplierDraft(
        storeId: 'ahim_cohen',
        sku: 'NEW-10',
        nameHe: 'x',
        categoryHe: 'y',
      );
      expect(draftToInventory(noPrice), isNull);
    });
  });
}
