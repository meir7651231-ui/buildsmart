// C2.4 — IDENTITY: server data == baked, 0 diffs (SPEC-catalog-to-server · regression).
//
// The full-scale regression guarantee: for EVERY product (16 fields), EVERY connection
// spec (static + PPR), and EVERY recipe (structure), the canonical doc is STABLE under
// a `toDoc → fromDoc → toDoc` round-trip — i.e. the migration + browse loses nothing.
// Deep JSON compare (toDoc's key order is deterministic) → any dropped/mutated field
// surfaces as a diff. Price is intentionally absent from products (R1-6) and recipes
// (→ inventory), so "identity" is over the fields the server actually stores.

import 'dart:convert' show jsonEncode;

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show kVerifiedSpecs;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/polyroll_specs.dart' show registerPolyrollSpecs;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository;
import 'package:buildsmart/data/repositories/firestore_cached_repo.dart'
    show RemoteDoc;
import 'package:buildsmart/data/repositories/recipe_seed.dart'
    show recipeFromDoc, recipeToDoc;
import 'package:buildsmart/data/repositories/verified_spec_seed.dart'
    show verifiedSpecFromDoc, verifiedSpecToDoc;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = FirebaseAuthoredProductsRepository();

  test('C2.4 — ALL products: toDoc stable under fromDoc (0 diffs, 16 fields)', () {
    var checked = 0;
    for (final p in kCatalogProducts) {
      final doc = repo.toDoc(p);
      final rt = repo.toDoc(repo.fromDoc(RemoteDoc(p.sku, doc)));
      expect(jsonEncode(rt), jsonEncode(doc), reason: 'product ${p.sku} diff');
      checked++;
    }
    expect(checked, kCatalogProducts.length);
    expect(checked, greaterThan(1500), reason: 'the whole catalog');
  });

  test('C2.4 — ALL specs (static + PPR): stable under round-trip (0 diffs)', () {
    registerPolyrollSpecs();
    var checked = 0;
    for (final s in kVerifiedSpecs.values) {
      final doc = verifiedSpecToDoc(s);
      final rt = verifiedSpecToDoc(verifiedSpecFromDoc(RemoteDoc(s.sku, doc)));
      expect(jsonEncode(rt), jsonEncode(doc), reason: 'spec ${s.sku} diff');
      checked++;
    }
    expect(checked, kVerifiedSpecs.length);
    expect(checked, greaterThanOrEqualTo(890));
  });

  test('C2.4 — ALL recipes: structure stable under round-trip (0 diffs)', () {
    var checked = 0;
    for (final r in kSmartProducts) {
      final doc = recipeToDoc(r);
      final rt = recipeToDoc(recipeFromDoc(RemoteDoc(r.key, doc)));
      expect(jsonEncode(rt), jsonEncode(doc), reason: 'recipe ${r.key} diff');
      checked++;
    }
    expect(checked, kSmartProducts.length);
  });
}
