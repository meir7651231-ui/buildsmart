// BuildSmart Protocol v3 — deterministic, SEMANTIC content-gate engine.
//
// WHY THIS EXISTS (lesson #52 + the 6-agent red team, ~380 bypass vectors):
//   v1's brittle bash content-greps broke under MSYS and were trivially bypassed
//   by lowercase/computed/split variants of the very strings they looked for.
//   v2 moved the matching into ONE deterministic Dart engine (RegExp is identical
//   on Linux/macOS/Windows — no external binary, no PATH games, no locale
//   surprises). v3 closes the *semantic* holes the red team proved:
//
//   R4 — match by MEANING, not literal substring:
//     * colors: parse 0x.. / Color.fromARGB / fromRGBO / HSLColor to LUMINANCE
//       and reject dark semantically (kills lowercase-hex / fromARGB / off-by-one
//       / computed-channel variants).
//     * secrets: name-AGNOSTIC Shannon entropy + provider fingerprints
//       (AKIA/AIza/ghp_/xox[bp]-/sk-/-----BEGIN). JOIN adjacent string literals
//       before matching (kills "split the secret across two strings").
//     * emoji: INVERTED to an ALLOWLIST over the legacy pictographic set — ANY
//       new emoji rune (incl. VS-16 / ZWJ / skin-tone / \u{..} escapes) warns.
//     * RTL: EdgeInsets.only(left|right:/fromLTRB + ASCII x/* multiply, ERR.
//   R2 — scan the committed TREE post-image (joined multi-line), not '+' lines.
//   R6 — runtime-emitted gate ids drive the registry-parity check; malformed
//        registry rows FAIL (not skip); --self-test is a blocking gate.
//   R5 — baselines parsed from the SUMMARY line; counts are tamper-evident.
//
// PURITY: all gate logic is pure top-level functions over Strings — trivially
// testable, zero IO except in main(). A built-in --self-test runs everywhere a
// Dart SDK exists (this repo lacks the standalone `test` package); a mirror
// flutter_test at test/protocol_check_engine_test.dart feeds gates 31/32/94.
//
// USAGE:
//   dart run tool/protocol_check.dart --diff <file> [--names <file>]
//                                     [--stuck-log <file>] [--gitignore <file>]
//       Runs all content gates against a `git diff --cached` dump. With --names
//       (a newline list of touched paths) each content gate is PATH-SCOPED so it
//       never fires on tests/docs/protocol files (red-team false-positive class).
//       Emits `<SEV>\t<gateId>\t<message>` per finding; exit 2 on any ERR.
//
//   dart run tool/protocol_check.dart --tree --names <file> [--stuck-log ..]
//                                     [--gitignore <file>] [--show <prefix>]
//       R2 mode: scans the post-image TREE of every touched file. --show is the
//       shell prefix to fetch a blob (default `git show :` for the index); the
//       bash runner passes the merge-base form in CI. Each file is read as a
//       single string and multi-line literals are joined before matching.
//
//   dart run tool/protocol_check.dart --verify-registry \
//       --emitted <ids-file> --registry protocol/gates.tsv
//       R6 parity: asserts the set of gate ids EMITTED AT RUNTIME equals the
//       registry's `enforced` set. FAILS on malformed tsv rows. Exit 2 on
//       mismatch. (Gate `reg`.)
//
//   dart run tool/protocol_check.dart --self-test
//       Runs the built-in regression suite (incl. every v3 close). Exit 2 on any
//       failure.

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

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

// --- Diff primitives ------------------------------------------------------

/// Added lines of a unified diff: lines starting with a single '+' but not
/// '+++'. We strip the leading '+'. Cross-OS equivalent of
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

// --- Path scoping (R4: never fire on tests/docs/protocol files) -----------
//
// The #1 false-positive class the red team found was a content gate firing on a
// TEST file (which legitimately contains `print`, `0xFF111111`, `TextAlign.left`
// as *test data*) or on a knowledge/*.md doc that quotes a forbidden pattern as
// an EXAMPLE, or on the protocol engine/registry itself. We scope every content
// gate by path: production code only.

/// True for a path that should be EXEMPT from production content gates: tests,
/// generated files, knowledge/docs, the protocol tooling, and the registry.
bool isExemptPath(String path) {
  final p = path.replaceAll('\\', '/');
  if (p.endsWith('.g.dart')) return true; // generated
  if (p.contains('/test/') || p.endsWith('_test.dart')) return true;
  if (p.contains('/knowledge/')) return true;
  if (p.contains('/tool/protocol_check')) return true; // the engine itself
  if (p.contains('protocol/gates.tsv')) return true;
  if (p.endsWith('.md')) return true; // docs quote forbidden patterns
  if (p.contains('/scripts/') && (p.endsWith('.sh') || p.endsWith('.py'))) {
    return true; // build scripts, not shipped code
  }
  return false;
}

/// True for a Dart production-code path under lib/ (excluding generated/tests).
bool isLibDartPath(String path) {
  final p = path.replaceAll('\\', '/');
  if (!p.endsWith('.dart')) return false;
  if (isExemptPath(p)) return false;
  return p.contains('lib/');
}

/// True for a screens/widgets production path (UI surface gates 46/47/74).
bool isScreensPath(String path) {
  final p = path.replaceAll('\\', '/');
  if (!isLibDartPath(p)) return false;
  return p.contains('lib/screens/') || p.contains('lib/widgets/');
}

/// True for screens/state/logic production code — gate 114's real scope. The
/// catalog itself lives in lib/data/ and legitimately defines/imports the
/// lipskey symbol, so data/ is EXCLUDED.
bool isScreensStateLogicPath(String path) {
  final p = path.replaceAll('\\', '/');
  if (!isLibDartPath(p)) return false;
  return p.contains('lib/screens/') ||
      p.contains('lib/widgets/') ||
      p.contains('lib/state/') ||
      p.contains('lib/logic/');
}

/// True for a Preact app/ source file (gate 67 — Hebrew strings to mirror into
/// Flutter). Excludes the frozen inspections dir and docs.
bool isPreactAppPath(String path) {
  final p = path.replaceAll('\\', '/');
  if (!p.startsWith('app/') && !p.contains('/app/')) return false;
  if (p.contains('/knowledge/') || p.endsWith('.md')) return false;
  return p.endsWith('.ts') ||
      p.endsWith('.tsx') ||
      p.endsWith('.js') ||
      p.endsWith('.jsx');
}

/// Text files secrets are scanned in (R4: widen beyond .dart).
bool isSecretScannablePath(String path) {
  final p = path.replaceAll('\\', '/').toLowerCase();
  if (isExemptPath(p)) return false;
  for (final ext in const [
    '.dart',
    '.arb',
    '.json',
    '.yaml',
    '.yml',
    '.txt',
    '.properties',
    '.env',
    '.gradle',
    '.xml',
  ]) {
    if (p.endsWith(ext)) return true;
  }
  return false;
}

// --- String-literal extraction & joining (R4: defeat split secrets) -------
//
// "Split the secret across two adjacent string literals" was a red-team bypass:
//   const k = "AKIA" "IOSFODNN7" "EXAMPLE";   // Dart adjacent-literal concat
//   const k = "AKIA" + "IOSFODNN7EXAMPLE";    // explicit concat
// We extract every single/double-quoted literal on a line, then ALSO produce a
// "joined" form where adjacent/`+`-separated literals are concatenated, so the
// reconstructed value is matched as one token.

/// All quoted string-literal *contents* on a line (single or double quoted,
/// no escape interpretation — we only need the raw character payload).
List<String> stringLiterals(String line) {
  final out = <String>[];
  final re = RegExp(r'''"((?:[^"\\]|\\.)*)"|'((?:[^'\\]|\\.)*)' ''');
  // (note: trailing space in the source is part of the raw string and harmless)
  for (final m in re.allMatches(line)) {
    out.add(m.group(1) ?? m.group(2) ?? '');
  }
  return out;
}

/// The line with adjacent / `+`-joined string literals concatenated into single
/// literals, so a value split across literals is reconstructed before matching.
/// Conservative: only joins literals separated by whitespace or a single `+`.
String joinAdjacentLiterals(String line) {
  // Collapse `"a" "b"`, `"a"+"b"`, `'a' + 'b'` (and mixed) -> `"ab"`.
  final joiner = RegExp(r'''(["'])((?:[^"'\\]|\\.)*)\1\s*\+?\s*(["'])''');
  var prev = '';
  var cur = line;
  // Iterate to a fixed point so 3+ literals collapse too.
  var guard = 0;
  while (cur != prev && guard < 64) {
    prev = cur;
    cur = cur.replaceAllMapped(joiner, (m) {
      // Re-open a literal with the first quote and the captured inner text so
      // the next pass can keep eating following literals.
      return '${m.group(1)}${m.group(2)}';
    });
    guard++;
  }
  return cur;
}

// --- Color luminance (R4: semantic dark-color detection) ------------------
//
// Reject DARK colors by computed luminance, not by literal `0xFF111111`. We
// parse the forms Dart code actually uses:
//   Color(0xFF112233) / Color(0xff112233)         hex ARGB
//   Color.fromARGB(255, 17, 17, 17)               int channels
//   Color.fromRGBO(17, 17, 17, 1.0)               int channels + opacity
//   HSLColor.fromAHSL(1, 0, 0, 0.07)              lightness < threshold
// Relative luminance (Rec. 709-ish, linear-enough for a threshold) on 0..1.

double _luma(int r, int g, int b) =>
    (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;

/// Dark when luminance below this. 0.18 catches #111..#2E greys without
/// flagging mid-tone brand colors. (0xFF333333 -> ~0.20 passes; 0xFF2A2A2A ->
/// ~0.16 fails, matching the legacy 0xFF[0-3][0-3] intent but semantically.)
const double _darkLumaThreshold = 0.18;

/// Parse every color construction on a line and return the list of luminances
/// found (empty if none). Case-insensitive; handles 0x/0X and 6- or 8-digit
/// hex (assumes opaque when 6-digit). Also parses fromARGB/fromRGBO/HSL.
List<double> colorLuminances(String line) {
  final out = <double>[];

  // 0xAARRGGBB or 0xRRGGBB (case-insensitive).
  for (final m in RegExp(r'0[xX]([0-9a-fA-F]{6,8})').allMatches(line)) {
    final hex = m.group(1)!;
    final v = int.parse(hex, radix: 16);
    final int r, g, b;
    if (hex.length == 8) {
      r = (v >> 16) & 0xFF;
      g = (v >> 8) & 0xFF;
      b = v & 0xFF;
    } else {
      r = (v >> 16) & 0xFF;
      g = (v >> 8) & 0xFF;
      b = v & 0xFF;
    }
    out.add(_luma(r, g, b));
  }

  // Color.fromARGB(a, r, g, b)
  for (final m in RegExp(
    r'fromARGB\s*\(\s*\d+\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)',
    caseSensitive: false,
  ).allMatches(line)) {
    out.add(
      _luma(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      ),
    );
  }

  // Color.fromRGBO(r, g, b, o)
  for (final m in RegExp(
    r'fromRGBO\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,',
    caseSensitive: false,
  ).allMatches(line)) {
    out.add(
      _luma(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      ),
    );
  }

  // HSLColor.fromAHSL(a, h, s, l) — use lightness directly as a luma proxy.
  for (final m in RegExp(
    r'fromAHSL\s*\(\s*[\d.]+\s*,\s*[\d.]+\s*,\s*[\d.]+\s*,\s*([\d.]+)\s*\)',
    caseSensitive: false,
  ).allMatches(line)) {
    out.add(double.parse(m.group(1)!));
  }

  return out;
}

/// True if the line constructs at least one color darker than the threshold.
bool hasDarkColor(String line) {
  for (final l in colorLuminances(line)) {
    if (l < _darkLumaThreshold) return true;
  }
  return false;
}

/// A line that paints a SURFACE/background (vs. text/icon ink). Gate 46/54 only
/// care about dark *surfaces*; dark text on a light background is correct in
/// this light-theme RTL app (the codebase legitimately uses 0xFF1A1A1A as text
/// ink ~18×). Scoping to surface constructors kills that whole false-positive
/// class while keeping the semantic dark-surface protection (a lowercase /
/// fromARGB dark *background* is still caught).
final RegExp _surfaceCtx = RegExp(
  r'\b(ColoredBox|DecoratedBox|BoxDecoration|backgroundColor|barBackgroundColor|'
  r'scaffoldBackgroundColor|canvasColor|cardColor|surfaceTintColor|'
  r'Scaffold\s*\(|Material\s*\(|Container\s*\(|Card\s*\(|fillColor|'
  r'BsTokens\.bg|color:\s*[^,)]*\bbg)\b',
  caseSensitive: false,
);

/// True when the line paints a dark *surface* (surface context AND dark color).
bool hasDarkSurface(String line) =>
    _surfaceCtx.hasMatch(line) && hasDarkColor(line);

// --- Secret detection (R4: entropy + provider fingerprints + joined) ------

/// Shannon entropy (bits per char) of a string.
double shannonEntropy(String s) {
  if (s.isEmpty) return 0;
  final counts = <int, int>{};
  for (final u in s.codeUnits) {
    counts[u] = (counts[u] ?? 0) + 1;
  }
  var h = 0.0;
  final n = s.length;
  for (final c in counts.values) {
    final p = c / n;
    h -= p * (math.log(p) / math.ln2);
  }
  return h;
}

/// Provider fingerprints — a literal value containing any of these is a secret
/// regardless of the variable name (name-agnostic). Order-independent.
final List<RegExp> _secretFingerprints = [
  RegExp(r'AKIA[0-9A-Z]{12,}'), // AWS access key id
  RegExp(r'AIza[0-9A-Za-z_\-]{20,}'), // Google API key
  RegExp(r'ghp_[0-9A-Za-z]{20,}'), // GitHub PAT
  RegExp(r'xox[bp]-[0-9A-Za-z\-]{10,}'), // Slack token
  RegExp(r'sk-[0-9A-Za-z]{20,}'), // OpenAI-style key
  RegExp(r'-----BEGIN [A-Z ]*PRIVATE KEY-----'), // PEM private key
  RegExp(r'eyJ[A-Za-z0-9_\-]{10,}\.[A-Za-z0-9_\-]{10,}\.'), // JWT
];

/// Names that strongly indicate a NON-secret (regex/test/placeholder). Used to
/// suppress the *entropy* heuristic only — fingerprints always fire.
final RegExp _secretAllow = RegExp(
  r'regex|pattern|\.test\(|expect\(|placeholder|example|dummy|fixture|sample|lorem',
  caseSensitive: false,
);

/// A value that is obviously NOT a credential even at high length: a file path,
/// an asset reference, a dotted lowercase identifier (e.g. 'bs.cart.v1' or
/// 'drainage.traps.floor'), a URL, or a snake/kebab key. These dominate this
/// codebase (asset paths, persistence keys, ids) and must not be flagged by the
/// entropy heuristic — that was the red-team-confirmed false-positive class.
bool _looksLikePathOrId(String v) {
  if (v.contains('/')) return true; // path / URL
  if (RegExp(
    r'\.(jpe?g|png|webp|gif|svg|json|dart|arb|txt|md|ya?ml|csv)$',
    caseSensitive: false,
  ).hasMatch(v)) {
    return true; // asset/file reference
  }
  // dotted lowercase identifier: word(.word)+ with no upper/+/= entropy markers
  if (RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)+$').hasMatch(v)) return true;
  // spaced human text
  if (v.contains(' ')) return true;
  return false;
}

/// A high-entropy assignment to a secret-ish value. We include `.` and `=` in
/// the value class (tokens often contain them) and require length+entropy so we
/// don't flag ordinary identifiers. Path/id/asset shapes are excluded.
bool _looksHighEntropySecret(String line) {
  if (_secretAllow.hasMatch(line)) return false;
  // assignment of a quoted value: name [:=] "VALUE"
  final assign = RegExp(r'''[:=]\s*['"]([A-Za-z0-9+/_.=\-]{20,})['"]''');
  for (final m in assign.allMatches(line)) {
    final v = m.group(1)!;
    if (_looksLikePathOrId(v)) continue;
    // Require BOTH high entropy and a mixed-case/alnum signature (real tokens
    // mix cases and digits; a long lowercase word does not).
    final mixed =
        RegExp(r'[A-Z]').hasMatch(v) &&
        RegExp(r'[a-z]').hasMatch(v) &&
        RegExp(r'[0-9]').hasMatch(v);
    if (shannonEntropy(v) >= 4.0 && mixed) {
      return true;
    }
  }
  return false;
}

/// Returns true if the (already literal-joined) line contains a secret by
/// fingerprint OR by entropy. Fingerprints scan BOTH the raw line and the
/// concatenated string literals (so split secrets are caught).
bool lineHasSecret(String line) {
  final joined = joinAdjacentLiterals(line);
  final literalsConcat = stringLiterals(joined).join();
  for (final fp in _secretFingerprints) {
    if (fp.hasMatch(joined) || fp.hasMatch(literalsConcat)) return true;
  }
  if (_looksHighEntropySecret(joined)) return true;
  return false;
}

// --- Emoji allowlist (R4: INVERT to allowlist over legacy set) ------------
//
// v2 watched a 5-emoji DENYLIST (🎯🎨🎮🎪🎲) as a proxy for "invented emoji" —
// trivially bypassed by any *other* new emoji. v3 inverts: we allow ONLY the
// legacy pictographic set actually used across app_flutter/ + app/ (extracted
// at build time, 297 runes) and warn on ANY Extended_Pictographic rune outside
// it. Variation selectors (VS-16 U+FE0F), ZWJ (U+200D) and skin-tone modifiers
// (U+1F3FB..U+1F3FF) are stripped before the check so a legacy base emoji with
// a modifier is still recognized as legacy.

/// The legacy emoji allowlist (verbatim runes harvested from the live codebase).
const Set<int> kLegacyEmoji = {
  0x2122,
  0x2139,
  0x2190,
  0x2191,
  0x2192,
  0x2193,
  0x2194,
  0x2195,
  0x2196,
  0x2198,
  0x21A4,
  0x21A6,
  0x21A9,
  0x21AA,
  0x21AE,
  0x21B3,
  0x21BA,
  0x21BB,
  0x21D0,
  0x21D2,
  0x2300,
  0x2302,
  0x23ED,
  0x23F0,
  0x23F1,
  0x23F2,
  0x23F3,
  0x23F9,
  0x23FC,
  0x2600,
  0x2601,
  0x2605,
  0x2606,
  0x2611,
  0x2630,
  0x2661,
  0x2668,
  0x267B,
  0x267F,
  0x2693,
  0x2696,
  0x2699,
  0x26A0,
  0x26A1,
  0x26AA,
  0x26AB,
  0x26C5,
  0x26D4,
  0x2702,
  0x2705,
  0x270D,
  0x270F,
  0x2713,
  0x2714,
  0x2715,
  0x2717,
  0x271A,
  0x2728,
  0x2744,
  0x274C,
  0x2753,
  0x2764,
  0x2795,
  0x2796,
  0x2934,
  0x2935,
  0x2B06,
  0x2B07,
  0x2B1B,
  0x2B1C,
  0x2B50,
  0x2B55,
  0x3030,
  0x1F0CF,
  0x1F1EE,
  0x1F1F9,
  0x1F300,
  0x1F309,
  0x1F30D,
  0x1F310,
  0x1F31F,
  0x1F321,
  0x1F326,
  0x1F327,
  0x1F331,
  0x1F333,
  0x1F33F,
  0x1F373,
  0x1F37D,
  0x1F381,
  0x1F389,
  0x1F393,
  0x1F397,
  0x1F399,
  0x1F39A,
  0x1F39B,
  0x1F39F,
  0x1F3A4,
  0x1F3A7,
  0x1F3A8,
  0x1F3AA,
  0x1F3AE,
  0x1F3AF,
  0x1F3B2,
  0x1F3C1,
  0x1F3C5,
  0x1F3C6,
  0x1F3D7,
  0x1F3D9,
  0x1F3DB,
  0x1F3E0,
  0x1F3E2,
  0x1F3EA,
  0x1F3EC,
  0x1F3ED,
  0x1F3F7,
  0x1F41B,
  0x1F446,
  0x1F44B,
  0x1F44D,
  0x1F451,
  0x1F454,
  0x1F464,
  0x1F465,
  0x1F477,
  0x1F48E,
  0x1F4A1,
  0x1F4A7,
  0x1F4A8,
  0x1F4AA,
  0x1F4AC,
  0x1F4B0,
  0x1F4B1,
  0x1F4B2,
  0x1F4B3,
  0x1F4B5,
  0x1F4BB,
  0x1F4BC,
  0x1F4BE,
  0x1F4C2,
  0x1F4C4,
  0x1F4C5,
  0x1F4C6,
  0x1F4C8,
  0x1F4C9,
  0x1F4CA,
  0x1F4CB,
  0x1F4CC,
  0x1F4CD,
  0x1F4CF,
  0x1F4D0,
  0x1F4D1,
  0x1F4D3,
  0x1F4DA,
  0x1F4DC,
  0x1F4DD,
  0x1F4DE,
  0x1F4E3,
  0x1F4E4,
  0x1F4E5,
  0x1F4E6,
  0x1F4E8,
  0x1F4F1,
  0x1F4F2,
  0x1F4F3,
  0x1F4F6,
  0x1F4F7,
  0x1F4F8,
  0x1F500,
  0x1F501,
  0x1F504,
  0x1F507,
  0x1F50A,
  0x1F50B,
  0x1F50C,
  0x1F50D,
  0x1F50E,
  0x1F510,
  0x1F511,
  0x1F512,
  0x1F513,
  0x1F514,
  0x1F517,
  0x1F518,
  0x1F51F,
  0x1F520,
  0x1F521,
  0x1F525,
  0x1F527,
  0x1F528,
  0x1F529,
  0x1F52A,
  0x1F52B,
  0x1F52C,
  0x1F52D,
  0x1F530,
  0x1F531,
  0x1F532,
  0x1F534,
  0x1F535,
  0x1F53A,
  0x1F53B,
  0x1F550,
  0x1F552,
  0x1F553,
  0x1F558,
  0x1F573,
  0x1F577,
  0x1F578,
  0x1F58C,
  0x1F5A5,
  0x1F5A8,
  0x1F5BC,
  0x1F5C2,
  0x1F5C4,
  0x1F5D1,
  0x1F5D3,
  0x1F5FA,
  0x1F648,
  0x1F64F,
  0x1F680,
  0x1F690,
  0x1F691,
  0x1F697,
  0x1F69A,
  0x1F69B,
  0x1F6A7,
  0x1F6A8,
  0x1F6AA,
  0x1F6AB,
  0x1F6B0,
  0x1F6B5,
  0x1F6BD,
  0x1F6BE,
  0x1F6BF,
  0x1F6C1,
  0x1F6CB,
  0x1F6CD,
  0x1F6D1,
  0x1F6D2,
  0x1F6D7,
  0x1F6DF,
  0x1F6E0,
  0x1F6E1,
  0x1F6E2,
  0x1F6F5,
  0x1F7E0,
  0x1F7E1,
  0x1F7E2,
  0x1F7E3,
  0x1F7E4,
  0x1F7E6,
  0x1F7E7,
  0x1F7E9,
  0x1F7EA,
  0x1F7EB,
  0x1F916,
  0x1F91A,
  0x1F91D,
  0x1F92B,
  0x1F947,
  0x1F948,
  0x1F949,
  0x1F9B5,
  0x1F9BA,
  0x1F9E0,
  0x1F9E4,
  0x1F9E9,
  0x1F9EA,
  0x1F9ED,
  0x1F9EE,
  0x1F9EF,
  0x1F9F0,
  0x1F9F1,
  0x1F9F4,
  0x1F9F5,
  0x1F9F7,
  0x1F9F9,
  0x1F9FA,
  0x1F9FC,
  0x1F9FD,
  0x1F9FE,
  0x1FA80,
  0x1FA91,
  0x1FA99,
  0x1FA9A,
  0x1FA9B,
  0x1FA9C,
  0x1FA9D,
  0x1FA9E,
  0x1FAA0,
  0x1FAA1,
  0x1FAA2,
  0x1FAA3,
  0x1FAA8,
  0x1FAAB,
  0x1FAB5,
};

/// Runes that are insignificant for the allowlist check (strip before testing).
bool _isEmojiModifier(int r) =>
    r == 0xFE0F || // VS-16 (emoji presentation)
    r == 0xFE0E || // VS-15 (text presentation)
    r == 0x200D || // ZWJ
    (r >= 0x1F3FB && r <= 0x1F3FF); // skin-tone modifiers

/// True if a rune is plausibly an emoji / pictographic symbol we should police.
/// Covers the Extended_Pictographic-ish ranges plus the dingbat/symbol/arrow
/// blocks the app uses as icons. Deliberately broad; the allowlist narrows it.
bool _isPictographic(int r) {
  return (r >= 0x1F000 && r <= 0x1FAFF) ||
      (r >= 0x2600 && r <= 0x27BF) ||
      (r >= 0x2B00 && r <= 0x2BFF) ||
      (r >= 0x2190 && r <= 0x21FF) ||
      (r >= 0x2300 && r <= 0x23FF) ||
      r == 0x2122 ||
      r == 0x2139 ||
      (r >= 0x2934 && r <= 0x2935) ||
      r == 0x3030 ||
      r == 0x303D ||
      (r >= 0x1F1E6 && r <= 0x1F1FF); // regional indicators
}

/// Decode `\u{XXXX}` and `\uXXXX` escapes so an emoji smuggled as an escape is
/// still seen by the rune scanner.
String decodeUnicodeEscapes(String line) {
  var s = line.replaceAllMapped(
    RegExp(r'\\u\{([0-9a-fA-F]+)\}'),
    (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
  );
  s = s.replaceAllMapped(
    RegExp(r'\\u([0-9a-fA-F]{4})'),
    (m) => String.fromCharCode(int.parse(m.group(1)!, radix: 16)),
  );
  return s;
}

/// Returns the first non-allowlisted pictographic rune on a line, or null.
int? firstNonLegacyEmoji(String line) {
  final decoded = decodeUnicodeEscapes(line);
  for (final r in decoded.runes) {
    if (_isEmojiModifier(r)) continue;
    if (!_isPictographic(r)) continue;
    if (kLegacyEmoji.contains(r)) continue;
    return r;
  }
  return null;
}

// --- Individual content gates --------------------------------------------
// Each is a pure function of its string input(s).
//
// Two entrypoints exist per gate-family:
//   * gateX(diff)         — line-oriented, used by --diff (and by the self-test
//                           for backward compatibility).
//   * the same predicates power --tree mode over whole-file post-images.

/// Gate 28: no absolute local URI (file:/// or C:\) in dart additions.
List<Finding> gateNoLocalUri(String dartDiff) {
  final re = RegExp(r'file:///|[A-Za-z]:\\');
  for (final l in addedLines(dartDiff)) {
    if (re.hasMatch(l)) {
      return [Finding('28', Sev.err, 'local URI in code: ${l.trim()}')];
    }
  }
  return const [];
}

/// Gate 46: no dark surface in screens. Preserves the v2 contract — the known
/// dark-surface tokens (`0xFF111111` / `BsTokens.bgDark`, case-insensitive) fire
/// unconditionally — and ADDS semantic, surface-context-scoped luminance
/// detection for OTHER dark backgrounds (lowercase/fromARGB/HSL), without
/// false-flagging dark TEXT ink.
final RegExp _legacyDarkSurface = RegExp(
  r'0[xX][fF]{2}111111|BsTokens\.bgDark',
);
List<Finding> gateNoDarkSurface(String screensDiff) {
  for (final l in addedLines(screensDiff)) {
    if (_legacyDarkSurface.hasMatch(l) || hasDarkSurface(l)) {
      return [
        Finding(
          '46',
          Sev.err,
          'dark surface: ${l.trim()} (background luminance below threshold)',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 48: no print() (or stdout/stderr.write, developer.log, bare-print
/// tear-off) in production dart. Only skips when the match itself is inside a
/// string literal.
List<Finding> gateNoPrint(String libDiff) {
  for (final l in addedLines(libDiff)) {
    final f = _printFinding(l);
    if (f != null) return [f];
  }
  return const [];
}

/// Shared predicate: does this single line invoke a forbidden print sink?
Finding? _printFinding(String l) {
  if (l.contains('debugPrint')) return null;
  // Strip string literals so a `print` appearing INSIDE a string is ignored,
  // but a real call is seen. (Strip strings BEFORE comments so a `//` inside a
  // string literal does not falsely truncate the line.)
  var code = l.replaceAll(
    RegExp(r'''"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*' '''),
    '',
  );
  // Drop an end-of-line `//` comment: a print sitting in a comment is not code.
  final cIdx = code.indexOf('//');
  if (cIdx >= 0) code = code.substring(0, cIdx);
  final outsideStrings = code;
  final patterns = <RegExp>[
    RegExp(r'(^|[^A-Za-z0-9_.])print\s*\('), // print(
    RegExp(r'(^|[^A-Za-z0-9_])std(out|err)\s*\.\s*write(ln)?\s*\('),
    RegExp(r'(^|[^A-Za-z0-9_])developer\s*\.\s*log\s*\('),
    RegExp(r'(^|[^A-Za-z0-9_.])print\s*\)'), // tear-off: foo(print)
    RegExp(r':\s*print\s*[,)]'), // tear-off in arg position
  ];
  for (final re in patterns) {
    if (re.hasMatch(outsideStrings)) {
      return Finding(
        '48',
        Sev.err,
        'print/log sink in production code: ${l.trim()} — use debugPrint or logger',
      );
    }
  }
  return null;
}

/// Gate 50: no `import 'dart:html'`.
List<Finding> gateNoDartHtml(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (RegExp(r'''import\s+['"]dart:html['"]''').hasMatch(l)) {
      return [
        Finding('50', Sev.err, "import dart:html forbidden: use package:web"),
      ];
    }
  }
  return const [];
}

/// Gate 51: no hard-coded https URL literal (warn).
List<Finding> gateNoHardUrl(String libDiff) {
  final re = RegExp(r'''https?://[^"']+["']''');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l)) {
      return [Finding('51', Sev.warn, 'hard-coded URL — consider config')];
    }
  }
  return const [];
}

/// Gate 52: secret literal — name-AGNOSTIC entropy + provider fingerprints +
/// joined adjacent literals. Scans the configured text file types.
List<Finding> gateNoSecrets(String diff) {
  for (final l in addedLines(diff)) {
    if (lineHasSecret(l)) {
      return [
        Finding(
          '52',
          Sev.err,
          'secret/high-entropy credential in code: ${l.trim().length > 80 ? "${l.trim().substring(0, 80)}…" : l.trim()}',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 54: no ColoredBox constructed with a dark color (semantic luminance).
List<Finding> gateNoDarkColoredBox(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (l.contains('ColoredBox') && hasDarkColor(l)) {
      return [Finding('54', Sev.err, 'dark ColoredBox: use light colors')];
    }
  }
  return const [];
}

/// Gate 62: no hard-coded left/right edge inset (ERR in v3). Matches
/// EdgeInsets.only(.. left:/right:), fromLTRB, and bare `left:`/`right:` in a
/// padding context. Excludes the *Directional variants. ASCII multiply not here.
List<Finding> gateNoHardLeftRight(String libDiff) {
  final only = RegExp(r'EdgeInsets\.only\([^)]*\b(left|right)\s*:');
  final ltrb = RegExp(r'EdgeInsets\.fromLTRB\s*\(');
  final padCtx = RegExp(r'padding[^=]*\b(left|right)\s*:');
  for (final l in addedLines(libDiff)) {
    if (l.contains('Directional')) continue;
    if (only.hasMatch(l) || ltrb.hasMatch(l) || padCtx.hasMatch(l)) {
      return [
        Finding(
          '62',
          Sev.err,
          'hard left/right edge inset — use EdgeInsetsDirectional start/end',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 63: no TextAlign.left/right (ERR in v3).
List<Finding> gateNoTextAlignLR(String libDiff) {
  final re = RegExp(r'TextAlign\.(left|right)\b');
  for (final l in addedLines(libDiff)) {
    if (re.hasMatch(l)) {
      return [
        Finding('63', Sev.err, 'TextAlign.left/right — use start/end (RTL)'),
      ];
    }
  }
  return const [];
}

/// Gate 64: no NON-legacy emoji — allowlist over the legacy pictographic set
/// (warn). Handles VS-16/ZWJ/skin-tone and \u{..}/\uXXXX escapes.
List<Finding> gateNoInventedEmoji(String libDiff) {
  for (final l in addedLines(libDiff)) {
    final r = firstNonLegacyEmoji(l);
    if (r != null) {
      return [
        Finding(
          '64',
          Sev.warn,
          'new emoji U+${r.toRadixString(16).toUpperCase()} not in legacy set — verify verbatim',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 65: no TextDirection.ltr in RTL app (warn). Only skips an explicit
/// isolate use (the legitimate case); the blanket `//`/`LTR` substring escapes
/// are removed (red team used `// LTR` to bypass).
List<Finding> gateNoTextDirectionLtr(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (!l.contains('TextDirection.ltr')) continue;
    // Skip ONLY if the line is a comment in its entirety, or uses an isolate.
    final trimmed = l.trimLeft();
    if (trimmed.startsWith('//')) continue;
    if (l.contains('isolate') || l.contains('Isolate')) continue;
    return [Finding('65', Sev.warn, 'TextDirection.ltr — app is RTL')];
  }
  return const [];
}

/// Gate 69: removed dark SURFACE token (warn — verify not a text color).
List<Finding> gateColorRevert(String libDiff) {
  for (final l in removedLines(libDiff)) {
    if (l.contains('BsTokens.bgDark') || hasDarkSurface(l)) {
      return [
        Finding(
          '69',
          Sev.warn,
          'removed surface color — verify not a text-color',
        ),
      ];
    }
  }
  return const [];
}

/// Gate 73: persistence key must match bs.<feature>.vN. Matches BOTH quote
/// styles, and flags interpolated/concatenated keys (red team built the key at
/// runtime to dodge the literal check).
List<Finding> gatePersistenceKey(String libDiff) {
  // Any quoted literal that starts the bs. namespace, either quote.
  final find = RegExp(r'''(['"])(bs\.[^'"]*)\1''');
  // feature segment allows snake_case / kebab (live keys: bs.saved_projects.v1).
  final valid = RegExp(r'^bs\.[a-z][a-z0-9_-]*\.v[0-9]+$');
  // Interpolation/concatenation forming a bs. key.
  final interp = RegExp(r'''(['"])bs\.[^'"]*\$''');
  final concat = RegExp(r'''(['"])bs\.[^'"]*\1\s*\+''');
  for (final l in addedLines(libDiff)) {
    if (interp.hasMatch(l) || concat.hasMatch(l)) {
      return [
        Finding(
          '73',
          Sev.err,
          'interpolated/concatenated persistence key — use a const bs.<feature>.vN literal',
        ),
      ];
    }
    final m = find.firstMatch(l);
    if (m == null) continue;
    final key = m.group(2)!;
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
    if (RegExp(r'ProviderContainer\s*\(').hasMatch(l)) {
      return [
        Finding('74', Sev.err, 'manual ProviderContainer — use ProviderScope'),
      ];
    }
  }
  return const [];
}

/// True for a line that is purely a comment (ignored by code gates that should
/// only police real code, e.g. gate 114's symbol mention in a doc-comment).
bool _isCommentLine(String l) {
  final t = l.trimLeft();
  return t.startsWith('//') || t.startsWith('*') || t.startsWith('/*');
}

/// Gate 114: the raw `kLipskeyCatalog` SYMBOL is forbidden in screens/state/
/// logic — use the de-duplicated `kCatalogProducts`. v3 also resolves `as`
/// aliases: `import '.../lipskey_catalog.dart' as lk;` then `lk.kLipskeyCatalog`
/// is caught (the red-team alias bypass). The bare import is NOT flagged — those
/// files legitimately import the `LipskeyCatalogProduct` type and `kLipskey-
/// Sections`; only the raw product-list symbol is the violation. Comment lines
/// are ignored. Caller path-scopes to screens/state/logic (data/ defines it).
List<Finding> gateNoKLipskeyInUi(String uiDiff) {
  final importRe = RegExp(
    r'''import\s+['"][^'"]*lipskey_catalog\.dart['"]\s+as\s+(\w+)''',
  );
  final added = addedLines(uiDiff).where((l) => !_isCommentLine(l)).toList();
  // Collect `as` aliases first so a later `alias.kLipskeyCatalog` is resolvable.
  final aliases = <String>{};
  for (final l in added) {
    final m = importRe.firstMatch(l);
    if (m != null) aliases.add(m.group(1)!);
  }
  for (final l in added) {
    if (RegExp(r'\bkLipskeyCatalog\b').hasMatch(l)) {
      return [
        Finding(
          '114',
          Sev.err,
          'kLipskeyCatalog in screens/state/logic: ${l.trim()} — use kCatalogProducts',
        ),
      ];
    }
    for (final a in aliases) {
      if (RegExp('\\b${RegExp.escape(a)}\\.kLipskeyCatalog\\b').hasMatch(l)) {
        return [
          Finding(
            '114',
            Sev.err,
            'aliased lipskey catalog ($a.kLipskeyCatalog) in UI — use kCatalogProducts',
          ),
        ];
      }
    }
  }
  return const [];
}

/// Gate 95: a number "<hebrew> NxN" without an LTR isolate (warn). Adds ASCII
/// `x` and `*` as multiply signs (red team used `30x40` to dodge the × glyph).
List<Finding> gateNumberIsolate(String libDiff) {
  final re = RegExp(r'[א-ת]+ [0-9]+\s*[×x*]\s*[0-9]+');
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

/// Gate 25: no edits to Preact-shared *_settings.dart.
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
    final t = l.trim();
    if (t == '.claude/' || t == '.claude' || t == '.claude/**') {
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
      continue;
    }
    if (pattern.isEmpty) continue;
    if (shellMeta.hasMatch(pattern)) continue;
    out.add((target: target, pattern: pattern));
  }
  return out;
}

/// Gate 103: a recorded ANTIPATTERN regex must not reappear in the new code.
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
        break;
      }
    }
  }
  return findings;
}

// --- Registry parity (gate `reg`) ----------------------------------------

/// A malformed registry row (R6: FAIL, do not skip).
class RegistryError {
  final int lineNo;
  final String reason;
  final String raw;
  const RegistryError(this.lineNo, this.reason, this.raw);
  @override
  String toString() => 'line $lineNo: $reason  [$raw]';
}

const Set<String> _validStatuses = {
  'enforced',
  'moved',
  'cancelled',
  'removed',
  'summary',
  'meta',
};

/// Parse the `enforced` ids from gates.tsv AND collect malformed rows. A row is
/// malformed when it has fewer than 9 columns, a blank id with content, a
/// duplicate id, or an unknown status. Comment(#)/blank/header rows are skipped.
({Set<String> enforced, List<RegistryError> errors}) parseRegistry(String tsv) {
  final ids = <String>{};
  final seen = <String>{};
  final errors = <RegistryError>[];
  var lineNo = 0;
  for (final line in const LineSplitter().convert(tsv)) {
    lineNo++;
    if (line.startsWith('#')) continue;
    if (line.trim().isEmpty) continue;
    final cols = line.split('\t');
    if (cols.isNotEmpty && cols[0] == 'id') continue; // header
    if (cols.length < 9) {
      errors.add(
        RegistryError(lineNo, 'fewer than 9 columns (${cols.length})', line),
      );
      continue;
    }
    final id = cols[0].trim();
    final status = cols[7].trim();
    if (id.isEmpty) {
      errors.add(RegistryError(lineNo, 'blank id', line));
      continue;
    }
    if (!_validStatuses.contains(status)) {
      errors.add(RegistryError(lineNo, 'unknown status "$status"', line));
      continue;
    }
    if (!seen.add(id)) {
      errors.add(RegistryError(lineNo, 'duplicate id "$id"', line));
      continue;
    }
    if (status == 'enforced') ids.add(id);
  }
  return (enforced: ids, errors: errors);
}

/// Backward-compatible accessor used by older callers/self-test.
Set<String> registryEnforcedIds(String tsv) => parseRegistry(tsv).enforced;

/// Parse emitted gate ids (one id per line).
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

// --- Orchestration --------------------------------------------------------

/// R6 — the content-gate ids THIS engine evaluates inside runAllContentGates().
/// Emitted as `RAN\t<id>` lines by --diff when --emit-ran is passed, so the
/// pre-commit runtime ledger can PROVE the engine actually executed each gate (a
/// stubbed/replaced engine would not emit them, and registry parity would then
/// fail). NOTE: registry rows 23/25/67/93/109 are marked engine=dart historically
/// but are implemented in the bash hook (ROADMAP markers / per-file globs); those
/// record via the hook's own `ran` calls, not here.
const List<String> kDartEngineGateIds = [
  '28',
  '46',
  '48',
  '50',
  '51',
  '52',
  '54',
  '62',
  '63',
  '64',
  '65',
  '67',
  '69',
  '70',
  '73',
  '74',
  '95',
  '97',
  '103',
  '114',
];

/// Run every line-oriented content gate over a combined `git diff --cached`
/// dump. `names` (when given) PATH-SCOPES the gates so they never fire on
/// exempt files. When `names` is null (legacy callers) all gates run over the
/// whole diff (preserves v2 behavior for the bash --diff path which already
/// pre-scopes via cheap name checks).
List<Finding> runAllContentGates({
  required String diff,
  List<String>? names,
  String? stuckLog,
  String? gitignoreDiff,
}) {
  // Decide which path-scoped families are in play.
  final touched = names ?? const <String>[];
  final anyLib = names == null || touched.any(isLibDartPath);
  final anyScreens = names == null || touched.any(isScreensPath);
  final anySSL = names == null || touched.any(isScreensStateLogicPath);
  final anyPreact = names == null || touched.any(isPreactAppPath);
  final anySecretScannable =
      names == null || touched.any(isSecretScannablePath);

  final findings = <Finding>[
    if (anyLib) ...gateNoLocalUri(diff),
    if (anyScreens) ...gateNoDarkSurface(diff),
    if (anyLib) ...gateNoPrint(diff),
    if (anyLib) ...gateNoDartHtml(diff),
    if (anyLib) ...gateNoHardUrl(diff),
    if (anySecretScannable) ...gateNoSecrets(diff),
    if (anyScreens) ...gateNoDarkColoredBox(diff),
    if (anyLib) ...gateNoHardLeftRight(diff),
    if (anyLib) ...gateNoTextAlignLR(diff),
    if (anyLib) ...gateNoInventedEmoji(diff),
    if (anyLib) ...gateNoTextDirectionLtr(diff),
    if (anyScreens) ...gateColorRevert(diff),
    if (anyLib) ...gatePersistenceKey(diff),
    if (anyScreens) ...gateNoManualContainer(diff),
    if (anySSL) ...gateNoKLipskeyInUi(diff),
    if (anyLib) ...gateNumberIsolate(diff),
    if (anyPreact) ...gateAppHebrewString(diff),
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
        hookAdded: added,
      ),
    );
  }
  return findings;
}

/// R2 — run the VALUE-oriented content gates over the whole-file POST-IMAGE of
/// each touched file (multi-line literals joined). Tree mode exists to catch the
/// bypass class where a forbidden VALUE is split/computed/encoded across diff
/// hunk boundaries: secrets, dark surfaces/ColoredBox, emoji, persistence keys,
/// the lipskey symbol, local URIs. The POSITIONAL/style gates (62/63/65/95/51)
/// are intentionally NOT run here: they cannot be "split", the unified diff
/// covers them line-locally, and re-scanning a whole touched file would re-flag
/// pre-existing instances (a false-block). They remain on the --diff path.
List<Finding> runTreeGates({
  required Map<String, String> files, // path -> post-image contents
  String? stuckLog,
  String? gitignoreContents,
}) {
  final findings = <Finding>[];
  for (final entry in files.entries) {
    final path = entry.key;
    final body = entry.value;
    if (isExemptPath(path)) continue;
    // Represent the whole file as an added hunk so the line predicates apply.
    final asDiff =
        '+++ b/$path\n${body.split('\n').map((l) => '+$l').join('\n')}';
    if (isLibDartPath(path)) {
      findings
        ..addAll(gateNoLocalUri(asDiff))
        ..addAll(gateNoDartHtml(asDiff))
        ..addAll(gateNoInventedEmoji(asDiff))
        ..addAll(gatePersistenceKey(asDiff));
    }
    if (isScreensPath(path)) {
      // NOTE: the dark-SURFACE / ColoredBox gates are intentionally NOT run in
      // tree mode. Dart `build()` methods are giant single expressions that mix
      // a surface constructor with legitimate dark TEXT ink (0xFF1A1A1A) in the
      // same statement, so any whole-file/statement flattening false-pairs them
      // (verified against the live tree). A dark surface is not a realistic
      // line-split bypass; the line-local --diff check (surface keyword + dark
      // color on the same added line, or `ColoredBox(color: <dark>)`) is sound.
      findings.addAll(gateNoManualContainer(asDiff));
    }
    if (isSecretScannablePath(path)) {
      findings.addAll(gateNoSecrets(asDiff));
    }
  }
  if (gitignoreContents != null && gitignoreContents.isNotEmpty) {
    // In tree mode we cannot diff removals; the .gitignore guards stay on the
    // --diff path (pre-commit). Tree mode only ADDS, so hide-claude still works.
    final asDiff =
        '+++ b/.gitignore\n${gitignoreContents.split('\n').map((l) => '+$l').join('\n')}';
    findings.addAll(gateGitignoreNoHideClaude(asDiff));
  }
  if (stuckLog != null && stuckLog.isNotEmpty) {
    final dartAdded = <String>[];
    for (final e in files.entries) {
      if (isLibDartPath(e.key)) dartAdded.addAll(e.value.split('\n'));
    }
    findings.addAll(
      gateAntipatternRecurrence(
        stuckLog: stuckLog,
        dartAdded: dartAdded,
        hookAdded: const [],
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

List<String> _readLines(String? path) {
  final raw = _readOrEmpty(path);
  return const LineSplitter()
      .convert(raw)
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
}

int _mainVerifyRegistry(List<String> args) {
  final emitted = parseEmittedIds(_readOrEmpty(_arg(args, '--emitted')));
  final reg = parseRegistry(_readOrEmpty(_arg(args, '--registry')));
  // R6: malformed rows are a HARD failure, not a silent skip.
  if (reg.errors.isNotEmpty) {
    for (final e in reg.errors) {
      stderr.writeln('ERR\treg\tmalformed registry row — $e');
    }
    return 2;
  }
  final d = registryDiff(emitted, reg.enforced);
  if (d.missingFromCode.isEmpty && d.missingFromRegistry.isEmpty) {
    stdout.writeln(
      'OK\treg\tregistry == code (${reg.enforced.length} enforced gates)',
    );
    return 0;
  }
  if (d.missingFromCode.isNotEmpty) {
    stderr.writeln(
      'ERR\treg\tin registry but NOT emitted at runtime: ${(d.missingFromCode.toList()..sort()).join(", ")}',
    );
  }
  if (d.missingFromRegistry.isNotEmpty) {
    stderr.writeln(
      'ERR\treg\temitted at runtime but NOT in registry: ${(d.missingFromRegistry.toList()..sort()).join(", ")}',
    );
  }
  return 2;
}

int _mainDiff(List<String> args) {
  final diff = _readOrEmpty(_arg(args, '--diff'));
  final names =
      _arg(args, '--names') == null ? null : _readLines(_arg(args, '--names'));
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
    names: names,
    stuckLog: stuck,
    gitignoreDiff: gitignore,
  );
  var hadErr = false;
  for (final f in findings) {
    stdout.writeln(f.toLine());
    if (f.sev == Sev.err) hadErr = true;
  }
  // R6: prove the engine RAN — emit the id of every content gate it owns. The
  // pre-commit ledger records these; a no-op/stub engine emits nothing and the
  // registry parity gate then fails.
  if (args.contains('--emit-ran')) {
    for (final id in kDartEngineGateIds) {
      stdout.writeln('RAN\t$id\t');
    }
  }
  return hadErr ? 2 : 0;
}

/// R2 tree mode. Reads the touched names, fetches each post-image via the
/// `--show` prefix (default `git show :` = the staged index), and scans it.
int _mainTree(List<String> args) {
  final names = _readLines(_arg(args, '--names'));
  final showPrefix = _arg(args, '--show') ?? 'git show :';
  final files = <String, String>{};
  for (final path in names) {
    if (path.isEmpty) continue;
    // Only fetch text we might scan.
    if (!isLibDartPath(path) &&
        !isScreensPath(path) &&
        !isSecretScannablePath(path)) {
      continue;
    }
    try {
      final parts = showPrefix.trim().split(RegExp(r'\s+'));
      final ProcessResult res;
      if (showPrefix.contains(':') && showPrefix.trim().endsWith(':')) {
        // `git show :path` (index) — append path to the last token.
        final argv = [
          ...parts.sublist(1, parts.length - 1),
          '${parts.last}$path',
        ];
        res = Process.runSync(parts.first, argv);
      } else {
        // e.g. `git show <sha>:` style or a base ref — caller appends path.
        res = Process.runSync(parts.first, [...parts.sublist(1), '$path']);
      }
      if (res.exitCode == 0) files[path] = res.stdout.toString();
    } catch (_) {
      // A file that cannot be shown (deleted) is simply not scanned.
    }
  }
  final stuck =
      _arg(args, '--stuck-log') == null
          ? null
          : _readOrEmpty(_arg(args, '--stuck-log'));
  final gi =
      _arg(args, '--gitignore') == null
          ? null
          : _readOrEmpty(_arg(args, '--gitignore'));
  final findings = runTreeGates(
    files: files,
    stuckLog: stuck,
    gitignoreContents: gi,
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
  if (args.contains('--tree')) {
    exit(_mainTree(args));
  }
  exit(_mainDiff(args));
}
