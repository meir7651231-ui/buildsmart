/// RingDive Pro-X-Light — the DERIVATION LAYER (the bridge). Projects every real
/// catalog product onto the 8 flat axes the design's drill-down needs
/// {dept, cat, type, size, angle, color, material, brand}, derived from the
/// catalog tree + the finder engine + direct fields. A product that has no data
/// for an axis simply omits it — the design's [rdFindAxes] only offers axes with
/// >=2 distinct options, so a sparse axis never blocks.
///
/// OWNER-LOCKED (6/7): no price · skip axes with no data · compat via the real
/// verified-connections engine · jobs via the real smart_tree recipes.
///
/// PURE: no Flutter / Riverpod / clock / IO. The pool + taxonomy maps are built
/// once (memoised) over the const catalog, exactly like `buildWordLexicon`.
library;

import 'package:buildsmart/data/catalog_tree.dart'
    show CatalogNode, kCatalogTree;
import 'package:buildsmart/data/lipskey_catalog.dart'
    show LipskeyCatalogProduct;
import 'package:buildsmart/features/word_finder/dive_pool.dart' show kDivePool;
import 'package:buildsmart/features/word_finder/material_lexicon.dart'
    show materialOf;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show productSizeTokens;
import 'package:buildsmart/logic/category_division.dart'
    show kDeptCatHeadings;
import 'package:buildsmart/screens/_size_norm.dart' show parseAngleTokens;

/// The 8 taxonomy+attribute axes in the design's drill (plan) order.
const List<String> kRdAxes = <String>[
  'dept',
  'cat',
  'type',
  'size',
  'angle',
  'color',
  'material',
  'brand',
];

/// axis-field → the Hebrew label shown in the chip strip / hub.
const Map<String, String> kRdAxisLabel = <String, String>{
  'dept': 'מחלקה',
  'cat': 'קטגוריה',
  'type': 'סוג',
  'size': 'גודל',
  'angle': 'זווית',
  'color': 'צבע',
  'material': 'חומר',
  'brand': 'מותג',
};

/// Preferred value order per axis (the design's `order`), so common values sort
/// first instead of alphabetically. Unknown values fall to the end.
const Map<String, List<String>> kRdOrder = <String, List<String>>{
  'size': <String>[
    '½"', '¾"', '1"', '1¼"', '1½"', '2"', 'DN40', 'DN50', 'DN110', '16 מ"מ',
  ],
  'angle': <String>['ישר', '45°', '90°'],
  'material': <String>[
    'נחושת', 'PPR', 'HDPE', 'רב-שכבתי', 'פקס', 'נירוסטה', 'פלדה', 'פליז',
    'קרמיקה',
  ],
  'color': <String>[
    'לבן', 'שחור מט', 'שחור', 'פרגמון', 'אפור', 'ניקל מוברש', 'ניקל', 'כרום',
    'נחושת', 'ירוק', 'כחול',
  ],
};

// ── taxonomy maps (built once from the catalog tree + dept headings) ─────────

/// A product's taxonomy position: the tree's top category (`cat`) + its leaf
/// title (`type`).
class _Taxo {
  const _Taxo(this.cat, this.type);
  final String cat;
  final String type;
}

Map<String, _Taxo>? _taxoByCatHe;

/// `categoryHe` → its tree top-title (cat) + leaf-title (type), memoised.
Map<String, _Taxo> get _taxo {
  final cached = _taxoByCatHe;
  if (cached != null) return cached;
  final out = <String, _Taxo>{};
  void walk(CatalogNode node, String topTitle) {
    final lc = node.lipskeyCategory;
    if (lc != null) out[lc] = _Taxo(topTitle, node.title);
    for (final child in node.children) {
      walk(child, topTitle);
    }
  }

  for (final top in kCatalogTree) {
    walk(top, top.title);
  }
  return _taxoByCatHe = out;
}

Map<String, String>? _deptByCatHe;

/// `categoryHe` → its department (reverse of [kDeptCatHeadings]), memoised.
Map<String, String> get _dept {
  final cached = _deptByCatHe;
  if (cached != null) return cached;
  final out = <String, String>{};
  kDeptCatHeadings.forEach((dept, headings) {
    for (final h in headings) {
      for (final title in h.titles) {
        for (final leafCat in _leafCatsUnderTitle(title)) {
          out.putIfAbsent(leafCat, () => dept);
        }
      }
    }
  });
  return _deptByCatHe = out;
}

/// The `categoryHe` values reachable under a dept-heading title (a tree node
/// title OR a bare category).
Set<String> _leafCatsUnderTitle(String title) {
  final cats = <String>{};
  void gatherLeaves(CatalogNode n) {
    final lc = n.lipskeyCategory;
    if (lc != null) cats.add(lc);
    for (final c in n.children) {
      gatherLeaves(c);
    }
  }

  void find(CatalogNode n) {
    if (n.title == title || n.lipskeyCategory == title) {
      gatherLeaves(n);
      return;
    }
    for (final c in n.children) {
      find(c);
    }
  }

  for (final t in kCatalogTree) {
    find(t);
  }
  if (cats.isEmpty) cats.add(title); // bare categoryHe with no tree node
  return cats;
}

/// Project one product onto the design axes. An axis with no data is omitted.
Map<String, Set<String>> rdAxesOf(LipskeyCatalogProduct p) {
  final out = <String, Set<String>>{};
  void put(String field, Iterable<String> values) {
    final s = <String>{
      for (final v in values)
        if (v.trim().isNotEmpty) v.trim(),
    };
    if (s.isNotEmpty) out[field] = s;
  }

  final taxo = _taxo[p.categoryHe];
  final dept = _dept[p.categoryHe];
  if (dept != null) put('dept', <String>[dept]);
  put('cat', <String>[taxo?.cat ?? p.categoryHe]);
  put('type', <String>[taxo?.type ?? p.categoryHe]);
  put('size', productSizeTokens(p).map((t) => t.label));
  put('angle', parseAngleTokens(p.nameHe).map((t) => t.label));
  final material = materialOf(p);
  if (material != null) put('material', <String>[material]);
  final color = p.color;
  if (color != null) put('color', <String>[color]);
  put('brand', <String>[p.brand]);
  return out;
}

/// A catalog product with its precomputed axes.
class RdProduct {
  RdProduct(this.product) : axes = rdAxesOf(product);

  final LipskeyCatalogProduct product;
  final Map<String, Set<String>> axes;

  String get sku => product.sku;
  String get name => product.nameHe;
  String? get color => product.color;
  String get brand => product.brand;

  /// True iff this product carries [value] on axis [field].
  bool has(String field, String value) => axes[field]?.contains(value) ?? false;
}

List<RdProduct>? _rdPool;

/// The RingDive pool — the curated dive-pool projected onto the axes, once.
List<RdProduct> get rdPool =>
    _rdPool ??= <RdProduct>[for (final p in kDivePool) RdProduct(p)];

// ── the drill-down algorithm (mirrors the design's matching/optsFor/findAxes) ─

/// Constraints chosen so far: axis-field → chosen value.
typedef RdCons = Map<String, String>;

/// Products satisfying every constraint (predicate membership, so multi-valued
/// axes like size work: a product matches if it CARRIES the chosen value).
List<RdProduct> rdMatching(RdCons cons, [List<RdProduct>? pool]) {
  final ps = pool ?? rdPool;
  if (cons.isEmpty) return ps;
  return ps
      .where((rp) => cons.entries.every((e) => rp.has(e.key, e.value)))
      .toList();
}

int _rank(String field, String value) {
  final ord = kRdOrder[field];
  if (ord == null) return 999;
  final i = ord.indexOf(value);
  return i < 0 ? 999 : i;
}

/// Distinct option values for [field] among products matching [cons], ordered by
/// [kRdOrder] then alphabetically. Pass [matched] (an already-computed
/// [rdMatching] result for the same [cons]/[pool]) to skip re-filtering.
List<String> rdOptsFor(
  String field,
  RdCons cons, [
  List<RdProduct>? pool,
  List<RdProduct>? matched,
]) {
  final base = matched ?? rdMatching(cons, pool);
  final set = <String>{};
  for (final rp in base) {
    final v = rp.axes[field];
    if (v != null) set.addAll(v);
  }
  final out = set.toList()
    ..sort((a, b) {
      final r = _rank(field, a).compareTo(_rank(field, b));
      return r != 0 ? r : a.compareTo(b);
    });
  return out;
}

/// The remaining discriminating axes (each still with >=2 options), in plan
/// order — the axes worth asking about. Empty once <=1 product remains.
List<String> rdFindAxes(RdCons cons, [List<RdProduct>? pool]) {
  final matched = rdMatching(cons, pool);
  if (matched.length <= 1) return const <String>[];
  return <String>[
    for (final f in kRdAxes)
      if (!cons.containsKey(f) && rdOptsFor(f, cons, pool, matched).length >= 2)
        f,
  ];
}
