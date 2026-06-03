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

// --- Path de-quoting (H1: non-ASCII filenames via core.quotePath) ----------
//
// H1 (v6): with the default `core.quotePath=true`, git C-style-QUOTES any path
// byte > 0x7F. A Hebrew-named `lib/screens/מסך.dart` is emitted by `ls-tree`
// and `diff --name-only` as `"app_flutter/lib/screens/\327\236\327\241\327\232.dart"`.
// When that QUOTED string is fed to the engine (as a `--names` entry, or as the
// `+++ b/<path>` header inside a diff), `git show HEAD:"<quoted>"` cannot resolve
// the blob → the file is SILENTLY DROPPED and forbidden content shipped. We fix
// at the source (callers pass `-c core.quotePath=false`) AND defensively here:
// any quoted name is decoded back to its true UTF-8 bytes before use, so the
// engine is correct even if a future caller forgets the flag.
//
// A quoted git path is wrapped in double-quotes and uses C escapes: \\ \" \t \n
// and OCTAL byte escapes `\NNN` (the raw UTF-8 bytes of the codepoint). We
// reassemble the byte sequence and utf8-decode it (allowMalformed so a genuinely
// invalid byte does not throw — H2's spirit applied to names too).
String unquoteGitPath(String name) {
  if (name.length < 2 || !name.startsWith('"') || !name.endsWith('"')) {
    return name; // not a C-quoted path — return as-is
  }
  final inner = name.substring(1, name.length - 1);
  final bytes = <int>[];
  for (var i = 0; i < inner.length; i++) {
    final c = inner[i];
    if (c != '\\') {
      // A normal char — emit its UTF-8 bytes (ASCII stays one byte).
      bytes.addAll(utf8.encode(c));
      continue;
    }
    // Escape sequence.
    if (i + 1 >= inner.length) {
      bytes.addAll(utf8.encode(c));
      break;
    }
    final n = inner[i + 1];
    // Octal byte escape: \NNN (1–3 octal digits). git always emits exactly 3.
    if (n.codeUnitAt(0) >= 0x30 && n.codeUnitAt(0) <= 0x37) {
      var j = i + 1;
      var oct = '';
      while (j < inner.length &&
          oct.length < 3 &&
          inner.codeUnitAt(j) >= 0x30 &&
          inner.codeUnitAt(j) <= 0x37) {
        oct += inner[j];
        j++;
      }
      bytes.add(int.parse(oct, radix: 8) & 0xFF);
      i = j - 1;
      continue;
    }
    // Named C escapes.
    switch (n) {
      case 'n':
        bytes.add(0x0A);
        break;
      case 't':
        bytes.add(0x09);
        break;
      case 'r':
        bytes.add(0x0D);
        break;
      case '"':
        bytes.add(0x22);
        break;
      case r'\':
        bytes.add(0x5C);
        break;
      default:
        bytes.addAll(utf8.encode(n)); // unknown escape — keep literal char
    }
    i++;
  }
  return utf8.decode(bytes, allowMalformed: true);
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

// --- F1: PER-FILE diff partitioning (kills cross-file contamination) -------
//
// The v3 false-positive keystone: runAllContentGates concatenated the WHOLE
// `git diff --cached` into one string, then ran each gate over it if ANY touched
// file matched the gate's scope. So a screens-only gate (46/114) fired on lines
// belonging to an out-of-scope CO-COMMITTED file (a theme/ file, a data/ file)
// merely because some OTHER file in the same commit was a screen. We now split
// the unified diff back into per-file sub-diffs keyed by the `+++ b/<path>`
// header, so each gate runs ONLY over the hunks of files whose PATH matches its
// own scope predicate. This is the structurally-correct fix (a gate's scope is a
// property of the FILE, not of the commit).

/// Split a unified `git diff` into a map of `path -> sub-diff`. Each sub-diff
/// retains a `+++ b/<path>` header plus that file's own +/-/context lines, so the
/// existing line-oriented gate predicates work unchanged.
///
/// The file BOUNDARY is detected from any of: a `diff --git a/x b/y` line, a
/// `--- a/<path>` / `+++ b/<path>` header pair, or a bare `+++ b/<path>` header
/// (our synthetic/test form, which has no `---`). Crucially each new boundary
/// FLUSHES the accumulated buffer to the PREVIOUS path first, so a file's lines
/// can never bleed into the next file's bucket (the v3 cross-file contamination
/// bug came from concatenation, and a naive splitter that only flushed on `---`
/// re-introduced it when `---` was absent). The post-image name wins; a
/// `+++ /dev/null` deletion is keyed by the `--- a/<path>` so removal gates see it.
Map<String, String> splitDiffByFile(String diff) {
  final out = <String, String>{};
  String? curPath;
  String? pendingMinusPath;
  final buf = StringBuffer();

  void flushTo(String? path) {
    if (path != null && buf.isNotEmpty) {
      final prev = out[path];
      out[path] = prev == null ? buf.toString() : '$prev\n${buf.toString()}';
    }
    buf.clear();
  }

  String strip(String raw, int prefixLen) {
    var p = raw.substring(prefixLen).trim();
    final tab = p.indexOf('\t');
    if (tab >= 0) p = p.substring(0, tab);
    // H1: a non-ASCII path is C-quoted by git in the `+++ b/"..."` header. Decode
    // it back to true bytes BEFORE stripping the a/ b/ prefix (the prefix is
    // INSIDE the quotes: `"b/app_flutter/..\NNN..dart"`).
    p = unquoteGitPath(p);
    if (p.startsWith('a/') || p.startsWith('b/')) p = p.substring(2);
    return p;
  }

  for (final raw in const LineSplitter().convert(diff)) {
    if (raw.startsWith('diff --git ')) {
      // New file boundary — commit whatever we held for the previous file.
      flushTo(curPath);
      curPath = null;
      pendingMinusPath = null;
      // Try to pre-seed the path from `diff --git a/x b/y` (post-image = b/y).
      final m = RegExp(r'^diff --git a/(.+) b/(.+)$').firstMatch(raw);
      if (m != null) curPath = m.group(2);
      buf.writeln(raw);
      continue;
    }
    if (raw.startsWith('--- ')) {
      final a = strip(raw, 4);
      pendingMinusPath = a == '/dev/null' ? null : a;
      buf.writeln(raw);
      continue;
    }
    if (raw.startsWith('+++ ')) {
      // A bare `+++` (no preceding `diff --git`) is also a boundary: flush first.
      final b = strip(raw, 4);
      final newPath = b == '/dev/null' ? pendingMinusPath : b;
      // If this header opens a DIFFERENT file than what we're buffering, flush
      // the previous file's content before switching.
      if (curPath != null && newPath != curPath) {
        // The `+++`/`---` header lines for THIS file were just written into buf;
        // pull them off and carry them to the new bucket.
        flushTo(curPath);
      }
      curPath = newPath;
      buf.writeln(raw);
      continue;
    }
    buf.writeln(raw);
  }
  flushTo(curPath);
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

/// Text files secrets are scanned in (R4 + C3: widen beyond .dart so a secret
/// hidden in a native/web/build file is still caught — .kt/.swift/.html/.css/
/// .toml/.gradle/.xml at least).
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
    // C3 — close the --tree extension gap (native + web + build configs).
    '.kt',
    '.kts',
    '.swift',
    '.html',
    '.htm',
    '.css',
    '.toml',
    '.cfg',
    '.ini',
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

/// C6 — dark when luminance below this. Raised from 0.18 to 0.205 so the
/// near-black grey band 0x2E..0x33 is caught as a dark surface
/// (0xFF333333 -> luma 0.20 < 0.205 now fails; 0xFF2E2E2E -> 0.18; 0xFF393939 ->
/// 0.224 still passes as a legit mid grey). Used together with the F4
/// near-greyscale test below so a SATURATED dark colour is NOT called "dark".
const double _darkLumaThreshold = 0.205;

/// F4 — max channel spread for a colour to count as "near-greyscale". A dark
/// SURFACE in this app's design is a grey/near-black (R≈G≈B); a saturated colour
/// (a brand blue like 0xFF0D47A1, a dark green ink) has a wide channel spread and
/// is NOT a "dark surface" even if its luma is low. Spread = max-min channel.
/// 64/255 ≈ 0.25 tolerates anti-aliased greys (e.g. 0xFF1A1B22) while rejecting
/// any colour with a real hue (0xFF0D47A1 spread = 0x9A = 154 ≫ 64).
const int _greyscaleSpreadMax = 64;

/// A parsed colour: its luminance plus the channel spread (max-min), so callers
/// can apply BOTH the dark-luma test (C6) and the near-greyscale test (F4).
class ParsedColor {
  final double luma;
  final int spread; // max(r,g,b) - min(r,g,b); -1 when unknown (HSL lightness)
  const ParsedColor(this.luma, this.spread);

  /// True for a DARK, NEAR-GREYSCALE colour — i.e. a dark *surface* candidate.
  /// (HSL with spread==-1 falls back to luma-only since we only have lightness.)
  bool get isDarkGrey =>
      luma < _darkLumaThreshold &&
      (spread < 0 || spread <= _greyscaleSpreadMax);
}

int _spread(int r, int g, int b) {
  final mx = math.max(r, math.max(g, b));
  final mn = math.min(r, math.min(g, b));
  return mx - mn;
}

/// Parse every colour construction on a line. Case-insensitive; handles 0x/0X
/// and 6- or 8-digit hex (opaque when 6-digit), fromARGB/fromRGBO/HSL.
List<ParsedColor> parseColors(String line) {
  final out = <ParsedColor>[];

  // 0xAARRGGBB or 0xRRGGBB (case-insensitive).
  for (final m in RegExp(r'0[xX]([0-9a-fA-F]{6,8})').allMatches(line)) {
    final hex = m.group(1)!;
    final v = int.parse(hex, radix: 16);
    final r = (v >> 16) & 0xFF;
    final g = (v >> 8) & 0xFF;
    final b = v & 0xFF;
    // F4/E4 hardening: an 8-digit value carries an ALPHA byte. A TRANSLUCENT
    // colour (alpha < 0x80) is a shadow / scrim / overlay — NOT a solid dark
    // SURFACE. `Color(0x14000000)` (a 8%-opacity black shadow) must NOT be read
    // as a dark surface. We skip it as a surface candidate; a solid dark surface
    // uses full/near-full alpha (`0xFF…`). 6-digit values are opaque (no alpha).
    if (hex.length == 8) {
      final a = (v >> 24) & 0xFF;
      if (a < 0x80) continue; // translucent — shadow/scrim, not a surface
    }
    out.add(ParsedColor(_luma(r, g, b), _spread(r, g, b)));
  }

  // Color.fromARGB(a, r, g, b)
  for (final m in RegExp(
    r'fromARGB\s*\(\s*\d+\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)',
    caseSensitive: false,
  ).allMatches(line)) {
    final r = int.parse(m.group(1)!);
    final g = int.parse(m.group(2)!);
    final b = int.parse(m.group(3)!);
    out.add(ParsedColor(_luma(r, g, b), _spread(r, g, b)));
  }

  // Color.fromRGBO(r, g, b, o)
  for (final m in RegExp(
    r'fromRGBO\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,',
    caseSensitive: false,
  ).allMatches(line)) {
    final r = int.parse(m.group(1)!);
    final g = int.parse(m.group(2)!);
    final b = int.parse(m.group(3)!);
    out.add(ParsedColor(_luma(r, g, b), _spread(r, g, b)));
  }

  // HSLColor.fromAHSL(a, h, s, l) — lightness as a luma proxy; spread unknown
  // (-1) BUT only treat as dark-grey when saturation is low, so a saturated dark
  // HSL hue is not mis-called grey. We encode that by reading saturation too.
  for (final m in RegExp(
    r'fromAHSL\s*\(\s*[\d.]+\s*,\s*[\d.]+\s*,\s*([\d.]+)\s*,\s*([\d.]+)\s*\)',
    caseSensitive: false,
  ).allMatches(line)) {
    final sat = double.parse(m.group(1)!);
    final light = double.parse(m.group(2)!);
    // low saturation -> behaves like grey (spread -1 => luma-only path);
    // high saturation -> give it a large spread so F4 rejects it as a surface.
    out.add(ParsedColor(light, sat <= 0.25 ? -1 : 255));
  }

  return out;
}

/// Backward-compatible list of luminances (older callers/self-test).
List<double> colorLuminances(String line) =>
    parseColors(line).map((c) => c.luma).toList();

/// True if the line constructs at least one DARK, NEAR-GREYSCALE colour. F4:
/// saturated dark colours (brand blues/greens) are NOT counted as "dark" here.
bool hasDarkColor(String line) {
  for (final c in parseColors(line)) {
    if (c.isDarkGrey) return true;
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

/// F2 — Subresource-Integrity / content-hash prefixes. A value carrying one of
/// these is an INTEGRITY DIGEST (a PUBLIC hash of a public asset), never a
/// credential. Allowlisted so the strengthened entropy heuristic (C1) does not
/// false-flag `integrity: "sha384-…"`, a pinned digest, or a git/blob sha.
/// Matched against the literal VALUE and its immediate context.
final RegExp _integrityContext = RegExp(
  r'''\bsha(?:1|224|256|384|512)-|''' // SRI: sha256-/sha384-/sha512-
  r'''\bintegrity['"]?\s*[:=]|''' // integrity: / 'integrity':
  r'''\b(?:sha256sum|sha1sum|checksum|digest|fingerprint|etag)\b|'''
  r'''\bsha(?:1|256|512)['"]?\s*[:=]''', // sha256: <hex>
  caseSensitive: false,
);

/// True when the VALUE itself is an SRI digest token (sha256-BASE64==).
bool _isSriDigest(String v) =>
    RegExp(r'^sha(?:256|384|512)-[A-Za-z0-9+/]+={0,2}$').hasMatch(v);

// V9-A — the v7/v8 inline-IMAGE exemption (`_isInlineImageBlob`, `_ImageVerdict`,
// `_classifyImageBlob`, `_hasImageMagic`, `byteEntropy`) has been REMOVED. It was
// a recurring laundering surface: v7 text-matched a PNG prefix and downgraded a
// spliced secret to WARN; v8's decode-and-scan re-fix left TWO holes (a secret
// APPENDED after a valid image escaped the scanned header window; a data-URI
// payload was never extracted). V9 eliminates the CLASS instead of patching the
// edge cases: any inline base64/binary blob (`_looksBinaryBlob`) is an ERR. Real
// images belong in assets/, not inline in source. See `_looksBinaryBlob` and
// `gateNoSecrets`.

/// Robustly base64-DECODE a candidate blob, or null if it is not valid base64.
/// Tolerates: an optional `data:...;base64,` prefix, url-safe alphabet (`-`/`_`),
/// and missing `=` padding. A `length % 4 == 1` string is never valid base64.
List<int>? _tryBase64Decode(String v) {
  var t = v.contains(',') ? v.substring(v.indexOf(',') + 1) : v;
  t = t.replaceAll(RegExp(r'\s'), '').replaceAll('-', '+').replaceAll('_', '/');
  if (t.isEmpty) return null;
  if (t.length % 4 == 1) return null; // never a valid base64 length
  final pad = (4 - t.length % 4) % 4;
  t = t + ('=' * pad);
  try {
    return base64.decode(t);
  } catch (_) {
    return null;
  }
}

/// Fraction of bytes that are NON-printable (outside tab/CR/LF and the
/// 0x20–0x7E printable-ASCII band). A real BINARY payload (image, archive,
/// compiled blob, raw key material) is dominated by non-printable bytes; a
/// base64 encoding of plain TEXT (a sentence, a JSON snippet) decodes to ~0
/// non-printable. This is the SHAPE discriminator V9 uses to tell an inline
/// binary blob apart from a long base64-charset *text* token.
double _nonPrintableFraction(List<int> b) {
  if (b.isEmpty) return 0;
  var np = 0;
  for (final x in b) {
    final printable = (x >= 0x20 && x <= 0x7E) || x == 0x09 || x == 0x0A || x == 0x0D;
    if (!printable) np++;
  }
  return np / b.length;
}

/// V9-A — the CLASS-KILLER. True when a quoted VALUE is an inline base64/binary
/// BLOB: a pure base64-charset token (standard or url-safe, ≥32 chars, optional
/// `=` padding) that base64-DECODES to a substantially NON-PRINTABLE (binary)
/// payload. This subsumes the entire former "inline image" exemption surface:
///   * a REAL inline image (PNG/JPEG/…) decodes to binary → blob → ERR (the
///     accepted small DX cost: real images belong in `assets/`, not source);
///   * a TRAILING secret appended after a complete valid image (v8 Hole A) is
///     part of the SAME blob → still binary → ERR (no header-window edge case,
///     no entropy threshold to tune, the trailing-bytes gap is gone);
///   * an OPAQUE high-entropy secret blob decodes to binary → ERR.
/// It is DELIBERATELY shape-based (no entropy floor) so a low-entropy real image
/// (entropy ~2.9–3.7, BELOW the old 4.2 floor) is ALSO caught — entropy tuning
/// is no longer a laundering surface. Legit non-blob base64-charset values (hex
/// git/asset DIGESTS, SRI integrity tokens, dotted/snake IDs, base32 seeds) are
/// exempted by the EARLIER guards in `_looksHighEntropySecret` and never reach
/// this check; a base64-of-plain-TEXT token decodes to printable bytes and is
/// NOT a binary blob here.
bool _looksBinaryBlob(String v) {
  if (!RegExp(r'^[A-Za-z0-9+/_\-]{32,}={0,2}$').hasMatch(v)) return false;
  // BUILDABILITY guard: a dotted/snake/kebab LOWERCASE identifier
  // (`some_long_snake_case_value`, `a.b.c.d`) is base64-CHARSET by accident but is
  // a human-readable ID, not binary content. Such ids decode to garbage bytes
  // (high non-printable) yet must NOT be flagged. A REAL base64 blob of binary
  // data is mixed-case (spans the full alphabet) and never matches this id shape
  // (verified across the real PNG/JPEG/secret fixtures — all return false here).
  if (RegExp(r'^[a-z0-9]+(?:[._-][a-z0-9]+)+$').hasMatch(v)) return false;
  final bytes = _tryBase64Decode(v);
  if (bytes == null || bytes.length < 16) return false;
  return _nonPrintableFraction(bytes) >= 0.30;
}

/// N1 + F2 — a value that is a PUBLIC content/object DIGEST by SHAPE, not a
/// credential. We exempt these from the bare-hex secret path so the engine does
/// NOT red its own clean tree (N1: the all-zero 40-hex SHA in the K1 fail-closed
/// code) and does not false-fire on git SHAs / md5 / sha256 digests (F2:
/// buildSha/cacheKey/assetHash). The discriminator is deliberate and honest:
///   * a SINGLE-REPEATED-CHARACTER run (all-zero `0000…`, all-`f`, …) carries
///     ZERO entropy — it is never a real credential (N1 path-a);
///   * a PURE-HEX token at a canonical git-object / hash DIGEST LENGTH
///     (md5=32, sha1=40, sha256=64) in LOWERCASE (or all-UPPER, the two ways a
///     digest is written) is a public hash, not a secret — UNLESS the LINE also
///     carries a credential/provider signal (then it IS flagged; see caller).
/// A pure-hex token of a NON-digest length (e.g. 48, 50, 33) is NOT exempted
/// here — only the canonical digest lengths are git/hash shapes.
bool _isRepeatedSingleChar(String v) =>
    v.isNotEmpty && RegExp(r'^(.)\1*$').hasMatch(v);

/// A pure-hex (only 0-9a-f / 0-9A-F, one case) token at a canonical digest
/// length (32/40/64). These are md5 / sha1 / sha256 / git-object shapes.
bool _isHexDigestShape(String v) {
  if (v.length != 32 && v.length != 40 && v.length != 64) return false;
  // Pure hex in a SINGLE case (a real digest is not MiXeD-case; a mixed-case
  // 40-char token is far more likely a credential than a git sha).
  return RegExp(r'^[0-9a-f]+$').hasMatch(v) ||
      RegExp(r'^[0-9A-F]+$').hasMatch(v);
}

/// A1 — a base32 token (RFC 4648 alphabet A-Z2-7, optional `=` padding), the
/// shape TOTP/2FA seeds and many recovery secrets use. Its entropy band
/// (~3.4–4.2 over 16–32 chars) sits BELOW the generic 4.2 base64 floor, so it
/// evaded the entropy heuristic. It is DISTINGUISHABLE from a pure-hex git SHA:
/// base32 contains uppercase letters G–Z and/or the digit 7 (and never lowercase
/// hex), which a `[0-9a-f]` digest cannot. We require ≥16 chars, the base32
/// charset, at least one char OUTSIDE the hex range (so a 32-hex md5 is NOT
/// mis-read as base32), and a real-token entropy floor (≥3.2) so an all-`A`
/// padding run does not trip.
bool _looksBase32Secret(String v) {
  if (v.length < 16) return false;
  if (!RegExp(r'^[A-Z2-7]+=*$').hasMatch(v)) return false;
  // Must use the base32-only part of the alphabet (G-Z, or 0/1/8/9 absence is
  // implied) — i.e. at least one symbol a hex digest could never contain.
  if (!RegExp(r'[G-Z]').hasMatch(v)) return false;
  if (_isRepeatedSingleChar(v)) return false;
  return shannonEntropy(v) >= 3.2;
}

/// A LINE-level credential/provider signal: a variable/field NAME or a provider
/// keyword that means "this value is a SECRET" even when its VALUE is bare hex.
/// Used so a hex run WITH this signal is STILL flagged (we lose no protection),
/// while a hex digest WITHOUT it (a git sha, an asset hash, the zero-SHA) is
/// exempt. Deliberately EXCLUDES digest-ish names (sha/hash/digest/etag/checksum
/// /buildSha/cacheKey/assetHash) which mean "public digest", not "secret".
///
/// NOTE: NO word-boundary anchors — camelCase names concatenate words without a
/// boundary (`apiSecret`, `clientSecretValue`, `accessKey`), so anchoring would
/// miss them. These keywords are distinctive enough that an unanchored match is
/// the correct (safe-side) behaviour: a hex value on a line mentioning "secret"
/// SHOULD be flagged.
final RegExp _credentialNameCtx = RegExp(
  r'secret|password|passwd|api[_-]?key|apikey|access[_-]?key|'
  r'client[_-]?secret|private[_-]?key|auth[_-]?token|bearer|credential|'
  r'session[_-]?key|encryption[_-]?key|signing[_-]?key|'
  r'passphrase|[_-]token|token[_-]|authtoken',
  caseSensitive: false,
);

/// A digest-ish NAME on the line (buildSha / cacheKey / assetHash / etag /
/// checksum / fingerprint / *Hash / *Sha / *Digest). When present, a bare-hex
/// value is a PUBLIC digest (F2) and must not be flagged — this is the explicit
/// counterpart to _credentialNameCtx.
final RegExp _digestNameCtx = RegExp(
  r'\b([A-Za-z_]*(sha|hash|digest|checksum|etag|fingerprint|crc|md5|blob|'
  r'commit|revision|oid))\b|\b(buildSha|cacheKey|assetHash)\b',
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

/// H4 (v6): a STRICT path/URL shape — a real URL scheme, or a value that ends in
/// a known file extension, or a relative/absolute filesystem path whose final
/// segment carries a `.<ext>`. This is the ONLY path/id form we still exempt when
/// a credential NAME is present on the line (`tokenFile = "assets/key.json"`,
/// `authUrl = "https://auth.example/cb"`). A "just contains a slash" value
/// (`clientSecret = "ab/cd/EF/GH"`) does NOT match → it is no longer laundered.
bool _isConcretePathOrUrl(String v) {
  // URL / URI scheme (http(s), ftp, file, ws(s), git, ssh, package, asset, …).
  if (RegExp(r'^[a-z][a-z0-9+.\-]*://').hasMatch(v)) return true;
  if (RegExp(r'^(mailto|tel|data|package|asset):').hasMatch(v)) return true;
  // A path whose LAST segment has a concrete file extension.
  final last = v.split('/').last;
  if (RegExp(
    r'\.(jpe?g|png|webp|gif|svg|ico|json|dart|arb|txt|md|ya?ml|csv|html?|css|'
    r'js|ts|kt|swift|xml|toml|cfg|ini|properties|gradle|lock|sh|py|pem|crt|key)$',
    caseSensitive: false,
  ).hasMatch(last)) {
    return true;
  }
  // An absolute/relative path that is clearly a filesystem location and NOT a
  // high-entropy blob: only path-safe chars and lowercase-ish segments.
  if (RegExp(r'^[./~]').hasMatch(v) &&
      RegExp(r'^[A-Za-z0-9._/~\-]+$').hasMatch(v) &&
      shannonEntropy(v) < 4.0) {
    return true;
  }
  return false;
}

/// V9-B (Hole B) — strip a leading `data:[<mime>][;base64],` URI prefix from an
/// extracted value, returning the bare PAYLOAD so it is judged as a base64 blob /
/// secret. v8's secret-extraction char-classes excluded `:` `;` `,`, so a
/// `data:image/png;base64,<secret>` literal was never extracted and its payload
/// never decoded — an opaque secret (no provider fingerprint) shipped as NONE.
/// We match `data:` followed by an OPTIONAL `<mediatype>` (token/subtype +
/// optional `;param`/`;base64`) up to the first `,`, and return everything after
/// the comma. A value with NO `data:`+`,` shape is returned unchanged.
String _stripDataUriPrefix(String v) {
  final m = RegExp(r'^data:[A-Za-z0-9/.+\-]*(?:;[A-Za-z0-9.+\-]+)*,(.*)$')
      .firstMatch(v);
  return m != null ? m.group(1)! : v;
}

/// C1 — a credential-shaped quoted value, detected by SHAPE not by char-class
/// mix. v3 required upper+lower+digit ALL present, which let a lowercase-hex,
/// UPPER-only, no-digit, or all-digit token sail through. We now fire on ANY of:
///   (a) a long hex run `[0-9a-fA-F]{32,}`  (md5/sha/hex secret, any case),
///   (b) a base64 blob `[A-Za-z0-9+/]{32,}={0,2}` that is high-entropy,
///   (c) a long token with high Shannon entropy regardless of case mix,
/// while EXCLUDING path/id/asset shapes (dominant non-secret class here), SRI/
/// integrity digests (F2), and regex/placeholder contexts.
bool _looksHighEntropySecret(String line) {
  if (_secretAllow.hasMatch(line)) return false;
  // F2: an SRI/integrity/checksum CONTEXT on the line means the long token is a
  // public digest, not a credential — do not entropy-flag it.
  final integrityCtx = _integrityContext.hasMatch(line);
  // assignment of a quoted value: name [:=] "VALUE". Allow base64 padding (=).
  // A1: floor lowered 20→16 so a 16-char base32 TOTP/2FA seed is captured. The
  // PER-SHAPE length floors below remain stricter (hex/base64 ≥32, general ≥24,
  // base32 ≥16), so lowering the extractor admits ONLY base32 in the 16-19 band.
  // V9-B (Hole B): the char-class now ALSO admits `:` `;` `,` so a whole
  // `data:image/png;base64,<payload>` URI literal is CAPTURED as one token (v8's
  // class stopped at the `:`, so a data-URI was never extracted → its payload was
  // never judged → an opaque secret wrapped in a data-URI laundered to NONE). The
  // `data:` prefix is stripped per-token below before any secret test runs.
  final assign = RegExp(r'''[:=]\s*['"]([A-Za-z0-9+/_.=:;,\-]{16,})['"]''');
  // F2/N1: a digest-ish NAME on the line (buildSha/cacheKey/assetHash/etag/…)
  // means a bare-hex value is a PUBLIC digest, not a credential.
  final digestCtx = _digestNameCtx.hasMatch(line);
  // A credential/provider NAME on the line (secret/apiKey/password/…) means a
  // bare-hex value IS a credential even at digest length — we lose no protection.
  final credCtx =
      _credentialNameCtx.hasMatch(line) ||
      _secretFingerprints.any((fp) => fp.hasMatch(line));
  for (final m in assign.allMatches(line)) {
    // V9-B: unwrap a `data:[mime];base64,` prefix so the data-URI PAYLOAD is the
    // value we judge (closes Hole B — an opaque secret in a data-URI now reaches
    // the binary-blob / entropy tests below instead of sliding through as NONE).
    final v = _stripDataUriPrefix(m.group(1)!);
    // H4 (v6): the path/id exemption must NOT override an explicit credential
    // NAME. A value containing `/` (or a dotted id, or a known asset extension)
    // is normally a path — but if the LINE names it as a credential
    // (`clientSecret = "a/b/c/SECRET"`) the slash is no longer disqualifying.
    // We therefore SKIP the path/id exemption when credCtx matches AND the value
    // is not itself a real file/URL shape (a concrete extension or URL scheme).
    // This keeps asset-path false-positives out (no cred name → exemption still
    // applies) while closing the slash-laundered-secret hole.
    //
    // V9-A: the path/id exemption ALSO must NOT swallow an inline base64/BINARY
    // BLOB. A base64 blob legitimately contains `/` (base64 alphabet), which made
    // `_looksLikePathOrId` mis-classify a real PNG / a trailing-secret blob as a
    // "path" and `continue` past the blob ERR (v8 Hole A would have re-opened).
    // A blob is base64-charset-only (no `.ext`, no dotted segments), so it is
    // never a real file path; we let it fall through to the blob check below.
    if (_looksLikePathOrId(v) &&
        !_looksBinaryBlob(v) &&
        (!credCtx || _isConcretePathOrUrl(v))) {
      continue;
    }
    if (_isSriDigest(v)) continue; // F2: sha256-<base64>
    if (integrityCtx) continue; // F2: integrity:/checksum/digest context
    // N1 path-a guard: a single-repeated-character run (all-zero `0000…0`,
    // all-`f`, …) is ZERO-entropy — never a credential. This is the SHA the K1
    // fail-closed code embeds; exempting it stops the engine reding its own tree.
    if (_isRepeatedSingleChar(v)) continue;
    // (A1) base32 (TOTP/2FA seed) — distinguishable from a hex digest by its
    // G–Z letters; entropy floor lowered for the 32-char base32 band. Checked
    // BEFORE the digest exemption so a base32 token is never read as a digest.
    if (_looksBase32Secret(v)) return true;
    // (a) long contiguous hex run — catches lowercase-hex / UPPER-hex / all-digit.
    final hexRun = RegExp(r'[0-9a-fA-F]{32,}').firstMatch(v);
    if (hexRun != null) {
      final hx = hexRun.group(0)!;
      if (hx.length >= 32) {
        // F2/N1: a PURE-HEX value at a canonical DIGEST LENGTH (md5=32/sha1=40/
        // sha256=64), single-case, is a git-object / content hash — a PUBLIC
        // digest, not a credential. Exempt it UNLESS the line names it as a
        // credential (credCtx) AND does not name it as a digest (digestCtx).
        final isDigestShape = _isHexDigestShape(v);
        if (isDigestShape && (digestCtx || !credCtx)) {
          continue; // public digest (git sha / md5 / sha256 / asset hash)
        }
        // A hex run that is NOT a canonical digest shape (odd length / mixed
        // case), or one explicitly named as a secret, is a credential.
        return true;
      }
    }
    // (b) V9-A — inline base64/BINARY BLOB. Any base64-charset token (≥32 chars)
    // that DECODES to a substantially non-printable (binary) payload is an inline
    // blob and is BLOCKED. This REPLACES v8's entropy-gated branch and its image
    // exemption: there is NO `_isInlineImageBlob` downgrade and NO entropy floor
    // here, so (1) a real inline image (low-entropy, ~2.9–3.7) is ERR — the
    // accepted DX cost; real images belong in assets/ — and (2) a secret APPENDED
    // after a valid image (v8 Hole A) is part of the same binary blob → ERR, with
    // no header-window or threshold to launder past. The whole class is gone.
    if (_looksBinaryBlob(v)) return true;
    // (b-text) a base64 blob that decodes to PRINTABLE text but is itself a
    // HIGH-ENTROPY base64-charset token is still a credential (an opaque token /
    // key material that happens to encode printable bytes). Kept name-agnostic.
    if (RegExp(r'^[A-Za-z0-9+/]{32,}={0,2}$').hasMatch(v) &&
        shannonEntropy(v) >= 4.2) {
      return true;
    }
    // (c) general high-entropy token (case-mix AGNOSTIC). Require a stronger
    // entropy floor than (b) so an ordinary long identifier/word does not trip.
    // Natural words and snake_case ids sit well below ~4.0 bits/char; random
    // tokens sit above. We also require it not be a single repeated alphabet.
    final distinctClasses =
        (RegExp(r'[A-Z]').hasMatch(v) ? 1 : 0) +
        (RegExp(r'[a-z]').hasMatch(v) ? 1 : 0) +
        (RegExp(r'[0-9]').hasMatch(v) ? 1 : 0) +
        (RegExp(r'[+/=_\-.]').hasMatch(v) ? 1 : 0);
    if (v.length >= 24 && distinctClasses >= 2 && shannonEntropy(v) >= 4.3) {
      return true;
    }
  }
  return false;
}

/// S1 (v8) — true when a base64 literal on the line DECODES to bytes that hide a
/// PROVIDER FINGERPRINT (AKIA…/ghp_…/PEM/JWT) inside the decoded payload. This is
/// the "secret in the DECODED bytes" vector — the secret lives ONLY after base64-
/// decoding, so a text scan of the source line never sees it. It complements
/// `_looksBinaryBlob`: a blob whose decoded payload is a printable fingerprint
/// (low non-printable fraction) is NOT caught as a binary blob, but IS caught
/// here. (V9: the former image-magic `laundered` branch is gone — any binary/
/// high-entropy blob is now an ERR via `_looksBinaryBlob`, so there is no
/// "magic + splice" special case left to evaluate.)
/// V9-B: the char-class admits `:;,` and we strip a `data:...,` prefix, so a
/// fingerprint hidden in a `data:...;base64,<payload>` literal is also decoded.
bool _decodedLiteralHidesSecret(String joined) {
  // base64-shaped quoted literals (allow url-safe + padding + data-URI); ≥24.
  final re = RegExp(r'''['"]([A-Za-z0-9+/_.=:;,\-]{24,})['"]''');
  for (final m in re.allMatches(joined)) {
    final v = _stripDataUriPrefix(m.group(1)!);
    final bytes = _tryBase64Decode(v);
    if (bytes == null || bytes.length < 8) continue;
    final latin = String.fromCharCodes(bytes);
    for (final fp in _secretFingerprints) {
      if (fp.hasMatch(latin)) return true; // fingerprint in decoded payload
    }
  }
  return false;
}

/// Returns true if the (already literal-joined) line contains a secret by
/// fingerprint OR by entropy. Fingerprints scan BOTH the raw line and the
/// concatenated string literals (so split secrets are caught). S1 (v8) ALSO
/// scans the DECODED bytes of base64 literals (secret-in-decoded-bytes vector).
bool lineHasSecret(String line) {
  final joined = joinAdjacentLiterals(line);
  final literalsConcat = stringLiterals(joined).join();
  for (final fp in _secretFingerprints) {
    if (fp.hasMatch(joined) || fp.hasMatch(literalsConcat)) return true;
  }
  if (_looksHighEntropySecret(joined)) return true;
  if (_decodedLiteralHidesSecret(joined)) return true; // S1
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

/// Gate 46: no dark surface in screens. The known dark-surface tokens
/// (`0xFF111111` / `BsTokens.bgDark`, case-insensitive) PLUS the semantic
/// luminance detector both fire ONLY in a SURFACE context.
///
/// F3 (v5) — `_legacyDarkSurface` previously fired UNCONDITIONALLY (no surface
/// guard), so `0xFF111111` used as TEXT INK (e.g. `TextStyle(color: …)`) and
/// `BsTokens.bgDark` referenced off a surface false-fired the gate. The codebase
/// legitimately uses `0xFF111111`/near-black as dark text ink. We now guard the
/// legacy token behind `_surfaceCtx` EXACTLY like the semantic path:
///   (legacyToken ∧ surfaceCtx) ∨ hasDarkSurface(line)
/// `hasDarkSurface` already requires surfaceCtx, so the whole predicate is
/// surface-scoped. A dark `0xFF111111` BACKGROUND/Container/Scaffold still fires;
/// a dark `0xFF111111` TextStyle ink does not.
final RegExp _legacyDarkSurface = RegExp(
  r'0[xX][fF]{2}111111|BsTokens\.bgDark',
);

/// True when this single line paints a dark surface — by the legacy token in a
/// surface context, OR by the semantic luminance detector (itself surface-
/// scoped). E4 (v5): the SURFACE gate also accepts a line that has ALREADY been
/// joined with its continuation (see _surfaceGateLines), so a `backgroundColor:`
/// whose `Color(0xFF0A0A0A)` wrapped to the next line is still caught.
///
/// F3 (v5): we STRIP nested ink spans (`TextStyle(...)`, `Icon(...)`) BEFORE the
/// decision, so a SURFACE constructor that merely CONTAINS dark TEXT ink (e.g.
/// `Container(child: Text(..., style: TextStyle(color: 0xFF111111)))`) does NOT
/// false-fire. A surface whose OWN `color:`/`backgroundColor:` is dark still
/// fires (its colour survives the strip). The strip is a no-op on a pure ink line
/// (a `TextStyle(color: …)` with no surrounding surface), which stays non-surface.
bool _isDarkSurfaceLine(String l) {
  final s = _stripInkSpans(l);
  return (_legacyDarkSurface.hasMatch(s) && _surfaceCtx.hasMatch(s)) ||
      hasDarkSurface(s);
}

/// E4 — a SURFACE COLOR PROPERTY that expects a colour VALUE: the named
/// background/fill properties, plus the surface constructors that take a `color:`
/// directly (ColoredBox/DecoratedBox). When such a property appears but its
/// colour value is NOT on the same line (dart-format wrapped it at >80 cols), we
/// must join the continuation lines to see the value.
///
/// This is INTENTIONALLY NARROWER than `_surfaceCtx`: we do NOT seed on a bare
/// `Scaffold(`/`Container(`/`Card(` (whose body may contain dark TEXT ink on a
/// later line — joining those would reopen F3). We seed ONLY on a property that
/// itself takes a surface colour, so the joined value is unambiguously a surface
/// colour, never ink.
final RegExp _surfaceColorPropSeed = RegExp(
  r'\b(backgroundColor|scaffoldBackgroundColor|barBackgroundColor|canvasColor|'
  r'cardColor|surfaceTintColor|fillColor)\b\s*:|'
  r'\b(ColoredBox|DecoratedBox)\s*\(',
  caseSensitive: false,
);

/// A line that OPENS a direct-colour surface constructor whose FIRST argument is
/// the surface colour (`ColoredBox(` / `DecoratedBox(` … actually take a
/// `decoration:`, but `ColoredBox` takes `color:` directly). Used so a bare
/// `color:` wrapped onto the line AFTER such a constructor is recognised as a
/// surface colour without seeding on every `Container(`/`Scaffold(` (whose body
/// carries siblings — shadows/borders/children — that must NOT be pulled in).
final RegExp _directColorSurfaceOpen = RegExp(
  r'\b(ColoredBox)\s*\(\s*$',
  caseSensitive: false,
);

/// Remove nested INK spans from a (joined) surface span so a dark text/icon ink
/// inside a surface constructor is not mistaken for the surface colour. Removes
/// the balanced `TextStyle( … )` / `Icon( … )` / `IconThemeData( … )` /
/// `TextTheme( … )` paren spans — conservative, structural (depth-balanced).
String _stripInkSpans(String s) {
  var out = s;
  for (final ctor in const [
    'TextStyle',
    'Icon',
    'IconThemeData',
    'TextTheme',
  ]) {
    out = _removeBalancedCalls(out, ctor);
  }
  return out;
}

/// Remove every `name( … )` balanced-paren call from a string (handles nesting).
String _removeBalancedCalls(String s, String name) {
  final start = RegExp('\\b${RegExp.escape(name)}\\s*\\(');
  while (true) {
    final m = start.firstMatch(s);
    if (m == null) return s;
    var depth = 0;
    var end = -1;
    for (var i = m.end - 1; i < s.length; i++) {
      final c = s.codeUnitAt(i);
      if (c == 0x28) depth++;
      if (c == 0x29) {
        depth--;
        if (depth == 0) {
          end = i;
          break;
        }
      }
    }
    if (end < 0) {
      // unbalanced — drop from the call start to end of string
      return s.substring(0, m.start);
    }
    s = s.substring(0, m.start) + ' ' + s.substring(end + 1);
  }
}

/// E4 — produce, IN ADDITION to every raw line, EXTRA joined lines so a surface
/// colour VALUE that `dart format` wrapped to a later line is scanned alongside
/// its surface property. The join is DELIBERATELY MINIMAL — it stops at the FIRST
/// colour token (or `;`) and consumes at most a few lines — so it captures the
/// wrapped value WITHOUT swallowing sibling shadows/borders/children (those
/// produced the v5 whole-tree over-fire when a constructor's full span was
/// joined). Two seeds:
///   (1) a NAMED surface-colour property (`backgroundColor:` / `cardColor:` /
///       `ColoredBox(` …) whose value is not on its own line;
///   (2) a bare `color:` whose IMMEDIATELY-PRECEDING line opened a direct-colour
///       surface constructor (`ColoredBox(` at end-of-line) — so a wrapped
///       `ColoredBox(\n color: Color(0x..))` is caught, while a `Container(`'s
///       inner siblings are NOT joined (Container takes a `decoration:`, not a
///       bare surface `color:`, so its real surface colour is a NAMED property
///       handled by seed (1)).
/// Nested ink spans are stripped from the join (F3). The same-line INK exclusion
/// is intact because an ink line (`TextStyle(color:)`) is neither seed.
List<String> _surfaceGateLines(List<String> lines) {
  final out = <String>[];
  final colorTok = RegExp(r'0[xX][0-9a-fA-F]{6,8}|BsTokens\.bg|Color\.from');

  String joinFromValue(int start) {
    // Join `lines[start]` forward until the first colour token / `;` is consumed.
    final buf = StringBuffer(lines[start]);
    for (var k = 1; k <= 4 && start + k < lines.length; k++) {
      final nxt = lines[start + k];
      buf.write(' ');
      buf.write(nxt);
      if (colorTok.hasMatch(nxt) || nxt.contains(';')) break;
    }
    return _stripInkSpans(buf.toString()).replaceAll(RegExp(r'\(\s+'), '(');
  }

  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    out.add(line); // always keep the raw line

    // (1) named surface-property / ColoredBox/DecoratedBox seed whose value is
    //     not already on this line.
    if (_surfaceColorPropSeed.hasMatch(line) && !colorTok.hasMatch(line)) {
      out.add(joinFromValue(i));
    }

    // (2) a bare `color:` whose previous line opened a direct-colour surface
    //     constructor (ColoredBox()) — recognise the wrapped surface colour.
    if (i > 0 &&
        _directColorSurfaceOpen.hasMatch(lines[i - 1]) &&
        RegExp(r'^\s*color\s*:').hasMatch(line) &&
        !colorTok.hasMatch(line)) {
      // Seed from the constructor line so the join carries the `ColoredBox(`
      // surface context together with the wrapped value.
      out.add(joinFromValue(i - 1));
    }
  }
  return out;
}

/// Net parenthesis balance of a line (open minus close), ignoring parens inside
/// string literals so a `"("` in a Hebrew label does not skew the depth.
int _parenDelta(String line) {
  final code = line.replaceAll(
    RegExp(r'''"(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*' '''),
    '',
  );
  var d = 0;
  for (final c in code.codeUnits) {
    if (c == 0x28) d++; // (
    if (c == 0x29) d--; // )
  }
  return d;
}

List<Finding> gateNoDarkSurface(String screensDiff) {
  // E4: evaluate each added line, AND each surface-continuation-joined line.
  final added = addedLines(screensDiff);
  for (final l in _surfaceGateLines(added)) {
    if (_isDarkSurfaceLine(l)) {
      return [
        Finding(
          '46',
          Sev.err,
          'dark surface in a screen (by-design light-theme enforcement): '
              '${l.trim()} — put dark/theme tokens in lib/theme/ and reference '
              'them there; screens stay light. (Dark TEXT ink is fine.)',
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
    // C4: stdout/stderr.add(...) is also a raw byte sink.
    RegExp(r'(^|[^A-Za-z0-9_])std(out|err)\s*\.\s*add(Stream)?\s*\('),
    RegExp(r'(^|[^A-Za-z0-9_])developer\s*\.\s*log\s*\('),
    RegExp(r'(^|[^A-Za-z0-9_.])print\s*\)'), // tear-off: foo(print)
    RegExp(r':\s*print\s*[,)]'), // tear-off in arg position (named: print)
    RegExp(r'=\s*print\s*[,;)]'), // C4: tear-off via assignment (x = print)
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
  // C4: unqualified `log(` from dart:developer. `math.log`/`obj.log` are EXCLUDED
  // by the no-dot prefix; to avoid flagging a bare dart:math `log(<number>)` we
  // only fire when the argument is MESSAGE-shaped (a string literal / interpolation
  // existed on the original line `l`), which a numeric math.log call is not.
  final bareLog = RegExp(
    r'(^|[^A-Za-z0-9_.])log\s*\(',
  ).hasMatch(outsideStrings);
  if (bareLog && RegExp(r'''log\s*\(\s*['"$]''').hasMatch(l)) {
    return Finding(
      '48',
      Sev.err,
      'log(...) sink in production code: ${l.trim()} — use debugPrint or logger',
    );
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
/// joined adjacent literals + decoded-bytes scan. Scans the configured text file
/// types.
///
/// V9-A: the inline-IMAGE WARN exemption is REMOVED. It was a recurring
/// laundering surface — v7 had a text-prefix hole, and v8's decode-and-scan
/// re-fix introduced two more (Hole A: a secret APPENDED after a valid image left
/// the scanned header window clean; Hole B: a data-URI payload was never
/// extracted). Rather than tune the entropy threshold or patch the header window
/// again, V9 ELIMINATES THE CLASS: ANY literal that decodes to an inline
/// base64/binary blob (`_looksBinaryBlob`) is an ERR that BLOCKS — there is no
/// "looks like an image → downgrade to WARN" path left. Inline base64/binary in
/// source is a rare anti-pattern; real images belong in `assets/`. The message is
/// actionable. Provider-fingerprint and decoded-bytes (S1) detection are intact.
List<Finding> gateNoSecrets(String diff) {
  for (final l in addedLines(diff)) {
    // lineHasSecret JOINS adjacent literals first, so a split blob
    // `"iVBORw0KGgo" "<secret>"` is reconstructed and caught here as ERR.
    if (lineHasSecret(l)) {
      // V9-A: an inline base64/binary BLOB gets an ACTIONABLE message pointing at
      // assets/ (distinguished from a provider/entropy credential message, which
      // is more useful when the offending literal is real binary data).
      final isBlob = _lineHasInlineBinaryBlob(l);
      final body = l.trim().length > 80 ? "${l.trim().substring(0, 80)}…" : l.trim();
      return [
        Finding(
          '52',
          Sev.err,
          isBlob
              ? 'inline base64/binary data is not allowed in source — move images '
                  'to assets/ and load them as an asset: $body'
              : 'secret/high-entropy credential in code: $body',
        ),
      ];
    }
  }
  return const [];
}

/// V9-A — true when the (literal-joined) line carries an inline base64/binary
/// BLOB value (used only to pick the actionable "move to assets/" message). A
/// data-URI prefix is stripped first so a `data:...;base64,<blob>` is recognised.
bool _lineHasInlineBinaryBlob(String line) {
  final joined = joinAdjacentLiterals(line);
  final re = RegExp(r'''['"]([A-Za-z0-9+/_.=:;,\-]{24,})['"]''');
  for (final m in re.allMatches(joined)) {
    if (_looksBinaryBlob(_stripDataUriPrefix(m.group(1)!))) return true;
  }
  return false;
}

/// Gate 54: no ColoredBox constructed with a dark color (semantic luminance).
/// E4 (v5): a `ColoredBox(` whose `Color(0x…)` wrapped to the next line is joined
/// via _surfaceGateLines (ColoredBox is a surface context) before the same-line
/// `ColoredBox ∧ hasDarkColor` predicate, so a dart-format-wrapped dark ColoredBox
/// is caught. (No ink concern: a ColoredBox is itself a surface.)
List<Finding> gateNoDarkColoredBox(String libDiff) {
  for (final l in _surfaceGateLines(addedLines(libDiff))) {
    if (l.contains('ColoredBox') && hasDarkColor(l)) {
      return [
        Finding(
          '54',
          Sev.err,
          'dark ColoredBox (by-design light-theme enforcement): screens stay '
              'light — put dark/theme tokens in lib/theme/, not inline in a screen',
        ),
      ];
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

/// C5 — a GENUINE bidi-isolate / Unicode-isolate context where a local
/// `TextDirection.ltr` is correct (wrapping LTR content inside RTL). v3 skipped
/// on ANY line containing the substring "isolate", so `// isolate` or a variable
/// named `isolate` was a bypass. We require a real isolate construct: a
/// `Directionality(`, a `Bidi.` call, a Unicode isolate format char (LRI/RLI/FSI
/// /PDI U+2066..U+2069), or an explicit `unicodeWrap`/`stripHtmlIfNeeded`-style
/// bidi helper — not a bare mention.
final RegExp _genuineIsolateCtx = RegExp(
  r'\bDirectionality\s*\(|'
  r'\bBidi\.|'
  r'\bunicodeWrap\b|'
  r'\bTextDirection\.ltr\s*,\s*\)\s*\.wrap|'
  // LRI/RLI/FSI/PDI written as \u escapes so no literal bidi chars sit in the
  // source (avoids analyzer warning text_direction_code_point_in_literal).
  '[\u2066\u2067\u2068\u2069]',
);

/// Gate 65: no TextDirection.ltr in RTL app (warn). Skips only a whole-line
/// comment or a GENUINE isolate/Bidi context (C5 — not any "isolate" substring).
List<Finding> gateNoTextDirectionLtr(String libDiff) {
  for (final l in addedLines(libDiff)) {
    if (!l.contains('TextDirection.ltr')) continue;
    final trimmed = l.trimLeft();
    if (trimmed.startsWith('//')) continue;
    if (_genuineIsolateCtx.hasMatch(l)) continue;
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

/// H5 (v6) — LOGIC-COUPLED RAN proof. The old `--emit-ran` printed
/// `kDartEngineGateIds` UNCONDITIONALLY, so K3 parity passed even if a Dart
/// content gate's predicate had been gutted (the id was printed regardless).
/// v6 mirrors the bash hook's `…; ran <id>` discipline: we run each gate's REAL
/// predicate over a KNOWN-POSITIVE canary and emit the id ONLY IF the gate
/// actually FIRES on its canary. Gut a gate (e.g. `return const [];`) → its
/// canary no longer fires → the id is NOT emitted → registry⇄runtime parity
/// FAILS. This makes `--emit-ran` a TRUE runtime proof for every gate class, not
/// an overstated static claim.
///
/// Each entry is `(id, predicate-call-that-must-fire)`. The closure builds the
/// minimal input that forces the gate's body to reach its finding, calls the
/// gate, and returns whether a finding tagged with that id came back.
///
/// `_added` here is the same single-line `+`-hunk builder the self-test uses
/// (both are parts of this library); production canaries call gates directly.
final List<(String, bool Function())> kDartGateCanaries = [
  ('28', () => gateNoLocalUri(_added('var p = "file:///etc/x";')).isNotEmpty),
  (
    '46',
    () => gateNoDarkSurface(
      _added('backgroundColor: const Color(0xFF111111),'),
    ).isNotEmpty,
  ),
  ('48', () => gateNoPrint(_added('print("x");')).isNotEmpty),
  ('50', () => gateNoDartHtml(_added("import 'dart:html';")).isNotEmpty),
  ('51', () => gateNoHardUrl(_added('var u = "https://x.example/";')).isNotEmpty),
  (
    '52',
    () =>
        gateNoSecrets(_added('const k = "AKIAIOSFODNN7EXAMPLE";')).isNotEmpty,
  ),
  (
    '54',
    () =>
        gateNoDarkColoredBox(_added('ColoredBox(color: Color(0xFF111111))'))
            .isNotEmpty,
  ),
  (
    '62',
    () => gateNoHardLeftRight(
      _added('padding: EdgeInsets.only(left: 8),'),
    ).isNotEmpty,
  ),
  ('63', () => gateNoTextAlignLR(_added('textAlign: TextAlign.left,')).isNotEmpty),
  (
    '64',
    // U+1FAE0 (melting face, Emoji 14.0) — certainly outside the legacy set.
    () => gateNoInventedEmoji(
      _added('var s = "${String.fromCharCode(0x1FAE0)}";'),
    ).isNotEmpty,
  ),
  (
    '65',
    () =>
        gateNoTextDirectionLtr(_added('textDirection: TextDirection.ltr,'))
            .isNotEmpty,
  ),
  (
    '67',
    // gate 67 fires on a Hebrew string; built via codeUnits so no literal RTL.
    () => gateAppHebrewString(
      _added('const t = "${String.fromCharCodes([0x05E9, 0x05DC, 0x05D5, 0x05DD])} x";'),
    ).isNotEmpty,
  ),
  (
    '69',
    // removal gate — feed a REMOVED dark-surface line.
    () =>
        gateColorRevert('+++ b/x\n-backgroundColor: Color(0xFF111111),')
            .isNotEmpty,
  ),
  (
    '70',
    () => gateGitignoreSecretsGuard('+++ b/.gitignore\n-.env').isNotEmpty,
  ),
  (
    '73',
    () =>
        gatePersistenceKey(_added('const k = "bs.BADKEY";')).isNotEmpty,
  ),
  (
    '74',
    () =>
        gateNoManualContainer(_added('final c = ProviderContainer();'))
            .isNotEmpty,
  ),
  (
    '95',
    () => gateNumberIsolate(
      _added('"${String.fromCharCodes([0x05D2, 0x05D5, 0x05D3, 0x05DC])} 30x40"'),
    ).isNotEmpty,
  ),
  ('97', () => gateGitignoreNoHideClaude('+++ b/.gitignore\n+.claude/').isNotEmpty),
  (
    '103',
    // gate 103 needs a stuck-log antipattern AND a matching added line.
    () => gateAntipatternRecurrence(
      stuckLog: 'ANTIPATTERN: FORBIDDEN_CANARY_TOKEN',
      dartAdded: const ['var x = FORBIDDEN_CANARY_TOKEN;'],
      hookAdded: const [],
    ).isNotEmpty,
  ),
  (
    '114',
    () =>
        gateNoKLipskeyInUi(_added('final p = kLipskeyCatalog.first;'))
            .isNotEmpty,
  ),
];

/// Run every gate canary and return the ids whose gate ACTUALLY FIRED (H5).
/// Emitted as `RAN\t<id>`. An id missing here means that gate's predicate did
/// not detect its own canary — i.e. it was gutted — and K3 parity will fail.
List<String> emitRanIds() {
  final ran = <String>[];
  for (final (id, fired) in kDartGateCanaries) {
    bool ok;
    try {
      ok = fired();
    } catch (_) {
      ok = false; // a throwing gate did NOT prove it ran on its canary
    }
    if (ok) ran.add(id);
  }
  return ran;
}

/// Run every line-oriented content gate over a `git diff --cached` dump.
///
/// F1 — PER-FILE SCOPING. When `names` is given the diff is split by file and
/// each gate runs ONLY over the sub-diff of files whose PATH matches that gate's
/// scope predicate. This kills the v3 cross-file contamination class where a
/// screens-scoped gate fired on lines of an out-of-scope co-committed file
/// merely because some OTHER file in the commit was a screen.
///
/// When `names` is null (legacy bash --diff callers that pre-scope by cheap name
/// checks) the gates run over the whole diff, preserving v2 behavior.
List<Finding> runAllContentGates({
  required String diff,
  List<String>? names,
  String? stuckLog,
  String? gitignoreDiff,
}) {
  final findings = <Finding>[];

  if (names == null) {
    // Legacy whole-diff path (pre-scoped by the caller).
    findings.addAll([
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
      ...gateAppHebrewString(diff),
    ]);
  } else {
    // F1 — partition the diff by file and run each gate only on the sub-diffs of
    // in-scope files. A gate that yields multiple findings across files is
    // accumulated (we no longer stop at the first file).
    final byFile = splitDiffByFile(diff);

    // (scopePredicate, gateOverSubDiff) pairs. Each gate is a closure taking a
    // single file's sub-diff string.
    final scoped = <(bool Function(String), List<Finding> Function(String))>[
      (isLibDartPath, gateNoLocalUri),
      (isScreensPath, gateNoDarkSurface),
      (isLibDartPath, gateNoPrint),
      (isLibDartPath, gateNoDartHtml),
      (isLibDartPath, gateNoHardUrl),
      (isSecretScannablePath, gateNoSecrets),
      (isScreensPath, gateNoDarkColoredBox),
      (isLibDartPath, gateNoHardLeftRight),
      (isLibDartPath, gateNoTextAlignLR),
      (isLibDartPath, gateNoInventedEmoji),
      (isLibDartPath, gateNoTextDirectionLtr),
      (isScreensPath, gateColorRevert),
      (isLibDartPath, gatePersistenceKey),
      (isScreensPath, gateNoManualContainer),
      (isScreensStateLogicPath, gateNoKLipskeyInUi),
      (isLibDartPath, gateNumberIsolate),
      (isPreactAppPath, gateAppHebrewString),
    ];

    for (final entry in byFile.entries) {
      final path = entry.key;
      final subDiff = entry.value;
      if (isExemptPath(path)) continue; // never police tests/docs/engine
      for (final (inScope, gate) in scoped) {
        if (inScope(path)) findings.addAll(gate(subDiff));
      }
    }
  }

  if (gitignoreDiff != null && gitignoreDiff.isNotEmpty) {
    findings
      ..addAll(gateGitignoreSecretsGuard(gitignoreDiff))
      ..addAll(gateGitignoreNoHideClaude(gitignoreDiff));
  }
  if (stuckLog != null && stuckLog.isNotEmpty) {
    // Antipattern recurrence runs over the production-code added lines only.
    final List<String> added;
    if (names == null) {
      added = addedLines(diff);
    } else {
      final byFile = splitDiffByFile(diff);
      added = <String>[];
      for (final e in byFile.entries) {
        if (isExemptPath(e.key)) continue;
        if (isLibDartPath(e.key)) added.addAll(addedLines(e.value));
      }
    }
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

/// C2 — tree-mode variant of gate 114. The raw kLipskeyCatalog symbol appears in
/// ~21 PRE-EXISTING legit screens/logic uses across the mature app, so promoting
/// a whole-tree 114 to ERR would permanently red the clean-tree baseline. We
/// therefore emit it as a WARN in tree mode (surfaces a context-line-smuggled
/// use without false-blocking the legacy uses); the --diff path keeps the ERR
/// for NEWLY-added uses. Honest split: tree=advisory, diff=blocking.
List<Finding> gateNoKLipskeyInUiTree(String uiDiff) =>
    gateNoKLipskeyInUi(uiDiff)
        .map(
          (f) => Finding('114', Sev.warn, '${f.message} (tree-mode advisory)'),
        )
        .toList();

/// R2 — run the VALUE-oriented content gates over the whole-file POST-IMAGE of
/// each touched file (multi-line literals joined). Tree mode catches the bypass
/// class where a forbidden VALUE is split/computed/encoded across hunk
/// boundaries OR hidden on an UNCHANGED context line the --diff addedLines path
/// never sees (C2 — context-line smuggling): secrets, dark surfaces/ColoredBox,
/// print sinks, emoji, persistence keys, the lipskey symbol, local URIs.
///
/// Each file's post-image is emitted as an all-`+` hunk, so the LINE-ORIENTED
/// predicates run line-locally (no literal-joining false-pairing across a giant
/// build() expression — that concern only applied to value-joining, not to the
/// per-line surface/print checks). The PURELY POSITIONAL gates (62/63/65/95/51)
/// stay --diff-only: they cannot be value-split and re-scanning a whole file
/// would re-flag pre-existing instances of legacy RTL/style choices.
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
        ..addAll(gatePersistenceKey(asDiff))
        // C2: print sinks are line-local and have ZERO pre-existing in-scope
        // matches (verified on the live tree) — safe as ERR in tree mode.
        ..addAll(gateNoPrint(asDiff));
    }
    if (isScreensPath(path)) {
      // C2: dark-SURFACE + dark-ColoredBox run line-locally here. They require a
      // surface context ON THE SAME LINE (F3), so the 172 dark TEXT inks in the
      // live tree do NOT fire; whole-tree is clean for these (verified). This
      // closes the context-line-smuggling hole (a dark surface on an unchanged
      // line that --diff missed) without re-flagging legit ink.
      findings
        ..addAll(gateNoManualContainer(asDiff))
        ..addAll(gateNoDarkSurface(asDiff))
        ..addAll(gateNoDarkColoredBox(asDiff));
    }
    if (isScreensStateLogicPath(path)) {
      // C2: lipskey symbol in tree mode — advisory (see gateNoKLipskeyInUiTree).
      findings.addAll(gateNoKLipskeyInUiTree(asDiff));
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
  // H1: decode C-quoted names defensively (the diff's `+++ b/<path>` headers are
  // unquoted inside splitDiffByFile, which is what actually keys the gates; this
  // keeps any names-derived logic consistent even if a caller forgot quotePath).
  final names =
      _arg(args, '--names') == null
          ? null
          : _readLines(_arg(args, '--names')).map(unquoteGitPath).toList();
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
  // R6 + H5: prove each gate RAN by running its predicate over a known-positive
  // canary and emitting the id ONLY IF the gate FIRED. A no-op/stub engine emits
  // nothing; a gate gutted to `return []` no longer fires its canary → its id is
  // absent → registry⇄runtime parity fails (true runtime proof, not a static list).
  if (args.contains('--emit-ran')) {
    for (final id in emitRanIds()) {
      stdout.writeln('RAN\t$id\t');
    }
  }
  return hadErr ? 2 : 0;
}

/// True for a name the tree scan is REQUIRED to fetch+scan (the reconciliation
/// universe — H3). Non-scannable assets (.png/.lock/…) are legitimately skipped
/// and are NOT counted as "must scan".
bool _isScannableName(String path) =>
    isLibDartPath(path) || isScreensPath(path) || isSecretScannablePath(path);

/// Build the argv for fetching one blob via the `--show` prefix, injecting
/// `-c core.quotePath=false` (H1) right after the `git` token so any internal
/// path-printing stays unquoted, and forcing `--no-replace-objects` is preserved
/// from the prefix as given by the caller.
List<String> _showArgv(String showPrefix, String path) {
  final parts = showPrefix.trim().split(RegExp(r'\s+'));
  final exe = parts.first;
  final rest = parts.sublist(1);
  // Inject quotePath=false as the first git-level option (only for a real git
  // invocation; harmless to require `git`).
  final List<String> opts = (exe == 'git') ? ['-c', 'core.quotePath=false'] : [];
  if (showPrefix.contains(':') && showPrefix.trim().endsWith(':')) {
    // `git ... show <ref>:` — append the path to the LAST token.
    final head = rest.sublist(0, rest.length - 1);
    return [...opts, ...head, '${rest.last}$path'];
  }
  // `git ... show <sha>:` style where the caller appends the path as its own arg.
  return [...opts, ...rest, path];
}

/// R2 tree mode (v6 hardened). Reads the touched names, fetches each post-image
/// via the `--show` prefix (default `git show :` = the staged index), DECODES the
/// blob bytes with allowMalformed (H2), and scans it. Crucially it RECONCILES the
/// set of scannable files FED against the set ACTUALLY SCANNED (H3): if any
/// scannable file was not fetched+decoded for ANY reason (C-quoted name, missing
/// blob, git error) the run FAILS CLOSED with the offending names — no silent
/// skip can let forbidden content ship green.
int _mainTree(List<String> args) {
  // H1: decode any C-quoted (`"...\NNN..."`) names back to true UTF-8 paths.
  final names = _readLines(_arg(args, '--names')).map(unquoteGitPath).toList();
  final showPrefix = _arg(args, '--show') ?? 'git show :';
  final files = <String, String>{};

  // H3 reconciliation bookkeeping.
  final fed = <String>{}; // distinct scannable names fed
  final scanned = <String>{}; // names successfully fetched + decoded
  final skipped = <String>[]; // scannable names we FAILED to scan (reason)

  for (final path in names) {
    if (path.isEmpty) continue;
    // Only fetch text we might scan; non-scannable assets are not reconciled.
    if (!_isScannableName(path)) continue;
    fed.add(path);
    try {
      final argv = _showArgv(showPrefix, path);
      final exe = showPrefix.trim().split(RegExp(r'\s+')).first;
      // H2: read RAW BYTES (stdoutEncoding: null) so a non-UTF-8 byte in the
      // blob cannot throw a FormatException that the old `catch (_)` swallowed.
      final res = Process.runSync(exe, argv, stdoutEncoding: null);
      if (res.exitCode == 0) {
        final bytes = (res.stdout as List<int>);
        // allowMalformed: a genuinely invalid byte becomes U+FFFD instead of
        // throwing — the file is STILL scanned (fail-CLOSED on bad bytes, never
        // fail-open by dropping it).
        files[path] = utf8.decode(bytes, allowMalformed: true);
        scanned.add(path);
      } else {
        skipped.add(
          '$path (git show rc=${res.exitCode}: '
          '${(res.stderr is List<int> ? utf8.decode(res.stderr as List<int>, allowMalformed: true) : "${res.stderr}").trim()})',
        );
      }
    } catch (e) {
      // ANY exception (process spawn failure, decode-of-stderr, …) is a HARD
      // fail — never a silent skip.
      skipped.add('$path (exception: $e)');
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

  // H3: FAIL CLOSED if any scannable file fed was not actually scanned.
  if (skipped.isNotEmpty) {
    stderr.writeln(
      'ERR\treg\tH3 reconciliation FAIL — ${skipped.length} scannable '
      'file(s) FED but NOT scanned (fail closed):',
    );
    for (final s in skipped) {
      stderr.writeln('ERR\treg\t  unscanned: $s');
    }
    stderr.writeln(
      'ERR\treg\tfed=${fed.length} scanned=${scanned.length} '
      'skipped=${skipped.length}',
    );
    return 3; // distinct from 2 (findings) and 0 (clean) — a SKIP is fail-closed.
  }
  // Belt: the reconciliation invariant must hold even with no recorded skip.
  if (scanned.length != fed.length) {
    stderr.writeln(
      'ERR\treg\tH3 reconciliation FAIL — fed=${fed.length} != '
      'scanned=${scanned.length} (unaccounted skip) — fail closed',
    );
    return 3;
  }
  stdout.writeln('OK\treg\tH3 reconciliation: fed==scanned==${fed.length}');
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
