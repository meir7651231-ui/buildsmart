// The journey model produced by the journey decomposer (DECOMP-DEPTH phase N).
// Where logic opens an ENGINE, data an ENTITY, and primitives the FLOOR, this
// opens the MOVEMENT between screens — the user's journey.
//
// BuildSmart routes with Navigator 1.0 IMPERATIVE: no router, no named table.
// `MaterialApp.home = OnboardingGate`; every transition is an un-named
// `MaterialPageRoute` pushed via `Navigator.push`, by the convention
// `static Route route([params])`; back is `Navigator.pop(ctx, value)`. So the
// graph is invisible to any route-table tool — you recover it only by reading
// the pushes.
//
//   node  = a screen (route-addressable if it exposes `static Route route()`).
//   edge  = a transition: from → to · trigger · params · kind.
//
// kinds:
//   push          — `Navigator.push(ctx, Target.route(...))` (the convention).
//   raw-push      — `Navigator.push(ctx, MaterialPageRoute(builder: …=>T()))`
//                   with NO `route()` (an off-convention screen: InstallStudio,
//                   Audit — step 78 gap).
//   pop-return    — `Navigator.pop(ctx, value)`: the screen returns a VALUE up
//                   (scanner/camera hand a result back to their caller).
//   provider-swap — a Navigator-INVISIBLE hop through one of the 3 bypass
//                   surfaces (`mainTabProvider` tabs · `storeSectionProvider`
//                   enum · `startupStepProvider`). These carry CENTRAL journey
//                   arcs (browse → cart → orders) yet no route tool can see them.
//
// Read-only: the decomposer documents the graph and flags the gaps (dead
// IntelRouteObserver, route-less screens, dormant flag-gated edges); it never
// adds a router or rewires a push.

/// One transition between screens.
class JourneyEdge {
  const JourneyEdge({
    required this.from,
    required this.to,
    required this.trigger,
    required this.kind,
    required this.line,
    this.params = '',
    this.dormant = false,
    this.gate,
  });

  /// The screen the transition leaves (the enclosing class).
  final String from;

  /// The screen (or bypass target, e.g. `Store/cart`) it lands on.
  final String to;

  /// The enclosing method — the handler that fires it (`onTap`, `build`, …).
  final String trigger;

  /// push · raw-push · pop-return · provider-swap.
  final String kind;

  /// 1-indexed source line of the transition.
  final int line;

  /// The route arguments carried, if any (`section: s`).
  final String params;

  /// True when the edge sits behind a feature flag (default-OFF → not walked
  /// today). A documented dormant arc, not a dead one.
  final bool dormant;

  /// The gate condition when [dormant] — the `if (...)` the edge lives under.
  final String? gate;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'from': from,
        'to': to,
        'trigger': trigger,
        'kind': kind,
        'line': line,
        if (params.isNotEmpty) 'params': params,
        if (dormant) 'dormant': true,
        if (gate != null) 'gate': gate,
      };
}

/// One screen node.
class JourneyNode {
  const JourneyNode({
    required this.screen,
    required this.line,
    this.routeAddressable = false,
    this.routeParams = '',
    this.returnsValue = false,
    this.bypassSurface,
  });

  final String screen;
  final int line;

  /// Exposes `static Route route([params])` — reachable by the convention.
  final bool routeAddressable;

  /// The `route()` parameter list, if any (`{required LipskeySection section}`).
  final String routeParams;

  /// Pops a VALUE back to its caller (`Navigator.pop(ctx, result)`).
  final bool returnsValue;

  /// When set, this node hosts a Navigator-bypass surface (step 73):
  /// `tabs` (IndexedStack + mainTabProvider) · `store-section`
  /// (storeSectionProvider enum) · `startup` (startupStepProvider + PopScope).
  final String? bypassSurface;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'screen': screen,
        'line': line,
        if (routeAddressable) 'routeAddressable': true,
        if (routeParams.isNotEmpty) 'routeParams': routeParams,
        if (returnsValue) 'returnsValue': true,
        if (bypassSurface != null) 'bypassSurface': bypassSurface,
      };
}

/// The journey decomposition of one module (a screen .dart file).
class JourneyModuleDecomposition {
  JourneyModuleDecomposition({
    required this.module,
    required this.sourcePath,
    required this.nodes,
    required this.edges,
  });

  final String module;
  final String sourcePath;
  final List<JourneyNode> nodes;
  final List<JourneyEdge> edges;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'module': module,
        'source': sourcePath,
        'nodeCount': nodes.length,
        'edgeCount': edges.length,
        'nodes': nodes.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
      };
}

/// The merged journey graph over many modules — the whole map.
class JourneyGraph {
  JourneyGraph({required this.nodes, required this.edges});

  /// Screen → node (deduped across modules).
  final Map<String, JourneyNode> nodes;
  final List<JourneyEdge> edges;

  /// Every screen reachable FROM [start] by walking edges (BFS, all kinds).
  Set<String> reachable(String start) {
    final seen = <String>{start};
    final queue = <String>[start];
    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      for (final e in edges) {
        if (e.from == cur && seen.add(e.to)) queue.add(e.to);
      }
    }
    return seen..remove(start);
  }

  bool hasPath(String from, String to) => reachable(from).contains(to);

  /// The direct out-edges of [screen].
  List<JourneyEdge> outOf(String screen) =>
      edges.where((e) => e.from == screen).toList();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'nodeCount': nodes.length,
        'edgeCount': edges.length,
        'nodes': nodes.values.map((n) => n.toJson()).toList(),
        'edges': edges.map((e) => e.toJson()).toList(),
      };
}
