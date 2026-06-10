// Catalog zero-DB-cost guard — the STATIC-catalog latch (SPEC-server-connect
// S3.K).
//
// THE DECISION (SSOT row S3.K): the 1,877-product catalog is STATIC — it stays
// bundled const Dart (`kCatalogProducts` / `kSmartProducts` / `kCatalogCats`)
// with full-quality images on the R2 CDN (`data/product_images.dart`). It must
// NEVER route through Firestore: 1,877 docs read on every catalog open would be
// pure, recurring DB cost for data that never changes per-user. DoD: "catalog
// from bundle/CDN · 0 DB cost."
//
// THE HAZARD: the sibling `_firebase` fleet ships an offline-first base
// (`FirestoreCachedRepo<T>` + its `FirestoreCollectionSource` adapter, in
// `data/repositories/firestore_cached_repo.dart`, which imports
// `cloud_firestore`). A `_firebase` repo joins Firestore by (a) importing
// `cloud_firestore` and/or (b) extending `FirestoreCachedRepo` / constructing a
// `FirestoreCollectionSource` (e.g. `orders_firebase.dart`). If a future
// `catalog_firebase.dart` ever did the same, the catalog would silently start
// costing reads — exactly the decision this row forbids.
//
// THE GATE: scan every `catalog_*.dart` under lib/data/repositories/ at test
// time (real File reads — NOT reflection). A catalog repo file MUST NOT:
//   • import `cloud_firestore`                            (import-directive scan
//     on RAW source — an import line is never inside a // or /* */ comment in
//     these files, and the raw scan is the literal "does this file pull in the
//     Firestore SDK" check), OR
//   • reference `FirestoreCachedRepo` / `FirestoreCollectionSource`
//     (identifier scan on COMMENT-STRIPPED source — so the very names in THIS
//     explanatory file, and any prose in the repo files, don't trip the gate;
//     only a real `extends FirestoreCachedRepo` / `FirestoreCollectionSource(…)`
//     in live code counts).
// If a future catalog repo ships any of those, this test goes red — locking the
// zero-DB-cost decision permanently.
//
// Modeled on state_loaded_guard_test.dart (dart:io File reads, Directory
// listing, an offenders list, expect(..., isEmpty, reason: …)) + an
// anti-vacuous-pass sanity check that the predicate actually selects files and
// actually fires on the known-Firestore sibling base.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The Firestore-coupling tokens a STATIC catalog repo must never carry.
const _firestoreImport = 'cloud_firestore';
const _firestoreIdentifiers = <String>[
  'FirestoreCachedRepo',
  'FirestoreCollectionSource',
];

/// Strip `//` line comments and `/* */` block comments so the identifier scan
/// sees only live code — the Firestore names appear all over the doc-comments
/// (including this very test's prose, were it ever scanned), and a repo file is
/// free to *mention* them in a "NOT Firestore" note without coupling to them.
/// Import directives are matched on RAW source instead (an `import '…';` line is
/// never commented-out in these files), so this stripping is identifier-only.
String _stripComments(String src) {
  final noBlock = src.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), ' ');
  final sb = StringBuffer();
  for (final line in noBlock.split('\n')) {
    final i = line.indexOf('//');
    sb.writeln(i >= 0 ? line.substring(0, i) : line);
  }
  return sb.toString();
}

/// True when [rawSource] has a live `import '…cloud_firestore…';` directive.
/// Matched on raw source (imports are never inside comments here) and anchored
/// to an `import` directive so a stray mention of the package name in prose
/// can't count.
bool _importsFirestore(String rawSource) {
  return RegExp(
    '''import\\s+['"][^'"]*$_firestoreImport[^'"]*['"]''',
  ).hasMatch(rawSource);
}

void main() {
  // Tests run with the package root as cwd, so this resolves to
  // app_flutter/lib/data/repositories (same convention as
  // state_loaded_guard_test.dart / regression_gate_test.dart).
  final repoDir = Directory('lib/data/repositories');

  test('lib/data/repositories exists and holds the catalog repo files', () {
    expect(repoDir.existsSync(), isTrue,
        reason: 'run from the app_flutter package root',);
  });

  // The catalog repo files this row owns: catalog_*.dart under the repo dir.
  List<File> catalogRepoFiles() => [
        for (final e in repoDir.listSync())
          if (e is File &&
              e.uri.pathSegments.last.startsWith('catalog_') &&
              e.path.endsWith('.dart'))
            e,
      ];

  test('catalog repo files never couple to Firestore '
      '(no cloud_firestore import · no FirestoreCachedRepo / '
      'FirestoreCollectionSource) — locks S3.K zero-DB-cost', () {
    final files = catalogRepoFiles();

    // Anti-vacuous-pass #1: the predicate must actually select files. Today
    // there are catalog_repository.dart + catalog_local.dart; a zero-match scan
    // would pass without checking anything.
    expect(files, isNotEmpty,
        reason: 'no catalog_*.dart found under lib/data/repositories — the '
            'guard would pass vacuously (did the files move/rename?)',);

    final offenders = <String>[];
    for (final f in files) {
      final raw = f.readAsStringSync();
      final code = _stripComments(raw);
      final name = f.uri.pathSegments.last;

      if (_importsFirestore(raw)) {
        offenders.add('$name → imports `$_firestoreImport`');
      }
      for (final id in _firestoreIdentifiers) {
        if (code.contains(id)) {
          offenders.add('$name → references `$id` in live code');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'the catalog must stay STATIC (bundled const Dart + R2 CDN) — '
            'these catalog repo files couple to Firestore, which would make '
            'the 1,877-product catalog cost DB reads (SPEC S3.K forbids this; '
            'a catalog_firebase.dart belongs nowhere):\n  '
            '${offenders.join("\n  ")}',);
  });

  // Anti-vacuous-pass #2: prove the predicate actually FIRES on real coupling.
  // The sibling _firebase base genuinely imports cloud_firestore AND declares
  // both gated identifiers in live code — so if our detectors silently stopped
  // matching (e.g. comment-stripping ate everything, or the import regex broke),
  // this would catch it. orders_firebase.dart extends FirestoreCachedRepo and
  // constructs FirestoreCollectionSource.
  test('sanity — the Firestore detectors fire on the known-coupled sibling base',
      () {
    final base = File('lib/data/repositories/firestore_cached_repo.dart');
    final orders = File('lib/data/repositories/orders_firebase.dart');
    // These are the sibling fleet's files; if they ever move this sanity check
    // is moot, not the guard — skip rather than fail on their absence.
    if (!base.existsSync() || !orders.existsSync()) {
      markTestSkipped('sibling _firebase files absent — sanity check moot');
      return;
    }

    final baseRaw = base.readAsStringSync();
    final baseCode = _stripComments(baseRaw);
    expect(_importsFirestore(baseRaw), isTrue,
        reason: 'the import detector should match the base that really imports '
            'cloud_firestore — if not, it would also miss a catalog_firebase',);
    expect(baseCode.contains('FirestoreCachedRepo'), isTrue,
        reason: 'the identifier detector should see the live class declaration '
            'even after comment-stripping',);
    expect(baseCode.contains('FirestoreCollectionSource'), isTrue,
        reason: 'the identifier detector should see the live adapter class',);

    // And the comment-stripper must NOT be a no-op (else the identifier scan is
    // really a raw scan). Probe with a sentinel placed ONLY in a comment:
    // CATALOG_GUARD_COMMENT_SENTINEL — it is present in the raw source but MUST
    // be gone after stripping. (Written split as 'CATALOG_GUARD' '_…' below so
    // the probe string itself never appears as one literal in live code.)
    const sentinel = 'CATALOG_GUARD' '_COMMENT_SENTINEL';
    final raw = File('test/catalog_static_guard_test.dart').readAsStringSync();
    expect(raw.contains(sentinel), isTrue,
        reason: 'the sentinel must exist in this file’s comment for the probe '
            'to mean anything',);
    expect(_stripComments(raw).contains(sentinel), isFalse,
        reason: 'comment-stripping must remove comment text — otherwise the '
            'identifier scan is comment-blind (a “NOT Firestore” note in a '
            'repo file could falsely trip the gate)',);
  });
}
