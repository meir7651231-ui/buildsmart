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
      luma < _darkLumaThreshold && (spread < 0 || spread <= _greyscaleSpreadMax);
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
  r'''\bsha(?:1|224|256|384|512)-|'''       // SRI: sha256-/sha384-/sha512-
  r'''\bintegrity['"]?\s*[:=]|'''           // integrity: / 'integrity':
  r'''\b(?:sha256sum|sha1sum|checksum|digest|fingerprint|etag)\b|'''
  r'''\bsha(?:1|256|512)['"]?\s*[:=]''',    // sha256: <hex>
  caseSensitive: false,
);

/// True when the VALUE itself is an SRI digest token (sha256-BASE64==).
bool _isSriDigest(String v) =>
    RegExp(r'^sha(?:256|384|512)-[A-Za-z0-9+/]+={0,2}$').hasMatch(v);

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
  final assign = RegExp(r'''[:=]\s*['"]([A-Za-z0-9+/_.=\-]{20,})['"]''');
  for (final m in assign.allMatches(line)) {
    final v = m.group(1)!;
    if (_looksLikePathOrId(v)) continue;
    if (_isSriDigest(v)) continue; // F2: sha256-<base64>
    if (integrityCtx) continue; // F2: integrity:/checksum/digest context
    // (a) long contiguous hex run — catches lowercase-hex / UPPER-hex / all-digit
    // (a 32+ all-digit value IS a hex run) / no-digit-hex. A real git blob sha or
    // SRI digest is excluded above by context; a bare 32+ hex literal assigned to
    // a variable in production code is a credential by our policy.
    final hexRun = RegExp(r'[0-9a-fA-F]{32,}').firstMatch(v);
    if (hexRun != null) {
      // A pure hex value of >=32 chars is suspicious regardless of case.
      final hx = hexRun.group(0)!;
      // Avoid flagging a long DECIMAL id (e.g. a 32-digit catalog code) ONLY if
      // it is all-digits AND short-ish; >=32 hex digits is still flagged (that is
      // far longer than any SKU/timestamp in this codebase).
      if (hx.length >= 32) return true;
    }
    // (b) base64 blob — high entropy, base64 charset, length >=32.
    if (RegExp(r'^[A-Za-z0-9+/]{32,}={0,2}$').hasMatch(v) &&
        shannonEntropy(v) >= 4.2) {
      return true;
    }
    // (c) general high-entropy token (case-mix AGNOSTIC). Require a stronger
    // entropy floor than (b) so an ordinary long identifier/word does not trip.
    // Natural words and snake_case ids sit well below ~4.0 bits/char; random
    // tokens sit above. We also require it not be a single repeated alphabet.
    final distinctClasses = (RegExp(r'[A-Z]').hasMatch(v) ? 1 : 0) +
        (RegExp(r'[a-z]').hasMatch(v) ? 1 : 0) +
        (RegExp(r'[0-9]').hasMatch(v) ? 1 : 0) +
        (RegExp(r'[+/=_\-.]').hasMatch(v) ? 1 : 0);
    if (v.length >= 24 && distinctClasses >= 2 && shannonEntropy(v) >= 4.3) {
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
  final bareLog = RegExp(r'(^|[^A-Za-z0-9_.])log\s*\(').hasMatch(outsideStrings);
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
        .map((f) => Finding('114', Sev.warn, '${f.message} (tree-mode advisory)'))
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
