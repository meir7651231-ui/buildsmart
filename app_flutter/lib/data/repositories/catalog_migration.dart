// FULL CATALOG MIGRATION (SPEC-catalog-to-server · C2).
//
// The full-scale migration — every bundled product → `catalogProducts` — reusing the
// SAME Step-61 importer (`seedCatalog`, stage→flip · idempotent · abort-safe) and the
// SAME `toDoc`/`fromDoc` mappers proven at slice scale in C1. No new pipeline: only
// the input list grows from the 20-SKU slice to the whole `kCatalogProducts` union.
//
// GATING: referenced only by the gated seed + tests → tree-shakes out of the OFF
// build (byte-identical preserved). The batch id is isolated from the C1 slice batch.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show kVerifiedSpecs;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/data/polyroll_specs.dart' show registerPolyrollSpecs;
import 'package:buildsmart/data/repositories/authored_products_firebase.dart'
    show FirebaseAuthoredProductsRepository, SeedOutcome;
import 'package:buildsmart/data/repositories/verified_spec_seed.dart'
    show VerifiedSpecSink, verifiedSpecToDoc;

/// The seed batch id for the FULL catalog — isolated from `c1_slice` so a full run
/// never resumes into (or collides with) the thin-slice batch.
const String kFullCatalogBatch = 'full';

/// Seed the WHOLE bundled catalog (`kCatalogProducts` = Lipskey + Polyroll + Huliot +
/// hot-water) → `catalogProducts/{sku}`, through the existing Step-61 importer. Reuse,
/// not a new pipeline. `live: false` (a test) drives the fake-sink path; the real seed
/// (1-B) passes the live sink. Returns the [SeedOutcome] (flipped count == the catalog
/// size on a clean run).
Future<SeedOutcome> seedFullCatalog(
  FirebaseAuthoredProductsRepository repo, {
  bool? live,
  bool? seedFresh,
}) =>
    repo.seedCatalog(
      kCatalogProducts,
      batchId: kFullCatalogBatch,
      live: live,
      seedFresh: seedFresh,
    );

/// C2.2 — seed ALL connection specs → `verified_specs/{sku}`: the 890 static
/// [kVerifiedSpecs] PLUS the PPR specs [registerPolyrollSpecs] folds in at runtime
/// (idempotent `putIfAbsent`, exactly as `main.dart` does at startup). Reuses the
/// C1.3 serializer [verifiedSpecToDoc]. Returns the count written (890+).
Future<int> seedAllVerifiedSpecs(VerifiedSpecSink sink) async {
  registerPolyrollSpecs(); // fold the runtime PPR specs into kVerifiedSpecs
  final specs = kVerifiedSpecs.values.toList();
  for (final s in specs) {
    await sink(s.sku, verifiedSpecToDoc(s));
  }
  return specs.length;
}
