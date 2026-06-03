// BuildSmart Protocol v2 — deterministic content-gate engine.
//
// WHY THIS EXISTS (lesson #52, recurring bug class):
//   The #1 recurring protocol bug was brittle bash content-analysis. emoji / RTL /
//   secret / antipattern greps repeatedly broke under MSYS / git-for-windows: git
//   swaps the grep binary/PATH at hook-invocation time, so a grep that passes
//   standalone silently mis-fires (false-negative OR false-positive) under
//   `git commit`. Gates 23/64/93/103/109/114 all had to be rewritten from `grep`
//   to bash `case`/glob to survive. Every NEW bash content gate is a latent MSYS
//   bug.
//
//   This file replaces those greps with ONE deterministic, OS-independent Dart
//   engine. Dart's RegExp is identical on Linux/macOS/Windows — no external
//   binary, no PATH games, no locale surprises. The pre-commit hook calls this
//   instead of greppng staged content itself.
//
// USAGE:
//   dart run tool/protocol_check.dart --diff <file> [--staged-names <file>]
//                                     [--stuck-log <file>] [--gitignore <file>]
//       Runs all content gates against a unified `git diff --cached` dump.
//       Emits one line per finding: `<SEV>\t<gateId>\t<message>` where SEV is
//       ERR or WARN. Exit code: 2 if any ERR finding, 0 otherwise (warnings do
//       not fail). The bash runner re-emits these via its own err()/warn() so the
//       fingerprint/retry bookkeeping still sees the gate ids.
//
//   dart run tool/protocol_check.dart --verify-registry \
//       --emitted <ids-file> --registry protocol/gates.tsv
//       Asserts the set of gate ids emitted by pre-commit equals the set of
//       `enforced` ids in the registry. Exit 2 on mismatch. (Gate `reg`.)
//
//   dart run tool/protocol_check.dart --self-test
//       Runs the built-in unit tests (no external test package needed — works
//       even where `dart test` / the `test` package is unavailable). Exit 2 on
//       any failure. A mirror flutter_test lives at
//       test/protocol_check_engine_test.dart for the `flutter test` suite.
//
// PURITY: all gate logic is in pure top-level functions over Strings, so it is
// trivially testable and has zero IO except in main().

import 'dart:convert';
import 'dart:io';

part 'protocol_check_selftest.dart';

/// Severity of a finding. `err` blocks the commit; `warn` is advisory.
enum Sev { err, warn }

/// One protocol finding produced by a content gate.
class Finding {
  final String gateId;
  final Sev sev;
  final String message;
  const Finding(this.gateId, this.sev, this.message);

  String get tag => sev == Sev.err ? 'ERR' : 'WARN';

  /// Machine-readable line consumed by the bash runner.
  String toLine() => '$tag\t$gateId\t$message';

  @override
  String toString() => toLine();
}

/// Added lines of a unified diff: lines starting with a single '+' but not
/// '+++'. We strip the leading '+'. This is the cross-OS equivalent of
/// `grep "^+" | grep -v "^+++"`.
List<String> addedLines(String diff) {
  final out = <String>[];
  for (final raw in const LineSplitter().convert(diff)) {
    if (raw.startsWith('+++')) continue;
    if (raw.startsWith('+')) out.add(raw.substring(1));
  }
  return out;
}

/// Removed lines of a unified diff: '-' but not '---'. Leading '-' stripped.
List<String> removedLines(String diff) {
  final out = <String>[];
  for (final raw in const LineSplitter().convert(diff)) {
    if (raw.startsWith('---')) continue;
    if (raw.startsWith('-')) out.add(raw.substring(1));
  }
  return out;
}

// --- Emoji handling -------------------------------------------------------
// Lesson #52: emoji byte-matching is exactly where bash grep broke. In Dart we
// match on Unicode code points, which is deterministic everywhere.
//
// The legacy hook's gate 64 watched a SMALL allowlist-violation set
// (🎯 🎨 🎮 🎪 🎲) as a proxy for "invented emoji". We preserve that exact
// behavior (verbatim set) so we LOSE NO protection, but centralize it here.
const Set<int> _inventedEmojiRunes = {
  0x1F3AF, // 🎯
  0x1F3A8, // 🎨
  0x1F3AE, // 🎮
  0x1F3AA, // 🎪
  0x1F3B2, // 🎲
};

bool _containsInventedEmoji(String line) {
  for (final r in line.runes) {
    if (_inventedEmojiRunes.contains(r)) return true;
  }
  return false;
}

// --- Individual content gates --------------------------------------------
// Each returns 0..n findings. Pure functions of their string inputs.

/// Gate 28: no absolute local URI (file:/// or C:\) in dart additions.
List<Finding> gateNoLocalUri(String dartDiff) {
  final re = RegExp(r'file:///|C:\\');
  for (final l in addedLines(dartDiff)) {
    if (re.hasMatch(l)) {
      return [Finding('28', Sev.err, 'local URI in code: ${l.trim()}')];
    }
  }
  return const [];
}

/// Gate 46: no dark surface token in screens additions.
List<Finding> gateNoDarkSurface(String screensDiff) {
  for (final l in addedLines(screensDiff)) {
    if (l.contains('0xFF111111') || l.contains('BsTokens.bgDark')) {
      return [
        Finding(
          '46',
          Sev.err,
          'dark surface: remove 0xFF111111/BsTokens.bgDark',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 48: no print() in production dart. Matches print( at start-of-token,
/// excludes debugPrint, comments, and string literals 'print / "print.
List<Finding> gateNoPrint(String libDiff) {
  final call = RegExp(r'(^|[^A-Za-z0-9_])print\s*\(');
  for (final l in addedLines(libDiff)) {
    if (!call.hasMatch(l)) continue;
    if (l.contains('debugPrint')) continue;
    if (RegExp(r'//.*print').hasMatch(l)) continue;
    if (l.contains("'print") || l.contains('"print')) continue;
    return [
      Finding(
        '48',
        Sev.err,
        'print() in production code: use debugPrint or remove',
      ),
    ];
  }
  return const [];
}

/// Gate 50: no `import 'dart:html'`.
List<Finding> gateNoDartHtml(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (l.contains("import 'dart:html'")) {
      return [
        Finding('50', Sev.err, "import dart:html forbidden: use package:web"),
      ];
    }
  }
  return const [];
}

/// Gate 51: no hard-coded https URL literal (warn).
List<Finding> gateNoHardUrl(String libDiff) {
  final re = RegExp(r'''https?://[^"']+"''');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l)) {
      return [Finding('51', Sev.warn, 'hard-coded URL — consider config')];
    }
  }
  return const [];
}

/// Gate 52: no secret/api_key/token/password/bearer literal value.
/// Faithful port of the bash pattern incl. its false-positive excludes.
List<Finding> gateNoSecrets(String diff) {
  final secret = RegExp(
    r'''(api[_-]?key|secret|token|password|bearer)\s*[:=]\s*['"][A-Za-z0-9+/_-]{16,}['"]''',
    caseSensitive: false,
  );
  final allow = RegExp(
    r'regex|pattern|kSecret|kToken|kPassword|kApiKey|\.test\(|expect\(|placeholder',
    caseSensitive: false,
  );
  for (final l in addedLines(diff)) {
    if (secret.hasMatch(l) && !allow.hasMatch(l)) {
      return [
        Finding(
          '52',
          Sev.err,
          'secret/api_key in code (if false-positive, rename var to include regex/pattern)',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 54: no ColoredBox with dark 0xFF[0-3][0-3] color.
List<Finding> gateNoDarkColoredBox(String libDiff) {
  final re = RegExp(r'ColoredBox.*0xFF[0-3][0-3]');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l)) {
      return [Finding('54', Sev.err, 'dark ColoredBox: use light colors')];
    }
  }
  return const [];
}

/// Gate 62: no hard-coded padding left/right (warn). Excludes Directional.
List<Finding> gateNoHardLeftRight(String libDiff) {
  final re = RegExp(r'padding.*\b(left|right):');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l) && !l.contains('EdgeInsetsDirectional')) {
      return [Finding('62', Sev.warn, 'hard left/right — use start/end')];
    }
  }
  return const [];
}

/// Gate 63: no TextAlign.left/right (warn).
List<Finding> gateNoTextAlignLR(String libDiff) {
  final re = RegExp(r'TextAlign\.(left|right)');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l)) {
      return [Finding('63', Sev.warn, 'TextAlign.left/right — use start/end')];
    }
  }
  return const [];
}

/// Gate 64: no invented (non-legacy) emoji (warn).
List<Finding> gateNoInventedEmoji(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (_containsInventedEmoji(l)) {
      return [
        Finding('64', Sev.warn, 'new emoji — verify verbatim from legacy'),
      ];
    }
  }
  return const [];
}

/// Gate 65: no TextDirection.ltr in RTL app (warn). Excludes isolate/LTR/comment.
List<Finding> gateNoTextDirectionLtr(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (!l.contains('TextDirection.ltr')) continue;
    if (l.contains('isolate') || l.contains('LTR') || l.contains('//'))
      continue;
    return [Finding('65', Sev.warn, 'TextDirection.ltr — app is RTL')];
  }
  return const [];
}

/// Gate 69: removed dark color token (warn — verify not a text color).
List<Finding> gateColorRevert(String libDiff) {
  for (final l in removedLines(libDiff)) {
    if (l.contains('BsTokens.bgDark') || l.contains('0xFF111111')) {
      return [
        Finding('69', Sev.warn, 'removed color — verify not a text-color'),
      ];
    }
  }
  return const [];
}

/// Gate 73: persistence key must match bs.<feature>.vN.
List<Finding> gatePersistenceKey(String libDiff) {
  final find = RegExp(r"'bs\.[a-z-]+\.v[0-9]+'");
  final valid = RegExp(r"^'bs\.[a-z-]+\.v[0-9]+'$");
  for (final l in addedLines(libDiff)) {
    final m = find.firstMatch(l);
    if (m == null) continue;
    final key = m.group(0)!;
    if (!valid.hasMatch(key)) {
      return [
        Finding(
          '73',
          Sev.err,
          'invalid persistence key: $key (format bs.<feature>.v1)',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 74: no manual ProviderContainer() in widget code.
List<Finding> gateNoManualContainer(String screensDiff) {
  for (final l in addedLines(screensDiff)) {
    if (l.contains('ProviderContainer()')) {
      return [
        Finding('74', Sev.err, 'manual ProviderContainer — use ProviderScope'),
      ];
    }
  }
  return const [];
}

/// Gate 114: kLipskeyCatalog forbidden in screens/state/logic.
List<Finding> gateNoKLipskeyInUi(String uiDiff) {
  for (final l in addedLines(uiDiff)) {
    if (l.contains('kLipskeyCatalog')) {
      return [
        Finding(
          '114',
          Sev.err,
          'kLipskeyCatalog in screens/state/logic: ${l.trim()} — use kCatalogProducts',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 95: a number "<hebrew> NxN" without an LTR isolate (warn).
List<Finding> gateNumberIsolate(String libDiff) {
  final re = RegExp(r'[א-ת]+ [0-9]+×[0-9]+');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l)) {
      return [
        Finding(
          '95',
          Sev.warn,
          'number with multiply-sign without LTR isolate',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 25: no edits to Preact-shared *_settings.dart. The bash gate diffs each
/// shared file; here we receive the per-file diff already filtered by the runner
/// and look for real content lines (`^[+-][^+-]`).
List<Finding> gatePreactSharedUntouched(String sharedDiff, String name) {
  final re = RegExp(r'^[+-][^+-]', multiLine: true);
  if (re.hasMatch(sharedDiff)) {
    return [
      Finding('25', Sev.err, 'touched $name — shared with Preact, do not edit'),
    ];
  }
  return const [];
}

/// Gate 70: no removal of secret patterns from .gitignore.
List<Finding> gateGitignoreSecretsGuard(String gitignoreDiff) {
  final re = RegExp(r'\.env|credentials|\.key|\.pem');
  for (final l in removedLines(gitignoreDiff)) {
    if (re.hasMatch(l)) {
      return [
        Finding('70', Sev.err, 'removed sensitive pattern from .gitignore'),
      ];
    }
  }
  return const [];
}

/// Gate 97: no .gitignore line that hides .claude/.
List<Finding> gateGitignoreNoHideClaude(String gitignoreDiff) {
  for (final l in addedLines(gitignoreDiff)) {
    if (l.trim() == '.claude/') {
      return [
        Finding(
          '97',
          Sev.err,
          'attempt to hide .claude — settings must be in repo',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 67: new Hebrew string literal added in app/ (warn — copy to Flutter).
List<Finding> gateAppHebrewString(String appDiff) {
  final re = RegExp("['\"][א-ת][^'\"]+['\"]");
  for (final l in addedLines(appDiff)) {
    if (re.hasMatch(l)) {
      return [
        Finding(
          '67',
          Sev.warn,
          'new Hebrew string in app/ — copy to app_flutter',
        ),
      ];
    }
  }
  return const [];
}

// --- Stuck-log antipattern recurrence (gate 103) --------------------------

/// Parse `ANTIPATTERN:` / `ANTIPATTERN[hook]:` lines from a stuck_log body.
/// Returns (target, pattern) pairs. target is 'hook' or 'dart'. Lines whose
/// pattern contains shell-meta are skipped (matches the bash safeguard, but in
/// Dart shell-meta is harmless — we skip purely for parity with documented
/// behavior so the same patterns are/aren't applied).
List<({String target, String pattern})> parseAntipatterns(String stuckLog) {
  final out = <({String target, String pattern})>[];
  final shellMeta = RegExp(r'\$\(|`|\$\{');
  for (final line in const LineSplitter().convert(stuckLog)) {
    String target;
    String pattern;
    if (line.startsWith('ANTIPATTERN[hook]:')) {
      target = 'hook';
      pattern = line.substring('ANTIPATTERN[hook]:'.length).trim();
    } else if (line.startsWith('ANTIPATTERN:')) {
      target = 'dart';
      pattern = line.substring('ANTIPATTERN:'.length).trim();
    } else {
      continue; // ignore ANTIPATTERN-EXAMPLE: and everything else
    }
    if (pattern.isEmpty) continue;
    if (shellMeta.hasMatch(pattern)) continue;
    out.add((target: target, pattern: pattern));
  }
  return out;
}

/// Gate 103: a recorded ANTIPATTERN regex must not reappear in the new code.
/// `dartAdded` = added lines from the staged dart diff (regression test file
/// already excluded by the caller). `hookAdded` = added non-comment lines from
/// the staged pre-commit diff. Returns one finding per recurrence.
List<Finding> gateAntipatternRecurrence({
  required String stuckLog,
  required List<String> dartAdded,
  required List<String> hookAdded,
}) {
  final findings = <Finding>[];
  for (final ap in parseAntipatterns(stuckLog)) {
    final RegExp re;
    try {
      re = RegExp(ap.pattern);
    } on FormatException {
      // A malformed stored pattern should not crash the engine; skip it.
      continue;
    }
    final haystack = ap.target == 'hook' ? hookAdded : dartAdded;
    for (final l in haystack) {
      if (re.hasMatch(l)) {
        findings.add(
          Finding(
            '103',
            Sev.err,
            'antipattern recurred: ${ap.pattern} — see stuck_log.md',
          ),
        );
        break; // one finding per antipattern
      }
    }
  }
  return findings;
}

// --- Registry parity (gate `reg`) ----------------------------------------

/// Parse the `enforced` gate ids from gates.tsv. Skips comment (#) and header
/// rows. A row is "enforced" when its `status` column == 'enforced'.
Set<String> registryEnforcedIds(String tsv) {
  final ids = <String>{};
  for (final line in const LineSplitter().convert(tsv)) {
    if (line.startsWith('#') || line.trim().isEmpty) continue;
    final cols = line.split('\t');
    if (cols.isEmpty) continue;
    if (cols[0] == 'id') continue; // header
    if (cols.length < 9) continue;
    // columns: id(0) group(1) name(2) severity(3) trigger(4) tier(5)
    //          engine(6) status(7) check-desc(8)
    if (cols[7].trim() == 'enforced') ids.add(cols[0].trim());
  }
  return ids;
}

/// Parse emitted gate ids (one id per line, already extracted by the runner /
/// bash from the live pre-commit) plus the synthetic 'reg' id which the dart
/// engine itself emits.
Set<String> parseEmittedIds(String raw) {
  final ids = <String>{};
  for (final line in const LineSplitter().convert(raw)) {
    final t = line.trim();
    if (t.isEmpty) continue;
    ids.add(t);
  }
  return ids;
}

/// Returns (missingFromCode, missingFromRegistry).
({Set<String> missingFromCode, Set<String> missingFromRegistry}) registryDiff(
  Set<String> emitted,
  Set<String> registry,
) {
  return (
    missingFromCode: registry.difference(emitted),
    missingFromRegistry: emitted.difference(registry),
  );
}

// --- Orchestration over a single combined diff ---------------------------
// The pre-commit runner passes ONE `git diff --cached` dump (all staged files).
// Most gates only care about a subset of paths, but running every gate over the
// full added/removed line set is safe because each pattern is specific. For the
// path-scoped gates the runner still decides WHETHER to call (via cheap
// name-only checks) — but for robustness the engine is also given the staged
// names so it can self-scope when asked to run "all".

/// Run every content gate that can be evaluated from the combined diff alone.
/// `diff` is the full `git diff --cached` output. This is what `--diff` runs.
List<Finding> runAllContentGates({
  required String diff,
  String? stuckLog,
  String? gitignoreDiff,
}) {
  final findings = <Finding>[
    ...gateNoLocalUri(diff),
    ...gateNoDarkSurface(diff),
    ...gateNoPrint(diff),
    ...gateNoDartHtml(diff),
    ...gateNoHardUrl(diff),
    ...gateNoSecrets(diff),
    ...gateNoDarkColoredBox(diff),
    ...gateNoHardLeftRight(diff),
    ...gateNoTextAlignLR(diff),
    ...gateNoInventedEmoji(diff),
    ...gateNoTextDirectionLtr(diff),
    ...gateColorRevert(diff),
    ...gatePersistenceKey(diff),
    ...gateNoManualContainer(diff),
    ...gateNoKLipskeyInUi(diff),
    ...gateNumberIsolate(diff),
  ];
  if (gitignoreDiff != null && gitignoreDiff.isNotEmpty) {
    findings
      ..addAll(gateGitignoreSecretsGuard(gitignoreDiff))
      ..addAll(gateGitignoreNoHideClaude(gitignoreDiff));
  }
  if (stuckLog != null && stuckLog.isNotEmpty) {
    final added = addedLines(diff);
    findings.addAll(
      gateAntipatternRecurrence(
        stuckLog: stuckLog,
        dartAdded: added,
        hookAdded: added, // runner separates targets; combined mode unifies
      ),
    );
  }
  return findings;
}

// --- main ----------------------------------------------------------------

String? _arg(List<String> a, String flag) {
  final i = a.indexOf(flag);
  if (i < 0 || i + 1 >= a.length) return null;
  return a[i + 1];
}

String _readOrEmpty(String? path) {
  if (path == null) return '';
  final f = File(path);
  return f.existsSync() ? f.readAsStringSync() : '';
}

int _mainVerifyRegistry(List<String> args) {
  final emitted = parseEmittedIds(_readOrEmpty(_arg(args, '--emitted')));
  final registry = registryEnforcedIds(_readOrEmpty(_arg(args, '--registry')));
  final d = registryDiff(emitted, registry);
  if (d.missingFromCode.isEmpty && d.missingFromRegistry.isEmpty) {
    stdout.writeln(
      'OK\treg\tregistry == code (${registry.length} enforced gates)',
    );
    return 0;
  }
  if (d.missingFromCode.isNotEmpty) {
    stderr.writeln(
      'ERR\treg\tin registry but NOT emitted by code: ${(d.missingFromCode.toList()..sort()).join(", ")}',
    );
  }
  if (d.missingFromRegistry.isNotEmpty) {
    stderr.writeln(
      'ERR\treg\temitted by code but NOT in registry: ${(d.missingFromRegistry.toList()..sort()).join(", ")}',
    );
  }
  return 2;
}

int _mainDiff(List<String> args) {
  final diff = _readOrEmpty(_arg(args, '--diff'));
  final stuck =
      _arg(args, '--stuck-log') == null
          ? null
          : _readOrEmpty(_arg(args, '--stuck-log'));
  final gitignore =
      _arg(args, '--gitignore') == null
          ? null
          : _readOrEmpty(_arg(args, '--gitignore'));
  final findings = runAllContentGates(
    diff: diff,
    stuckLog: stuck,
    gitignoreDiff: gitignore,
  );
  var hadErr = false;
  for (final f in findings) {
    stdout.writeln(f.toLine());
    if (f.sev == Sev.err) hadErr = true;
  }
  return hadErr ? 2 : 0;
}

void main(List<String> args) {
  if (args.contains('--self-test')) {
    exit(runSelfTest());
  }
  if (args.contains('--verify-registry')) {
    exit(_mainVerifyRegistry(args));
  }
  exit(_mainDiff(args));
}
