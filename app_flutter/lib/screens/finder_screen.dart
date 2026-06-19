// "מאתר" — a non-technical product finder, built in the existing catalog's
// design language (WhatsApp-style rows + chips). The user answers the two
// questions a layman can answer: מה זה (a plain-language type — not the plumber
// taxonomy) and איזה גודל (a size read off their list). Results render through
// the shared LipskeyProductsList so cards behave like the rest of the catalog.
import 'package:buildsmart/data/huliot_smartlock_catalog.dart';
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/lipskey_verified_connections.dart'
    show WaterSystem;
import 'package:buildsmart/data/repositories/catalog_local.dart';
import 'package:buildsmart/logic/system_division.dart';
import 'package:buildsmart/screens/_size_norm.dart';
import '../features/word_finder/narrow_axis.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ink = BsTokens.inkLight;
const _mute = Color(0xFF888888);
const _surface = Color(0xFFF5F5F5);

/// Dismiss flag for the one-time "orange chip = tap to change" hint shown above
/// the finder results (the product cards' chip colours have no legend of their
/// own). Session-scoped; the X hides it for the rest of the session.
final finderChipTipDismissedProvider = StateProvider<bool>((_) => false);

/// A plain-language product group: a layman label + a one-line plain-Hebrew
/// description + the plumber `categoryHe` values it maps to. Empty [cats] marks
/// the catch-all ("אחר").
class FinderGroup {
  const FinderGroup(this.emoji, this.label, this.cats, {this.desc = ''});
  final String emoji;
  final String label;
  final Set<String> cats;
  final String desc;
}

// Ordered for a non-technical user: the consumer fixtures everyone recognises
// first (taps → toilets → shower/bath), then the everyday problems (drainage →
// pipes), then garden, then the technical plumbing components, then the
// catch-all last.
const List<FinderGroup> kFinderGroups = [
  FinderGroup('🚰', 'ברזים', {
    'ברזי כיור', 'ברזי מטבח', 'ברזי אמבטיה', 'ברזי מקלחת', 'ברזי קיר',
    'ברזי ניל', 'ברזי מעבר', 'ברזי דלי', 'ברזי גן', 'ברזים',
    'מחלקים', 'נקודות מים', 'אביזרי ברזים', 'דיורים ופיות',
  }, desc: 'ברזים לכיור, מטבח, אמבטיה, מקלחת וגינה',),
  FinderGroup('🚽', 'אסלות', {
    'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'מנגנונים',
    'חלקים סניטריים', 'התקנה גבוהה', 'התקנה נמוכה', 'התקנה צמודה',
  }, desc: 'אסלות, מושבים, מנגנוני הדחה ואביזרים',),
  FinderGroup('🚿', 'מקלחת ואמבטיה', {
    'ראשי מקלחת', 'מזלפי יד', 'זרועות דוש', 'אביזרי מקלחת',
    'מערכות אמבטיה', 'ערכות רחצה', 'מערכות שטיפה',
    'אביזרי חדר רחצה', 'ידיות אחיזה',
  }, desc: 'ראשי מקלחת, מזלפים, מערכות אמבטיה וידיות אחיזה',),
  FinderGroup('🕳️', 'ניקוז', {
    'תעלות ניקוז', 'מחסומי רצפה', 'מחסומים גלויים', 'מאספי רצפה',
    'מאספים וקולטים', 'סיפונים', 'כיסויים', 'מכסים ורשתות', 'ניקוז גג',
    'אביזרי ביוב', 'מסעפים וחיבורי אסלה', 'זקיף אסלה',
  }, desc: 'מחסומי רצפה, סיפונים, תעלות ניקוז ומכסים',),
  FinderGroup('📏', 'צינורות', {
    'צינורות אפורות', 'צינורות', 'צינורות PP', 'צינורות רב שכבתי',
    'צינורות גמישים', 'צינורות מקלחת',
  }, desc: 'צינורות מים, ביוב, גמישים ורב-שכבתיים',),
  FinderGroup('🌱', 'גינה', {'ציוד גן'}, desc: 'ציוד גינה והשקיה'),
  FinderGroup('🔗', 'מחברים וחיבורים', {
    'אביזרי נחושת', 'מחברי HDPE', 'מחברי NTM', 'אביזרי תבריג',
    'אביזרי שקע-תקע', 'ברכיים', 'מצמדים וצינורות', 'אטמים ופקקים',
    'אל חזור', 'אביזרי חיבור', 'סטי הידוק וחיבורים', 'פקקים וצינורות',
  }, desc: 'מחברים, ברכיים, מצמדים ואביזרי תבריג',),
  FinderGroup('🔩', 'חבקים ותלייה', {
    'חבקי תליה', 'חבקי צינור', 'עוגנים ובנדים',
  }, desc: 'חבקים, תליות ועוגנים לצנרת',),
  FinderGroup('🔵', 'צנרת PPR', {
    'צינורות PPR אספקת מים', 'צינורות PPR פייזר', 'צינורות PPR מיזוג אוויר',
    'ברכיים PPR', 'מסעפים PPR', 'מצמדים PPR', 'מתאמים PPR', 'רוכבים PPR',
    'פקקים PPR', 'אומגה PPR', 'ברזים PPR', 'צווארונים ואוגנים PPR',
    'אביזרי ריתוך חשמלי PPR', 'כלי ריתוך PPR',
  }, desc: 'מערכת צנרת PPR לאספקת מים ומיזוג — פולירול',),
  FinderGroup('🟢', 'דלוחין SmartLock', {
    kSmlPipes, kSmlCutters, kSmlJoker,
    kSmlElbowOneSide, kSmlElbow, kSmlElbowReducing, kSmlElbowTelescopic,
    kSmlTee, kSmlDoubleCoupling, kSmlReducer,
    kSmlGutters, kSmlFloorDrains, kSmlAccessories, kSmlNuts,
    kSmlAquaSlim, kSmlCovers, kSmlSiphons,
  }, desc: 'מערכת דלוחין SmartLock מפוליפרופילן 32-63 מ"מ — חוליות',),
  FinderGroup('🔧', 'אחר', {}, desc: 'כל שאר המוצרים בקטלוג'), // catch-all
];

/// Display-only icon per finder group. The data keeps its emoji (`g.emoji`,
/// still used in text contexts like the catalog overview row), but the home
/// circles render a Material icon because canvasKit's bundled font can't draw
/// the plumbing emoji (🚰🚽🕳️…) — they showed as empty boxes. Keyed by the
/// group label (stable identity); `finder_group_icons_test` fails if a group
/// ships without an entry. Same display-fold philosophy as P13's font fold.
const Map<String, IconData> kFinderGroupIcons = {
  'ברזים': Icons.water_drop,
  'אסלות': Icons.wc,
  'מקלחת ואמבטיה': Icons.shower,
  'ניקוז': Icons.water,
  'צינורות': Icons.plumbing,
  'גינה': Icons.grass,
  'מחברים וחיבורים': Icons.link,
  'חבקים ותלייה': Icons.hardware,
  'צנרת PPR': Icons.trip_origin,
  'דלוחין SmartLock': Icons.water_damage,
  'אחר': Icons.category,
};

/// The Material icon for a finder group, with a generic catch-all fallback
/// for any unmapped label (the test guards against that path in practice).
IconData finderGroupIcon(String label) =>
    kFinderGroupIcons[label] ?? Icons.category;

/// Designer-supplied 3D product icon per finder group (transparent PNGs in
/// `assets/lipskey/categories/`). Groups without an image fall back to the
/// Material icon (all 10 groups now have a dedicated product icon).
const Map<String, String> kFinderGroupImage = {
  'ברזים': 'faucets',
  'אסלות': 'toilets',
  'מקלחת ואמבטיה': 'shower_bath',
  'ניקוז': 'drainage',
  'צינורות': 'pipes',
  'גינה': 'garden',
  'מחברים וחיבורים': 'connectors',
  'חבקים ותלייה': 'clamps',
  'צנרת PPR': 'ppr',
  'דלוחין SmartLock': 'smartlock',
  'אחר': 'other',
};

/// Asset path for a group's product icon, or null when none exists.
String? finderGroupImageAsset(String label) {
  final f = kFinderGroupImage[label];
  return f == null ? null : 'assets/lipskey/categories/$f.png';
}

/// The circle content for a finder group: the designer's product image when
/// present, else the Material icon. [size] is the icon/image box edge.
Widget finderGroupGlyph(String label, {required double size}) {
  final asset = finderGroupImageAsset(label);
  if (asset != null) {
    return Image.asset(asset,
        width: size, height: size, fit: BoxFit.contain,
        // If the file is missing/corrupt, degrade to the icon — never a
        // broken-image box.
        errorBuilder: (_, __, ___) =>
            Icon(finderGroupIcon(label), size: size * 0.7, color: BsTokens.brand),);
  }
  return Icon(finderGroupIcon(label), size: size * 0.7, color: BsTokens.brand);
}

/// A curated sub-type within a finder group: a plain label + the real
/// `categoryHe` values it covers. Lets us merge catalog misfiles (e.g. the lone
/// "ברזים" garden tap belongs under "גן") and drop jargon-y 1-item categories,
/// instead of dumping raw plumber categories on a non-technical user.
class FinderSub {
  const FinderSub(this.label, this.cats);
  final String label;
  final Set<String> cats;
}

/// Curated sub-types per group label. Groups without an entry fall back to the
/// auto path (real categories, merged by cleaned label). Labels are verbatim
/// tokens of real catalog categories — no invented Hebrew (R6/R8).
const Map<String, List<FinderSub>> kFinderSubs = {
  'ברזים': [
    FinderSub('כיור', {'ברזי כיור'}),
    FinderSub('מטבח', {'ברזי מטבח'}),
    FinderSub('אמבטיה', {'ברזי אמבטיה'}),
    FinderSub('מקלחת', {'ברזי מקלחת'}),
    FinderSub('קיר', {'ברזי קיר'}),
    FinderSub('גן', {'ברזי גן', 'ברזים'}), // folds the lone misfiled garden tap
    FinderSub('מעבר', {'ברזי מעבר'}),
    FinderSub('ניל', {'ברזי ניל'}),
    FinderSub('דלי', {'ברזי דלי'}),
    FinderSub('מחלקים', {'מחלקים'}),
    FinderSub('נקודות מים', {'נקודות מים'}),
    FinderSub('אביזרים', {'אביזרי ברזים'}),
    FinderSub('פיות', {'דיורים ופיות'}),
  ],
  // household-common first (floor drains / traps / siphons), technical last
  'ניקוז': [
    FinderSub('מחסומי רצפה', {'מחסומי רצפה', 'מאספים וקולטים'}), // folds a stray floor drain
    FinderSub('מחסומים גלויים', {'מחסומים גלויים'}),
    FinderSub('סיפונים', {'סיפונים', 'אביזרי ביוב'}), // folds a lone siphon funnel
    FinderSub('תעלות ניקוז', {'תעלות ניקוז'}),
    FinderSub('מכסים ורשתות', {'מכסים ורשתות'}),
    FinderSub('כיסויים', {'כיסויים'}),
    FinderSub('מאספי רצפה', {'מאספי רצפה'}),
    FinderSub('מסעפים', {'מסעפים וחיבורי אסלה'}),
    FinderSub('זקיף אסלה', {'זקיף אסלה'}),
    FinderSub('ניקוז גג', {'ניקוז גג'}),
  ],
  // showerheads/hand-showers first, accessories and grab bars last
  'מקלחת ואמבטיה': [
    FinderSub('ראשי מקלחת', {'ראשי מקלחת'}),
    FinderSub('מזלפי יד', {'מזלפי יד'}),
    FinderSub('מערכות שטיפה', {'מערכות שטיפה'}),
    FinderSub('מערכות אמבטיה', {'מערכות אמבטיה'}),
    FinderSub('ערכות רחצה', {'ערכות רחצה'}),
    FinderSub('זרועות דוש', {'זרועות דוש'}),
    FinderSub('אביזרי מקלחת', {'אביזרי מקלחת'}),
    FinderSub('אביזרי חדר רחצה', {'אביזרי חדר רחצה'}),
    FinderSub('ידיות אחיזה', {'ידיות אחיזה'}),
  ],
  // consumer items first, technical installation-height types last
  'אסלות': [
    FinderSub('מושבים', {'מושבי אסלה'}),
    FinderSub('אסלות וכיורים', {'אסלות וכיורים'}),
    FinderSub('אביזרים', {'אביזרי אסלה'}),
    FinderSub('מנגנונים', {'מנגנונים'}),
    FinderSub('חלקים סניטריים', {'חלקים סניטריים'}),
    FinderSub('התקנה נמוכה', {'התקנה נמוכה'}),
    FinderSub('התקנה גבוהה', {'התקנה גבוהה'}),
    FinderSub('התקנה צמודה', {'התקנה צמודה'}),
  ],
  // recognisable fitting families first, niche/single types last
  'מחברים וחיבורים': [
    FinderSub('תבריג', {'אביזרי תבריג'}),
    FinderSub('ברכיים', {'ברכיים'}),
    FinderSub('נחושת', {'אביזרי נחושת'}),
    FinderSub('HDPE', {'מחברי HDPE'}),
    FinderSub('NTM', {'מחברי NTM'}),
    FinderSub('שקע-תקע', {'אביזרי שקע-תקע'}),
    FinderSub('מצמדים', {'מצמדים וצינורות'}),
    FinderSub('אטמים ופקקים', {'אטמים ופקקים'}),
    FinderSub('אל חזור', {'אל חזור'}),
    FinderSub('פקקים וצינורות', {'פקקים וצינורות'}),
    FinderSub('סטי הידוק', {'סטי הידוק וחיבורים'}),
    FinderSub('חיבור', {'אביזרי חיבור'}),
  ],
  'חבקים ותלייה': [
    FinderSub('חבקי צינור', {'חבקי צינור'}),
    FinderSub('חבקי תליה', {'חבקי תליה'}),
    FinderSub('עוגנים ובנדים', {'עוגנים ובנדים'}),
  ],
  // flexible/shower hoses first (most consumer-relatable), rigid systems last
  'צינורות': [
    FinderSub('צינורות גמישים', {'צינורות גמישים'}),
    FinderSub('צינורות מקלחת', {'צינורות מקלחת'}),
    FinderSub('צינורות אפורות', {'צינורות אפורות'}),
    FinderSub('צינורות', {'צינורות'}),
    FinderSub('צינורות PP', {'צינורות PP'}),
    FinderSub('צינורות רב שכבתי', {'צינורות רב שכבתי'}),
  ],
};

final Set<String> _claimedCats = {for (final g in kFinderGroups) ...g.cats};

List<LipskeyCatalogProduct> _productsForGroup(FinderGroup g) {
  // T6.3: route through the catalog repository (same const `kCatalogProducts`).
  if (g.cats.isEmpty) {
    return catalogRepo()
        .allProducts()
        .where((p) => !_claimedCats.contains(p.categoryHe))
        .toList();
  }
  return catalogRepo()
      .allProducts()
      .where((p) => g.cats.contains(p.categoryHe))
      .toList();
}

class FinderScreen extends ConsumerStatefulWidget {
  const FinderScreen({super.key});
  @override
  ConsumerState<FinderScreen> createState() => _FinderScreenState();
}

class _FinderScreenState extends ConsumerState<FinderScreen> {
  FinderGroup? _group;
  String? _sub;
  String? _size;
  String? _angle;
  String? _letter;
  String? _wall;

  // Memo of the system-filtered group pool. `filterBySystem(_productsForGroup(g))`
  // is a full O(catalog) scan, but it depends ONLY on the active group + system
  // filter — NOT on the chip selections (_size/_angle/_sub/_letter/_wall) that
  // setState on every tap. Cache it keyed on (group, systemFilter) so toggling a
  // chip reuses the same base instead of rescanning the catalog each build.
  FinderGroup? _baseGroup;
  WaterSystem? _baseSystem;
  List<LipskeyCatalogProduct>? _baseCache;

  List<LipskeyCatalogProduct> _baseFor(FinderGroup g, WaterSystem? systemFilter) {
    if (_baseCache != null &&
        identical(_baseGroup, g) &&
        _baseSystem == systemFilter) {
      return _baseCache!;
    }
    _baseGroup = g;
    _baseSystem = systemFilter;
    return _baseCache = filterBySystem(_productsForGroup(g), systemFilter);
  }

  // Per-(systemFilter) tally of how many in-system products each `categoryHe`
  // has — built ONCE per system from a single catalog pass, so `_typeList` can
  // size all 12 group badges by summing each group's categories instead of
  // re-scanning the whole catalog 12× (filterBySystem ∘ _productsForGroup per
  // group). Byte-identical: filtering-then-grouping == grouping-then-filtering.
  WaterSystem? _catCountSystem;
  Map<String, int>? _catCountCache;

  Map<String, int> _categoryCountsFor(WaterSystem? systemFilter) {
    if (_catCountCache != null && _catCountSystem == systemFilter) {
      return _catCountCache!;
    }
    final counts = <String, int>{};
    for (final p
        in filterBySystem(catalogRepo().allProducts(), systemFilter)) {
      counts[p.categoryHe] = (counts[p.categoryHe] ?? 0) + 1;
    }
    _catCountSystem = systemFilter;
    return _catCountCache = counts;
  }

  /// In-system product count for [g] — sums the per-category tally so it avoids
  /// the old per-group `filterBySystem(_productsForGroup(g))` rescan. Catch-all
  /// (`g.cats` empty) sums every category not claimed by another group, exactly
  /// as `_productsForGroup` selects them.
  int _groupCount(FinderGroup g, Map<String, int> catCounts) {
    if (g.cats.isEmpty) {
      var n = 0;
      catCounts.forEach((cat, c) {
        if (!_claimedCats.contains(cat)) n += c;
      });
      return n;
    }
    var n = 0;
    for (final c in g.cats) {
      n += catCounts[c] ?? 0;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    if (_group == null) return _typeList();

    // Scope to the active water system (Benzi #1, option 2): a department sets
    // catalogSystemFilterProvider, so the finder's whole pool — subs, narrow
    // chips, results — derives from the filtered base.
    final systemFilter = ref.watch(catalogSystemFilterProvider);
    final base = _baseFor(_group!, systemFilter);
    final subs = _subsFor(base);
    FinderSub? sel;
    for (final s in subs) {
      if (s.label == _sub) {
        sel = s;
        break;
      }
    }
    final pool = sel == null
        ? base
        : base.where((p) => sel!.cats.contains(p.categoryHe)).toList();
    final narrow = narrowAxis(pool, _sub);
    // Secondary angle row appears whenever the primary axis was סוג/גודל/דגם
    // AND the pool has >1 angles — so a user looking at a 90° elbow can flip
    // to 45° from the same screen.
    final angleChips = narrow.label == 'זווית'
        ? const <String>[]
        : angleTokensIn(pool).map((t) => t.label).toList();
    // Secondary letter-size row (S/M/L): some collars/anchors carry a letter
    // size instead of a number. Surfaced like the angle axis, co-filterable.
    final letterChips = _letterOptions(pool);
    // Secondary wall-thickness row (PPR/multilayer): the SAME OD ships at
    // different walls (PN ratings), so `20×2.8` vs `40×5.5` — wall narrows
    // beyond the גודל (OD) axis. Co-filterable.
    final wallChips = _wallOptions(pool);
    var results = pool;
    if (_size != null) {
      results = results.where((p) => productHasChip(p, _size!)).toList();
    }
    if (_angle != null) {
      results = results.where((p) => productHasChip(p, _angle!)).toList();
    }
    if (_letter != null) {
      results = results
          .where((p) => letterSizeTokens(p.nameHe).contains(_letter))
          .toList();
    }
    if (_wall != null) {
      results =
          results.where((p) => wallTokens(p.nameHe).contains(_wall)).toList();
    }
    // Count of cards the user will actually see (variants collapse to one).
    final shown = results.map(productListDedupeKey).toSet().length;

    return Column(
      children: [
        _header(),
        if (subs.length > 1) _subBar(subs),
        if (narrow.chips.isNotEmpty) _sizeBar(narrow.label, narrow.chips),
        if (angleChips.length > 1) _angleBar(angleChips),
        if (letterChips.length > 1) _letterBar(letterChips),
        if (wallChips.length > 1) _wallBar(wallChips),
        if (results.isNotEmpty) _countStrip(shown),
        if (results.isNotEmpty &&
            !ref.watch(finderChipTipDismissedProvider))
          _chipTip(),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Text('לא נמצאו מוצרים',
                      style: TextStyle(color: _mute),),)
              : LipskeyProductsList(products: results),
        ),
      ],
    );
  }

  /// Secondary chip row for angle variants — same vocabulary as the primary
  /// `_sizeBar`, but keyed against `_angle` so size + angle can co-filter.
  Widget _angleBar(List<String> chips) {
    return _chipRow('זווית', [
      _chip('הכל', _angle == null, () => setState(() => _angle = null)),
      for (final c in chips)
        _chip(c, _angle == c, () => setState(() => _angle = c)),
    ]);
  }

  /// Secondary chip row for letter sizes (S/M/L) — keyed against `_letter`.
  Widget _letterBar(List<String> chips) {
    return _chipRow('מידה', [
      _chip('הכל', _letter == null, () => setState(() => _letter = null)),
      for (final c in chips)
        _chip(c, _letter == c, () => setState(() => _letter = c)),
    ]);
  }

  /// Distinct letter sizes across the pool (small→large), or empty.
  List<String> _letterOptions(List<LipskeyCatalogProduct> pool) {
    final all = <String>{};
    for (final p in pool) {
      all.addAll(letterSizeTokens(p.nameHe));
    }
    final out = all.toList()
      ..sort((a, b) => kLetterSizeOrder
          .indexOf(a)
          .compareTo(kLetterSizeOrder.indexOf(b)),);
    return out;
  }

  /// Secondary chip row for wall thickness (PPR PN ratings) — keyed `_wall`.
  Widget _wallBar(List<String> chips) {
    return _chipRow('עובי', [
      _chip('הכל', _wall == null, () => setState(() => _wall = null)),
      for (final c in chips)
        _chip('$c מ"מ', _wall == c, () => setState(() => _wall = c)),
    ]);
  }

  /// Distinct cross-dim wall thicknesses across the pool (numeric-ascending).
  List<String> _wallOptions(List<LipskeyCatalogProduct> pool) {
    final all = <String>{};
    for (final p in pool) {
      all.addAll(wallTokens(p.nameHe));
    }
    final out = all.toList()
      ..sort((a, b) => double.parse(a).compareTo(double.parse(b)));
    return out;
  }

  // One-time hint explaining the orange chips on the product cards below
  // (their colour code has no legend of its own). Dismissible via the X.
  Widget _chipTip() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        const Text('💡', style: TextStyle(fontSize: 13)),
        const SizedBox(width: 6),
        const Expanded(
          child: Text('צ׳יפ כתום על מוצר — הקש כדי להחליף גודל או צבע',
              style: TextStyle(color: _ink, fontSize: 12),),
        ),
        Semantics(
          button: true,
          label: 'סגור',
          child: Tooltip(
            message: 'סגור',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () =>
                  ref.read(finderChipTipDismissedProvider.notifier).state = true,
              // ≥48dp tap target around the small ✕ (a11y), without
              // enlarging the visible glyph.
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(Icons.close, size: 16, color: _mute),
                ),
              ),
            ),
          ),
        ),
      ],),
    );
  }

  // Small reassurance line above the list: how many products matched.
  Widget _countStrip(int n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text('נמצאו $n מוצרים',
            style: const TextStyle(color: _mute, fontSize: 12),),
      ),
    );
  }

  // ── step 1: type rows — same WhatsApp-style row as _CatalogList ──────────
  Widget _typeList() {
    // Scope to the active water system (Benzi #1, option 2): hide groups with no
    // products in it, and show the in-system count. The count comes from a
    // single per-category tally (built once per system) summed per group —
    // instead of one full catalog scan per group (was ≈12×O(catalog) per build).
    final systemFilter = ref.watch(catalogSystemFilterProvider);
    final catCounts = _categoryCountsFor(systemFilter);
    final groups = <(FinderGroup, int)>[];
    for (final g in kFinderGroups) {
      final n = _groupCount(g, catCounts);
      if (n > 0) groups.add((g, n));
    }
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: groups.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 82,
        color: _surface,
      ),
      itemBuilder: (_, i) {
        final g = groups[i].$1;
        final count = groups[i].$2;
        return InkWell(
          onTap: () => setState(() {
            _group = g;
            _sub = null;
            _size = null;
            _angle = null;
            _letter = null;
            _wall = null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                    color: _surface, shape: BoxShape.circle,),
                alignment: Alignment.center,
                child: finderGroupGlyph(g.label, size: 46),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.label,
                        style: const TextStyle(
                            color: _ink,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,),),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(g.desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _mute, fontSize: 13,),),
                        ),
                        const SizedBox(width: 8),
                        // Count pill — same idiom as the קטלוג category badge.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2,),
                          decoration: BoxDecoration(
                            color: BsTokens.brand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,),),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left, color: _mute),
            ],),
          ),
        );
      },
    );
  }

  // ── selected-type header — breadcrumb + back ONE level (size→sub→types) ──
  Widget _header() {
    final crumbs = <String>[
      _group!.label,
      if (_sub != null) _sub!,
      if (_size != null) _size!,
    ];
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => setState(() {
          if (_angle != null) {
            _angle = null;
            _letter = null;
            _wall = null;
          } else if (_size != null) {
            _size = null;
          } else if (_sub != null) {
            _sub = null;
          } else {
            _group = null;
          }
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            const Icon(Icons.chevron_right, color: _mute),
            const SizedBox(width: 6),
            Container(
              width: 38,
              height: 38,
              decoration:
                  const BoxDecoration(color: _surface, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: finderGroupGlyph(_group!.label, size: 30),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(crumbs.join('  ‹  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _ink, fontSize: 16, fontWeight: FontWeight.w700,),),
            ),
          ],),
        ),
      ),
    );
  }

  // ── step 1b: sub-type chips ──────────────────────────────────────────────
  // Curated sub-types when the group defines them; otherwise the real
  // categories, merged by cleaned label so two categories never show as
  // duplicate chips (e.g. "אביזרי ברזים" + "ברזים" → one "ברזים").
  List<FinderSub> _subsFor(List<LipskeyCatalogProduct> base) {
    final present = <String>{for (final p in base) p.categoryHe};
    final curated = kFinderSubs[_group!.label];
    if (curated != null) {
      return [
        for (final s in curated)
          if (s.cats.any(present.contains)) s,
      ];
    }
    final cats = <String, Set<String>>{};
    final counts = <String, int>{};
    for (final p in base) {
      final l = _cleanSub(p.categoryHe);
      (cats[l] ??= <String>{}).add(p.categoryHe);
      counts[l] = (counts[l] ?? 0) + 1;
    }
    final labels = cats.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    return [for (final l in labels) FinderSub(l, cats[l]!)];
  }

  String _cleanSub(String cat) {
    for (final pre in const ['ברזי ', 'אביזרי ', 'מחברי ']) {
      if (cat.startsWith(pre)) return cat.substring(pre.length);
    }
    return cat;
  }

  // A labeled chip row: a fixed leading hint (e.g. "סוג"/"גודל") so a layman
  // knows what each row narrows by, then the horizontally-scrolling chips.
  Widget _chipRow(String hint, List<Widget> chips) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _surface)),
      ),
      child: Row(children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 14, end: 2),
          child: Text(hint,
              style: const TextStyle(
                  color: _mute, fontSize: 12, fontWeight: FontWeight.w700,),),
        ),
        Expanded(child: _ChipScroll(children: chips)),
      ],),
    );
  }

  Widget _subBar(List<FinderSub> subs) {
    return _chipRow('סוג', [
      _chip('הכל', _sub == null,
          () => setState(() {
                _sub = null;
                _size = null;
                _angle = null;
                _letter = null;
                _wall = null;
              }),),
      for (final s in subs)
        _chip(s.label, _sub == s.label,
            () => setState(() {
                  _sub = s.label;
                  _size = null;
                  _angle = null;
                  _letter = null;
                  _wall = null;
                }),),
    ]);
  }

  // ── step 2: narrow chips (size/colour/option) — catalog chip style ───────
  Widget _sizeBar(String hint, List<String> chips) {
    return _chipRow(hint.isEmpty ? 'גודל' : hint, [
      _chip('הכל', _size == null, () => setState(() => _size = null)),
      for (final s in chips)
        _chip(s, _size == s, () => setState(() => _size = s)),
    ]);
  }

  Widget _chip(String label, bool active, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? BsTokens.brand : _surface,
            borderRadius: BorderRadius.circular(20),
          ),
          // LTR for digit-bearing labels (shared with the product-card chip
          // via chipLabelDirection — keeps the two display paths in sync).
          child: Text(label,
              textDirection: chipLabelDirection(label),
              style: TextStyle(
                  color: active ? Colors.white : _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,),),
        ),
      ),
    );
  }
}

/// Horizontal chip strip with a scroll-discoverability hint: when chips
/// overflow, a soft edge-fade + ‹ chevron appears on the END edge (the left,
/// in RTL) so the user knows there are more chips to scroll to. The hint
/// hides once scrolled to the end / when nothing overflows.
class _ChipScroll extends StatefulWidget {
  const _ChipScroll({required this.children});
  final List<Widget> children;
  @override
  State<_ChipScroll> createState() => _ChipScrollState();
}

class _ChipScrollState extends State<_ChipScroll> {
  final _ctrl = ScrollController();
  bool _more = false; // hidden chips remain toward the end edge

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_recompute);
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  void _recompute() {
    if (!_ctrl.hasClients) return;
    final more = _ctrl.offset < _ctrl.position.maxScrollExtent - 0.5;
    if (more != _more) setState(() => _more = more);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (_) {
            _recompute();
            return false;
          },
          child: ListView(
            controller: _ctrl,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 7),
            children: widget.children,
          ),
        ),
        if (_more)
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                key: const Key('chip-scroll-more'),
                width: 30,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                    colors: [Color(0x00FFFFFF), Colors.white],
                  ),
                ),
                alignment: Alignment.centerLeft,
                child: const Icon(Icons.chevron_left, size: 18, color: _mute,
                    textDirection: TextDirection.ltr),
              ),
            ),
          ),
      ],
    );
  }
}
