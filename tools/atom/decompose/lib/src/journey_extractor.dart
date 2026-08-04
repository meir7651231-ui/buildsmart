import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

import 'journey_models.dart';

/// Identifiers that are `X.route(` targets but NOT screens.
const _kNotScreens = {'Route', 'MaterialPageRoute', 'PageRoute', 'Navigator'};

final _routeCall = RegExp(r'\b([A-Z]\w*)\.route\s*\(([^;]*?)\)');
final _rawPush = RegExp(
    r'MaterialPageRoute(?:<[^>]*>)?\(\s*builder:\s*\([^)]*\)\s*=>\s*(?:const\s+)?([A-Z]\w*)\s*\(');
final _routeDef = RegExp(r'static\s+Route(?:<[^>]*>)?\s+route\s*\(([^)]*)\)');
final _popReturn = RegExp(r'Navigator\.pop\(\s*context\s*,');
final _providerSwap = RegExp(
    r'(mainTabProvider|storeSectionProvider|startupStepProvider)\.notifier\)\.state\s*(?:=\s*([^;\n,)]+)|(\+\+))');
final _flagCond = RegExp(r'[Ee]nabled|[Ff]lag|kEnable|dormant|feature', caseSensitive: true);

/// Decompose one screen module [sourcePath] into journey nodes + edges.
/// AST for structure (class / method ranges), source-scan for the edge grammar.
/// Read-only.
JourneyModuleDecomposition decomposeJourneys(
  String sourcePath, {
  String? moduleName,
}) {
  final parsed = parseFile(
    path: sourcePath,
    featureSet: FeatureSet.latestLanguageVersion(),
  );
  final unit = parsed.unit;
  final lineInfo = parsed.lineInfo;
  // Scan the RAW content (offsets align with the AST + lineInfo), but blank
  // comments to spaces first so a `Foo.route(` inside a doc-comment is not a
  // phantom edge. Same length + newlines preserved → offsets & lines unchanged.
  final fileSrc = _blankComments(File(sourcePath).readAsStringSync());

  // Class + method ranges (offset → owner), so `from`/`trigger` resolve.
  final classes = <_Range>[];
  final methods = <_Range>[];
  for (final d in unit.declarations) {
    if (d is ClassDeclaration) {
      classes.add(_Range(d.name.lexeme, d.offset, d.end));
      for (final m in d.members.whereType<MethodDeclaration>()) {
        methods.add(_Range(m.name.lexeme, m.offset, m.end));
      }
    }
  }

  final module = moduleName ?? p.basenameWithoutExtension(sourcePath);
  String ownerAt(int offset) =>
      classes.firstWhere((r) => r.contains(offset),
          orElse: () => _Range(module, -1, -1)).name;
  String triggerAt(int offset) =>
      methods.firstWhere((r) => r.contains(offset),
          orElse: () => _Range('(top)', -1, -1)).name;
  int lineAt(int offset) => lineInfo.getLocation(offset).lineNumber;

  // ── nodes: every screen class ─────────────────────────────────────────────
  final nodes = <JourneyNode>[];
  for (final d in unit.declarations.whereType<ClassDeclaration>()) {
    final name = d.name.lexeme;
    final src = fileSrc.substring(d.offset, d.end); // comment-blanked slice
    final routeDef = _routeDef.firstMatch(src);
    final returnsValue = _popReturn.hasMatch(src);
    nodes.add(JourneyNode(
      screen: name,
      line: lineAt(d.name.offset),
      routeAddressable: routeDef != null,
      routeParams: routeDef?.group(1)?.trim() ?? '',
      returnsValue: returnsValue,
      bypassSurface: _bypassSurface(src, fileSrc),
    ));
  }

  // ── edges: scan the whole file, resolve owner/trigger by offset ───────────
  final edges = <JourneyEdge>[];
  void addEdge(String to, String kind, int offset, {String params = ''}) {
    final from = ownerAt(offset);
    if (to == from) return; // a route() builder constructing its own screen
    final gate = _gateFor(fileSrc, offset);
    edges.add(JourneyEdge(
      from: from,
      to: to,
      trigger: triggerAt(offset),
      kind: kind,
      line: lineAt(offset),
      params: params,
      dormant: gate != null,
      gate: gate,
    ));
  }

  // convention pushes: `Target.route(args)`
  for (final m in _routeCall.allMatches(fileSrc)) {
    final target = m.group(1)!;
    if (_kNotScreens.contains(target)) continue;
    addEdge(target, 'push', m.start, params: m.group(2)!.trim());
  }
  // raw pushes: `MaterialPageRoute(builder: (_) => Target(...))` off-convention.
  for (final m in _rawPush.allMatches(fileSrc)) {
    addEdge(m.group(1)!, 'raw-push', m.start);
  }
  // provider-swaps: the 3 bypass surfaces.
  for (final m in _providerSwap.allMatches(fileSrc)) {
    final provider = m.group(1)!;
    final value = (m.group(2) ?? m.group(3) ?? '').trim();
    addEdge(_swapTarget(provider, value), 'provider-swap', m.start,
        params: value);
  }

  return JourneyModuleDecomposition(
    module: module,
    sourcePath: sourcePath,
    nodes: nodes,
    edges: edges,
  );
}

/// Merge many screen modules into one journey graph.
JourneyGraph decomposeJourneyGraph(List<String> sourcePaths) {
  final nodes = <String, JourneyNode>{};
  final edges = <JourneyEdge>[];
  for (final path in sourcePaths) {
    final m = decomposeJourneys(path);
    for (final n in m.nodes) {
      // keep the richer node (route-addressable / bypass wins over a bare ref).
      final prev = nodes[n.screen];
      if (prev == null ||
          (!prev.routeAddressable && n.routeAddressable) ||
          (prev.bypassSurface == null && n.bypassSurface != null)) {
        nodes[n.screen] = n;
      }
    }
    edges.addAll(m.edges);
  }
  return JourneyGraph(nodes: nodes, edges: edges);
}

/// The label a provider-swap lands on.
String _swapTarget(String provider, String value) {
  switch (provider) {
    case 'mainTabProvider':
      return 'HomeShell#tab$value';
    case 'storeSectionProvider':
      final sec = value.startsWith('StoreSection.')
          ? value.substring('StoreSection.'.length)
          : value;
      return 'Store/$sec';
    case 'startupStepProvider':
      return 'startup#${value == '++' ? 'next' : value}';
    default:
      return provider;
  }
}

/// The Navigator-bypass surface a class hosts (step 73), else null.
String? _bypassSurface(String classSrc, String fileSrc) {
  if (classSrc.contains('IndexedStack') && classSrc.contains('mainTabProvider')) {
    return 'tabs';
  }
  if (classSrc.contains('storeSectionProvider') &&
      (fileSrc.contains('enum StoreSection') || classSrc.contains('StoreSection.'))) {
    return 'store-section';
  }
  if (classSrc.contains('startupStepProvider') && classSrc.contains('PopScope')) {
    return 'startup';
  }
  return null;
}

/// If the edge at [offset] sits directly under a flag-ish `if (...)`, return the
/// condition (→ the edge is dormant); else null. Conservative: only the nearest
/// preceding `if (` within a small window, and only when its condition looks
/// like a feature flag.
String? _gateFor(String src, int offset) {
  final windowStart = offset - 220 < 0 ? 0 : offset - 220;
  final window = src.substring(windowStart, offset);
  final ifIdx = window.lastIndexOf('if (');
  if (ifIdx < 0) return null;
  final condStart = ifIdx + 'if ('.length;
  var depth = 1;
  final buf = StringBuffer();
  for (var i = condStart; i < window.length && depth > 0; i++) {
    final ch = window[i];
    if (ch == '(') depth++;
    if (ch == ')') {
      depth--;
      if (depth == 0) break;
    }
    buf.write(ch);
  }
  final cond = buf.toString().trim();
  return _flagCond.hasMatch(cond) ? cond : null;
}

/// Replace every `//…` and `/*…*/` comment with spaces of equal length, keeping
/// newlines — so offsets and line numbers stay identical while comment text can
/// no longer match an edge pattern.
String _blankComments(String s) {
  final out = s.split('');
  var i = 0;
  while (i < s.length) {
    if (s[i] == '/' && i + 1 < s.length && s[i + 1] == '/') {
      while (i < s.length && s[i] != '\n') {
        out[i] = ' ';
        i++;
      }
    } else if (s[i] == '/' && i + 1 < s.length && s[i + 1] == '*') {
      out[i] = ' ';
      out[i + 1] = ' ';
      i += 2;
      while (i < s.length && !(s[i] == '*' && i + 1 < s.length && s[i + 1] == '/')) {
        if (s[i] != '\n') out[i] = ' ';
        i++;
      }
      if (i + 1 < s.length) {
        out[i] = ' ';
        out[i + 1] = ' ';
        i += 2;
      }
    } else if (s[i] == "'" || s[i] == '"') {
      // skip string literals so a `//` inside a string isn't treated as comment
      final quote = s[i];
      i++;
      while (i < s.length && s[i] != quote) {
        if (s[i] == r'\' && i + 1 < s.length) i++;
        i++;
      }
      i++;
    } else {
      i++;
    }
  }
  return out.join();
}

class _Range {
  const _Range(this.name, this.offset, this.end);
  final String name;
  final int offset;
  final int end;
  bool contains(int o) => offset <= o && o < end;
}
