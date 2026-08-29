// Anti-duplication gate — TODO-dedup-gate (owner-requested 2026-06-07).
//
// THE GAP: the ~100 protocol gates cover correctness/consistency but had ZERO
// coverage for FEATURE duplication. In Phase-1, parallel agents reimplemented the
// same feature (scan-plan, cheaper-alternatives, barcode) in several entry points
// instead of routing to one shared opener — each copy passed all 100 gates.
//
// THE LOCK (single-source + many entry points): every shared feature has EXACTLY
// ONE canonical opener function and ONE implementation widget, both in one
// canonical file; the historically-duplicating entry point (the AI hub) must ROUTE
// THROUGH the opener, never reimplement. Multiple CALL sites are the goal (that is
// how one feature is reached from many places); multiple DEFINITIONS are the bug
// this gate fails on.
//
// Modeled on catalog_static_guard_test.dart (real File reads, an offenders list,
// expect(..., isEmpty)) + anti-vacuous-pass checks.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

class _Feature {
  const _Feature({
    required this.name,
    required this.opener,
    required this.implClasses,
    required this.canonicalFile,
    required this.routedFrom,
  });

  /// Human label for the offender message.
  final String name;

  /// The canonical opener function name. It must be DEFINED exactly once (a
  /// `void`/`Future<…>` return type in front) and that definition must live in
  /// [canonicalFile]; entry points reach the feature by CALLING it.
  final String opener;

  /// Implementation-widget classes that must be declared ONLY in [canonicalFile]
  /// (a second `class _X` elsewhere = a rival implementation = the bug).
  final List<String> implClasses;

  /// Basename of the file that owns this feature.
  final String canonicalFile;

  /// Entry-point basenames that MUST call [opener] (route through, not
  /// reimplement) — the files that historically duplicated it.
  final List<String> routedFrom;
}

const _features = <_Feature>[
  _Feature(
    name: 'scan-plan',
    opener: 'openScanPlanSheet',
    implClasses: ['_ScanPlanSheet'],
    canonicalFile: 'contractor_tools_sheets.dart',
    routedFrom: ['ai_hub_screen.dart'],
  ),
  _Feature(
    name: 'cheaper-alternatives',
    opener: 'openCheaperAlternativesSheet',
    implClasses: ['_CheaperAlternativesSheet'],
    canonicalFile: 'contractor_tools_sheets.dart',
    routedFrom: ['ai_hub_screen.dart'],
  ),
  _Feature(
    name: 'barcode-scanner',
    opener: 'openBarcodeScanner',
    implClasses: <String>[],
    canonicalFile: 'barcode_scanner.dart',
    routedFrom: <String>[],
  ),
];

void main() {
  final dartFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('lib exists and holds dart files', () {
    expect(dartFiles, isNotEmpty, reason: 'run from the app_flutter package root');
  });

  test('the anti-duplication registry is non-empty (no vacuous pass)', () {
    expect(_features, isNotEmpty);
  });

  test('each shared feature has ONE canonical opener + impl; entry points route '
      'through it (locks TODO-dedup-gate)', () {
    final contents = {
      for (final f in dartFiles) f.uri.pathSegments.last: f.readAsStringSync()
    };

    final offenders = <String>[];
    for (final feat in _features) {
      // (1) The opener is DEFINED exactly once — a return type in front tells a
      // definition from the (many, allowed) call sites — and in the canonical file.
      final defRe = RegExp('(void|Future<[^>]*>)\\s+${feat.opener}\\s*\\(');
      final defFiles = [
        for (final e in contents.entries)
          if (defRe.hasMatch(e.value)) e.key
      ];
      if (defFiles.length != 1) {
        offenders.add('${feat.name}: `${feat.opener}` DEFINED ${defFiles.length}× '
            '(${defFiles.join(", ")}) — expected exactly 1 canonical opener');
      } else if (defFiles.single != feat.canonicalFile) {
        offenders.add('${feat.name}: `${feat.opener}` defined in '
            '${defFiles.single}, expected ${feat.canonicalFile}');
      }

      // (2) Each implementation widget class lives ONLY in the canonical file.
      for (final cls in feat.implClasses) {
        final clsRe = RegExp('class\\s+$cls\\b');
        final where = <String>{
          for (final e in contents.entries)
            if (clsRe.hasMatch(e.value)) e.key
        };
        final rogue = where.where((b) => b != feat.canonicalFile).toList();
        if (rogue.isNotEmpty) {
          offenders.add('${feat.name}: `$cls` also declared outside '
              '${feat.canonicalFile}: ${rogue.join(", ")} — a rival implementation');
        }
      }

      // (3) Entry points route THROUGH the opener (call it), not reimplement.
      for (final entry in feat.routedFrom) {
        final src = contents[entry];
        if (src == null) {
          offenders.add('${feat.name}: entry point $entry not found');
        } else if (!src.contains('${feat.opener}(')) {
          offenders.add('${feat.name}: $entry no longer calls `${feat.opener}` — '
              'did it grow its own copy of the feature?');
        }
      }
    }

    expect(offenders, isEmpty,
        reason: 'feature duplication (TODO-dedup-gate): a shared feature must have '
            'ONE canonical opener + implementation, reached from many call sites '
            '— NOT reimplemented per entry point:\n  ${offenders.join("\n  ")}');
  });
}
