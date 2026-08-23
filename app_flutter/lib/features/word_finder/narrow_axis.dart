/// Pure "narrow by" axis logic for the product finder (בית/מאתר).
///
/// Lifted verbatim out of `screens/finder_screen.dart` (STEP 0) so the axis
/// selection — sizes → angles → colours → characterizing words, behind the
/// curated facet override — can be unit-tested and reused without pulling in
/// Flutter widgets. ZERO logic change: each function body is byte-identical to
/// its former file-private form; only the names lost their leading underscore.
///
/// Size/angle token parsing still lives in `_size_norm.dart` (the single
/// vocabulary shared with the product-card chips) — this library imports it
/// rather than duplicating it.
library;

import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/_size_norm.dart';

/// Size labels a product carries — readable tokens from the name AND from
/// the dims map. A pipe carries TWO orthogonal axes: a diameter (in dims)
/// and a length (in name); the chooser needs both — they aren't substitutes.
/// Returns a deduped set; the family tag lets the chooser keep family-
/// coherent ordering (no inch interleaved with cm).
List<SizeToken> productSizeTokens(LipskeyCatalogProduct p) {
  final out = <SizeToken>{...parseSizeTokens(p.nameHe)};
  final d = p.dims;
  if (d != null) out.addAll(tokensFromDims(d));
  return out.toList();
}

/// Sorted, deduped chip list for the pool. Keeps every family the pool
/// surfaces (mm + cm, inch + DN, …) but groups them so the row reads
/// coherently: all mm in numeric order, THEN all cm in numeric order — never
/// `200 · 25 · 250 · 30` interleaved. Length equivalents across cm/meters/mm
/// collapse to one chip (e.g. `15 ס"מ` ≡ `0.15 מ׳`).
List<SizeToken> sizeTokensIn(List<LipskeyCatalogProduct> ps) {
  final all = <SizeToken>{};
  for (final p in ps) {
    all.addAll(productSizeTokens(p));
  }
  final out = dedupLengthByMm(all.toList());
  sortSizeTokens(out);
  return out;
}

/// Angle chips for the pool (separate axis — used only when sizes don't
/// split). Sorted ascending.
List<SizeToken> angleTokensIn(List<LipskeyCatalogProduct> ps) {
  final all = <SizeToken>{};
  for (final p in ps) {
    all.addAll(parseAngleTokens(p.nameHe));
  }
  final out = all.toList()..sort((a, b) => a.mm.compareTo(b.mm));
  return out;
}

/// Characterizing-word chips for sub-types with no size axis (e.g. toilet seats
/// differ by model/shape, not size). The first distinguishing word per name —
/// same idea as the catalog's auto-facets.
List<String> wordOptions(List<LipskeyCatalogProduct> pool) {
  if (pool.length <= 1) return const [];
  List<String> toks(String name) => name
      .split(RegExp(r'[\s()"׳/×,.+-]+'))
      .where((w) => w.length >= 2 && !RegExp(r'\d').hasMatch(w))
      .toList();
  final lists = [for (final p in pool) toks(p.nameHe)];
  final shared = lists.first.toSet();
  for (final t in lists.skip(1)) {
    shared.retainAll(t.toSet());
  }
  final counts = <String, int>{};
  for (final t in lists) {
    for (final w in t) {
      if (shared.contains(w)) continue;
      counts[w] = (counts[w] ?? 0) + 1;
      break; // first distinguishing word wins
    }
  }
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return [for (final e in entries.take(12)) e.key];
}

/// Curated narrow chips for sub-types that resist auto size/word detection —
/// keyword splits a non-technical user understands (cover/grate, round/square…).
const Map<String, List<String>> kFinderFacets = {
  'מכסים ורשתות': ['מכסה', 'רשת', 'עגול', 'מרובע', 'ניקל', 'נחושת', 'שחור'],
  'מחסומים גלויים': ['אמריקאי', 'נסתר', 'לכיור', 'למדיח', 'כביסה', 'מטבח'],
  // floor drains read off plain words, not opaque "245/50" DN codes
  'מחסומי רצפה': ['פתוח', 'סגור', 'למקלחת', 'קומקום'],
};

/// Distinct product colours in the pool (≥2) — narrows identical-name items
/// that differ only by colour (e.g. toilet seats: לבן/פרגמון/אפור).
List<String> colorOptions(List<LipskeyCatalogProduct> pool) {
  final cols = <String>{};
  for (final p in pool) {
    final c = p.color;
    if (c != null && c.trim().isNotEmpty) cols.add(c);
  }
  return cols.length > 1 ? (cols.toList()..sort()) : const [];
}

/// "Narrow by" axis for a pool, best first: curated facets → sizes → angles
/// (when sizes don't split) → colours → characterizing words. Returns a Hebrew
/// axis label (for the chip-row hint) plus the chip *labels*; empty when
/// nothing splits the pool.
({String label, List<String> chips}) narrowAxis(
    List<LipskeyCatalogProduct> pool, String? subtype,) {
  final curated = subtype == null ? null : kFinderFacets[subtype];
  if (curated != null) {
    final matching =
        curated.where((k) => pool.any((p) => p.nameHe.contains(k))).toList();
    if (matching.length > 1) return (label: 'אפשרות', chips: matching);
  }
  // Each axis must actually split the pool (>1 option); a lone chip can't
  // narrow anything, so fall through to the next axis (or show no bar).
  final sizes = sizeTokensIn(pool);
  if (sizes.length > 1) {
    return (label: 'גודל', chips: sizes.map((t) => t.label).toList());
  }
  final angles = angleTokensIn(pool);
  if (angles.length > 1) {
    return (label: 'זווית', chips: angles.map((t) => t.label).toList());
  }
  final colors = colorOptions(pool);
  if (colors.length > 1) return (label: 'צבע', chips: colors);
  final words = wordOptions(pool);
  return words.length > 1
      ? (label: 'דגם', chips: words)
      : (label: '', chips: const <String>[]);
}

/// Returns true iff a product carries the structural token for [chipLabel] —
/// no String.contains fallback. Lets the filter reject "25 שנים אחריות" when
/// the chip is "25 ס"מ".
bool productHasChip(LipskeyCatalogProduct p, String chipLabel) {
  for (final t in productSizeTokens(p)) {
    if (t.label == chipLabel) return true;
  }
  for (final t in parseAngleTokens(p.nameHe)) {
    if (t.label == chipLabel) return true;
  }
  // curated-facet chips (kFinderFacets) are plain Hebrew words — substring
  // match is correct ONLY for them (e.g. "אמריקאי" inside a drain name). It
  // must NEVER run for a digit-bearing size/angle label: "5\"" is a substring
  // of "1.25\"", "50 מ\"מ" of "250 מ\"מ", "2\"" of "1/2\"" — so a bare contains
  // would let a chip match a larger size it isn't. Those are handled
  // structurally above; here we gate the fallback to digit-free labels.
  if (!RegExp(r'\d').hasMatch(chipLabel) && p.nameHe.contains(chipLabel)) {
    return true;
  }
  return p.color == chipLabel;
}
