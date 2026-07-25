/// Pure UNION-pool index for the product finder (בית/מאתר) "dive".
///
/// STEP 1 of the word-finder swarm. A PURE library — no Flutter widgets, no
/// Riverpod providers — mirroring the purity of `narrow_axis.dart` (STEP 0)
/// and `catalog_lens.dart`. Everything here is built from `const`/`final`
/// catalog data; importing it pulls in zero UI.
///
/// WHY THIS EXISTS:
///   `kCatalogProducts` (in polyroll_catalog.dart) is the union the catalog
///   UI walks — but it is `[...kLipskeyCatalog, ...kPolyrollCatalog,
///   ...kHuliotCatalog]` and therefore OMITS the hot-water family
///   (`kHotWaterCatalog`). The compatibility engine sees hot-water only
///   through the separate `kCompatCatalog`. The finder needs ONE pool that
///   contains every product the app knows about, deduped by sku.
///   `kDivePool` is that pool, and it FIXES the hot-water omission.
///
/// MEMBERSHIP:
///   For each sku we record which sub-corpus it belongs to (catalog / compat /
///   verified-specs / smart-tree). This lets the finder reason about a product
///   without re-walking four lists: e.g. "show only items the install engine
///   can auto-wire" (`hasSpec`) or "items with a guided install" (`hasSmart`).
library;

import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_hotwater.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/data/smart_tree.dart';
import 'package:buildsmart/features/word_finder/narrow_axis.dart';
import 'package:buildsmart/state/app_profile.dart';

/// The deduped UNION of every product corpus the app carries, built fresh
/// (NOT reusing `kCatalogProducts`, which omits hot-water). EMPTY on the clean
/// shell ([kProfileEmptyCatalog]) — the dive/word-finder/keyboard pool is
/// BuildSmart product content, and the engines are already empty-safe
/// (word_finder_engine:512 · narrow_axis:59).
///
/// Order of sources is the dedupe priority — FIRST WINS on a sku collision:
///   Lipskey → Polyroll → Huliot/SmartLock → HotWater.
/// So a Lipskey entry shadows any later duplicate of the same sku. Because the
/// hot-water skus are synthetic ('HW-…') they never collide with the numeric
/// supplier skus, so this pool is strictly a superset of `kCatalogProducts`.
final List<LipskeyCatalogProduct> kDivePool =
    kProfileEmptyCatalog ? const <LipskeyCatalogProduct>[] : _buildDivePool();

List<LipskeyCatalogProduct> _buildDivePool() {
  final seen = <String>{};
  final out = <LipskeyCatalogProduct>[];
  for (final p in [
    ...kLipskeyCatalog,
    ...kPolyrollCatalog,
    ...kHuliotCatalog,
    ...kHotWaterCatalog,
  ]) {
    if (seen.add(p.sku)) out.add(p); // add() is false on a repeat sku → skip
  }
  return out;
}

/// Which corpora a sku belongs to. A compact per-sku fact sheet so the finder
/// never re-scans four lists at query time.
///
///  - [inCatalog] : present in `kCatalogProducts` (the catalog-UI union; this
///    is FALSE for hot-water skus — that is the omission `kDivePool` fixes).
///  - [inCompat]  : present in `kCompatCatalog` (the compatibility-engine
///    union: Lipskey + hot-water).
///  - [hasSpec]   : the verified-specs gate (`kVerifiedSpecs[sku] != null`) —
///    the SAME predicate `install_engine._usableConnector` uses to decide a
///    product has trustworthy geometry for auto-wiring.
///  - [hasSmart]  : `smartProductForSku(sku) != null` — a guided SmartProduct
///    lists this sku as a brand option.
class Membership {
  const Membership({
    required this.inCatalog,
    required this.inCompat,
    required this.hasSpec,
    required this.hasSmart,
  });

  final bool inCatalog;
  final bool inCompat;
  final bool hasSpec;
  final bool hasSmart;
}

/// sku → [Membership], keyed across the deduped union. Built fresh once.
final Map<String, Membership> divePoolIndex = _buildDivePoolIndex();

Map<String, Membership> _buildDivePoolIndex() {
  final inCatalog = {for (final p in kCatalogProducts) p.sku};
  final inCompat = {for (final p in kCompatCatalog) p.sku};
  return {
    for (final p in kDivePool)
      p.sku: Membership(
        inCatalog: inCatalog.contains(p.sku),
        inCompat: inCompat.contains(p.sku),
        // SAME public gate the install engine reads — kVerifiedSpecs is a
        // public top-level map in lipskey_verified_connections.dart, so no
        // private symbol is fabricated here.
        hasSpec: kVerifiedSpecs[p.sku] != null,
        hasSmart: smartProductForSku(p.sku) != null,
      ),
  };
}

/// Thin pass-through to STEP-0's [narrowAxis]: pick the best "narrow by" axis
/// (curated facets → sizes → angles → colours → words) for a [pool] and an
/// optional [subtype]. Kept here so finder callers depend on one library; the
/// logic itself stays in `narrow_axis.dart`.
({String label, List<String> chips}) offerAxis(
  List<LipskeyCatalogProduct> pool,
  String? subtype,
) =>
    narrowAxis(pool, subtype);
