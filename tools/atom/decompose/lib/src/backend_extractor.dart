import 'dart:io';

import 'package:path/path.dart' as p;

import 'backend_models.dart';

final _fnDef = RegExp(
    r'export\s+const\s+(\w+)\s*=\s*(onCall|onRequest|onDocumentWritten|onDocumentCreated|onDocumentUpdated|onDocumentDeleted|onSchedule)\b');
final _region = RegExp('''region:\\s*["']([^"']+)["']''');
final _collection = RegExp('''collection\\(\\s*["']([^"']+)["']''');
final _httpsError = RegExp('''HttpsError\\(\\s*["']([^"']+)["']''');

/// Decompose one Cloud Functions module [sourcePath] (TypeScript) into its
/// functions. Source-scan over comment-blanked text (TS has no Dart analyzer
/// here). Read-only.
BackendModuleDecomposition decomposeBackend(
  String sourcePath, {
  String? moduleName,
}) {
  final src = _blankComments(File(sourcePath).readAsStringSync());
  final defs = _fnDef.allMatches(src).toList();
  final functions = <BackendFunction>[];

  for (var i = 0; i < defs.length; i++) {
    final m = defs[i];
    // The body runs to the next TOP-LEVEL `export …` (a sibling function OR a
    // re-export line) — a function body never contains a nested `export`, so
    // this stops it bleeding into a trailing `export { x } from …`.
    final nextExport = RegExp(r'\nexport\s').firstMatch(src.substring(m.end));
    final bodyEnd =
        nextExport != null ? m.end + nextExport.start : src.length;
    final body = src.substring(m.start, bodyEnd);

    final region = _region.firstMatch(body)?.group(1) ??
        (body.contains('REGION') ? 'REGION' : 'default');

    final collections = _collection
        .allMatches(body)
        .map((x) => x.group(1)!)
        .toSet()
        .toList();

    final writeOps = <String>[];
    for (final op in ['set', 'update', 'create', 'delete', 'add']) {
      if (RegExp(r'(?:\.|\b)' + op + r'\(').hasMatch(body)) writeOps.add(op);
    }
    final readsAny = body.contains('.get(') ||
        body.contains('.onSnapshot') ||
        body.contains('tx.get(');

    final calls = <String>[];
    if (RegExp(r'sendMail|nodemailer|transporter|sendEmail').hasMatch(body)) {
      calls.add('email');
    }
    if (RegExp(r'sendEachForMulticast|sendMulticast|messaging\(\)|sendPush')
        .hasMatch(body)) calls.add('fcm');
    if (RegExp(r'getSignedUrl|S3Client|PutObjectCommand|GetObjectCommand')
        .hasMatch(body)) calls.add('r2');
    if (RegExp(r'anthropic|messages\.create|askClaude').hasMatch(body)) {
      calls.add('claude');
    }
    if (RegExp(r'\bfetch\(').hasMatch(body)) calls.add('http');

    final errorCodes =
        _httpsError.allMatches(body).map((x) => x.group(1)!).toSet().toList()
          ..sort();

    functions.add(BackendFunction(
      name: m.group(1)!,
      trigger: m.group(2)!,
      region: region,
      line: _lineAt(src, m.start),
      authGated: body.contains('request.auth') || body.contains('context.auth'),
      reads: readsAny ? collections : <String>[],
      writes: writeOps.isEmpty ? <String>[] : collections,
      calls: calls,
      errorCodes: errorCodes,
    ));
  }

  return BackendModuleDecomposition(
    module: moduleName ?? p.basenameWithoutExtension(sourcePath),
    sourcePath: sourcePath,
    functions: functions,
  );
}

/// Merge every functions/src module into one overview.
BackendOverview decomposeBackendOverview(List<String> sourcePaths) {
  final functions = <BackendFunction>[];
  for (final path in sourcePaths) {
    functions.addAll(decomposeBackend(path).functions);
  }
  return BackendOverview(functions: functions);
}

int _lineAt(String src, int offset) {
  var line = 1;
  for (var i = 0; i < offset && i < src.length; i++) {
    if (src[i] == '\n') line++;
  }
  return line;
}

/// Blank comments to equal-length spaces (offsets/lines preserved), skipping
/// string literals. Works for TS (same `//` and `/* */`).
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
    } else if (s[i] == "'" || s[i] == '"' || s[i] == '`') {
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
