import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:path/path.dart' as p;

import 'logic_models.dart';

/// SDK / language names that are never "module calls" — they are the floor.
const _kFloorNames = {
  'SplayTreeMap', 'Map', 'Set', 'List', 'int', 'double', 'String', 'bool',
  'putIfAbsent', 'add', 'addAll', 'remove', 'removeLast', 'removeAt', 'insert',
  'intersection', 'union', 'difference', 'contains', 'isEmpty', 'isNotEmpty',
  'firstKey', 'lastKey', 'first', 'last', 'length', 'toList', 'toSet', 'where',
  'map', 'any', 'every', 'sort', 'compareTo', 'firstWhere', 'reduce', 'fold',
  'clamp', 'round', 'toDouble', 'abs', 'tryParse', 'parse', 'replaceAll', 'trim',
  'keys', 'values', 'entries', 'containsKey', 'update', 'generate', 'join',
};

/// Well-known write forms → their write-kind.
const _kIoNames = {'setString', 'setInt', 'setBool', 'remove', 'set', 'add', 'update', 'commit'};

/// Decompose one logic module [sourcePath] into logic atoms — one per top-level
/// function (Phase 0: top-level functions; methods/notifiers land in a later
/// slice). AST-only, read-only. When [only] is set, decompose just that function
/// (the golden path). [moduleName] overrides the module key.
ModuleDecomposition decomposeModule(
  String sourcePath, {
  String? only,
  String? moduleName,
}) {
  final unit = parseFile(
    path: sourcePath,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).unit;

  // ── index top-level declarations ──────────────────────────────────────────
  final topFns = <String, FunctionDeclaration>{};
  final constNames = <String>{}; // top-level `const` maps/sets/vars
  final globalNames = <String>{}; // top-level non-const getters/vars (state/caches)
  final caches = <String>[]; // top-level MUTABLE vars (hidden state debt)

  for (final d in unit.declarations) {
    if (d is FunctionDeclaration) {
      topFns[d.name.lexeme] = d;
    } else if (d is TopLevelVariableDeclaration) {
      final mutableColl = _isMutableCollectionDecl(d.variables);
      for (final v in d.variables.variables) {
        final n = v.name.lexeme;
        if (d.variables.isConst) {
          constNames.add(n);
        } else {
          globalNames.add(n);
          // A top-level `final`/`var`/`late` whose CONTENTS are mutable (a Map/
          // List/Set — even when the reference is `final`) is hidden runtime
          // state: the god-module's caches (`_compatCache`, `_syntheticPipeCache`,
          // `_skuCache`). Surface it as debt, never refactor it.
          if (!d.variables.isFinal ||
              mutableColl ||
              RegExp(r'cache|memo|index', caseSensitive: false).hasMatch(n)) {
            caches.add(n);
          }
        }
      }
    }
  }

  // ── index classes: fields + methods (DECOMP-DEPTH phase L, method slice) ────
  final classes = <String, ClassDeclaration>{};
  for (final d in unit.declarations) {
    if (d is ClassDeclaration) classes[d.name.lexeme] = d;
  }

  // Every callable in the module — top-level functions AND class methods — under
  // one model so a single code path decomposes both.
  final callables = <String, _Callable>{}; // qname → callable
  final classOf = <String, String?>{}; // qname → owning class (null for top-level)
  final classFields = <String, Set<String>>{}; // class → field names
  final classMethods = <String, Set<String>>{}; // class → method simple-names
  final notifierClasses = <String>{}; // classes that own a `state` (StateNotifier)

  for (final f in topFns.values) {
    final c = _Callable.fromFunction(f);
    callables[c.qname] = c;
    classOf[c.qname] = null;
  }
  for (final cls in classes.values) {
    final owner = cls.name.lexeme;
    final fields = <String>{};
    final methods = <String>{};
    final base = cls.extendsClause?.superclass.name.lexeme ?? '';
    final isNotifier =
        RegExp(r'(StateNotifier|ChangeNotifier|Notifier|AsyncNotifier)').hasMatch(base);
    if (isNotifier) notifierClasses.add(owner);
    for (final m in cls.members) {
      if (m is FieldDeclaration) {
        for (final v in m.fields.variables) {
          fields.add(v.name.lexeme);
        }
      } else if (m is MethodDeclaration && m.body is! EmptyFunctionBody) {
        methods.add(m.name.lexeme);
        final c = _Callable.fromMethod(m, owner, isNotifier);
        callables[c.qname] = c;
        classOf[c.qname] = owner;
      }
    }
    classFields[owner] = fields;
    classMethods[owner] = methods;
  }

  // ── per-callable DIRECT facts ──────────────────────────────────────────────
  final direct = <String, _Facts>{};
  for (final e in callables.entries) {
    final owner = classOf[e.key];
    direct[e.key] = _collectFacts(
      e.value,
      // sibling methods + all top-level fns are the module-call universe.
      moduleFns: {...topFns.keys, if (owner != null) ...classMethods[owner]!},
      constNames: constNames,
      globalNames: globalNames,
      params: e.value.paramNames,
      fields: owner != null ? classFields[owner]! : const <String>{},
      isNotifier: owner != null && notifierClasses.contains(owner),
    );
  }

  // ── reverse call-graph (called-by), resolved within class then top-level ───
  final calledBy = <String, Set<String>>{for (final k in callables.keys) k: <String>{}};
  for (final e in direct.entries) {
    final owner = classOf[e.key];
    for (final c in e.value.moduleCalls) {
      final calleeQ = _resolveCallee(c, owner, callables);
      if (calleeQ != null) calledBy[calleeQ]!.add(e.key);
    }
  }

  final targets = only != null
      ? {
          for (final e in callables.entries)
            if (e.key == only || e.value.name == only) e.key: e.value,
        }
      : callables;

  final atoms = <LogicAtom>[];
  for (final e in targets.entries) {
    final owner = classOf[e.key];
    atoms.add(_buildAtom(
      call: e.value,
      facts: direct[e.key]!,
      direct: direct,
      owner: owner,
      classFields: owner != null ? classFields[owner]! : const <String>{},
      isNotifier: owner != null && notifierClasses.contains(owner),
      callables: callables,
      calledBy: (calledBy[e.key]!.map((q) => callables[q]!.label).toList()..sort()),
    ));
  }
  // stable order: top-level first (file order via topFns), then methods.
  return ModuleDecomposition(
    module: moduleName ?? p.basenameWithoutExtension(sourcePath),
    sourcePath: sourcePath,
    atoms: atoms,
    caches: caches..sort(),
  );
}

/// Resolve a simple call name from a callable in [owner] to a callable qname:
/// a sibling method (`Owner.name`) wins over a top-level function (`name`).
String? _resolveCallee(String simple, String? owner, Map<String, _Callable> all) {
  if (owner != null && all.containsKey('$owner.$simple')) return '$owner.$simple';
  if (all.containsKey(simple)) return simple;
  return null;
}

/// A unit of logic — a top-level function OR a class method/getter/setter.
class _Callable {
  _Callable({
    required this.name,
    required this.kind,
    required this.body,
    required this.parameters,
    required this.returnType,
    this.owner,
    this.isSetter = false,
  });

  factory _Callable.fromFunction(FunctionDeclaration d) => _Callable(
        name: d.name.lexeme,
        kind: 'top-level-function',
        body: d.functionExpression.body,
        parameters: d.functionExpression.parameters,
        returnType: d.returnType,
      );

  factory _Callable.fromMethod(MethodDeclaration m, String owner, bool isNotifier) {
    final kind = m.isGetter
        ? 'getter'
        : m.isSetter
            ? 'setter'
            : isNotifier
                ? 'notifier-method'
                : 'method';
    return _Callable(
      name: m.name.lexeme,
      kind: kind,
      body: m.body,
      parameters: m.parameters,
      returnType: m.returnType,
      owner: owner,
      isSetter: m.isSetter,
    );
  }

  final String name;
  final String kind;
  final FunctionBody body;
  final FormalParameterList? parameters;
  final TypeAnnotation? returnType;
  final String? owner;
  final bool isSetter;

  // A setter `set x` is `Owner.x=` so it never collides with a getter/method `x`.
  String get qname =>
      owner == null ? name : '$owner.$name${isSetter ? '=' : ''}';
  String get label => owner == null ? name : '$owner.$name${isSetter ? '=' : ''}';

  Set<String> get paramNames {
    final out = <String>{};
    for (final p in parameters?.parameters ?? const <FormalParameter>[]) {
      final n = p.name?.lexeme;
      if (n != null) out.add(n);
    }
    return out;
  }
}

// ─── direct-fact collection ───────────────────────────────────────────────────

class _Facts {
  final reads = <String, LogicRead>{}; // key → read
  final writes = <String, LogicWrite>{};
  final moduleCalls = <String>[]; // ordered, deduped
  final floor = <String>[];
  final gatedBy = <String>[];
  final constants = <String>[];
  final throwsAt = <String>[];
  bool nondeterministic = false;
}

/// True when the declaration's contents are a mutable collection (a Map/List/Set
/// type, or a `{…}`/`[…]`/`<…>{}` initializer) — mutable even behind `final`.
bool _isMutableCollectionDecl(VariableDeclarationList vars) {
  final t = vars.type?.toSource() ?? '';
  if (RegExp(r'^(Map|List|Set|HashMap|SplayTreeMap|LinkedHashMap)\b').hasMatch(t)) {
    return true;
  }
  for (final v in vars.variables) {
    final init = v.initializer;
    if (init is SetOrMapLiteral || init is ListLiteral) return true;
    final s = init?.toSource() ?? '';
    if (RegExp(r'^(<[^>]*>)?[\[{]').hasMatch(s)) return true;
  }
  return false;
}

_Facts _collectFacts(
  _Callable call, {
  required Set<String> moduleFns,
  required Set<String> constNames,
  required Set<String> globalNames,
  required Set<String> params,
  Set<String> fields = const <String>{},
  bool isNotifier = false,
}) {
  final f = _Facts();
  final body = call.body;
  // Body-bound names (var-decls, closure params, patterns, for/catch vars) —
  // mutating one of these is NOT a side effect (a private accumulator). Mutating
  // a formal PARAM, by contrast, is observable by the caller (an in-place write).
  final bodyLocals = <String>{};
  body.accept(_LocalCollector(bodyLocals));
  final locals = <String>{...params, ...bodyLocals};

  body.accept(_FactVisitor(
    f: f,
    moduleFns: moduleFns,
    constNames: constNames,
    globalNames: globalNames,
    locals: locals,
    params: params,
    bodyLocals: bodyLocals,
    fields: fields,
    isNotifier: isNotifier,
  ));
  return f;
}

/// Collects every locally-bound name so a free identifier can be told apart from
/// a bound one WITHOUT type resolution: var-decls · for-each vars · catch params
/// · closure formal parameters · record/object pattern variables.
class _LocalCollector extends RecursiveAstVisitor<void> {
  _LocalCollector(this.locals);
  final Set<String> locals;

  @override
  void visitVariableDeclaration(VariableDeclaration node) {
    locals.add(node.name.lexeme);
    super.visitVariableDeclaration(node);
  }

  @override
  void visitDeclaredIdentifier(DeclaredIdentifier node) {
    locals.add(node.name.lexeme);
    super.visitDeclaredIdentifier(node);
  }

  @override
  void visitCatchClause(CatchClause node) {
    final e = node.exceptionParameter?.name.lexeme;
    if (e != null) locals.add(e);
    final st = node.stackTraceParameter?.name.lexeme;
    if (st != null) locals.add(st);
    super.visitCatchClause(node);
  }

  @override
  void visitSimpleFormalParameter(SimpleFormalParameter node) {
    final n = node.name?.lexeme;
    if (n != null) locals.add(n);
    super.visitSimpleFormalParameter(node);
  }

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    locals.add(node.name.lexeme);
    super.visitFieldFormalParameter(node);
  }

  @override
  void visitSuperFormalParameter(SuperFormalParameter node) {
    locals.add(node.name.lexeme);
    super.visitSuperFormalParameter(node);
  }

  @override
  void visitDeclaredVariablePattern(DeclaredVariablePattern node) {
    locals.add(node.name.lexeme);
    super.visitDeclaredVariablePattern(node);
  }
}

class _FactVisitor extends RecursiveAstVisitor<void> {
  _FactVisitor({
    required this.f,
    required this.moduleFns,
    required this.constNames,
    required this.globalNames,
    required this.locals,
    required this.params,
    required this.bodyLocals,
    this.fields = const <String>{},
    this.isNotifier = false,
  });

  final _Facts f;
  final Set<String> moduleFns;
  final Set<String> constNames;
  final Set<String> globalNames;
  final Set<String> locals;
  final Set<String> params;
  final Set<String> bodyLocals;

  /// This method's owning-class instance fields (for a class method).
  final Set<String> fields;

  /// The owning class is a StateNotifier/ChangeNotifier — `state` is its value.
  final bool isNotifier;

  void _addRead(String kind, String name) {
    final r = LogicRead(kind: kind, name: name);
    f.reads.putIfAbsent(r.key, () => r);
  }

  void _addWrite(String kind, String name) {
    final w = LogicWrite(kind: kind, name: name);
    f.writes.putIfAbsent(w.key, () => w);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final n = node.name;
    if (constNames.contains(n)) {
      _addRead('const', n);
    } else if (isNotifier && n == 'state' && !locals.contains(n)) {
      _addRead('field', 'state'); // the notifier's own value
    } else if (fields.contains(n) && !locals.contains(n)) {
      _addRead('field', n); // an instance field of the owning class
    } else if (globalNames.contains(n) && !locals.contains(n)) {
      _addRead('global', n);
    } else if (_isExternalValueRef(node)) {
      // An IMPORTED top-level const/global (kVerifiedSpecs, chainUniverse, …).
      // No resolution: classify by convention. `kXxx` = const table; a plain
      // lowerCamel free name = a global getter/var.
      final kind = RegExp(r'^_?k[A-Z0-9]').hasMatch(n) ? 'const' : 'global';
      _addRead(kind, n);
    }
    super.visitSimpleIdentifier(node);
  }

  /// True when [node] is a value reference to a name that is not local, not a
  /// module function, not an SDK primitive, and not a Type/enum — i.e. an
  /// imported top-level const or global read.
  bool _isExternalValueRef(SimpleIdentifier node) {
    final n = node.name;
    if (locals.contains(n) || moduleFns.contains(n) || _kFloorNames.contains(n)) {
      return false;
    }
    if (node.inDeclarationContext()) return false;
    // Only value-shaped names: lowerCamel or k-prefixed. PascalCase = a
    // Type/enum reference, never a value read.
    if (!RegExp(r'^_?[a-z]').hasMatch(n)) return false;
    final parent = node.parent;
    // The method name of a call — handled by visitMethodInvocation.
    if (parent is MethodInvocation && identical(parent.methodName, node)) {
      return false;
    }
    // The member side of `a.b` — `b` is a field/getter on the receiver, not a
    // free global. (The receiver `a`, if free, is visited on its own.)
    if (parent is PrefixedIdentifier && identical(parent.identifier, node)) {
      return false;
    }
    if (parent is PropertyAccess && identical(parent.propertyName, node)) {
      return false;
    }
    // A named-argument / statement label (`maxDepth:`), never a read.
    if (parent is Label) return false;
    // A `break outer;` / `continue outer;` loop-label reference.
    if (parent is BreakStatement || parent is ContinueStatement) return false;
    // A named-expression's name is a Label already; the constructor/enum member
    // names are handled above. Everything else that reaches here is a value.
    return true;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final name = node.methodName.name;
    final target = node.target;
    if (target == null) {
      // Bare call: a module function, or an SDK/free function.
      if (moduleFns.contains(name)) {
        if (!f.moduleCalls.contains(name)) f.moduleCalls.add(name);
      } else {
        _addFloor(name);
        if (name == 'now') f.nondeterministic = true;
      }
    } else {
      // Method call on a receiver → floor (SDK) + possible mutation/IO write.
      _addFloor(name);
      _classifyWrite(node);
    }
    super.visitMethodInvocation(node);
  }

  void _addFloor(String name) {
    if (!f.floor.contains(name)) f.floor.add(name);
  }

  static const _mutating = {
    'insert', 'add', 'addAll', 'removeAt', 'removeWhere', 'remove', 'clear',
    'putIfAbsent', 'update', 'updateAll', 'sort',
  };

  void _classifyWrite(MethodInvocation node) {
    final name = node.methodName.name;
    final targetSrc = node.target?.toSource() ?? '';
    // Navigation.
    if (targetSrc == 'Navigator' || targetSrc.startsWith('Navigator.of')) {
      _addWrite('nav', 'Navigator.$name');
      return;
    }
    // Toast.
    if (name == 'showToast' || name == 'showGlobalToast') {
      _addWrite('toast', name);
      return;
    }
    // Notifier / listenable.
    if (name == 'notifyListeners') {
      _addWrite('state', 'notifyListeners');
      return;
    }
    // IO on prefs/firestore-ish receivers.
    if (_kIoNames.contains(name) &&
        RegExp(r'prefs|store|doc|collection|ref', caseSensitive: false)
            .hasMatch(targetSrc)) {
      _addWrite('io', '$targetSrc.$name');
      return;
    }
    // Mutating a collection/map in place. The RECEIVER decides the kind:
    //   • a body-local accumulator → NOT a side effect (skip);
    //   • a private cache (`_…Cache` / `_…`)  → cache write (memoisation);
    //   • a formal param            → mutation write (caller-observable);
    //   • a global collection       → state/mutation write.
    if (_mutating.contains(name)) {
      final base = _receiverBase(node.target!);
      if (base == null) return;
      if (bodyLocals.contains(base)) return; // private accumulator — no effect
      if (_looksCache(base)) {
        _addWrite('cache', base);
      } else if (globalNames.contains(base)) {
        _addWrite('state', base);
      } else if (params.contains(base)) {
        _addWrite('mutation', '$base.$name');
      } else if (_isExternalName(base)) {
        // Mutating an IMPORTED table at runtime — e.g. `kVerifiedSpecs.putIfAbsent`
        // in _syntheticPipe, which writes a synthetic spec into the "const"
        // registry. Hidden runtime state; surfaced as a state write, not fixed.
        _addWrite('state', base);
      }
    }
  }

  bool _looksCache(String base) =>
      base.startsWith('_') &&
      RegExp(r'cache|memo').hasMatch(base.toLowerCase());

  /// An imported top-level name (const table / global) — not local, not a module
  /// function, value-shaped (lowerCamel or `kXxx`, never a PascalCase Type).
  bool _isExternalName(String base) =>
      !locals.contains(base) &&
      !moduleFns.contains(base) &&
      !_kFloorNames.contains(base) &&
      RegExp(r'^_?[a-z]|^k[A-Z0-9]').hasMatch(base);

  /// The root identifier of a receiver chain (`a.b.c(...)` → `a`, `xs[i]` → `xs`).
  String? _receiverBase(Expression e) {
    if (e is SimpleIdentifier) return e.name;
    if (e is PrefixedIdentifier) return e.prefix.name;
    if (e is MethodInvocation) return e.target != null ? _receiverBase(e.target!) : null;
    if (e is IndexExpression) return _receiverBase(e.realTarget);
    if (e is PropertyAccess) return e.target != null ? _receiverBase(e.target!) : null;
    return null;
  }

  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    super.visitFunctionExpressionInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final t = node.constructorName.type.name.lexeme;
    _addFloor(t);
    if (t == 'Random' || t == 'DateTime') f.nondeterministic = true;
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final lhs = node.leftHandSide;
    // `super.state = …` / `state = …` in a StateNotifier is the state write.
    final superState = lhs is PropertyAccess &&
        lhs.target is SuperExpression &&
        lhs.propertyName.name == 'state';
    final base = _baseName(lhs);
    if (base != null && !locals.contains(base)) {
      if (isNotifier && (base == 'state' || superState)) {
        _addWrite('state', 'state'); // the notifier's own value
      } else if (fields.contains(base)) {
        _addWrite('field', base); // an instance field (e.g. _loaded race-guard)
      } else if (globalNames.contains(base) || constNames.contains(base)) {
        _addWrite('cache', base);
      }
    } else if (superState) {
      _addWrite('state', 'state');
    }
    super.visitAssignmentExpression(node);
  }

  String? _baseName(Expression e) {
    if (e is IndexExpression) return _baseName(e.realTarget);
    if (e is PrefixedIdentifier) return e.prefix.name;
    if (e is PropertyAccess) return _baseName(e.target ?? e);
    if (e is SimpleIdentifier) return e.name;
    return null;
  }

  @override
  void visitThrowExpression(ThrowExpression node) {
    f.throwsAt.add(_short(node.expression.toSource()));
    super.visitThrowExpression(node);
  }

  @override
  void visitIntegerLiteral(IntegerLiteral node) {
    _maybeConst(node);
    super.visitIntegerLiteral(node);
  }

  @override
  void visitBinaryExpression(BinaryExpression node) {
    // Capture shift sentinels like `1 << 30`.
    if (node.operator.lexeme == '<<') {
      final s = node.toSource();
      if (!f.constants.contains(s)) f.constants.add(s);
    }
    super.visitBinaryExpression(node);
  }

  void _maybeConst(IntegerLiteral node) {
    // Record a default value on a named parameter (e.g. maxDepth = 6).
    final parent = node.parent;
    if (parent is DefaultFormalParameter) {
      final n = parent.name?.lexeme;
      if (n != null) f.constants.add('$n=${node.literal.lexeme}');
    }
  }
}

// ─── atom assembly (steps · contract · transitive rollup) ─────────────────────

LogicAtom _buildAtom({
  required _Callable call,
  required _Facts facts,
  required Map<String, _Facts> direct,
  required String? owner,
  required Set<String> classFields,
  required bool isNotifier,
  required Map<String, _Callable> callables,
  required List<String> calledBy,
}) {
  // 1-hop transitive rollup: fold each module callee's DIRECT reads/writes in,
  // marked transitive (findShortestPath "reads" kVerifiedSpecs / "writes"
  // _compatCache only THROUGH its callees).
  final reads = <String, LogicRead>{
    for (final r in facts.reads.values) r.key: r,
  };
  final writes = <String, LogicWrite>{
    for (final w in facts.writes.values) w.key: w,
  };

  // Callees to roll up: the explicit module calls, PLUS — when this method writes
  // `state` on a StateNotifier that OVERRIDES `set state` — the setter itself.
  // That is hard-case #6: `SmartCartNotifier.add` is one line (`state = […]`),
  // but the real behaviour (the `_loaded` race-guard + the async `_persist()`
  // IO) lives in the setter it triggers.
  final rollup = <String>[
    for (final c in facts.moduleCalls) _resolveCallee(c, owner, callables) ?? c,
  ];
  if (owner != null &&
      facts.writes.values.any((w) => w.kind == 'state' && w.name == 'state') &&
      callables.containsKey('$owner.state=')) {
    final setterQ = '$owner.state=';
    rollup.add(setterQ);
    // Reach ONE hop past the setter too, so `add` surfaces the async `_persist()`
    // IO the setter triggers — the full hard-case #6 (`_loaded` guard + IO).
    final sf = direct[setterQ];
    if (sf != null) {
      for (final sc in sf.moduleCalls) {
        final q = _resolveCallee(sc, owner, callables);
        if (q != null) rollup.add(q);
      }
    }
  }
  for (final calleeQ in rollup) {
    final cf = direct[calleeQ];
    if (cf == null) continue;
    for (final r in cf.reads.values) {
      reads.putIfAbsent(
          r.key, () => LogicRead(kind: r.kind, name: r.name, transitive: true));
    }
    for (final w in cf.writes.values) {
      writes.putIfAbsent(
          w.key, () => LogicWrite(kind: w.kind, name: w.name, transitive: true));
    }
  }

  final steps = _algorithmSteps(call);
  final contract = _inferContract(
    call: call,
    facts: facts,
    writes: writes.values.toList(),
    steps: steps,
  );

  // A name that is WRITTEN (a cache/state you populate) is classified as a
  // write, not a read — even though `putIfAbsent`/`[]=` also reads it.
  final writtenNames = {for (final w in writes.values) w.name};
  reads.removeWhere((_, r) => writtenNames.contains(r.name));

  // Deterministic ordering.
  final readList = reads.values.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final writeList = writes.values.toList()
    ..sort((a, b) => a.key.compareTo(b.key));
  final gates = facts.gatedBy..sort();

  return LogicAtom(
    fn: call.label,
    kind: call.kind,
    signature: _signature(call),
    constants: facts.constants,
    reads: readList,
    writes: writeList,
    calls: [for (final c in facts.moduleCalls) LogicCall(name: c, module: true)],
    calledBy: calledBy,
    gatedBy: gates,
    steps: steps,
    floor: facts.floor..sort(),
    contract: contract,
  );
}

String _signature(_Callable c) {
  final params = c.parameters?.toSource() ?? (c.isSetter ? '' : '()');
  final ret = c.returnType?.toSource() ?? (c.isSetter ? 'void' : 'dynamic');
  final kw = c.kind == 'getter' ? 'get ' : c.isSetter ? 'set ' : '';
  return '$kw$params -> $ret';
}

/// Walk the body's top-level statements into ordered algorithm steps. An
/// early-return `if` is a precond; a `while`/`for` is a loop (its body is walked
/// one level deeper for branch/effect steps); a var-decl is compute/init; a bare
/// return is the terminal.
List<LogicStep> _algorithmSteps(_Callable c) {
  final body = c.body;
  final steps = <LogicStep>[];
  if (body is! BlockFunctionBody) {
    // Expression-bodied function: one formula step.
    if (body is ExpressionFunctionBody) {
      steps.add(LogicStep(kind: 'formula', detail: _short(body.expression.toSource())));
    }
    return steps;
  }
  _walk(body.block.statements, steps, depth: 0);
  return steps;
}

void _walk(List<Statement> stmts, List<LogicStep> out, {required int depth}) {
  for (final s in stmts) {
    if (s is IfStatement) {
      final isGuard = _isEarlyExit(s);
      final cond = _short(s.expression.toSource());
      final then = _guardEffect(s.thenStatement);
      out.add(LogicStep(
        kind: isGuard && depth == 0 ? 'precond' : 'branch',
        detail: then == null ? 'if $cond' : 'if $cond → $then',
      ));
    } else if (s is WhileStatement) {
      out.add(LogicStep(kind: 'loop', detail: 'while ${_short(s.condition.toSource())}'));
      if (depth < 1 && s.body is Block) {
        _walk((s.body as Block).statements, out, depth: depth + 1);
      }
    } else if (s is ForStatement) {
      out.add(LogicStep(kind: 'loop', detail: 'for ${_short(_forHeader(s))}'));
      if (depth < 1 && s.body is Block) {
        _walk((s.body as Block).statements, out, depth: depth + 1);
      }
    } else if (s is VariableDeclarationStatement) {
      final v = s.variables.variables.first;
      final init = v.initializer;
      final kind = _isAccumulator(init) ? 'init' : 'compute';
      out.add(LogicStep(
          kind: kind,
          detail: '${v.name.lexeme} = ${_short(init?.toSource() ?? '')}'));
    } else if (s is ReturnStatement) {
      out.add(LogicStep(
          kind: 'return', detail: _short(s.expression?.toSource() ?? '(void)')));
    } else if (s is ExpressionStatement) {
      out.add(LogicStep(kind: 'effect', detail: _short(s.expression.toSource())));
    } else if (s is SwitchStatement) {
      out.add(LogicStep(kind: 'branch', detail: 'switch ${_short(s.expression.toSource())}'));
    }
  }
}

String _forHeader(ForStatement s) {
  final parts = s.forLoopParts;
  return parts.toSource();
}

/// An `if` whose then-branch is (or contains only) a return/continue/break —
/// i.e. a guard, not a computation branch.
bool _isEarlyExit(IfStatement s) {
  final t = s.thenStatement;
  if (t is ReturnStatement || t is ContinueStatement || t is BreakStatement) {
    return true;
  }
  if (t is Block && t.statements.length == 1) {
    final only = t.statements.first;
    return only is ReturnStatement ||
        only is ContinueStatement ||
        only is BreakStatement;
  }
  return false;
}

String? _guardEffect(Statement then) {
  Statement s = then;
  if (s is Block && s.statements.length == 1) s = s.statements.first;
  if (s is ReturnStatement) return 'return ${_short(s.expression?.toSource() ?? '(void)')}';
  if (s is ContinueStatement) return 'continue';
  if (s is BreakStatement) return 'break';
  return null;
}

/// A collection/accumulator initializer (a fresh map/list/set) → 'init'.
bool _isAccumulator(Expression? e) {
  if (e == null) return false;
  final src = e.toSource();
  return e is InstanceCreationExpression ||
      e is ListLiteral ||
      e is SetOrMapLiteral ||
      RegExp(r'^<[^>]*>[\[{]').hasMatch(src) ||
      src.startsWith('SplayTreeMap') ||
      src.startsWith('{') ||
      src.startsWith('[');
}

LogicContract _inferContract({
  required _Callable call,
  required _Facts facts,
  required List<LogicWrite> writes,
  required List<LogicStep> steps,
}) {
  final params = call.parameters?.toSource() ?? (call.isSetter ? '' : '()');
  final ret = call.returnType?.toSource() ?? (call.isSetter ? 'void' : 'dynamic');
  final nullable = ret.trimRight().endsWith('?');

  // Purity from writes.
  String purity;
  if (facts.nondeterministic) {
    purity = 'nondeterministic';
  } else if (writes.isEmpty) {
    purity = 'pure';
  } else if (writes.every((w) => w.kind == 'cache')) {
    purity = 'deterministic-side-effecting';
  } else {
    purity = 'side-effecting';
  }

  // null-return condition: the precond guards that return a null literal.
  String? nullReturn;
  final nullGuards = <String>[];
  for (final s in steps) {
    if (s.kind == 'precond' && s.detail.contains('return null')) {
      final m = RegExp(r'^if (.*) → return null$').firstMatch(s.detail);
      if (m != null) nullGuards.add(m.group(1)!);
    }
  }
  if (nullable && nullGuards.isNotEmpty) {
    nullReturn = '${nullGuards.join(' · ')} · or search exhausted';
  } else if (nullable) {
    nullReturn = 'no result';
  }

  // precond = the early-exit guards; postcond/invariants are left for the human
  // depth pass (the .md) — a mechanical extractor states control-flow, not intent.
  final precond = [
    for (final s in steps)
      if (s.kind == 'precond') s.detail,
  ];

  return LogicContract(
    input: params,
    output: ret,
    purity: purity,
    precond: precond,
    throws: facts.throwsAt,
    nullReturn: nullReturn,
  );
}

String _short(String s, [int max = 90]) {
  final one = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return one.length <= max ? one : '${one.substring(0, max - 1)}…';
}
