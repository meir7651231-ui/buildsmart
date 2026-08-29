import 'dart:io';

import 'package:analyzer/dart/analysis/features.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:path/path.dart' as p;

import 'async_models.dart';

final _providerDef = RegExp(
    r'final\s+(\w+)\s*=\s*(StreamProvider|FutureProvider|AsyncNotifierProvider|StateNotifierProvider|StateProvider|Provider)\b');
final _whenCall = RegExp(r'(\w+)\.when\s*\(');
final _exceptionDef = RegExp(r'class\s+(\w+)\s+implements\s+Exception');

const _kAsyncKinds = {'StreamProvider', 'FutureProvider', 'AsyncNotifierProvider'};

/// Decompose one module [sourcePath] into its async surface — providers,
/// `.when` consumers, and typed exceptions. Source-scan over comment-blanked
/// content (offsets align with lineInfo). Read-only.
AsyncModuleDecomposition decomposeAsync(
  String sourcePath, {
  String? moduleName,
}) {
  final lineInfo = parseFile(
    path: sourcePath,
    featureSet: FeatureSet.latestLanguageVersion(),
  ).lineInfo;
  final src = _blankComments(File(sourcePath).readAsStringSync());
  int lineAt(int o) => lineInfo.getLocation(o).lineNumber;

  // ── providers ─────────────────────────────────────────────────────────────
  final providers = <AsyncProvider>[];
  for (final m in _providerDef.allMatches(src)) {
    final kind = m.group(2)!;
    final tail = src.substring(m.end, (m.end + 600).clamp(0, src.length));
    providers.add(AsyncProvider(
      name: m.group(1)!,
      kind: kind,
      async: _kAsyncKinds.contains(kind),
      backing: _backing(tail),
      line: lineAt(m.start),
    ));
  }

  // ── consumers (.when) ──────────────────────────────────────────────────────
  final consumers = <AsyncConsumer>[];
  for (final m in _whenCall.allMatches(src)) {
    final open = m.end - 1; // index of '('
    final region = _balanced(src, open);
    if (region == null) continue;
    final errorBody = _labelBody(region, 'error:');
    final dataBody = _labelBody(region, 'data:');
    consumers.add(AsyncConsumer(
      source: m.group(1)!,
      line: lineAt(m.start),
      loading: region.contains('loading:'),
      error: region.contains('error:'),
      data: region.contains('data:'),
      errorFoldsToEmpty: _looksEmpty(errorBody),
      emptyInData: dataBody.contains('isEmpty'),
    ));
  }

  // ── typed exceptions ───────────────────────────────────────────────────────
  final exceptions = <AsyncException>[];
  for (final m in _exceptionDef.allMatches(src)) {
    final name = m.group(1)!;
    final throwSites = RegExp('throw\\s+$name\\s*\\(').allMatches(src).length;
    exceptions.add(AsyncException(
      name: name,
      line: lineAt(m.start),
      throwSites: throwSites,
    ));
  }

  return AsyncModuleDecomposition(
    module: moduleName ?? p.basenameWithoutExtension(sourcePath),
    sourcePath: sourcePath,
    providers: providers,
    consumers: consumers,
    exceptions: exceptions,
  );
}

/// Merge many modules into one async overview (the local/remote split, counted).
AsyncOverview decomposeAsyncOverview(List<String> sourcePaths) {
  final providers = <AsyncProvider>[];
  final consumers = <AsyncConsumer>[];
  final exceptions = <AsyncException>[];
  for (final path in sourcePaths) {
    final m = decomposeAsync(path);
    providers.addAll(m.providers);
    consumers.addAll(m.consumers);
    exceptions.addAll(m.exceptions);
  }
  return AsyncOverview(
    providers: providers,
    consumers: consumers,
    exceptions: exceptions,
  );
}

/// Where a provider's data comes from (scan its body head).
String _backing(String body) {
  if (RegExp(r'Firestore|collection\(|snapshots\(\)|FirebaseFirestore|RemoteDoc')
      .hasMatch(body)) {
    return 'firestore';
  }
  if (RegExp(r'httpsCallable|CloudFunctions|functions\.|FirebaseFunctions')
      .hasMatch(body)) {
    return 'functions';
  }
  return 'local';
}

/// The substring inside the parens starting at [open] (index of '('), balanced.
String? _balanced(String src, int open) {
  var depth = 0;
  for (var i = open; i < src.length; i++) {
    final ch = src[i];
    if (ch == '(') depth++;
    if (ch == ')') {
      depth--;
      if (depth == 0) return src.substring(open + 1, i);
    }
  }
  return null;
}

/// The body of a named argument `label` up to the next top-level `,` handler —
/// a rough slice (enough to test what the branch returns).
String _labelBody(String region, String label) {
  final i = region.indexOf(label);
  if (i < 0) return '';
  final start = i + label.length;
  final end = (start + 160).clamp(0, region.length);
  return region.substring(start, end);
}

/// Does a `.when` branch return the EMPTY view (HARD RULE #3 fold)?
bool _looksEmpty(String body) => RegExp(
        r'_empty|Empty|showToast|SizedBox\.shrink|SizedBox\(\)|Container\(\)')
    .hasMatch(body);

/// Blank comments to equal-length spaces (offsets/lines preserved), skipping
/// string literals so a `//` inside a string is not treated as a comment.
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
      out[i] = out[i + 1] = ' ';
      i += 2;
      while (i < s.length && !(s[i] == '*' && i + 1 < s.length && s[i + 1] == '/')) {
        if (s[i] != '\n') out[i] = ' ';
        i++;
      }
      if (i + 1 < s.length) {
        out[i] = out[i + 1] = ' ';
        i += 2;
      }
    } else if (s[i] == "'" || s[i] == '"') {
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
