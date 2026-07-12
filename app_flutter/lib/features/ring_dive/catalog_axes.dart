// CATALOG AXES — the extended "any wheel first" projection for the layman finder.
//
// The owner's design: the FIRST wheel lets you pick WHICH of the ~15 axes to
// start from (type / diameter / length / room / material / …), then keep picking
// any remaining axis in any order until one product. It is a CONSTRAINT engine
// (axis→value map), not a fixed tree — every door is open.
//
// This builds ON RingDive's [rdAxesOf] (8 axes: world/cat/type/size/angle/color/
// material/brand) and (1) SPLITS the single "size" axis into the distinct physical
// axes a plumber actually means — קוטר (diameter) · אורך (length) · מעבר
// (transition/reducer) — and (2) ADDS קבוצה · חדר · מין-חיבור · שיטה · תכולה.
//
// PURE + deterministic. Imported by nothing yet ⇒ inert (byte-identical) until a
// screen reads it.

import 'dart:math' show log;

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/features/ring_dive/ring_dive_catalog.dart'
    show kRdOrder, rdAxesOf;
import 'package:buildsmart/features/word_finder/category_groups.dart'
    show groupOf;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOfEnriched;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show productSizeTokens;
import 'package:buildsmart/screens/_size_norm.dart'
    show SizeFamily, parseSizeTokens;

/// One selectable axis: its id, the layman label + emoji shown on the wheel.
class CatAxis {
  const CatAxis(this.id, this.label, this.emoji);
  final String id;
  final String label;
  final String emoji;
}

/// The axis registry, in first-wheel display order (structure → size → attributes
/// → smart). The first wheel offers whichever of these still split the pool.
const List<CatAxis> kCatAxes = <CatAxis>[
  CatAxis('type', 'סוג', '🏷️'),
  CatAxis('group', 'קבוצה', '🗂️'),
  CatAxis('world', 'עולם', '🏢'),
  CatAxis('cat', 'קטגוריה', '📁'),
  CatAxis('diamInch', 'קוטר אינץ׳', '⭕'),
  CatAxis('diamDn', 'קוטר DN', '⭕'),
  CatAxis('diamMm', 'קוטר מ"מ', '⭕'),
  CatAxis('length', 'אורך', '📏'),
  CatAxis('transition', 'מעבר', '↔️'),
  CatAxis('material', 'חומר', '🧱'),
  CatAxis('color', 'צבע', '🎨'),
  CatAxis('angle', 'זווית', '📐'),
  CatAxis('room', 'חדר', '🚿'),
  CatAxis('brand', 'מותג', '🏭'),
  CatAxis('method', 'שיטה', '🔗'),
  CatAxis('gender', 'מין חיבור', '🔩'),
  CatAxis('capacity', 'תכולה', '💧'),
];

/// Hebrew label for the axis id (for the axis-selector wheel + breadcrumb).
final Map<String, String> kCatAxisLabel = <String, String>{
  for (final a in kCatAxes) a.id: a.label,
};

String _methodHe(String m) => switch (m) {
      'thread' => 'הברגה',
      'glue' => 'הדבקה/הלחמה',
      'electrofusion' => 'ריתוך חשמלי',
      _ => m,
    };

/// Project a product onto EVERY catalog axis → axisId → its value(s). Multi-valued
/// axes (a reducer carries two diameters) are sets, so membership matching works.
Map<String, Set<String>> catAxesOf(LipskeyCatalogProduct p) {
  final base = rdAxesOf(p);
  final out = <String, Set<String>>{};
  void put(String ax, Iterable<String> vals) {
    final s = <String>{
      for (final v in vals)
        if (v.trim().isNotEmpty) v.trim(),
    };
    if (s.isNotEmpty) out[ax] = s;
  }

  // Reused verbatim from RingDive's projection.
  if (base['dept'] != null) out['world'] = base['dept']!;
  if (base['cat'] != null) out['cat'] = base['cat']!;
  if (base['type'] != null) out['type'] = base['type']!;
  if (base['angle'] != null) out['angle'] = base['angle']!;
  if (base['color'] != null) out['color'] = base['color']!;
  if (base['brand'] != null) out['brand'] = base['brand']!;

  // Material — the enriched variant (adds ~64 dims-only rows over the name parse).
  final mat = materialOfEnriched(p);
  if (mat != null) put('material', <String>[mat]);

  // Category group — the 12 human-curated buckets (100% coverage).
  put('group', <String>[groupOf(p)]);

  // ── SIZE, split into the physical axes a plumber distinguishes — and the bore
  //    itself split by MEASURING SYSTEM (owner: inch / DN / mm never share a wheel).
  final diamInch = <String>{}; // ½" / ¾" / 2"
  final diamDn = <String>{}; //   DN40 / DN110
  final diamMm = <String>{}; //   250 מ"מ (shower heads etc.)
  final length = <String>{}; //   50 ס"מ / 3 מ׳ — how long
  final transition = <String>{}; // 16×½ / 20×¾ — a reducer's two bores
  for (final t in productSizeTokens(p)) {
    if (t.label.contains('×')) {
      transition.add(t.label);
    } else if (t.family == SizeFamily.cm || t.family == SizeFamily.meters) {
      length.add(t.label);
    } else if (t.family == SizeFamily.inchDiameter) {
      diamInch.add(t.label);
    } else if (t.family == SizeFamily.dnDiameter) {
      diamDn.add(t.label);
    } else {
      diamMm.add(t.label);
    }
  }
  if (diamInch.isNotEmpty) out['diamInch'] = diamInch;
  if (diamDn.isNotEmpty) out['diamDn'] = diamDn;
  if (diamMm.isNotEmpty) out['diamMm'] = diamMm;
  if (length.isNotEmpty) out['length'] = length;
  if (transition.isNotEmpty) out['transition'] = transition;

  // ── Smart / derived axes ───────────────────────────────────────────────────
  final dims = p.dims;
  if (dims != null) {
    final use = dims['ייעוד']?.toString();
    if (use != null) put('room', <String>[use]);
    final cap = dims['תכולה']?.toString();
    if (cap != null) put('capacity', <String>[cap]);
  }
  final g = p.connectionGender;
  if (g != null) put('gender', <String>[g == 'male' ? 'זכר' : 'נקבה']);
  final m = p.connectionMethod;
  if (m != null) put('method', <String>[_methodHe(m)]);

  return out;
}

/// A product with its axes precomputed once.
class CatProduct {
  CatProduct(this.product) : axes = catAxesOf(product);
  final LipskeyCatalogProduct product;
  final Map<String, Set<String>> axes;
  String get sku => product.sku;
  bool has(String ax, String value) => axes[ax]?.contains(value) ?? false;
}

List<CatProduct>? _pool;

/// The whole dive pool, projected onto the axes once.
List<CatProduct> get catPool =>
    _pool ??= <CatProduct>[for (final p in kDivePool) CatProduct(p)];

/// Products satisfying every chosen constraint (axis→value), by membership.
List<CatProduct> catMatching(Map<String, String> cons,
    [List<CatProduct>? pool]) {
  final ps = pool ?? catPool;
  if (cons.isEmpty) return ps;
  return <CatProduct>[
    for (final rp in ps)
      if (cons.entries.every((e) => rp.has(e.key, e.value))) rp,
  ];
}

const Set<String> _sizeAxes = <String>{
  'diamInch',
  'diamDn',
  'diamMm',
  'length',
  'transition',
};

int _sizeRank(String axis, String value) {
  if (!_sizeAxes.contains(axis)) return -1;
  final t = parseSizeTokens(value);
  if (t.isEmpty) return -1;
  return (t.first.family.index * 100000) + t.first.mm.round();
}

/// Distinct values of [axis] among products matching [cons], ordered: size axes
/// by physical family+magnitude (DN15 before DN100), others by kRdOrder then alpha.
List<String> catOptsFor(String axis, Map<String, String> cons,
    [List<CatProduct>? pool, List<CatProduct>? matched]) {
  final base = matched ?? catMatching(cons, pool);
  final counts = <String, int>{};
  for (final rp in base) {
    final v = rp.axes[axis];
    if (v != null) {
      for (final x in v) {
        counts[x] = (counts[x] ?? 0) + 1;
      }
    }
  }
  final ord = kRdOrder[axis] ?? const <String>[];
  return counts.keys.toList()
    ..sort((a, b) {
      final sa = _sizeRank(axis, a);
      final sb = _sizeRank(axis, b);
      if (sa >= 0 && sb >= 0) return sa.compareTo(sb); // size: small → large
      // ENGINE 2 (ranking): the most COMMON values lead, so the wheel's first
      // (and its top-12 before "עוד") are the ones people actually reach for.
      final c = counts[b]!.compareTo(counts[a]!);
      if (c != 0) return c;
      final ra = ord.indexOf(a);
      final rb = ord.indexOf(b);
      final x = (ra < 0 ? 999 : ra) - (rb < 0 ? 999 : rb);
      return x != 0 ? x : a.compareTo(b);
    });
}

/// ENGINE 1 — the "easy path" (info-gain). How much a single ring narrows the
/// pool: the Shannon entropy of [axis]'s value distribution over [base]. A high
/// score means the axis splits the pool into many, evenly-sized groups — the most
/// decisive question to ask. Zero when the axis is absent or single-valued.
double catAxisGain(String axis, List<CatProduct> base) {
  if (base.isEmpty) return 0;
  final counts = <String, int>{};
  var total = 0;
  var present = 0; // products that HAVE this axis (for coverage weighting)
  for (final p in base) {
    final vals = p.axes[axis];
    if (vals == null) continue;
    present++;
    for (final v in vals) {
      counts[v] = (counts[v] ?? 0) + 1;
      total++;
    }
  }
  if (total == 0 || counts.length < 2) return 0;
  var h = 0.0;
  for (final c in counts.values) {
    final pr = c / total;
    h -= pr * (log(pr) / log(2));
  }
  // Weight by COVERAGE. Raw entropy is computed over ONLY the products that have
  // the axis, so a 1-23%-coverage axis (קוטר-מ"מ, אורך, חדר) whose few present
  // products spread over many values scores as "most decisive" — but picking such
  // a value drops the 77-99% that simply LACK the axis. Scaling by present/base
  // demotes sparse axes below full-coverage ones (סוג/קבוצה/מותג), so the first
  // wheel leads with genuinely pool-splitting questions.
  return h * (present / base.length);
}

/// The axes still worth asking about for [cons] — each with ≥2 distinct options —
/// ORDERED BY the easy-path engine (most-decisive first). THIS is the wheel-
/// selector: with an empty [cons] it is the FIRST wheel (every startable axis, the
/// smartest question on top); deeper it is "which axis next".
List<String> catFindAxes(Map<String, String> cons, [List<CatProduct>? pool]) {
  final base = catMatching(cons, pool);
  if (base.length <= 1) return const <String>[];
  final out = <String>[];
  for (final ax in kCatAxes) {
    if (cons.containsKey(ax.id)) continue;
    if (catOptsFor(ax.id, cons, base, base).length >= 2) out.add(ax.id);
  }
  // Easy-path: the most-decisive axis leads. Ties keep registry order (stable).
  final gain = <String, double>{for (final ax in out) ax: catAxisGain(ax, base)};
  out.sort((a, b) => gain[b]!.compareTo(gain[a]!));
  return out;
}
