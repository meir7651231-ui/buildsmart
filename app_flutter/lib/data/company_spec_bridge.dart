// ─────────────────────────────────────────────────────────────────────────────
// Company spec bridge — "הניואנסים הם גם נתונים" (owner): when a company pours
// its own catalog in (company_catalog_import), the open spec columns it typed
// ('קצה 1'/'קצה 2'/'קצה 3' · 'חומר' · 'טמפ׳ מקסימלית' · 'לחץ'/'PN') are DATA,
// not card decoration — this bridge turns them into runtime [VerifiedSpec]s so
// the SmartProduct helper toolbox (compat / pair-warning / install-engine /
// install-kit / pressure-drop) serves an imported product exactly like a
// built-in one.
//
// The polyroll_specs discipline, cloned:
//   · pure per-product factory ([companySpecFor]; null = honest-absent — the
//     product stays on name-inference, nothing is fabricated);
//   · registration is CALL-SITE-ONLY ([registerCompanySpecs], idempotent
//     `putIfAbsent`), NEVER a module-load side effect: the 890-pin
//     (test/plumbing_seed_test.dart counts the STATIC kVerifiedSpecs in a
//     fresh isolate) means merely importing this file must change nothing;
//   · static entries WIN on a sku collision, and provenance
//     ([kCompanySpecSkus]) is recorded only for specs actually inserted.
//
// THE INCH-MARK RULE (load-bearing): `ConnectorEnd.directMatesWith` is RAW
// string equality, and every static BSP spec writes inch sizes WITH the mark
// ('1/2"'). A parsed thread size is therefore canonicalized onto the nine
// [kBspInchToMm] keys and ALWAYS emitted with the trailing '"' — '1/2' · '½' ·
// '0.5' all land as '1/2"' — or the end is dropped as unparseable. No mark,
// no mate.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart';

/// skus whose spec came from a company import (provenance for the honest
/// 'לפי חישוב' badge — never a field on VerifiedSpec).
final Set<String> kCompanySpecSkus = <String>{};

/// Pure factory — a runtime [VerifiedSpec] built from a company product's
/// imported spec columns, or null (= honest-absent, the polyroll null
/// contract: the product stays on name-inference, nothing is fabricated).
///
/// Reads the open spec columns the import lands in `dims`:
///   · 'קצה 1' / 'קצה 2' / 'קצה 3' — one connector end each (trimmed;
///     missing/empty skipped; an unparseable end is dropped — it can only
///     MISS matches, never invent them; ZERO parseable ends ⇒ null):
///       תבריג/הברגה + זכר/חיצוני → [EndType.bspMale], + נקבה/פנימי →
///         [EndType.bspFemale] — the size canonicalized onto the nine
///         [kBspInchToMm] keys and emitted WITH the trailing '"' (the
///         inch-mark rule); an unrecognized inch size drops the end;
///       פקס/PEX + מספר → [EndType.pexPress], bare mm ('16');
///       נחושת + מספר → [EndType.copperPress], bare mm;
///       הדבקה/דבק/שקע/מופה/כניסה · קידומת DN · מספר-מ"מ חשוף →
///         [EndType.hdpeCompression], bare mm ('32') — the engine's
///         documented push-fit overload (the PPR precedent): the spec's
///         MATERIAL drives family compatibility;
///       פתח ניקוז + גודל → [EndType.drainOpening], הגודל כלשונו;
///       כל טקסט אחר → הקצה נופל (unparseable).
///   · 'חומר' — verbatim after trimming, normalized ONLY by exact match onto
///     the engine tokens (HDPE · PEX · נחושת · פליז · פלדה · נירוסטה · PVC ·
///     PP · רב-שכבתי · PPR; latin ones case-insensitively). Any other
///     non-empty string is kept verbatim — safe-degraded (it can only
///     self-family via the engine's same-material rule), never guessed.
///     EMPTY/missing 'חומר': kept as '' when every end is a direct-mating
///     type (thread/press/drain — material-independent joints, and '' hits
///     no engine token), but a spec with a push-fit
///     ([EndType.hdpeCompression]) end returns null — push-fit families are
///     material-driven, and '' == '' in the engine's `_materialsCompatible`
///     would fabricate a same-material family out of ignorance.
///   · 'טמפ׳ מקסימלית' (both geresh spellings; °/C/מעלות suffixes stripped)
///     → [VerifiedSpec.maxTempC]. Absent/unparseable ⇒ the argument is
///     OMITTED so the ctor default (40°C — the conservative HDPE cap)
///     applies: a company product with no stated temperature is honestly
///     REJECTED from hot lines by design.
///   · 'לחץ' / 'PN' → [VerifiedSpec.pressureRating] verbatim when non-empty.
///
/// `systemOverride` / `pexType` are deliberately NOT set — the class resolves
/// the plumbing system from material + ends itself ([VerifiedSpec.endSystems]).
VerifiedSpec? companySpecFor(LipskeyCatalogProduct p) {
  final ends = <ConnectorEnd>[];
  for (final key in const ['קצה 1', 'קצה 2', 'קצה 3']) {
    final cell = p.dims?[key]?.toString().trim();
    if (cell == null || cell.isEmpty) continue; // missing/empty — skipped
    final end = _parseEnd(cell);
    if (end != null) ends.add(end);
  }
  if (ends.isEmpty) return null; // zero parseable ends — name-inference stays

  final material = _normalizeMaterial(p.dims?['חומר']?.toString().trim() ?? '');
  if (material.isEmpty &&
      ends.any((e) => e.type == EndType.hdpeCompression)) {
    // Push-fit family compatibility is MATERIAL-driven (the hdpeCompression
    // overload): with no 'חומר', '' == '' in the engine's same-material rule
    // would fabricate a family out of ignorance — honest-absent instead.
    return null;
  }

  final pressure = _pressureRating(p);
  final maxTemp = _maxTempC(p);
  if (maxTemp != null) {
    return VerifiedSpec(
      sku: p.sku,
      ends: ends,
      material: material,
      pressureRating: pressure,
      maxTempC: maxTemp,
    );
  }
  // No parseable 'טמפ׳ מקסימלית' — maxTempC is OMITTED so the ctor default
  // (40°C) applies: an unstated temperature rejects hot lines by design.
  return VerifiedSpec(
    sku: p.sku,
    ends: ends,
    material: material,
    pressureRating: pressure,
  );
}

/// Pour every parseable company spec into the shared [kVerifiedSpecs] map —
/// the polyroll registration discipline, CALL-SITE-ONLY: hydration
/// (`company_catalog_store`) and the import sheet's mid-session commit call
/// this; NOTHING runs at module load (the 890-pin counts the static map in a
/// fresh isolate).
///
/// Idempotent across repeated calls (`putIfAbsent` — re-running on
/// hot-reload / re-import never churns the map). A sku already present keeps
/// its STATIC spec (static entries win on collision), and provenance is
/// recorded in [kCompanySpecSkus] ONLY for a spec actually inserted — a
/// skipped sku never wears the company badge.
void registerCompanySpecs(List<LipskeyCatalogProduct> products) {
  for (final p in products) {
    final spec = companySpecFor(p);
    if (spec == null) continue;
    var inserted = false;
    kVerifiedSpecs.putIfAbsent(p.sku, () {
      inserted = true;
      return spec;
    });
    if (inserted) kCompanySpecSkus.add(p.sku);
  }
}

// ── parsing internals ────────────────────────────────────────────────────────

/// A whole cell that is just a number — the bare-mm push-fit spelling ('32').
final RegExp _kBareMm = RegExp(r'^\d+(?:\.\d+)?$');

/// One dims end-cell → a [ConnectorEnd], or null when the text doesn't parse.
/// [text] arrives trimmed and non-empty; buckets are checked in the table's
/// order (① thread · ② PEX · ③ copper · ④ push-fit · ⑤ drain · else null).
ConnectorEnd? _parseEnd(String text) {
  final upper = text.toUpperCase(); // Hebrew is untouched; PEX/DN go latin

  // ① BSP thread — תבריג/הברגה + gender (the connectionGender vocabulary:
  //    זכר/חיצוני ↔ נקבה/פנימי; both-or-neither is ambiguous → unparseable).
  if (text.contains('תבריג') || text.contains('הברגה')) {
    final male = text.contains('זכר') || text.contains('חיצוני');
    final female = text.contains('נקבה') || text.contains('פנימי');
    if (male == female) return null;
    final inch = _canonInchSize(text);
    if (inch == null) return null; // unrecognized inch size — unparseable
    return ConnectorEnd(male ? EndType.bspMale : EndType.bspFemale, inch);
  }

  // ② PEX press — פקס/PEX + a number (pipe OD, bare mm — '16').
  if (text.contains('פקס') || upper.contains('PEX')) {
    final mm = _mmSize(text);
    return mm == null ? null : ConnectorEnd(EndType.pexPress, mm);
  }

  // ③ copper press — נחושת + a number (tube OD, bare mm).
  if (text.contains('נחושת')) {
    final mm = _mmSize(text);
    return mm == null ? null : ConnectorEnd(EndType.copperPress, mm);
  }

  // ④ push-fit socket — glue/socket vocabulary, a DN prefix, or a bare-mm
  //    cell → [EndType.hdpeCompression], the engine's documented push-fit
  //    overload (lipskey_verified_connections + the PPR precedent in
  //    polyroll_specs); the spec's MATERIAL drives family compatibility.
  const socketWords = ['הדבקה', 'דבק', 'שקע', 'מופה', 'כניסה'];
  if (socketWords.any(text.contains) ||
      upper.startsWith('DN') ||
      _kBareMm.hasMatch(text)) {
    final mm = _mmSize(text);
    return mm == null ? null : ConnectorEnd(EndType.hdpeCompression, mm);
  }

  // ⑤ drain opening — 'פתח ניקוז' + the size AS WRITTEN ('4"' mates the
  //    static drain-opening specs; a garbled remainder mates nothing —
  //    a false negative, never a false positive).
  if (text.contains('פתח ניקוז')) {
    final size = text.replaceFirst('פתח ניקוז', '').trim();
    return size.isEmpty ? null : ConnectorEnd(EndType.drainOpening, size);
  }

  return null; // anything else — honestly unparseable
}

/// value-in-inches → the canonical [kBspInchToMm] key. Every value is an
/// exact binary double (quarters/eighths), so `==` lookup is sound. (`final`,
/// not `const` — Dart forbids double keys in const maps.)
final Map<double, String> _kInchValueToKey = {
  0.25: '1/4',
  0.375: '3/8',
  0.5: '1/2',
  0.75: '3/4',
  1: '1',
  1.25: '1-1/4',
  1.5: '1-1/2',
  2: '2',
  2.5: '2-1/2',
};

/// The BSP size inside a thread end-cell, canonicalized onto the nine
/// [kBspInchToMm] keys and emitted WITH the trailing '"' (the inch-mark
/// rule). Accepts '1/2' · '3/4' · '1' · '1.25' · '1 1/4' · '1-1/4' · unicode
/// fractions — each with or without גרש/גרשיים/quote marks. Null when the
/// size is not one of the nine — the end is then honestly unparseable.
String? _canonInchSize(String text) {
  var t = text;
  // The mark is re-emitted canonically, so every input spelling of it goes.
  for (final mark in const ['"', '״', "'", '׳', '″', '′']) {
    t = t.replaceAll(mark, ' ');
  }
  t = _expandInchFractions(t);
  // '1 ½' expanded to '1 .5' — close the gap so it parses as one number.
  t = t.replaceAllMapped(
    RegExp(r'(\d+)\s+\.(\d+)'),
    (m) => '${m[1]}.${m[2]}',
  );
  double? v;
  final mixed = RegExp(r'(\d+)[\s-]+(\d+)\s*/\s*(\d+)').firstMatch(t);
  if (mixed != null) {
    // '1 1/4' / '1-1/4' — a whole plus a fraction.
    v = int.parse(mixed[1]!) + int.parse(mixed[2]!) / int.parse(mixed[3]!);
  } else {
    final frac = RegExp(r'(\d+)\s*/\s*(\d+)').firstMatch(t);
    if (frac != null) {
      v = int.parse(frac[1]!) / int.parse(frac[2]!);
    } else {
      final dec = RegExp(r'\d*\.?\d+').firstMatch(t);
      if (dec != null) v = double.tryParse(dec[0]!);
    }
  }
  if (v == null) return null;
  final key = _kInchValueToKey[v];
  // Canonical means A KEY OF kBspInchToMm — the single map the whole engine
  // reads; anything outside the nine is honestly unparseable.
  if (key == null || !kBspInchToMm.containsKey(key)) return null;
  return '$key"';
}

/// Unicode inch fractions → decimals (the lipskey_catalog
/// `_expandInchFractions` vocabulary, mirrored — it is file-private there).
String _expandInchFractions(String w) => w
    .replaceAll('¼', '.25')
    .replaceAll('½', '.5')
    .replaceAll('¾', '.75')
    .replaceAll('⅛', '.125')
    .replaceAll('⅜', '.375')
    .replaceAll('⅝', '.625')
    .replaceAll('⅞', '.875');

/// First number in [text] as the engine's bare-mm size string. Integral
/// values lose the '.0' ('16.0' → '16', the polyroll normalization) so they
/// byte-match the static specs' mm vocabulary; a genuinely fractional value
/// is kept as written (never truncated into a wrong size). Null when the
/// text holds no number at all.
String? _mmSize(String text) {
  final m = RegExp(r'\d+(?:\.\d+)?').firstMatch(text);
  if (m == null) return null;
  final n = double.parse(m[0]!);
  return n == n.roundToDouble() ? n.toInt().toString() : m[0]!;
}

/// The engine's material vocabulary — the ONLY normalization targets
/// (the supply set of `VerifiedSpec.endSystems`, the drainage family of
/// `_materialsCompatible`, plus PPR — the polyroll bridge's token).
const List<String> _kEngineMaterials = [
  'HDPE', 'PEX', 'נחושת', 'פליז', 'פלדה', 'נירוסטה',
  'PVC', 'PP', 'רב-שכבתי', 'PPR',
];

/// Exact-match normalization onto [_kEngineMaterials] — latin tokens match
/// case-insensitively ('hdpe' → 'HDPE'; Hebrew is untouched by toUpperCase).
/// ANY other string is returned as-is: safe-degraded, never guessed.
String _normalizeMaterial(String raw) {
  for (final token in _kEngineMaterials) {
    if (raw.toUpperCase() == token) return token;
  }
  return raw;
}

/// dims['טמפ׳ מקסימלית'] — BOTH geresh spellings of the column title are
/// accepted (U+05F3 'טמפ׳' and ASCII-apostrophe "טמפ'"), and °/C/מעלות
/// suffixes are stripped. Null (absent/unparseable) makes [companySpecFor]
/// OMIT the maxTempC argument so the [VerifiedSpec] ctor default (40°C, the
/// conservative HDPE cap) applies — hot lines are rejected by design.
double? _maxTempC(LipskeyCatalogProduct p) {
  final raw = p.dims?['טמפ׳ מקסימלית']?.toString() ??
      p.dims?["טמפ' מקסימלית"]?.toString();
  if (raw == null) return null;
  final cleaned = raw
      .replaceAll('מעלות', '')
      .replaceAll('°', '')
      .trim()
      .replaceAll(RegExp(r'[Cc]$'), '')
      .trim();
  return double.tryParse(cleaned);
}

/// dims['לחץ'] first, then dims['PN'] — VERBATIM when non-empty (trimmed).
/// Unlike the polyroll bridge, no 'PN' prefix is fabricated: the company's
/// own wording is the truth we have.
String? _pressureRating(LipskeyCatalogProduct p) {
  for (final key in const ['לחץ', 'PN']) {
    final v = p.dims?[key]?.toString().trim();
    if (v != null && v.isNotEmpty) return v;
  }
  return null;
}
