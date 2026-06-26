// hop_graph.dart — the ONE between-products navigation graph (build-plan v3, P0
// step 4: SKELETON; edges populated in steps 5-8). The <=4 contract is "<=4 taps to
// a RELATED product" over this graph.
//
// Nodes are EXACTLY the reach-universe skus (divePoolBySku.keys) — REAL products
// only, NO virtual/hub nodes (round-1 blocker #4: a category bridge must be a real
// edge between real products, never a synthetic node that fakes the diameter).
// Edges are TAGGED by EdgeKind so the <=4 census and the on-screen rail verify and
// render the SAME edge set. Pure; nothing reads it until the hop UI (P8) wires it.

import 'package:buildsmart/features/word_finder/word_finder_engine.dart'
    show divePoolBySku;

/// The kind of a navigational edge between two real products. The <=4 graph is the
/// UNION of these (round-2/3: honestly "navigational adjacency", not "verified
/// physical connection only" — a category edge is allowed but tagged as such).
enum EdgeKind { compat, variant, kit, category }

/// Pure DIRECTED product graph. Nodes == divePoolBySku.keys; adjacency is
/// per-source so a directed all-pairs BFS over [neighborsOf] matches the asymmetric
/// on-screen rail (round-2 blocker: an undirected backbone bound does not transfer
/// to a directed rail). Edge population is steps 5-8; the skeleton is edge-empty so
/// the <=4 claim is NOT asserted yet (honest).
class HopGraph {
  HopGraph._(this._adj);

  /// An EMPTY-edge graph over every reach-universe sku — the skeleton. Steps 5-8
  /// populate the adjacency (compat / variant / kit / category).
  factory HopGraph.skeleton() => HopGraph._({
        for (final sku in divePoolBySku.keys) sku: <String, Set<EdgeKind>>{},
      });

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
