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
  CatAxis('diameter', 'קוטר', '⭕'),
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

  // ── SIZE, split into the physical axes a plumber distinguishes ─────────────
  final diameter = <String>{};
  final length = <String>{};
  final transition = <String>{};
  for (final t in productSizeTokens(p)) {
    if (t.label.contains('×')) {
      transition.add(t.label); // 16×½ / 20×¾ — a reducer's two bores
    } else if (t.family == SizeFamily.cm || t.family == SizeFamily.meters) {
      length.add(t.label); // 50 ס"מ / 3 מ׳ — how long
    } else {
      diameter.add(t.label); // ½" / DN40 / 250 מ"מ — the bore
    }
  }
  if (diameter.isNotEmpty) out['diameter'] = diameter;
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

int _sizeRank(String axis, String value) {
  if (axis != 'diameter' && axis != 'length' && axis != 'transition') return -1;
  final t = parseSizeTokens(value);
  if (t.isEmpty) return -1;
  return (t.first.family.index * 100000) + t.first.mm.round();
}

/// Distinct values of [axis] among products matching [cons], ordered: size axes
/// by physical family+magnitude (DN15 before DN100), others by kRdOrder then alpha.
List<String> catOptsFor(String axis, Map<String, String> cons,
    [List<CatProduct>? pool, List<CatProduct>? matched]) {
  final base = matched ?? catMatching(cons, pool);
  final set = <String>{};
  for (final rp in base) {
    final v = rp.axes[axis];
    if (v != null) set.addAll(v);
  }
  final ord = kRdOrder[axis] ?? const <String>[];
  return set.toList()
    ..sort((a, b) {
      final sa = _sizeRank(axis, a);
      final sb = _sizeRank(axis, b);
      if (sa >= 0 && sb >= 0) return sa.compareTo(sb);
      final ra = ord.indexOf(a);
      final rb = ord.indexOf(b);
      final x = (ra < 0 ? 999 : ra) - (rb < 0 ? 999 : rb);
      return x != 0 ? x : a.compareTo(b);
    });
}

/// The axes still worth asking about for [cons] — each with ≥2 distinct options —
/// in registry order. THIS is the wheel-selector: with an empty [cons] it is the
/// FIRST wheel (every startable axis); deeper it is "which axis next".
List<String> catFindAxes(Map<String, String> cons, [List<CatProduct>? pool]) {
  final base = catMatching(cons, pool);
  if (base.length <= 1) return const <String>[];
  final out = <String>[];
  for (final ax in kCatAxes) {
    if (cons.containsKey(ax.id)) continue;
    if (catOptsFor(ax.id, cons, base, base).length >= 2) out.add(ax.id);
  }
  return out;
}
