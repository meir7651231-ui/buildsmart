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
              RegExp(r'cache|index', caseSensitive: false).hasMatch(n)) {
            caches.add(n);
          }
        }
      }
    }
  }

  final paramSets = <String, Set<String>>{}; // fn → its param names
  for (final e in topFns.entries) {
    paramSets[e.key] = _paramNames(e.value);
  }

  // ── per-function DIRECT facts (needed before transitive propagation) ───────
  final direct = <String, _Facts>{};
  for (final e in topFns.entries) {
    direct[e.key] = _collectFacts(
      e.value,
      moduleFns: topFns.keys.toSet(),
      constNames: constNames,
      globalNames: globalNames,
      params: paramSets[e.key]!,
    );
  }

  // ── reverse call-graph (called-by) ────────────────────────────────────────
  final calledBy = <String, Set<String>>{for (final n in topFns.keys) n: <String>{}};
  for (final e in direct.entries) {
    for (final c in e.value.moduleCalls) {
      if (calledBy.containsKey(c)) calledBy[c]!.add(e.key);
    }
  }

  final targets = only != null
      ? {if (topFns.containsKey(only)) only: topFns[only]!}
      : topFns;

  final atoms = <LogicAtom>[];
  for (final e in targets.entries) {
    atoms.add(_buildAtom(
      name: e.key,
      decl: e.value,
      facts: direct[e.key]!,
      direct: direct,
      calledBy: (calledBy[e.key]!.toList()..sort()),
    ));
  }

  return ModuleDecomposition(
    module: moduleName ?? p.basenameWithoutExtension(sourcePath),
    sourcePath: sourcePath,
    atoms: atoms,
    caches: caches..sort(),
  );
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

Set<String> _paramNames(FunctionDeclaration d) {
  final out = <String>{};
  final params = d.functionExpression.parameters?.parameters ?? const [];
  for (final param in params) {
    final n = param.name?.lexeme;
    if (n != null) out.add(n);
  }
  return out;
}

_Facts _collectFacts(
  FunctionDeclaration decl, {
  required Set<String> moduleFns,
  required Set<String> constNames,
  required Set<String> globalNames,
  required Set<String> params,
}) {
  final f = _Facts();
  final body = decl.functionExpression.body;
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
  });

  final _Facts f;
  final Set<String> moduleFns;
  final Set<String> constNames;
  final Set<String> globalNames;
  final Set<String> locals;
  final Set<String> params;
  final Set<String> bodyLocals;

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
      base.startsWith('_') && base.toLowerCase().contains('cache');

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
    // Writes to a cache / global (index or member assignment on a non-local).
    final lhs = node.leftHandSide;
    final base = _baseName(lhs);
    if (base != null && !locals.contains(base)) {
      if (globalNames.contains(base) || constNames.contains(base)) {
        _addWrite('cache', base);
      }
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
  required String name,
  required FunctionDeclaration decl,
  required _Facts facts,
  required Map<String, _Facts> direct,
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
  for (final callee in facts.moduleCalls) {
    final cf = direct[callee];
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

  final steps = _algorithmSteps(decl);
  final contract = _inferContract(
    decl: decl,
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
    fn: name,
    kind: 'top-level-function',
    signature: _signature(decl),
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

String _signature(FunctionDeclaration d) {
  final params = d.functionExpression.parameters?.toSource() ?? '()';
  final ret = d.returnType?.toSource() ?? 'dynamic';
  return '$params -> $ret';
}

/// Walk the body's top-level statements into ordered algorithm steps. An
/// early-return `if` is a precond; a `while`/`for` is a loop (its body is walked
/// one level deeper for branch/effect steps); a var-decl is compute/init; a bare
/// return is the terminal.
List<LogicStep> _algorithmSteps(FunctionDeclaration d) {
  final body = d.functionExpression.body;
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
  required FunctionDeclaration decl,
  required _Facts facts,
  required List<LogicWrite> writes,
  required List<LogicStep> steps,
}) {
  final params = decl.functionExpression.parameters?.toSource() ?? '()';
  final ret = decl.returnType?.toSource() ?? 'dynamic';
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
