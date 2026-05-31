/// Size-token normalization for the finder (בית) "גודל" axis.
///
/// One vocabulary for every size chip the finder may surface:
///  - structural parse (no `String.contains` ambiguity),
///  - family-tagged so we never mix DN with cm in one chooser,
///  - numeric value for true ordering (25, 30, 200, 250 — not lex).
library;

import 'package:flutter/foundation.dart' show immutable;

/// Physical family of a size token. Different families do NOT share a chooser
/// row — a user can't meaningfully compare an inch diameter to a cm length.
enum SizeFamily {
  inchDiameter, // ½" / 1" / 1¼"
  dnDiameter,   // DN16 / DN40
  mm,           // 200 מ"מ
  cm,           // 25 ס"מ
  meters,       // 0.5 מ׳ (catalog L (cm)/100)
  angle,        // 45° / 90°  — surfaced as its own axis, never with sizes
}

@immutable
class SizeToken {
  const SizeToken({required this.label, required this.family, required this.mm});

  final String label;     // verbatim display, e.g. '½"', 'DN40', '25 ס"מ'
  final SizeFamily family;
  final double mm;        // canonical scalar for sorting only

  @override
  bool operator ==(Object other) =>
      other is SizeToken && other.label == label && other.family == family;
  @override
  int get hashCode => Object.hash(label, family);
}

/// Family precedence when picking the chooser's axis. Diameter first — for
/// connectors/heads/taps it's the user's mental anchor; length is shape, not
/// fit. Angles never compete with sizes (own axis).
const List<SizeFamily> _kFamilyPrecedence = [
  SizeFamily.inchDiameter,
  SizeFamily.dnDiameter,
  SizeFamily.mm,
  SizeFamily.cm,
  SizeFamily.meters,
];

/// Display-only pretty-fold for one raw size-token label. Use anywhere a chip
/// label is shown to the user — keep the underlying data raw, collapse only
/// the visual form. `prettyInch('1.25"')=='1¼"'`; non-inch labels pass
/// through unchanged. The post-fold step replaces glyphs canvaskit can't
/// render with ASCII forms (e.g. `⅜"` → `3/8"`).
String prettyInch(String label) {
  final folded = kInchPretty[label] ?? label;
  return kHardToRenderFractions[folded] ?? folded;
}

/// The single chip-display function used by BOTH the finder filter and the
/// product-card chips. Strips noise prefixes (like `Ø` on a garden hose's
/// `Ø1/2"`) and pretty-folds the inch form. Falls back to `prettyInch` for
/// already-clean strings, and to the raw label for non-size words.
///
/// Keeping card + filter on a single function is how P9/P12 stay closed.
String displaySizeLabel(String raw) {
  final tokens = parseSizeTokens(raw);
  if (tokens.isNotEmpty) return tokens.first.label;
  return prettyInch(raw);
}

/// Display-only fallback for fraction glyphs canvaskit's bundled font can't
/// draw — they render as empty boxes on screen, so we fold them to ASCII
/// fractions for the chip text. The common glyphs (`¼ ½ ¾`) are kept as
/// canvaskit renders them correctly. Applied at every chip display site so
/// card + filter agree.
const Map<String, String> kHardToRenderFractions = {
  '⅛"': '1/8"', '⅜"': '3/8"', '⅝"': '5/8"', '⅞"': '7/8"',
};

/// Confusing compound/decimal inch notations folded to one clean fraction
/// glyph, so "11/4"" and "1.25"" don't render as two chips for the same 1¼".
const Map<String, String> kInchPretty = {
  '1.25"': '1¼"', '11/4"': '1¼"',
  '1.5"':  '1½"', '11/2"': '1½"',
  '21/2"': '2½"',
  '1/2"': '½"',  '3/4"': '¾"',
  '1/4"': '¼"',  '3/8"': '⅜"',
  '5/8"': '⅝"',  '7/8"': '⅞"',
};

/// Inch label → millimetres (for sorting only — display stays verbatim).
const Map<String, double> _kInchMm = {
  '⅛"': 3.175, '¼"': 6.35, '⅜"': 9.525,
  '½"': 12.7, '⅝"': 15.875, '¾"': 19.05, '⅞"': 22.225,
  '1"': 25.4,
  '1¼"': 31.75, '1½"': 38.1,
  '2"': 50.8, '2½"': 63.5,
  '3"': 76.2, '4"': 101.6, '6"': 152.4,
};

/// Size tokens (NO angles — angle has its own regex/axis).
/// Order of alternatives matters: longer / more-specific shapes first so the
/// engine can't accidentally split "DN40" into "40" or "1½"" into two halves.
final RegExp _kSizeRe = RegExp(
  // DN16 / DN 40
  r'DN ?\d+'
  // 25 ס"מ / 200 מ"מ  (Hebrew unit suffixes)
  r'|\d+(?:\.\d+)? ?[מס]["״]מ'
  // 1.25" / 1.5"
  r'|\d+\.\d+["׳]'
  // 11/4" / 21/2" (legacy two-int form before pretty-fold)
  r'|\d{2}/\d["׳]'
  // 1¼" / ½" / 1½"
  r'|\d*[¼½¾⅛⅜⅝⅞]["׳]'
  // 1/2" / 3/4" (single-digit fraction inch)
  r'|\d/\d["׳]'
  // 16×20 / 20×2.8 / 1/2×3/4 cross-sizes — decimals allowed on both sides
  // (multilayer pipe `20×2.8`: 20mm OD × 2.8mm wall).
  r'|\d+(?:\.\d+)?(?:/\d+)?×\d+(?:\.\d+)?(?:/\d+)?'
  // plain whole-inch — 1" / 2" / 3"
  r'|\d+["׳]',
);

final RegExp _kAngleRe = RegExp(r'\d+°');

/// Hard rule: tokens that look like sizes but aren't (years, generic IDs).
/// "25 שנים אחריות" must NOT become a 25 chip. We require an explicit unit
/// glyph next to the number — so a bare integer in the name yields nothing.
List<SizeToken> parseSizeTokens(String name) {
  final out = <SizeToken>[];
  for (final m in _kSizeRe.allMatches(name)) {
    final raw = m.group(0)!.trim();
    final folded = kInchPretty[raw] ?? raw;
    final tok = _tokenize(folded);
    if (tok == null) continue;
    // Apply the canvaskit font fold to the FINAL tokenized label (`_tokenize`
    // has already done the numeric cleanup like `020 מ"מ` → `20 מ"מ`).
    final display = kHardToRenderFractions[tok.label] ?? tok.label;
    out.add(display == tok.label
        ? tok
        : SizeToken(label: display, family: tok.family, mm: tok.mm));
  }
  return out;
}

/// Angles as their own list — the chooser surfaces them only when sizes don't.
List<SizeToken> parseAngleTokens(String name) {
  final out = <SizeToken>[];
  for (final m in _kAngleRe.allMatches(name)) {
    final raw = m.group(0)!.trim();
    final n = double.tryParse(raw.replaceAll('°', ''));
    if (n != null) {
      out.add(SizeToken(label: raw, family: SizeFamily.angle, mm: n));
    }
  }
  return out;
}

/// Render a `double` the way a chip label should read: integers lose the
/// decimal point; values like `1.5` stay `1.5`. Crucially this strips
/// leading zeros from source strings like `020` → `20`.
String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : '$v';

SizeToken? _tokenize(String label) {
  // Inch (pretty)
  final inchMm = _kInchMm[label];
  if (inchMm != null) {
    return SizeToken(label: label, family: SizeFamily.inchDiameter, mm: inchMm);
  }
  // DN — accept `DN40` / `DN 40` / `DN040`, normalize the integer.
  final dn = RegExp(r'^DN ?(\d+)$').firstMatch(label);
  if (dn != null) {
    final v = double.parse(dn.group(1)!);
    return SizeToken(label: 'DN${_fmt(v)}',
        family: SizeFamily.dnDiameter, mm: v);
  }
  // mm — normalize the number so `020 מ"מ` reads `20 מ"מ`.
  final mm = RegExp(r'^(\d+(?:\.\d+)?) ?מ["״]מ$').firstMatch(label);
  if (mm != null) {
    final v = double.parse(mm.group(1)!);
    return SizeToken(label: '${_fmt(v)} מ"מ', family: SizeFamily.mm, mm: v);
  }
  // cm — same normalization.
  final cm = RegExp(r'^(\d+(?:\.\d+)?) ?ס["״]מ$').firstMatch(label);
  if (cm != null) {
    final v = double.parse(cm.group(1)!);
    return SizeToken(label: '${_fmt(v)} ס"מ', family: SizeFamily.cm, mm: v * 10);
  }
  // Cross-dim (16×20 / 20×2.8): first dim is the sort key, decimals accepted
  // on both sides for multilayer pipes (OD × wall thickness).
  final cross =
      RegExp(r'^(\d+(?:\.\d+)?)(?:/\d+)?×(\d+(?:\.\d+)?)(?:/\d+)?$')
          .firstMatch(label);
  if (cross != null) {
    final v = double.parse(cross.group(1)!);
    return SizeToken(label: label, family: SizeFamily.mm, mm: v);
  }
  // Plain inch — "2"" (no fraction, not in pretty table)
  final plainInch = RegExp(r'^(\d+)["׳]$').firstMatch(label);
  if (plainInch != null) {
    final inches = double.parse(plainInch.group(1)!);
    return SizeToken(
        label: '${inches.toInt()}"',
        family: SizeFamily.inchDiameter,
        mm: inches * 25.4);
  }
  return null;
}

/// Dims-fallback (DN, L (cm)) for products whose name carries no size token.
List<SizeToken> tokensFromDims(Map<String, dynamic> dims) {
  final out = <SizeToken>[];
  final dnRaw = (dims['DN'] ?? dims['dn'] ?? dims['mm'])?.toString();
  if (dnRaw != null && dnRaw.trim().isNotEmpty) {
    final n = double.tryParse(dnRaw.trim());
    if (n != null) {
      out.add(SizeToken(label: 'DN${n.toInt()}',
          family: SizeFamily.dnDiameter, mm: n));
    }
  }
  final cm = double.tryParse(dims['L (cm)']?.toString() ?? '');
  if (cm != null) {
    final m = cm / 100;
    final label = m == m.roundToDouble() ? '${m.toInt()} מ׳' : '$m מ׳';
    out.add(SizeToken(label: label, family: SizeFamily.meters, mm: cm * 10));
  }
  return out;
}

/// In-place sort: by family precedence first, then numeric value inside the
/// family. The chooser's UI is family-coherent — never alternating units.
void sortSizeTokens(List<SizeToken> toks) {
  int rank(SizeFamily f) {
    final i = _kFamilyPrecedence.indexOf(f);
    return i < 0 ? _kFamilyPrecedence.length : i;
  }
  toks.sort((a, b) {
    final r = rank(a.family).compareTo(rank(b.family));
    return r != 0 ? r : a.mm.compareTo(b.mm);
  });
}

/// Length-only family rank: prefer cm (most product-like, compact), then
/// meters, then mm. Used by [dedupLengthByMm] to collapse equivalent length
/// representations (e.g. `15 ס"מ` and `0.15 מ׳` are the same physical value
/// and should not both be chips).
const Map<SizeFamily, int> _kLengthFamilyRank = {
  SizeFamily.cm: 0,
  SizeFamily.meters: 1,
  SizeFamily.mm: 2,
};

/// Collapse equivalent length tokens (same `mm`, length families) to a single
/// representative — cm wins over meters wins over mm. Non-length families
/// (diameter, angle) pass through untouched. Caller should still
/// `sortSizeTokens` after if the input wasn't pre-sorted.
List<SizeToken> dedupLengthByMm(List<SizeToken> tokens) {
  final byKey = <String, SizeToken>{};
  final out = <SizeToken>[];
  for (final t in tokens) {
    final rank = _kLengthFamilyRank[t.family];
    if (rank == null) {
      out.add(t);
      continue;
    }
    final key = 'L:${t.mm}';
    final cur = byKey[key];
    if (cur == null || rank < _kLengthFamilyRank[cur.family]!) {
      byKey[key] = t;
    }
  }
  out.addAll(byKey.values);
  return out;
}

/// Returns the single family the chooser should surface, or null if no
/// usable size tokens exist. Precedence comes first — diameter beats length
/// even when fewer in count — because diameter is the user's mental anchor
/// for fit; count breaks precedence-ties.
SizeFamily? dominantFamily(List<SizeToken> toks) {
  if (toks.isEmpty) return null;
  final counts = <SizeFamily, int>{};
  for (final t in toks) {
    counts[t.family] = (counts[t.family] ?? 0) + 1;
  }
  SizeFamily? best;
  int bestRank = 1 << 30;
  int bestCount = -1;
  counts.forEach((f, c) {
    final r = _kFamilyPrecedence.indexOf(f);
    final fr = r < 0 ? _kFamilyPrecedence.length : r;
    if (fr < bestRank || (fr == bestRank && c > bestCount)) {
      best = f;
      bestRank = fr;
      bestCount = c;
    }
  });
  return best;
}
