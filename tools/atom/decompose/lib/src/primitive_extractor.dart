import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'primitive_models.dart';

/// Side-effect sinks — any of these in a body makes the primitive NON-pure.
const _kSinks = <String, String>{
  'showSnackBar': 'shows a SnackBar (UI side effect)',
  'clearSnackBars': 'mutates the messenger queue',
  'notifyListeners': 'notifies listeners',
  'Navigator.': 'navigates',
  '.currentState': 'reaches a global GlobalKey state',
  'print(': 'writes to the console',
  'SharedPreferences': 'touches persisted storage',
  'FirebaseFirestore': 'touches the network',
};

/// Decompose one primitive module [sourcePath] into per-function contracts.
/// AST-only, read-only. Every top-level function is a primitive; when [only] is
/// set, decompose just that one.
PrimitiveModuleDecomposition decomposePrimitives(
  String sourcePath, {
  String? only,
  String? moduleName,
}) {
  final parsed = parseFile(
    path: sourcePath,
    featureSet: FeatureSet.latestLanguageVersion(),
  );
  final unit = parsed.unit;
  final lineInfo = parsed.lineInfo;

  final primitives = <PrimitiveContract>[];
  for (final d in unit.declarations) {
    if (d is! FunctionDeclaration) continue;
    if (only != null && d.name.lexeme != only) continue;
    // Anchor on the declaration line (the name token), not the doc-comment
    // start — so `file:line` matches the signature line a reader jumps to.
    primitives.add(_contractOf(d, lineInfo.getLocation(d.name.offset).lineNumber));
  }

  return PrimitiveModuleDecomposition(
    module: moduleName ?? p.basenameWithoutExtension(sourcePath),
    sourcePath: sourcePath,
    primitives: primitives,
  );
}

PrimitiveContract _contractOf(FunctionDeclaration d, int line) {
  final expr = d.functionExpression;
  final params = expr.parameters?.toSource() ?? '()';
  final ret = d.returnType?.toSource() ?? (d.isGetter ? '' : 'dynamic');
  final signature = '$params → ${ret.isEmpty ? 'dynamic' : ret}';

  final body = expr.body;
  final src = body.toSource();

  // ── purity ────────────────────────────────────────────────────────────────
  var pure = true;
  String? sideEffect;
  if (ret == 'void') {
    pure = false;
    sideEffect = 'returns void — invoked for effect, not value';
  }
  for (final entry in _kSinks.entries) {
    if (src.contains(entry.key)) {
      pure = false;
      sideEffect = entry.value;
      break;
    }
  }

  // ── edges (ordered, deterministic — each tied to a syntactic signal) ───────
  final edges = <PrimitiveEdge>[];
  void add(bool when, String signal, String note) {
    if (when) edges.add(PrimitiveEdge(signal: signal, note: note));
  }

  final nullableParam = _hasNullableParam(expr.parameters);

  final emptyToStr = RegExp(r"isEmpty\)\s*return\s*''").hasMatch(src) ||
      RegExp(r'isEmpty\)\s*return\s*""').hasMatch(src);
  final emptyToFalse = src.contains('isEmpty') && src.contains('return false');

  final moneySign = RegExp(r"<\s*0\s*\?\s*'?-").hasMatch(src);
  add(src.contains('.abs()'), '.abs()',
      'negative input → absolute value (caller prepends the sign)');
  add(moneySign, 'n<0 ? "-"',
      'sign is placed BEFORE the symbol (never "symbol-minus")');
  add(!moneySign && RegExp(r'<\s*0\s*\?').hasMatch(src), 'lookup < 0',
      'a not-found lookup (index < 0) → the fallback branch');
  add(emptyToStr, 'isEmpty → ""',
      'no usable characters → "" (caller decides what empty means)');
  add(emptyToFalse && !emptyToStr, 'isEmpty → false',
      'empty input → false / no-match (short-circuits before the work)');
  add(RegExp(r'==\s*\w+\)\s*return\s*0').hasMatch(src), 'a==b → 0',
      'identical inputs → 0 (the trivial short-circuit)');
  add(RegExp(r'isEmpty\)\s*return\s+\w+\.length').hasMatch(src),
      'isEmpty → other.length',
      'one side empty → the other length (edit distance to "")');
  add(nullableParam && src.contains('!= null'), 'null-guard',
      'null argument → false / degrades (never throws on null)');
  add(RegExp(r'return\s+-1').hasMatch(src), 'return -1',
      'no match → -1 (sentinel, distinct from a real score of 0)');
  add(src.contains('substring(0,'), 'substring(0, maxLen)',
      'over the cap → truncated to maxLen');
  add(RegExp(r'%\s*10\s*==\s*0').hasMatch(src), '% 10 == 0',
      'invalid check digit → false (1-2-1-2 weighted checksum, mod 10)');
  add(RegExp(r'==\s*null\)\s*return;').hasMatch(src), 'null → no-op',
      'target not mounted → silent no-op (never a throw)');
  add(src.contains('.isAfter('), '.isAfter(',
      'boundary is strict (end must be strictly after start)');
  add(src.contains('~/'), '~/ (floor-div)',
      'integer floor division (tolerance = len ~/ 3 + 1)');
  add(src.contains('.toLowerCase()'), '.toLowerCase()',
      'case-folded to lowercase');
  add(src.contains(r"RegExp(r'\s+'), ' '"), 'replaceAll(\\s+ → " ")',
      'whitespace RUNS collapsed to a single space (conditional)');
  add(src.contains(r"RegExp(r'\s'), ''"), 'replaceAll(\\s → "")',
      'ALL whitespace removed (tight dedup key)');
  add(src.contains("kHebrewFinalFold["), 'final-fold table',
      'Hebrew final letters folded to base form (ך→כ …)');
  add(src.contains("RegExp('["), 'RegExp char-class strip',
      'Hebrew diacritics (niqqud) / punctuation stripped');
  add(src.contains('.trim()') && !emptyToStr, '.trim()',
      'surrounding whitespace trimmed');
  add(src.contains('.hasMatch('), 'RegExp.hasMatch',
      'a regex shape gate (returns the boolean match)');

  return PrimitiveContract(
    name: d.name.lexeme,
    line: line,
    signature: signature,
    returns: ret.isEmpty ? 'dynamic' : ret,
    pure: pure,
    sideEffect: sideEffect,
    edges: edges,
  );
}

bool _hasNullableParam(FormalParameterList? params) {
  if (params == null) return false;
  for (final param in params.parameters) {
    final inner = param is DefaultFormalParameter ? param.parameter : param;
    if (inner is SimpleFormalParameter) {
      final t = inner.type?.toSource() ?? '';
      if (t.endsWith('?')) return true;
    }
  }
  return false;
}
