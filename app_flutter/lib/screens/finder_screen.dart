// "מאתר" — a non-technical product finder, built in the existing catalog's
// design language (WhatsApp-style rows + chips). The user answers the two
// questions a layman can answer: מה זה (a plain-language type — not the plumber
// taxonomy) and איזה גודל (a size read off their list). Results render through
// the shared LipskeyProductsList so cards behave like the rest of the catalog.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/data/polyroll_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ink = Color(0xFF1A1A1A);
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
  }, desc: 'ברזים לכיור, מטבח, אמבטיה, מקלחת וגינה'),
  FinderGroup('🚽', 'אסלות', {
    'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'מנגנונים',
    'חלקים סניטריים', 'התקנה גבוהה', 'התקנה נמוכה', 'התקנה צמודה',
  }, desc: 'אסלות, מושבים, מנגנוני הדחה ואביזרים'),
  FinderGroup('🚿', 'מקלחת ואמבטיה', {
    'ראשי מקלחת', 'מזלפי יד', 'זרועות דוש', 'אביזרי מקלחת',
    'מערכות אמבטיה', 'ערכות רחצה', 'מערכות שטיפה',
    'אביזרי חדר רחצה', 'ידיות אחיזה',
  }, desc: 'ראשי מקלחת, מזלפים, מערכות אמבטיה וידיות אחיזה'),
  FinderGroup('🕳️', 'ניקוז', {
    'תעלות ניקוז', 'מחסומי רצפה', 'מחסומים גלויים', 'מאספי רצפה',
    'מאספים וקולטים', 'סיפונים', 'כיסויים', 'מכסים ורשתות', 'ניקוז גג',
    'אביזרי ביוב', 'מסעפים וחיבורי אסלה', 'זקיף אסלה',
  }, desc: 'מחסומי רצפה, סיפונים, תעלות ניקוז ומכסים'),
  FinderGroup('📏', 'צינורות', {
    'צינורות אפורות', 'צינורות', 'צינורות PP', 'צינורות רב שכבתי',
    'צינורות גמישים', 'צינורות מקלחת',
  }, desc: 'צינורות מים, ביוב, גמישים ורב-שכבתיים'),
  FinderGroup('🌱', 'גינה', {'ציוד גן'}, desc: 'ציוד גינה והשקיה'),
  FinderGroup('🔗', 'מחברים וחיבורים', {
    'אביזרי נחושת', 'מחברי HDPE', 'מחברי NTM', 'אביזרי תבריג',
    'אביזרי שקע-תקע', 'ברכיים', 'מצמדים וצינורות', 'אטמים ופקקים',
    'אל חזור', 'אביזרי חיבור', 'סטי הידוק וחיבורים', 'פקקים וצינורות',
  }, desc: 'מחברים, ברכיים, מצמדים ואביזרי תבריג'),
  FinderGroup('🔩', 'חבקים ותלייה', {
    'חבקי תליה', 'חבקי צינור', 'עוגנים ובנדים',
  }, desc: 'חבקים, תליות ועוגנים לצנרת'),
  FinderGroup('🔵', 'צנרת PPR', {
    'צינורות PPR אספקת מים', 'צינורות PPR פייזר', 'צינורות PPR מיזוג אוויר',
    'ברכיים PPR', 'מסעפים PPR', 'מצמדים PPR', 'מתאמים PPR', 'רוכבים PPR',
    'פקקים PPR', 'אומגה PPR', 'ברזים PPR', 'צווארונים ואוגנים PPR',
    'אביזרי ריתוך חשמלי PPR', 'כלי ריתוך PPR',
  }, desc: 'מערכת צנרת PPR לאספקת מים ומיזוג — פולירול'),
  FinderGroup('🔧', 'אחר', {}, desc: 'כל שאר המוצרים בקטלוג'), // catch-all
];

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
  if (g.cats.isEmpty) {
    return kCatalogProducts
        .where((p) => !_claimedCats.contains(p.categoryHe))
        .toList();
  }
  return kCatalogProducts.where((p) => g.cats.contains(p.categoryHe)).toList();
}

/// Readable size tokens found in product names (1/2" · 3/4" · DN40 · 16×20 ·
/// 50 מ"מ). Catches inch/fraction, DN, cross-sizes, and Hebrew "מ"מ" (mm).
final RegExp _sizeRe = RegExp(
    r'DN ?\d+|\d+ ?[מס]["״]מ|\d+°|\d+\.\d+(?:/\d+)?["׳]|\d*[¼½¾⅛⅜⅝⅞]["׳]|\d+(?:/\d+)?×\d+(?:/\d+)?|\d+(?:/\d+)?["׳]|\d+/\d+');

/// Confusing compound/decimal inch notations folded to one clean fraction
/// glyph, so "11/4"" and "1.25"" don't show as two chips for the same 1¼".
const Map<String, String> _kInchPretty = {
  '1.25"': '1¼"', '11/4"': '1¼"',
  '1.5"': '1½"', '11/2"': '1½"',
  '21/2"': '2½"',
};

/// Size labels a product carries — readable tokens from the name, or (when the
/// name has none, e.g. gray pipes) derived from dims (DN + length in metres).
Set<String> _productSizes(LipskeyCatalogProduct p) {
  final fromName = <String>{};
  for (final m in _sizeRe.allMatches(p.nameHe)) {
    final v = m.group(0)!.trim();
    if (v.length <= 12) fromName.add(_kInchPretty[v] ?? v);
  }
  if (fromName.isNotEmpty) return fromName;
  final d = p.dims;
  if (d == null) return const {};
  final out = <String>{};
  final dn = (d['DN'] ?? d['dn'] ?? d['mm'])?.toString();
  if (dn != null && dn.trim().isNotEmpty) out.add('DN$dn');
  final cm = double.tryParse(d['L (cm)']?.toString() ?? '');
  if (cm != null) {
    final m = cm / 100;
    out.add('${m == m.roundToDouble() ? m.toInt() : m} מ׳');
  }
  return out;
}

List<String> _sizesIn(List<LipskeyCatalogProduct> ps) {
  final set = <String>{};
  for (final p in ps) {
    set.addAll(_productSizes(p));
  }
  return set.toList()..sort((a, b) => a.compareTo(b));
}

/// Characterizing-word chips for sub-types with no size axis (e.g. toilet seats
/// differ by model/shape, not size). The first distinguishing word per name —
/// same idea as the catalog's auto-facets.
List<String> _wordOptions(List<LipskeyCatalogProduct> pool) {
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
List<String> _colorOptions(List<LipskeyCatalogProduct> pool) {
  final cols = <String>{};
  for (final p in pool) {
    final c = p.color;
    if (c != null && c.trim().isNotEmpty) cols.add(c);
  }
  return cols.length > 1 ? (cols.toList()..sort()) : const [];
}

/// "Narrow by" axis for a pool, best first: curated facets → sizes → colours →
/// characterizing words. Returns a Hebrew axis label (for the chip-row hint)
/// plus the chips; empty when nothing splits the pool.
({String label, List<String> chips}) _narrowAxis(
    List<LipskeyCatalogProduct> pool, String? subtype) {
  final curated = subtype == null ? null : kFinderFacets[subtype];
  if (curated != null) {
    final matching =
        curated.where((k) => pool.any((p) => p.nameHe.contains(k))).toList();
    if (matching.length > 1) return (label: 'אפשרות', chips: matching);
  }
  // Each axis must actually split the pool (>1 option); a lone chip can't
  // narrow anything, so fall through to the next axis (or show no bar).
  final sizes = _sizesIn(pool);
  if (sizes.length > 1) return (label: 'גודל', chips: sizes);
  final colors = _colorOptions(pool);
  if (colors.length > 1) return (label: 'צבע', chips: colors);
  final words = _wordOptions(pool);
  return words.length > 1
      ? (label: 'דגם', chips: words)
      : (label: '', chips: const <String>[]);
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

  @override
  Widget build(BuildContext context) {
    if (_group == null) return _typeList();

    final base = _productsForGroup(_group!);
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
    final narrow = _narrowAxis(pool, _sub);
    final results = _size == null
        ? pool
        : pool
            .where((p) =>
                _productSizes(p).contains(_size!) ||
                p.nameHe.contains(_size!) ||
                p.color == _size)
            .toList();
    // Count of cards the user will actually see (variants collapse to one).
    final shown = results.map(productListDedupeKey).toSet().length;

    return Column(
      children: [
        _header(),
        if (subs.length > 1) _subBar(subs),
        if (narrow.chips.isNotEmpty) _sizeBar(narrow.label, narrow.chips),
        if (results.isNotEmpty) _countStrip(shown),
        if (results.isNotEmpty &&
            !ref.watch(finderChipTipDismissedProvider))
          _chipTip(),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Text('לא נמצאו מוצרים',
                      style: TextStyle(color: _mute)))
              : LipskeyProductsList(products: results),
        ),
      ],
    );
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
              style: TextStyle(color: _ink, fontSize: 12)),
        ),
        GestureDetector(
          onTap: () =>
              ref.read(finderChipTipDismissedProvider.notifier).state = true,
          child: const Icon(Icons.close, size: 16, color: _mute),
        ),
      ]),
    );
  }

  // Small reassurance line above the list: how many products matched.
  Widget _countStrip(int n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text('נמצאו $n מוצרים',
            style: const TextStyle(color: _mute, fontSize: 12)),
      ),
    );
  }

  // ── step 1: type rows — same WhatsApp-style row as _CatalogList ──────────
  Widget _typeList() {
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: kFinderGroups.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 82,
        color: _surface,
      ),
      itemBuilder: (_, i) {
        final g = kFinderGroups[i];
        final count = _productsForGroup(g).length;
        return InkWell(
          onTap: () => setState(() {
            _group = g;
            _sub = null;
            _size = null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                    color: _surface, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(g.emoji, style: const TextStyle(fontSize: 26)),
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
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(g.desc,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: _mute, fontSize: 13)),
                        ),
                        const SizedBox(width: 8),
                        // Count pill — same idiom as the קטלוג category badge.
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: BsTokens.brand,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$count',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_left, color: _mute),
            ]),
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
          if (_size != null) {
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
              child: Text(_group!.emoji, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(crumbs.join('  ›  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ]),
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
          padding: const EdgeInsets.only(right: 14, left: 2),
          child: Text(hint,
              style: const TextStyle(
                  color: _mute, fontSize: 12, fontWeight: FontWeight.w700)),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 7),
            children: chips,
          ),
        ),
      ]),
    );
  }

  Widget _subBar(List<FinderSub> subs) {
    return _chipRow('סוג', [
      _chip('הכל', _sub == null,
          () => setState(() {
                _sub = null;
                _size = null;
              })),
      for (final s in subs)
        _chip(s.label, _sub == s.label,
            () => setState(() {
                  _sub = s.label;
                  _size = null;
                })),
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
      padding: const EdgeInsets.only(left: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: active ? BsTokens.brand : _surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : _ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
