// The primitive-contract model produced by the primitive decomposer
// (DECOMP-DEPTH phase P). Where the logic decomposer opens an ENGINE and the
// data decomposer opens an ENTITY, this closes the FLOOR: it turns each
// floor-primitive — the smallest pure value-transformer an engine bottoms out
// on (`groupThousands`, `normSearch`, `validBusinessId`, `damerauLevenshtein`) —
// from a NAME into a CONTRACT.
//
//   name · file:line · signature · returns · EDGES · pure?
//
// The edge is the point: a primitive's real contract lives at its boundaries —
// `groupThousands(-3150)` returns the ABS ("3,150", caller prepends the sign),
// `normalizePhone('abc')` returns `""`, `validPositiveAmount(null)` is `false`,
// `validBusinessId` folds a 1-2-1-2 checksum mod-10, `fuzzyScore` returns `-1`
// for no-match, `promptSafeText` hard-caps at 600, `showToast` on an unmounted
// messenger is a silent no-op (and is NOT pure). Each documented edge is a
// `PrimitiveEdge` — a (signal → note) pair, the signal being the syntactic
// proof in the body, so step 70's `primitive_contract_test` can map every edge
// to an assertion.
//
// Read-only: the decomposer documents the contract; it never tightens or
// refactors the primitive.

/// One boundary of a primitive's contract — an edge case with the syntactic
/// signal that proves it in the body.
class PrimitiveEdge {
  const PrimitiveEdge({required this.signal, required this.note});

  /// The syntactic proof in the body (e.g. `.abs()`, `return -1`, `null-guard`).
  final String signal;

  /// The contract statement (e.g. `negative → absolute value`).
  final String note;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'signal': signal, 'note': note};
}

/// One decomposed primitive — a floor-level function turned into a contract.
class PrimitiveContract {
  PrimitiveContract({
    required this.name,
    required this.line,
    required this.signature,
    required this.returns,
    required this.pure,
    this.sideEffect,
    List<PrimitiveEdge>? edges,
  }) : edges = edges ?? <PrimitiveEdge>[];

  final String name;

  /// 1-indexed source line of the declaration (`file:line` anchors the row).
  final int line;

  /// The full signature — `(int n, {String prefix}) → String`.
  final String signature;

  /// The return type — the OUTPUT half of the contract.
  final String returns;

  /// True when the function is a pure value-transformer (no I/O, no mutation,
  /// deterministic). A `void` sink or a messenger/navigator/global touch → false.
  final bool pure;

  /// When [pure] is false, the one-line reason (the side effect it carries).
  final String? sideEffect;

  /// The documented contract edges (step 69 → step 70 assertions).
  final List<PrimitiveEdge> edges;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'line': line,
        'signature': signature,
        'returns': returns,
        'pure': pure,
        if (sideEffect != null) 'sideEffect': sideEffect,
        'edges': edges.map((e) => e.toJson()).toList(),
      };
}

/// The whole primitive decomposition of one module (a `logic/*` primitive file
/// or `widgets/toast.dart`).
class PrimitiveModuleDecomposition {
  PrimitiveModuleDecomposition({
    required this.module,
    required this.sourcePath,
    required this.primitives,
  });

  final String module;
  final String sourcePath;
  final List<PrimitiveContract> primitives;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'module': module,
        'source': sourcePath,
        'primitiveCount': primitives.length,
        'primitives': primitives.map((p) => p.toJson()).toList(),
      };
}
