// hop_graph.dart — the ONE between-products navigation graph (build-plan v3, P0
// steps 4-8). The <=4 contract is "<=4 taps to a RELATED product" over this graph.
//
// Nodes are EXACTLY the reach-universe skus (divePoolBySku.keys) — REAL products
// only, NO virtual/hub nodes (round-1 blocker #4: a category bridge must be a real
// edge between real products, never a synthetic node that fakes the diameter).
// Edges are TAGGED by EdgeKind so the <=4 census and the on-screen rail verify and
// render the SAME edge set. Pure; nothing reads it until the hop UI (P8) wires it.
//
// Step 4 = skeleton. Step 5 (this) = compat edges, FILTERED through crossesSystem so
// a hop can never smuggle a physically-incompatible supply<->drainage jump
// (round-3 blocker-4). Steps 6-8 add variant / kit / category.

import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show WaterSystem, kVerifiedSpecs;
import 'package:buildsmart/data/related_info.dart' show compatibleProductsFor;
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

/// Pure DIRECTED product graph. Nodes == divePoolBySku.keys; adjacency is
/// per-source so a directed all-pairs BFS over [neighborsOf] matches the asymmetric
/// on-screen rail (round-2 blocker: an undirected backbone bound does not transfer
/// to a directed rail).
class HopGraph {
  HopGraph._(this._adj);

  /// An EMPTY-edge graph over every reach-universe sku — the skeleton.
  factory HopGraph.skeleton() => HopGraph._(_emptyAdj());

  /// The populated graph. Step 5 adds compat edges; steps 6-8 add variant / kit /
  /// category. Built once by the hop UI / census.
  factory HopGraph.build() {
    final adj = _emptyAdj();
    _addCompatEdges(adj);
    return HopGraph._(adj);
  }

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
