// PLAIN DIVE — a layman-first drill that runs ALONGSIDE the pro RingDive (never
// replacing it). The simplest person navigates by the owner's dictionary hierarchy,
// in everyday words, four rings deep:
//
//   1) קטגוריית-על   2) סיווג   3) שם-טכני\סלנג   4) המוצר עצמו
//
// The tree is the owner's dictionary (מעודכן.xlsx); products attach to each leaf
// through the SAME bilingual+slang search the catalog uses (catalogProductMatchesQuery),
// so a node "reaches products" for real — not a dead label. Nodes that reach NO
// product (tools/sealants the catalog doesn't stock) are hidden, so every ring the
// user sees actually lands somewhere.
//
// Pure + deterministic. Behind [kPlainDive] at the wiring layer; this data module
// is inert until a screen reads it.

import 'package:buildsmart/data/lipskey_catalog.dart' show LipskeyCatalogProduct;
import 'package:buildsmart/data/polyroll_catalog.dart' show kCatalogProducts;
import 'package:buildsmart/features/ring_dive/plain_dive_coverage.dart'
    show kPlainCoverage;
import 'package:buildsmart/features/ring_dive/ring_dive_catalog.dart'
    show kRdOrder, rdAxesOf;
import 'package:buildsmart/features/word_finder/narrow_axis.dart'
    show productHasChip, sizeTokensIn;
import 'package:buildsmart/screens/catalog_screen.dart'
    show catalogProductMatchesQuery;
import 'package:buildsmart/state/app_profile.dart' show kProfileEmptyCatalog;

/// The catalog pool the drill reaches products through — the RAW
/// `kCatalogProducts` union (this module is a sanctioned raw reader), emptied
/// on the clean shell ([kProfileEmptyCatalog]): no BuildSmart product content.
final List<LipskeyCatalogProduct> _pool =
    kProfileEmptyCatalog ? const <LipskeyCatalogProduct>[] : kCatalogProducts;

/// One row of the owner's dictionary: its place in the tree (superCat →
/// classification → technical), plus the layman label (slang) + English + usage.
class PlainNode {
  const PlainNode({
    required this.superCat,
    required this.classification,
    required this.technical,
    required this.slang,
    required this.english,
    required this.usage,
    this.categoriesExact,
  });

  final String superCat; // ring 1
  final String classification; // ring 2
  final String technical; // ring 3 (the query that reaches products)
  final String slang; // ring 3 label — the everyday word
  final String english;
  final String usage; // "what it does / where it goes"

  /// When set, this leaf reaches products by EXACT catalog category membership
  /// (p.categoryHe ∈ categoriesExact) instead of the [technical] search — used by
  /// the coverage nodes (curated + auto-fallback) so every category is reachable.
  /// A list because several catalog categories can share one plain word (all the
  /// drain-pipe categories → "צינור ניקוז").
  final List<String>? categoriesExact;
}

/// The owner's dictionary (מעודכן.xlsx) verbatim — the 4-ring tree source.
const List<PlainNode> kPlainDict = <PlainNode>[
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת גמישה', technical: '16', slang: 'חצי צול · 16מ"מ', english: '16mm PEX', usage: 'צנרת פקסגול/מולטיגול (ביתית)'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת גמישה', technical: '20', slang: '3/4 צול · 20מ"מ', english: '20mm PEX', usage: 'הזנה ראשית למקלחת/מטבח'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת קשיחה', technical: 'PPR', slang: 'פייזר/פולירול', english: 'PPR Pipe', usage: 'צנרת ירוקה (הלחמה)'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת ניקוז', technical: '32', slang: 'צול ורבע · 32מ"מ', english: 'DN32 Pipe', usage: 'כיורי רחצה'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת ניקוז', technical: '40', slang: 'צול וחצי · 40מ"מ', english: 'DN40 Pipe', usage: 'מטבח, כביסה, מדיח'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת ניקוז', technical: '50', slang: '2 צול · 50מ"מ', english: 'DN50 Pipe', usage: 'ניקוז רצפה, קופסאות ריח'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת ניקוז', technical: '110', slang: '4 צול · 110מ"מ', english: 'DN110 Pipe', usage: 'אסלות וקווים ראשיים'),
  PlainNode(superCat: 'צנרת וחומרים', classification: 'צנרת ניקוז', technical: '160', slang: '6 צול · 160מ"מ', english: 'DN160 Pipe', usage: 'קו ביוב ראשי בחצר'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'מופה', slang: 'מחבר ישר', english: 'Coupling', usage: 'חיבור בין שני צינורות'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'ניפל', slang: 'צינור קצר', english: 'Nipple', usage: 'זכר-זכר לחיבור אביזרים'),
  // ONE generic elbow leaf — the drill's angle ring ("איזו זווית?") splits 45°/90°
  // natively, so a separate "ברך 45" leaf would just duplicate a subset and the
  // "ברך 90" header would sit over 45° products.
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'ברך', slang: 'ברך', english: 'Elbow', usage: 'שינוי כיוון בצנרת'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'טי', slang: 'T', english: 'Tee Fitting', usage: 'פיצול קו ל-3 כיוונים'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'בוקסה', slang: 'מתאם הברגה', english: 'Bushing', usage: 'מעבר מהברגה גדולה לקטנה'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'מעבר', slang: 'רדוקציה / מקטין', english: 'Reducer', usage: 'מעבר קוטר בצינור'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'רקורד', slang: 'מחבר פירוק', english: 'Union', usage: 'חיבור מתפרק ללא סיבוב צינור'),
  PlainNode(superCat: 'אביזרי חיבור', classification: 'הברגות', technical: 'פקק', slang: 'פקק / טאפה', english: 'End Cap / Plug', usage: 'סגירת נקודה'),
  PlainNode(superCat: 'ברזים ובקרים', classification: 'ברזים', technical: 'ברז ניל', slang: 'ברז ניל', english: 'Angle Valve', usage: 'ברז פינתי מתחת לכיור/אסלה'),
  PlainNode(superCat: 'ברזים ובקרים', classification: 'ברזים', technical: 'ברז כדורי', slang: 'שיבר', english: 'Ball Valve', usage: 'ברז ראשי (פתיחה/סגירה)'),
  PlainNode(superCat: 'ברזים ובקרים', classification: 'ברזים', technical: 'ברז פרח', slang: 'ברז כיור', english: 'Monobloc Tap', usage: 'ברז עומד לכיור'),
  PlainNode(superCat: 'ברזים ובקרים', classification: 'מנגנונים', technical: 'מצוף', slang: 'מצוף ניאגרה', english: 'Float Valve', usage: 'שליטה במילוי מים'),
  PlainNode(superCat: 'ברזים ובקרים', classification: 'מנגנונים', technical: 'אל חוזר', slang: 'אל-חוזר', english: 'Check Valve', usage: 'מניעת זרימה חוזרת'),
  PlainNode(superCat: 'ברזים ובקרים', classification: 'מנגנונים', technical: 'מנגנון', slang: 'פעמון / מנגנון', english: 'Flush Valve', usage: 'הורדת מים בניאגרה'),
  PlainNode(superCat: 'סניטרי וניקוז', classification: 'ניקוז', technical: 'סיפון', slang: 'סיפון', english: 'S-Trap', usage: 'מונע ריח מהביוב'),
  PlainNode(superCat: 'סניטרי וניקוז', classification: 'ניקוז', technical: 'מחסום', slang: 'קופסת ריח', english: 'Floor Trap', usage: 'ניקוז רצפתי'),
  PlainNode(superCat: 'סניטרי וניקוז', classification: 'ניקוז', technical: 'שרשורי', slang: 'שרשורי', english: 'Flexible Pipe', usage: 'חיבור ניקוז גמיש'),
  PlainNode(superCat: 'סניטרי וניקוז', classification: 'כלים', technical: 'אסלה', slang: 'אסלה / מונובלוק', english: 'Toilet', usage: 'התקנה רצפתית/תלויה'),
];

final Map<String, List<LipskeyCatalogProduct>> _cache =
    <String, List<LipskeyCatalogProduct>>{};

/// The products a leaf node reaches — through the SAME bilingual+slang search the
/// catalog uses. Falls back from the technical term to the slang if the technical
/// term finds nothing. Memoised (the catalog is const).
List<LipskeyCatalogProduct> plainProductsFor(PlainNode n) {
  final key =
      '${n.superCat}|${n.classification}|${n.technical}|${n.categoriesExact?.join(',') ?? ''}';
  final cached = _cache[key];
  if (cached != null) return cached;
  // Coverage node: reach the whole catalog category/categories exactly (no fuzz).
  if (n.categoriesExact != null) {
    final cats = n.categoriesExact!.toSet();
    return _cache[key] = _pool
        .where((p) => cats.contains(p.categoryHe))
        .toList();
  }
  var ps = _pool
      .where((p) => catalogProductMatchesQuery(p, n.technical))
      .toList();
  // A bare-number technical ('16','40','110') is a CALIBER, but the catalog search
  // matches by startsWith — so '16' also grabs DN160 6-inch fittings and '20' grabs
  // '200 מ"מ'. Require the number as a WHOLE digit-run so a size node keeps to its
  // own caliber (digits are invariant under search-normalisation, so match raw).
  if (RegExp(r'^\d+$').hasMatch(n.technical)) {
    final whole = RegExp('(?<![0-9])${n.technical}(?![0-9])');
    ps = ps
        .where((p) => whole.hasMatch('${p.nameHe} ${p.categoryHe}'))
        .toList();
  }
  if (ps.isEmpty) {
    ps = _pool
        .where((p) => catalogProductMatchesQuery(p, n.slang))
        .toList();
  }
  return _cache[key] = ps;
}

bool _reaches(PlainNode n) => plainProductsFor(n).isNotEmpty;

/// The FULL tree: the owner's core dictionary + the swarm-curated coverage nodes +
/// an AUTO-FALLBACK so every catalog category is reachable (no product invisible).
/// Memoised (the catalog is const). The auto nodes sit under a catch-all 'עוד'
/// super-category, each reaching one leftover category by exact match.
List<PlainNode>? _treeCache;
List<PlainNode> _allNodes() {
  final cached = _treeCache;
  if (cached != null) return cached;
  final curated = <PlainNode>[...kPlainDict, ...kPlainCoverage];
  final reached = <String>{};
  for (final n in curated) {
    for (final p in plainProductsFor(n)) {
      reached.add(p.sku);
    }
  }
  final leftover = <String>{};
  for (final p in _pool) {
    if (!reached.contains(p.sku)) leftover.add(p.categoryHe);
  }
  final auto = <PlainNode>[
    for (final cat in leftover.toList()..sort())
      PlainNode(
        superCat: 'עוד',
        classification: 'קטגוריות נוספות',
        technical: cat,
        slang: cat,
        english: '',
        usage: '',
        categoriesExact: <String>[cat],
      ),
  ];
  return _treeCache = <PlainNode>[...curated, ...auto];
}

/// Ring 1 — the super-categories that actually reach products, in tree order.
List<String> plainSuperCats() {
  final out = <String>[];
  for (final n in _allNodes()) {
    if (!out.contains(n.superCat) && _reaches(n)) out.add(n.superCat);
  }
  return out;
}

/// Ring 2 — the classifications under [superCat] that reach products.
List<String> plainClassifications(String superCat) {
  final out = <String>[];
  for (final n in _allNodes()) {
    if (n.superCat == superCat &&
        !out.contains(n.classification) &&
        _reaches(n)) {
      out.add(n.classification);
    }
  }
  return out;
}

/// Ring 3 — the type nodes under [superCat] / [classification] that reach products.
List<PlainNode> plainNodes(String superCat, String classification) => [
      for (final n in _allNodes())
        if (n.superCat == superCat &&
            n.classification == classification &&
            _reaches(n))
          n,
    ];

// ── rings 4+ : keep drilling PAST the type — narrow the variants (size-first,
//    then material/angle/colour) ring-by-ring, in plain words, until ONE product
//    instead of dumping a list of 22. Reuses RingDive's [rdAxesOf] projection. ────

/// Axes we narrow the variants by, size-first (the plumber's first question);
/// 'type' LAST so a big single-caliber family (46 PPR ½" fittings) still splits by
/// kind (ברכיים / מסעפים / מתאמים) instead of dumping one long list.
const List<String> _narrowAxes = <String>[
  'size',
  'material',
  'angle',
  'color',
  'type',
];

/// Inch sizes → the spoken word, so rings 4+ stay in plain language ("חצי צול"
/// not '½"'). Non-inch sizes (mm / DN) already read plainly enough.
const Map<String, String> _sizePlain = <String, String>{
  '¼"': 'רבע צול',
  '3/8"': '3/8 צול',
  '½"': 'חצי צול',
  '1/2"': 'חצי צול',
  '¾"': '3/4 צול',
  '3/4"': '3/4 צול',
  '1"': 'צול',
  '1¼"': 'צול ורבע',
  '1½"': 'צול וחצי',
  '2"': '2 צול',
  '2½"': '2 וחצי צול',
  '2⅜"': '2 ו-3/8 צול',
  '3"': '3 צול',
  '4"': '4 צול',
};

/// Plain label for a variant value — inch sizes become the spoken "צול" word;
/// every other axis value already reads plainly (נחושת, לבן, 45°).
String plainAxisLabel(String axis, String value) =>
    axis == 'size' ? (_sizePlain[value] ?? value) : value;

/// The ring's question for a narrowing axis.
String plainAxisTitle(String axis) => switch (axis) {
      'size' => 'איזה גודל?',
      'material' => 'איזה חומר?',
      'angle' => 'איזו זווית?',
      'color' => 'איזה צבע?',
      'type' => 'איזה סוג?',
      _ => 'בחר',
    };

/// The NEXT narrowing ring for [products]: the first axis (size-first) on which
/// they actually SPLIT into ≥2 groups, its values ordered by [kRdOrder] then
/// alphabetically. Returns null when the drill is DONE — ≤1 product left, or the
/// products share every axis (indistinguishable) — so the caller shows the
/// remaining product(s).
({String axis, List<String> values})? plainNextAxis(
    List<LipskeyCatalogProduct> products,
    {Set<String> usedAxes = const <String>{}}) {
  if (products.length <= 1) return null;
  for (final axis in _narrowAxes) {
    // Each axis narrows ONCE — a product may carry two sizes (½×⅜), so re-offering
    // the same axis would loop on it forever without shrinking the set.
    if (usedAxes.contains(axis)) continue;
    if (axis == 'size') {
      // Route the size ring through the finder's OWN size vocabulary: it dedups
      // cm/meter twins (15 ס"מ ≡ 0.15 מ׳ → one chip), groups families (no inch
      // mixed with DN), and orders each family small→large — none of which the raw
      // rdAxesOf set does. plainFilterBy mirrors it via productHasChip.
      final toks = sizeTokensIn(products);
      // Offer size ONLY when every product carries a size chip — otherwise a
      // size-less product would be dropped by the pick and never reach a final
      // list. When some lack a size we skip to the next axis ('type' always covers
      // everyone), so no product is lost on the way down.
      if (toks.length >= 2 &&
          products.every((p) => toks.any((t) => productHasChip(p, t.label)))) {
        return (axis: 'size', values: [for (final t in toks) t.label]);
      }
      continue;
    }
    final vals = <String>{};
    var everyoneHasIt = true;
    for (final p in products) {
      final a = rdAxesOf(p)[axis];
      if (a == null || a.isEmpty) {
        everyoneHasIt = false;
      } else {
        vals.addAll(a);
      }
    }
    // Same rule for the other axes: only narrow when NO product lacks a value on
    // it, so the pick can't strand a value-less product.
    if (vals.length >= 2 && everyoneHasIt) {
      final ord = kRdOrder[axis] ?? const <String>[];
      final sorted = vals.toList()
        ..sort((a, b) {
          final ia = ord.indexOf(a);
          final ib = ord.indexOf(b);
          final ra = ia < 0 ? 999 : ia;
          final rb = ib < 0 ? 999 : ib;
          return ra != rb ? ra - rb : a.compareTo(b);
        });
      return (axis: axis, values: sorted);
    }
  }
  return null;
}

/// Keep only the products carrying [value] on [axis] — one drill-narrow step.
List<LipskeyCatalogProduct> plainFilterBy(
        List<LipskeyCatalogProduct> products, String axis, String value) =>
    [
      for (final p in products)
        if (axis == 'size'
            ? productHasChip(p, value)
            : (rdAxesOf(p)[axis]?.contains(value) ?? false))
          p,
    ];
