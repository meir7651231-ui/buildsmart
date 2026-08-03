import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import 'models.dart';
import 'registry_index.dart';

/// The widget base classes that mark a class as a decomposable atom.
const _kWidgetBases = {
  'ConsumerWidget',
  'ConsumerStatefulWidget',
  'StatelessWidget',
  'StatefulWidget',
};

/// Framework / SDK constructors that are NEVER "floor" functions.
const _kFrameworkNames = {
  'SizedBox', 'Text', 'Container', 'Column', 'Row', 'Padding', 'Icon',
  'InkWell', 'GridView', 'ListView', 'Expanded', 'Flexible', 'Center',
  'Semantics', 'Opacity', 'BoxDecoration', 'Border', 'BorderRadius',
  'EdgeInsets', 'TextStyle', 'FilledButton', 'MaterialPageRoute', 'Spacer',
  'LinearGradient', 'RoundedRectangleBorder', 'Color', 'Alignment',
  'SliverGridDelegateWithFixedCrossAxisCount', 'CfgText', 'CfgVisible',
  'SmartCartLine',
};

/// Decompose one screen [sourcePath] into atoms, cross-checking registry ids
/// against [registry]. AST-only (no element resolution). [screenName] overrides
/// the logical screen key (the output dir + `screen` field); defaults to the
/// file basename — e.g. pass `contractor-home` for `smart_home_screen.dart`.
ScreenDecomposition decomposeScreen(
  String sourcePath,
  RegistryIndex registry, {
  String? screenName,
}) {
  final unit = parseFile(
    path: sourcePath,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;

  // 1 · index every widget class + top-level function in the file.
  final widgetClasses = <String, ClassDeclaration>{};
  final topFns = <String, FunctionDeclaration>{};
  for (final d in unit.declarations) {
    if (d is ClassDeclaration) {
      final base = d.extendsClause?.superclass.name.lexeme;
      if (base != null && _kWidgetBases.contains(base)) {
        widgetClasses[d.name.lexeme] = d;
      }
    } else if (d is FunctionDeclaration) {
      topFns[d.name.lexeme] = d;
    }
  }

  // 2 · the composer = the public (non-`_`) widget class. Ties → the one whose
  //     build instantiates the most sibling widgets.
  final publicWidgets =
      widgetClasses.keys.where((n) => !n.startsWith('_')).toList();
  String composerName;
  if (publicWidgets.length == 1) {
    composerName = publicWidgets.first;
  } else {
    publicWidgets.sort((a, b) => _instantiatedWidgets(
          widgetClasses[b]!,
          widgetClasses.keys.toSet(),
        ).length.compareTo(_instantiatedWidgets(
          widgetClasses[a]!,
          widgetClasses.keys.toSet(),
        ).length));
    composerName =
        publicWidgets.isNotEmpty ? publicWidgets.first : widgetClasses.keys.first;
  }
  final composer = widgetClasses[composerName]!;

  // 3 · sections = widgets the composer instantiates directly, PLUS widgets
  //     reached through an in-file dispatch function it calls (…SectionFor).
  final allWidgetNames = widgetClasses.keys.toSet();
  final sectionNames = <String>{};
  sectionNames.addAll(_instantiatedWidgets(composer, allWidgetNames));
  final sectionEnum = <String, String>{}; // widget → HomeSection member
  for (final fnName in _calledTopFns(composer, topFns.keys.toSet())) {
    final fn = topFns[fnName]!;
    sectionNames.addAll(_instantiatedWidgets(fn, allWidgetNames));
    sectionEnum.addAll(_switchEnumMap(fn, allWidgetNames));
  }
  sectionNames.remove(composerName);

  // 4 · atom order: composer first, then sections in source order.
  final orderedSections = widgetClasses.keys
      .where(sectionNames.contains)
      .toList();
  final atomOrder = <String>[composerName, ...orderedSections];

  // 5 · decompose each atom. A section's SUPPORT helpers (in-file widgets it
  //     composes that are NOT themselves atoms — cards, tiles, pads) roll UP into
  //     it, so e.g. `_SmartTreeCard`'s `add_to_cart` id is attributed to the
  //     `_SmartTreeRow` products section (else registry would read 5/6, not 6/6).
  final inFileFnNames = topFns.keys.toSet();
  final atomSet = atomOrder.toSet();
  final atoms = <Atom>[];
  final registryRefs = <RegistryRef>[];
  for (final name in atomOrder) {
    final decl = widgetClasses[name]!;
    final closure = _supportClosure(decl, widgetClasses, atomSet);
    final ex = _AtomExtractor(
      className: name,
      inFileFns: inFileFnNames,
      inFileWidgets: allWidgetNames,
      registry: registry,
    );
    for (final d in closure) {
      d.accept(ex);
    }
    atoms.add(Atom(
      name: name,
      role: name == composerName ? 'composer' : 'section',
      section: sectionEnum[name],
      nodes: ex.nodes,
      edges: ex.edges,
      flows: ex.flows,
      floor: ex.floor.toList()..sort(),
    ));
    for (final n in ex.nodes) {
      if (n.registryId != null) {
        registryRefs.add(RegistryRef(
          id: n.registryId!,
          ok: n.registryOk,
          atom: name,
        ));
      }
    }
  }

  // Dedupe registry refs by id (first atom wins), keep source order.
  final seen = <String>{};
  final dedupRefs = <RegistryRef>[];
  for (final r in registryRefs) {
    if (seen.add(r.id)) dedupRefs.add(r);
  }

  final screenKey = screenName ?? p.basenameWithoutExtension(sourcePath);
  return ScreenDecomposition(
    screen: screenKey,
    sourcePath: p.basename(sourcePath),
    atoms: atoms,
    registry: RegistryReconciliation(entries: dedupRefs),
  );
}

/// Widget class names instantiated anywhere inside [node] (a class/function).
Set<String> _instantiatedWidgets(AstNode node, Set<String> widgetNames) {
  final v = _InstanceCollector(widgetNames);
  node.accept(v);
  return v.found;
}

/// In-file top-level function names called inside [node].
Set<String> _calledTopFns(AstNode node, Set<String> fnNames) {
  final v = _CallCollector(fnNames);
  node.accept(v);
  return v.found;
}

/// From a `…SectionFor(x) => switch (x) { Enum.member => const _Widget() }`
/// body, map each widget → its `Enum.member` name.
Map<String, String> _switchEnumMap(FunctionDeclaration fn, Set<String> widgets) {
  final out = <String, String>{};
  final v = _SwitchEnumCollector(widgets, out);
  fn.accept(v);
  return out;
}

class _InstanceCollector extends RecursiveAstVisitor<void> {
  _InstanceCollector(this.widgetNames);
  final Set<String> widgetNames;
  final Set<String> found = <String>{};

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final t = node.constructorName.type.name.lexeme;
    if (widgetNames.contains(t)) found.add(t);
    super.visitInstanceCreationExpression(node);
  }

  // Unresolved AST parses a NON-const constructor call (`_SmartTreeCard(…)`) as
  // a MethodInvocation — catch those too, else the support closure misses them.
  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && widgetNames.contains(node.methodName.name)) {
      found.add(node.methodName.name);
    }
    super.visitMethodInvocation(node);
  }
}

class _CallCollector extends RecursiveAstVisitor<void> {
  _CallCollector(this.fnNames);
  final Set<String> fnNames;
  final Set<String> found = <String>{};

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target == null && fnNames.contains(node.methodName.name)) {
      found.add(node.methodName.name);
    }
    super.visitMethodInvocation(node);
  }
}

class _SwitchEnumCollector extends RecursiveAstVisitor<void> {
  _SwitchEnumCollector(this.widgets, this.out);
  final Set<String> widgets;
  final Map<String, String> out;

  @override
  void visitSwitchExpressionCase(SwitchExpressionCase node) {
    final pat = node.guardedPattern.pattern.toSource();
    // pattern like `HomeSection.categories`
    final member = pat.contains('.') ? pat.split('.').last.trim() : pat;
    final widget = _firstWidget(node.expression);
    if (widget != null && widgets.contains(widget)) out[widget] = member;
    super.visitSwitchExpressionCase(node);
  }

  String? _firstWidget(Expression e) {
    String? name;
    e.accept(_InstanceNameGrabber((n) => name ??= n));
    return name;
  }
}

class _InstanceNameGrabber extends RecursiveAstVisitor<void> {
  _InstanceNameGrabber(this.onFound);
  final void Function(String) onFound;
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    onFound(node.constructorName.type.name.lexeme);
    super.visitInstanceCreationExpression(node);
  }
}

/// The atom's class + the transitive in-file SUPPORT widgets it composes
/// (widgets that are not themselves atoms). Content in those helpers is the
/// atom's content, so it rolls up. Other atoms are boundaries — never entered.
List<ClassDeclaration> _supportClosure(
  ClassDeclaration atom,
  Map<String, ClassDeclaration> widgetClasses,
  Set<String> atomSet,
) {
  final out = <ClassDeclaration>[atom];
  final seen = <String>{atom.name.lexeme};
  final queue = <ClassDeclaration>[atom];
  while (queue.isNotEmpty) {
    final cur = queue.removeAt(0);
    for (final w in _instantiatedWidgets(cur, widgetClasses.keys.toSet())) {
      if (seen.contains(w) || atomSet.contains(w)) continue; // stop at atoms
      seen.add(w);
      final decl = widgetClasses[w];
      if (decl != null) {
        out.add(decl);
        queue.add(decl);
      }
    }
  }
  return out;
}

/// Per-atom extractor — walks the atom's class body (+ its support closure) and
/// pulls the three layers: nodes (object), edges (connections), flows
/// (behaviour), plus the external "floor" functions.
class _AtomExtractor extends RecursiveAstVisitor<void> {
  _AtomExtractor({
    required this.className,
    required this.inFileFns,
    required this.inFileWidgets,
    required this.registry,
  });

  final String className;
  final Set<String> inFileFns;
  final Set<String> inFileWidgets;
  final RegistryIndex registry;

  final List<AtomNode> nodes = <AtomNode>[];
  final List<AtomEdge> edges = <AtomEdge>[];
  final List<AtomFlow> flows = <AtomFlow>[];
  final Set<String> floor = <String>{};

  final Set<String> _edgeKeys = <String>{};
  final Set<String> _nodeKeys = <String>{};
  final Set<String> _flowKeys = <String>{};

  void _addEdge(AtomEdge e) {
    if (_edgeKeys.add('${e.kind}|${e.via}|${e.target}')) edges.add(e);
  }

  void _addFlow(AtomFlow f) {
    if (_flowKeys.add('${f.trigger}|${f.mechanism}|${f.detail}|${f.effect}')) {
      flows.add(f);
    }
  }

  /// Mutating notifier methods that count as WRITES (with `.state =`).
  static const _mutators = {
    'add', 'addAll', 'remove', 'removeWhere', 'removeAt', 'toggle', 'clear',
    'set', 'update', 'put', 'delete', 'insert',
  };

  // ── Layer 1 · nodes (object) ───────────────────────────────────────────────
  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    _creationNode(node.constructorName.type.name.lexeme, node.argumentList);
    super.visitInstanceCreationExpression(node);
  }

  /// Node detection shared by the `const`-form (InstanceCreationExpression) and
  /// the unresolved-AST non-const form (MethodInvocation) of a constructor call.
  void _creationNode(String type, ArgumentList argList) {
    final args = argList.arguments;
    String? litAt(int i) {
      if (i < args.length && args[i] is SimpleStringLiteral) {
        return (args[i] as SimpleStringLiteral).value;
      }
      return null;
    }

    if (type == 'CfgText') {
      final id = litAt(0);
      final text = litAt(1);
      if (id != null) {
        _addNode(AtomNode(
          kind: 'cfgText',
          text: text ?? '',
          registryId: id,
          registryOk: registry.has(id),
        ));
      }
    } else if (type == 'CfgVisible') {
      final id = litAt(0);
      if (id != null) {
        _addNode(AtomNode(
          kind: 'cfgVisible',
          text: '',
          registryId: id,
          registryOk: registry.has(id),
        ));
      }
    } else if (type == 'Text') {
      final t = litAt(0);
      if (t != null) _addNode(AtomNode(kind: 'text', text: t));
    } else if (inFileWidgets.contains(type)) {
      // A string literal passed positionally to an in-file widget is visible
      // copy (section titles via `_SectionTitle('…')`, empty cards, …).
      final t = litAt(0);
      if (t != null) _addNode(AtomNode(kind: 'text', text: t));
    }
  }

  void _addNode(AtomNode n) {
    final key = '${n.kind}|${n.text}|${n.registryId ?? ''}';
    if (_nodeKeys.add(key)) nodes.add(n);
  }

  // ── Layer 2 · edges (connections) + floor ──────────────────────────────────
  @override
  void visitMethodInvocation(MethodInvocation node) {
    final method = node.methodName.name;
    final targetSrc = node.target?.toSource();

    // A non-const constructor call parses as a MethodInvocation — feed it to the
    // node detector too (this is how CfgText/CfgVisible ids are captured).
    if (node.target == null &&
        (method == 'CfgText' ||
            method == 'CfgVisible' ||
            method == 'Text' ||
            inFileWidgets.contains(method))) {
      _creationNode(method, node.argumentList);
    }

    // gated-by: modOn(ref,'module') / featOn(ref,'module','feature').
    if (_isGate(node)) {
      final keys = node.argumentList.arguments
          .whereType<SimpleStringLiteral>()
          .map((s) => s.value)
          .join('.');
      _addEdge(AtomEdge(kind: 'gated-by', via: method, target: keys));
      super.visitMethodInvocation(node);
      return;
    }

    // reads: ref.watch(X) / ref.read(X) — unless this read is the BASE of a
    // write (`.state =` / a mutator), which is recorded as a write instead.
    if (targetSrc == 'ref' && (method == 'watch' || method == 'read')) {
      if (!_isWriteBase(node)) {
        final arg = node.argumentList.arguments.isEmpty
            ? ''
            : _providerName(node.argumentList.arguments.first.toSource());
        _addEdge(AtomEdge(kind: 'reads', via: method, target: arg));
      }
    }

    // writes: ref.read(X.notifier).<mutator>(…).
    if (_mutators.contains(method) && _isNotifierChain(node.target)) {
      final base = _notifierProvider(node.target!);
      if (base != null) {
        _addEdge(AtomEdge(kind: 'writes', via: method, target: base));
      }
    }

    // actions: Navigator push, and show*/open* helpers (incl. showToast).
    if (method == 'push') {
      _addEdge(AtomEdge(
        kind: 'action',
        via: 'push',
        target: _routeName(node.argumentList.arguments),
      ));
    } else if (node.target == null &&
        (method.startsWith('show') || method.startsWith('open'))) {
      _addEdge(AtomEdge(kind: 'action', via: method, target: method));
    }

    // floor: a bare call to an external, lowercase-named function — not in this
    // file, not a framework/widget name, not an action (external helpers like
    // groupThousands / productImage / cfgRadius).
    if (node.target == null &&
        !inFileFns.contains(method) &&
        !inFileWidgets.contains(method) &&
        !_kFrameworkNames.contains(method) &&
        !(method.startsWith('show') || method.startsWith('open')) &&
        _looksLikeFunction(method)) {
      floor.add(method);
    }

    super.visitMethodInvocation(node);
  }

  /// True when [readNode] (a `ref.read/watch(...)`) feeds a `.state =` or a
  /// mutator call — i.e. it is the base of a WRITE, not a standalone read.
  bool _isWriteBase(MethodInvocation readNode) {
    final parent = readNode.parent;
    if (parent is MethodInvocation &&
        parent.target == readNode &&
        _mutators.contains(parent.methodName.name)) {
      return true;
    }
    // ref.read(X.notifier).state = v  → PropertyAccess('.state') → Assignment.
    if (parent is PropertyAccess &&
        parent.propertyName.name == 'state' &&
        parent.parent is AssignmentExpression) {
      return true;
    }
    return false;
  }

  // ── Layer 2/3 · `.state =` writes (also outside callbacks) ──────────────────
  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final lhs = node.leftHandSide.toSource();
    if (lhs.contains('.notifier') && lhs.endsWith('.state')) {
      _addEdge(AtomEdge(
        kind: 'writes',
        via: 'state=',
        target: _providerName(lhs),
      ));
    }
    super.visitAssignmentExpression(node);
  }

  // gate: modOn / featOn calls are section gates.
  bool _isGate(MethodInvocation node) =>
      node.target == null &&
      (node.methodName.name == 'modOn' || node.methodName.name == 'featOn');

  // ── Layer 2 · gated-by + Layer 3 · rule flows ──────────────────────────────
  @override
  void visitIfStatement(IfStatement node) {
    // `if (cond) return const SizedBox.shrink();` → the atom is gated by cond.
    final then = node.thenStatement;
    final isShrinkGuard = then.toSource().contains('SizedBox.shrink');
    if (isShrinkGuard) {
      _addEdge(AtomEdge(
        kind: 'gated-by',
        via: _gateVia(node.expression),
        target: node.expression.toSource(),
      ));
      _addFlow(AtomFlow(
        trigger: 'build',
        mechanism: 'rule',
        detail: 'if (${node.expression.toSource()})',
        effect: 'hidden (SizedBox.shrink)',
      ));
    }
    super.visitIfStatement(node);
  }

  // ── Layer 3 · verb flows (callbacks) ───────────────────────────────────────
  @override
  void visitNamedExpression(NamedExpression node) {
    final label = node.name.label.name;
    if (label == 'onTap' || label == 'onPressed') {
      final body = node.expression;
      _collectCallbackFlows(label, body);
    }
    super.visitNamedExpression(node);
  }

  void _collectCallbackFlows(String trigger, Expression body) {
    // find the verbs (calls) inside the callback and name their effect.
    final calls = <MethodInvocation>[];
    body.accept(_MethodGrabber(calls.add));
    for (final c in calls) {
      final m = c.methodName.name;
      final tSrc = c.target?.toSource() ?? '';
      String? effect;
      String detail = c.toSource();
      if (detail.length > 80) detail = '${detail.substring(0, 77)}…';
      if (m == 'push') {
        effect = 'navigate → ${_routeName(c.argumentList.arguments)}';
      } else if (m == 'showToast') {
        effect = 'toast';
      } else if (_isNotifierChain(c.target)) {
        effect = 'write → ${_notifierProvider(c.target!)}';
      } else if (m.startsWith('open') || m.startsWith('show')) {
        effect = 'open → $m';
      } else if (tSrc.contains('.notifier')) {
        effect = 'write → ${_providerName(tSrc)}';
      }
      if (effect != null) {
        _addFlow(AtomFlow(
          trigger: trigger,
          mechanism: 'verb',
          detail: detail,
          effect: effect,
        ));
      }
    }
    // assignment writes: `ref.read(X.notifier).state = v`.
    body.accept(_AssignGrabber((assign) {
      final lhs = assign.leftHandSide.toSource();
      if (lhs.contains('.notifier') && lhs.endsWith('.state')) {
        final prov = _providerName(lhs);
        _addEdge(AtomEdge(kind: 'writes', via: 'state=', target: prov));
        _addFlow(AtomFlow(
          trigger: trigger,
          mechanism: 'verb',
          detail: '${assign.toSource().length > 80 ? '${assign.toSource().substring(0, 77)}…' : assign.toSource()}',
          effect: 'write → $prov',
        ));
      }
    }));
  }

  // ── helpers ────────────────────────────────────────────────────────────────
  String _gateVia(Expression e) {
    final s = e.toSource();
    if (s.contains('modOn')) return 'modOn';
    if (s.contains('featOn')) return 'featOn';
    if (s.startsWith('k') || s.contains('kProfile') || s.contains('kSmart')) {
      return 'const-flag';
    }
    return 'guard';
  }

  static final _lowerFirst = RegExp(r'^[a-z]');
  bool _looksLikeFunction(String name) => _lowerFirst.hasMatch(name);

  bool _isNotifierChain(Expression? target) {
    if (target == null) return false;
    final s = target.toSource();
    return s.contains('.notifier') && s.startsWith('ref.read');
  }

  String? _notifierProvider(Expression target) {
    final s = target.toSource();
    return _providerName(s);
  }

  /// Extract the provider name from a `ref.read(X.notifier)` / `X.notifier.state`
  /// / `ref.watch(X)` source string → `X`.
  String _providerName(String src) {
    var s = src;
    final readIdx = s.indexOf('ref.read(');
    if (readIdx >= 0) {
      s = s.substring(readIdx + 'ref.read('.length);
      final close = s.indexOf(')');
      if (close >= 0) s = s.substring(0, close);
    }
    s = s.replaceAll('.notifier', '').replaceAll('.state', '').trim();
    return s;
  }

  String _routeName(NodeList<Expression> args) {
    if (args.isEmpty) return 'route';
    final s = args.first.toSource();
    // `X.route()` → X ; `MaterialPageRoute(builder: (_) => const Y())` → Y
    final routeCall = RegExp(r'(\w+)\.route\(').firstMatch(s);
    if (routeCall != null) return routeCall.group(1)!;
    final ctor = RegExp(r'=>\s*const\s+(\w+)\(').firstMatch(s);
    if (ctor != null) return ctor.group(1)!;
    return s.length > 40 ? '${s.substring(0, 37)}…' : s;
  }
}

class _MethodGrabber extends RecursiveAstVisitor<void> {
  _MethodGrabber(this.onFound);
  final void Function(MethodInvocation) onFound;
  @override
  void visitMethodInvocation(MethodInvocation node) {
    onFound(node);
    super.visitMethodInvocation(node);
  }
}

class _AssignGrabber extends RecursiveAstVisitor<void> {
  _AssignGrabber(this.onFound);
  final void Function(AssignmentExpression) onFound;
  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    onFound(node);
    super.visitAssignmentExpression(node);
  }
}
