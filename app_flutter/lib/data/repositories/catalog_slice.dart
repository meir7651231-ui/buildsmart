// CATALOG SLICE (SPEC-catalog-to-server · C1 — the thin vertical slice).
//
// The 20 owner-approved SKUs the catalog→server proof migrates FIRST (C1.2), before
// any full migration (C2). Pure data + a resolver + a thin seed wrapper that REUSES
// `FirebaseAuthoredProductsRepository.seedCatalog` (Step 61, stage→flip · idempotent ·
// abort-safe) UNCHANGED — no new migration pipeline.
//
// GATING: referenced ONLY by the flag-gated seed path + tests. Nothing on the
// always-compiled path imports this, so it tree-shakes out of the OFF (default)
// build → byte-identical preserved (C0.5).

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository, SeedOutcome;

/// The seed batch id for the C1 slice — isolated from the full-catalog `seed` batch,
/// so seeding the slice never collides with (or resumes into) a full migration.
const String kC1SliceBatch = 'c1_slice';

/// The 20 approved SKUs (owner-signed). Diverse ON PURPOSE — 13 categories · 4 brands
/// (ליפסקי·AQUATEC·פולירול·חוליות) · 4 materials (PVC·HDPE·נחושת·PPR) · 9 with a
/// VerifiedSpec + 11 without · 3 multi-image · diameters 16→63 + DN110 · a reducer,
/// an angle, an electrofusion sleeve, a tap and a seal — so search + dive (ring/plain/
/// axis) all have real axes to narrow. Incl. the complex manifold 118220. (C1.1.)
const List<String> kC1SliceSkus = <String>[
  '118220', //     מסעף 45° DN110 עם תבריג (PVC · VerifiedSpec) ⭐ manifold · ליפסקי
  '9101601610', // מצמד HDPE 16×16 (spec) · AQUATEC
  '9102002004', // מצמד HDPE 16×20 — reducer (spec)
  '9102002010', // מצמד HDPE 20×20 (spec)
  '77777641', //   ניפל כפול נחושת ½" (spec)
  '77777642', //   ניפל כפול נחושת ¾" (spec)
  '77777643', //   ניפל כפול נחושת 1" (spec)
  '77401622', //   מקשר כפול NTM 16×16 (spec)
  '77401028', //   מקשר כפול NTM 20×20 (spec)
  '98415838', //   מחבר מתוברג מפורק 20 — multi-image · פולירול
  '98415840', //   מחבר מתוברג מפורק 25 — multi-image
  '98415842', //   מחבר מתוברג מפורק 32 — multi-image
  '94117202', //   מסעף PPR 20
  '92117102', //   ברך PPR 45° 20 — angle
  '91117002', //   מצמד PPR 20
  '98217741', //   רוכב PPR 40/20
  '99040858', //   ברז PPR סמוי (ציפוי כרום) 20 — tap
  '91814802', //   שרוול PPR חשמלי 20 — electrofusion
  '98417805', //   צווארון PPR 40 — flange
  '67750440', //   אטם לג'וקר 40 — seal (non-pipe) · חוליות
];

/// Resolve the slice SKUs → their [LipskeyCatalogProduct]s from the bundled union, in
/// [kC1SliceSkus] order. Throws if ANY SKU is missing — a typo must fail loudly, not
/// silently seed 19.
List<LipskeyCatalogProduct> c1SliceProducts() {
  final bySku = <String, LipskeyCatalogProduct>{
    for (final p in kCatalogProducts) p.sku: p,
  };
  final out = <LipskeyCatalogProduct>[];
  final missing = <String>[];
  for (final sku in kC1SliceSkus) {
    final p = bySku[sku];
    if (p == null) {
      missing.add(sku);
    } else {
      out.add(p);
    }
  }
  if (missing.isNotEmpty) {
    throw StateError('catalog slice: SKUs not found in kCatalogProducts: $missing');
  }
  return out;
}

/// Seed the C1 slice through the EXISTING Step-61 importer (reuse — not a new
/// pipeline). [live]/[seedFresh] default to the live globals inside `seedCatalog`; a
/// test passes them explicitly (`live: false` drives the fake-sink path, exactly like
/// `catalog_seed_test.dart`). The real-cloud seed (decision 1-B) calls this same
/// function with the live sink — one entry point, two backends.
Future<SeedOutcome> seedC1Slice(
  FirebaseAuthoredProductsRepository repo, {
  bool? live,
  bool? seedFresh,
}) =>
    repo.seedCatalog(
      c1SliceProducts(),
      batchId: kC1SliceBatch,
      live: live,
      seedFresh: seedFresh,
    );
