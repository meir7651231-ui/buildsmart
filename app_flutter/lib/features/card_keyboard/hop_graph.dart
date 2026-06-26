// hop_graph.dart — the ONE between-products navigation graph (build-plan v3, P0
// steps 4-8). The <=4 contract is "<=4 taps to a RELATED product" over this graph.
//
// Nodes are EXACTLY the reach-universe skus (divePoolBySku.keys) — REAL products
// only, NO virtual/hub nodes (round-1 blocker #4: a category bridge must be a real
// edge between real products, never a synthetic node that fakes the diameter).
// Edges are TAGGED by EdgeKind so the <=4 census and the on-screen rail verify and
// render the SAME edge set. Pure; nothing reads it until the hop UI (P8) wires it.
//
// Step 4 = skeleton. Step 5 = compat (crossesSystem-gated). Step 6 = variant
// (per-family clique). Step 7 = kit (recipe co-membership, crossesSystem-gated).
// Step 8 (this) = category (same-categoryHe clique within one water system — the
// isolation-prevention fallback rail). HopGraph.build() is MEMOISED: the graph is a
// pure function of const catalog data, so it is constructed exactly once (round-3
// scale finding — the build is the module's most expensive op).

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show WaterSystem, kVerifiedSpecs;
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
import 'package:buildsmart/data/smart_tree.dart' show kSmartProducts;
import 'package:buildsmart/data/variant_families.dart' show allVariantFamilies;
import 'package:buildsmart/features/word_finder/recipe_kit.dart'
    show KitMatch, assembleKit;
import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;

/// The kind of a navigational edge between two real products. The <=4 graph is the
/// UNION of these (round-2/3: honestly "navigational adjacency", not "verified
/// physical connection only" — a category edge is allowed but tagged as such).
enum EdgeKind { compat, variant, kit, category }

/// True if [aSku] and [bSku] sit on OPPOSITE water systems (one only-supply, the
/// other only-drainage) — they cannot directly connect, so a hop edge must never
/// bridge them (round-3 blocker-4). Mirrors gapAdviceHe's crossSystem guard
/// (related_info.dart:394) EXACTLY, reading the same verified-spec end-systems;
/// kept card-scoped here (no edit to the live related_info, no import cycle). If
/// either sku lacks a verified spec the system is unknown -> NOT a cross (don't
/// over-block; gapAdviceHe falls back to a generic adapter hint there too).
bool crossesSystem(String aSku, String bSku) {
  final a = kVerifiedSpecs[aSku]?.endSystems;
  final b = kVerifiedSpecs[bSku]?.endSystems;
  if (a == null || b == null) return false;
  bool only(Set<WaterSystem> s, WaterSystem w) =>
      s.length == 1 && s.contains(w);
  return (only(a, WaterSystem.supply) && only(b, WaterSystem.drainage)) ||
      (only(a, WaterSystem.drainage) && only(b, WaterSystem.supply));
}

/// The single memoised populated graph (built once — see file header).
HopGraph? _builtHopGraph;

/// Pure DIRECTED product graph. Nodes == divePoolBySku.keys; adjacency is
/// per-source so a directed all-pairs BFS over [neighborsOf] matches the asymmetric
/// on-screen rail (round-2 blocker: an undirected backbone bound does not transfer
/// to a directed rail).
class HopGraph {
  HopGraph._(this._adj);

  /// An EMPTY-edge graph over every reach-universe sku — the skeleton.
  factory HopGraph.skeleton() => HopGraph._(_emptyAdj());

  /// The fully-populated graph (compat + variant + kit + category edges). MEMOISED:
  /// built once per isolate, then cached.
  factory HopGraph.build() => _builtHopGraph ??= _buildPopulated();

  /// sku -> (neighbour sku -> the kinds of the directed edge source->neighbour).
  final Map<String, Map<String, Set<EdgeKind>>> _adj;

  /// The node set — exactly the reach-universe skus, real products only.
  Iterable<String> get nodes => _adj.keys;

  /// Directed neighbours of [sku] (empty for an unknown sku).
  Iterable<String> neighborsOf(String sku) =>
      _adj[sku]?.keys ?? const <String>[];

  /// The edge kinds on the directed edge [a] -> [b] (empty if no edge).
  Set<EdgeKind> kindsBetween(String a, String b) =>
      _adj[a]?[b] ?? const <EdgeKind>{};
}

HopGraph _buildPopulated() {
  final adj = _emptyAdj();
  _addCompatEdges(adj);
  _addVariantEdges(adj);
  _addKitEdges(adj);
  _addCategoryEdges(adj);
  return HopGraph._(adj);
}

Map<String, Map<String, Set<EdgeKind>>> _emptyAdj() => {
      for (final sku in divePoolBySku.keys) sku: <String, Set<EdgeKind>>{},
    };

/// Step 5 — compat edges from [compatibleProductsFor], directed source->mate, with
/// self-loops dropped, non-node mates skipped, and any cross-WaterSystem pair
/// filtered out (the round-3 blocker-4 honesty gate).
void _addCompatEdges(Map<String, Map<String, Set<EdgeKind>>> adj) {
  for (final entry in divePoolBySku.entries) {
    final sku = entry.key;
    for (final mate in compatibleProductsFor(entry.value)) {
      final m = mate.sku;
      if (m == sku || !adj.containsKey(m)) continue; // no self-loop / real node only
      if (crossesSystem(sku, m)) continue; // never bridge supply<->drainage
      adj[sku]!.putIfAbsent(m, () => <EdgeKind>{}).add(EdgeKind.compat);
    }
  }
}

/// Step 6 — variant edges: within each variant family every member is a directed
/// neighbour of every other (a real-product clique). Variants share one frame on
/// one water system, so no crossesSystem filter is needed. Members outside the node
/// set are skipped.
void _addVariantEdges(Map<String, Map<String, Set<EdgeKind>>> adj) {
  for (final fam in allVariantFamilies()) {
    final skus = [for (final p in fam.products) p.sku];
    for (final a in skus) {
      if (!adj.containsKey(a)) continue;
      for (final b in skus) {
        if (a == b || !adj.containsKey(b)) continue;
        adj[a]!.putIfAbsent(b, () => <EdgeKind>{}).add(EdgeKind.variant);
      }
    }
  }
}

/// Step 7 — kit edges: products that resolve into the SAME recipe kit are co-members
/// (every resolved line connects to every other). Only RESOLVED lines count
/// (KitMatch.curated / auto / swarm — a real bound product); ambiguous/none lines
/// carry no product. crossesSystem-gated (a kit can't span supply<->drainage), real
/// nodes only.
void _addKitEdges(Map<String, Map<String, Set<EdgeKind>>> adj) {
  for (final recipe in kSmartProducts) {
    final skus = <String>[
      for (final line in assembleKit(recipe))
        if (line.product != null &&
            (line.match == KitMatch.curated ||
                line.match == KitMatch.auto ||
                line.match == KitMatch.swarm))
          line.product!.sku,
    ];
    for (final a in skus) {
      if (!adj.containsKey(a)) continue;
      for (final b in skus) {
        if (a == b || !adj.containsKey(b)) continue;
        if (crossesSystem(a, b)) continue; // a kit can't straddle water systems
        adj[a]!.putIfAbsent(b, () => <EdgeKind>{}).add(EdgeKind.kit);
      }
    }
  }
}

/// Step 8 — category edges: the isolation-prevention fallback rail. Within each
/// RAW categoryHe (NOT finderGroupFor, which is null outside ~6 groups) every
/// product is a directed neighbour of every same-category product, EXCEPT a pair
/// that straddles water systems (a category like 'אל חזור' mixes supply check
/// valves + sewage backflow — never bridge those). Real nodes only; uncategorised
/// products are skipped. Guarantees every categorised product with a same-system
/// peer has >=1 category edge.
void _addCategoryEdges(Map<String, Map<String, Set<EdgeKind>>> adj) {
  final byCat = <String, List<String>>{};
  for (final entry in divePoolBySku.entries) {
    final cat = entry.value.categoryHe;
    if (cat.isEmpty) continue;
    (byCat[cat] ??= <String>[]).add(entry.key);
  }
  for (final skus in byCat.values) {
    for (final a in skus) {
      for (final b in skus) {
        if (a == b) continue;
        if (crossesSystem(a, b)) continue; // category can mix systems; don't bridge
        adj[a]!.putIfAbsent(b, () => <EdgeKind>{}).add(EdgeKind.category);
      }
    }
  }
}
