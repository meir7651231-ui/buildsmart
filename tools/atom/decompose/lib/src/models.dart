// The 3-layer atom model produced by the decomposer.
//
//   Layer 1 · עצם   (object)      — [AtomNode]s: the visible text literals the
//                                    atom paints (Text / CfgText / CfgVisible),
//                                    each cross-checked against element_registry.
//   Layer 2 · חיבורים (connections) — [AtomEdge]s: reads / writes / actions /
//                                    gated-by — how the atom is wired to state.
//   Layer 3 · התנהגות (behaviour)  — [AtomFlow]s: trigger → mechanism → effect.
//
// Plus [Atom.floor] — the external (out-of-file) functions the atom leans on.
//
// Everything is a plain value object with a stable `toJson` so the emitters and
// the golden test compare byte-for-byte.

/// A visible text node the atom renders.
class AtomNode {
  const AtomNode({
    required this.kind,
    required this.text,
    this.registryId,
    this.registryOk = false,
  });

  /// 'text' (plain `Text`) · 'cfgText' (`CfgText` id+literal) ·
  /// 'cfgVisible' (`CfgVisible` composite-hide wrapper, id only).
  final String kind;

  /// The literal string. Empty for a `cfgVisible` wrapper (no own text).
  final String text;

  /// The element_registry id, for cfgText / cfgVisible. Null for plain Text.
  final String? registryId;

  /// True when [registryId] is present AND found in element_registry.
  final bool registryOk;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        'text': text,
        if (registryId != null) 'registryId': registryId,
        if (registryId != null) 'registryOk': registryOk,
      };
}

/// A wiring connection from the atom to app state / navigation.
class AtomEdge {
  const AtomEdge({required this.kind, required this.via, required this.target});

  /// 'reads' · 'writes' · 'action' · 'gated-by'.
  final String kind;

  /// The call form: watch/read (reads) · state=/add/... (writes) ·
  /// push/showX/openX (action) · modOn/featOn/const-flag (gated-by).
  final String via;

  /// The provider / route / gate expression the edge points at.
  final String target;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'kind': kind,
        'via': via,
        'target': target,
      };
}

/// A behaviour flow: a [trigger] runs a [mechanism] over [detail], producing
/// [effect].
class AtomFlow {
  const AtomFlow({
    required this.trigger,
    required this.mechanism,
    required this.detail,
    required this.effect,
  });

  /// Where it fires: 'onTap' · 'onPressed' · 'itemBuilder' · 'build' …
  final String trigger;

  /// 'verb' (a call) · 'rule' (if / ?:) · 'formula' (a pure expression).
  final String mechanism;

  /// The call / condition / expression text.
  final String detail;

  /// The resulting effect (a write, a navigation, a toast, a render decision).
  final String effect;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'trigger': trigger,
        'mechanism': mechanism,
        'detail': detail,
        'effect': effect,
      };
}

/// One decomposed atom — the composer or a section widget.
class Atom {
  Atom({
    required this.name,
    required this.role,
    this.section,
    List<AtomNode>? nodes,
    List<AtomEdge>? edges,
    List<AtomFlow>? flows,
    List<String>? floor,
  })  : nodes = nodes ?? <AtomNode>[],
        edges = edges ?? <AtomEdge>[],
        flows = flows ?? <AtomFlow>[],
        floor = floor ?? <String>[];

  /// The class name (e.g. `SmartHomeBody`, `_Departments`).
  final String name;

  /// 'composer' (arranges sections) · 'section' (a content block).
  final String role;

  /// The HomeSection enum name a section maps to, when the composer dispatches
  /// it through a `…SectionFor` switch (else null).
  final String? section;

  final List<AtomNode> nodes;
  final List<AtomEdge> edges;
  final List<AtomFlow> flows;

  /// External (out-of-file) functions the atom calls — the "floor" it stands on.
  final List<String> floor;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'role': role,
        if (section != null) 'section': section,
        'object': <String, dynamic>{
          'nodes': nodes.map((n) => n.toJson()).toList(),
        },
        'connections': <String, dynamic>{
          'edges': edges.map((e) => e.toJson()).toList(),
        },
        'behaviour': <String, dynamic>{
          'flows': flows.map((f) => f.toJson()).toList(),
        },
        'floor': floor,
      };
}

/// The screen-level registry reconciliation.
class RegistryReconciliation {
  RegistryReconciliation({required this.entries});

  /// Each id used by the screen → whether element_registry carries it.
  final List<RegistryRef> entries;

  int get matched => entries.where((e) => e.ok).length;
  int get total => entries.length;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'matched': matched,
        'total': total,
        'summary': '$matched/$total',
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}

class RegistryRef {
  const RegistryRef({required this.id, required this.ok, required this.atom});

  final String id;
  final bool ok;
  final String atom; // the atom that references the id

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'id': id, 'ok': ok, 'atom': atom};
}

/// The whole decomposition of one screen file.
class ScreenDecomposition {
  ScreenDecomposition({
    required this.screen,
    required this.sourcePath,
    required this.atoms,
    required this.registry,
  });

  /// The screen key (e.g. `smart_home_screen`) — the file basename sans `.dart`.
  final String screen;
  final String sourcePath;
  final List<Atom> atoms;
  final RegistryReconciliation registry;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'screen': screen,
        'source': sourcePath,
        'atomCount': atoms.length,
        'atoms': atoms.map((a) => a.toJson()).toList(),
        'registry': registry.toJson(),
      };
}
