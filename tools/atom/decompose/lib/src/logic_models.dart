// The logic-atom model produced by the logic decomposer (Phase 0 of
// DECOMP-DEPTH). Where [models.dart] decomposes a WIDGET into object/connections/
// behaviour, this decomposes a FUNCTION / METHOD / ENGINE — the layer the widget
// graph named but never opened.
//
//   Layer 1 · עצם     (object)      — signature + embedded constants.
//   Layer 2 · חיבורים (connections) — reads · writes · calls · called-by ·
//                                     gated-by (the data-flow / call-graph).
//   Layer 3 · התנהגות (behaviour)   — the ALGORITHM as ordered steps
//                                     (precond → branch / formula / loop → effect).
//   Plus [LogicAtom.floor]    — the language-primitive / SDK calls it stands on.
//   Plus [LogicAtom.contract] — input → output · precond · postcond · invariants
//                               · null/throw · purity.
//
// reads/writes carry a `transitive` flag: a fact reached only THROUGH a call to
// another module function (e.g. findShortestPath "writes" _compatCache only via
// compatibleWith). The intra-file call-graph propagates these one hop.
//
// Every value object has a stable `toJson` so the emitters + golden test compare
// byte-for-byte.

/// A data-flow READ: a value the function consumes.
class LogicRead {
  const LogicRead({required this.kind, required this.name, this.transitive = false});

  /// 'param' · 'field' (a `this`/param field, e.g. `p.sku`) · 'global' (a
  /// top-level getter/var, e.g. `chainUniverse`) · 'const' (a `const` map/set,
  /// e.g. `kVerifiedSpecs`, `_supplyCats`).
  final String kind;
  final String name;

  /// True when this read is reached only through a call to another module
  /// function, not the body itself.
  final bool transitive;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        'name': name,
        if (transitive) 'transitive': true,
      };

  String get key => '$kind|$name';
}

/// A data-flow WRITE: a mutation / side effect the function performs.
class LogicWrite {
  const LogicWrite({required this.kind, required this.name, this.transitive = false});

  /// 'cache' (memo map, e.g. `_compatCache`) · 'state' (`state=` / notifier) ·
  /// 'io' (prefs/firestore) · 'nav' (`Navigator.*`) · 'toast' ·
  /// 'mutation' (in-place on an argument/collection, e.g. `list.insert`).
  final String kind;
  final String name;
  final bool transitive;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        'name': name,
        if (transitive) 'transitive': true,
      };

  String get key => '$kind|$name';
}

/// A CALL edge to another module function (SDK / framework calls are `floor`).
class LogicCall {
  const LogicCall({required this.name, this.module = true});

  final String name;

  /// True when the callee is defined in the SAME file (module-internal) — the
  /// call-graph resolves it; false = out-of-file module function.
  final bool module;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'module': module};
}

/// A single step of the algorithm IR.
class LogicStep {
  const LogicStep({required this.kind, required this.detail});

  /// 'precond' (early-return guard) · 'compute' (a local binding) ·
  /// 'init' (state/accumulator setup) · 'loop' (while/for) · 'branch' (if/switch
  /// inside a loop) · 'formula' (a pure arithmetic expression) · 'effect' (a
  /// write/return inside the flow) · 'return' (terminal return).
  final String kind;
  final String detail;

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'kind': kind, 'detail': detail};
}

/// The input→output contract inferred from the signature + body.
class LogicContract {
  const LogicContract({
    required this.input,
    required this.output,
    required this.purity,
    List<String>? precond,
    List<String>? postcond,
    List<String>? invariants,
    this.nullReturn,
    List<String>? throws,
  })  : precond = precond ?? const <String>[],
        postcond = postcond ?? const <String>[],
        invariants = invariants ?? const <String>[],
        throws = throws ?? const <String>[];

  final String input;
  final String output;

  /// 'pure' · 'deterministic-side-effecting' (writes only a transparent cache) ·
  /// 'side-effecting' (state/io/nav/toast) · 'nondeterministic' (DateTime.now /
  /// Random / IO read).
  final String purity;

  final List<String> precond;
  final List<String> postcond;
  final List<String> invariants;

  /// The condition under which the function returns null (when the return type
  /// is nullable), else null.
  final String? nullReturn;
  final List<String> throws;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'input': input,
        'output': output,
        'purity': purity,
        'precond': precond,
        'postcond': postcond,
        'invariants': invariants,
        if (nullReturn != null) 'nullReturn': nullReturn,
        'throws': throws,
      };
}

/// One decomposed logic atom — a function / method / engine.
class LogicAtom {
  LogicAtom({
    required this.fn,
    required this.kind,
    required this.signature,
    required this.contract,
    List<String>? constants,
    List<LogicRead>? reads,
    List<LogicWrite>? writes,
    List<LogicCall>? calls,
    List<String>? calledBy,
    List<String>? gatedBy,
    List<LogicStep>? steps,
    List<String>? floor,
  })  : constants = constants ?? <String>[],
        reads = reads ?? <LogicRead>[],
        writes = writes ?? <LogicWrite>[],
        calls = calls ?? <LogicCall>[],
        calledBy = calledBy ?? <String>[],
        gatedBy = gatedBy ?? <String>[],
        steps = steps ?? <LogicStep>[],
        floor = floor ?? <String>[];

  /// The function name (e.g. `findShortestPath`, `_edgeCost`).
  final String fn;

  /// 'top-level-function' · 'method' · 'getter' · 'notifier-method'.
  final String kind;

  /// The rendered signature: `(params) -> ReturnType`.
  final String signature;

  /// Literals baked into the body (defaults, magic numbers, sentinels).
  final List<String> constants;

  final List<LogicRead> reads;
  final List<LogicWrite> writes;
  final List<LogicCall> calls;

  /// Module functions that invoke this one (reverse call-graph, intra-file).
  final List<String> calledBy;

  /// External gates guarding the body — `if(kFlag)` · `if(role==)` ·
  /// `if(tradeId!=…)` · try/on-Object kill-switch.
  final List<String> gatedBy;

  final List<LogicStep> steps;

  /// Language-primitive / SDK calls the body leans on (the floor).
  final List<String> floor;

  final LogicContract contract;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'fn': fn,
        'kind': kind,
        'object': <String, dynamic>{
          'signature': signature,
          'constants': constants,
        },
        'connections': <String, dynamic>{
          'reads': reads.map((r) => r.toJson()).toList(),
          'writes': writes.map((w) => w.toJson()).toList(),
          'calls': calls.map((c) => c.toJson()).toList(),
          'calledBy': calledBy,
          'gatedBy': gatedBy,
        },
        'behaviour': <String, dynamic>{
          'steps': steps.map((s) => s.toJson()).toList(),
        },
        'floor': floor,
        'contract': contract.toJson(),
      };
}

/// The whole logic decomposition of one module (.dart file in logic/state/domain).
class ModuleDecomposition {
  ModuleDecomposition({
    required this.module,
    required this.sourcePath,
    required this.atoms,
    List<String>? caches,
  }) : caches = caches ?? <String>[];

  /// The module key (file basename sans `.dart`, e.g. `install_engine`).
  final String module;
  final String sourcePath;
  final List<LogicAtom> atoms;

  /// File-level mutable caches / hidden state (top-level non-const vars) — the
  /// "hidden state" debt the god-module carries. Documented, never refactored.
  final List<String> caches;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'module': module,
        'source': sourcePath,
        'atomCount': atoms.length,
        if (caches.isNotEmpty) 'caches': caches,
        'atoms': atoms.map((a) => a.toJson()).toList(),
      };
}
