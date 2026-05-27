// "מאתר" — a non-technical product finder, built in the existing catalog's
// design language (WhatsApp-style rows + chips). The user answers the two
// questions a layman can answer: מה זה (a plain-language type — not the plumber
// taxonomy) and איזה גודל (a size read off their list). Results render through
// the shared LipskeyProductsList so cards behave like the rest of the catalog.
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _ink = Color(0xFF1A1A1A);
const _mute = Color(0xFF888888);
const _surface = Color(0xFFF5F5F5);

/// A plain-language product group: a layman label + the plumber `categoryHe`
/// values it maps to. Empty [cats] marks the catch-all ("אחר").
class FinderGroup {
  const FinderGroup(this.emoji, this.label, this.cats);
  final String emoji;
  final String label;
  final Set<String> cats;
}

const List<FinderGroup> kFinderGroups = [
  FinderGroup('🚰', 'ברזים', {
    'ברזי כיור', 'ברזי מטבח', 'ברזי אמבטיה', 'ברזי מקלחת', 'ברזי קיר',
    'ברזי ניל', 'ברזי מעבר', 'ברזי דלי', 'ברזי גן', 'ברזים',
    'מחלקים', 'נקודות מים', 'אביזרי ברזים',
  }),
  FinderGroup('🔗', 'מחברים וחיבורים', {
    'אביזרי נחושת', 'מחברי HDPE', 'מחברי NTM', 'אביזרי תבריג',
    'אביזרי שקע-תקע', 'ברכיים', 'מצמדים וצינורות', 'אטמים ופקקים',
    'אל חזור', 'אביזרי חיבור', 'סטי הידוק וחיבורים',
  }),
  FinderGroup('📏', 'צינורות', {
    'צינורות אפורות', 'צינורות', 'צינורות PP', 'צינורות רב שכבתי',
    'צינורות גמישים', 'צינורות מקלחת',
  }),
  FinderGroup('🕳️', 'ניקוז', {
    'תעלות ניקוז', 'מחסומי רצפה', 'מחסומים גלויים', 'מאספי רצפה',
    'מאספים וקולטים', 'סיפונים', 'כיסויים', 'מכסים ורשתות', 'ניקוז גג',
    'אביזרי ביוב', 'מסעפים וחיבורי אסלה', 'זקיף אסלה',
  }),
  FinderGroup('🚿', 'מקלחת ואמבטיה', {
    'ראשי מקלחת', 'מזלפי יד', 'זרועות דוש', 'אביזרי מקלחת',
    'מערכות אמבטיה', 'ערכות רחצה', 'מערכות שטיפה', 'אמבט ואגנית',
  }),
  FinderGroup('🚽', 'אסלות', {
    'אסלות וכיורים', 'מושבי אסלה', 'אביזרי אסלה', 'מנגנונים',
    'חלקים סניטריים', 'התקנה גבוהה', 'התקנה נמוכה', 'התקנה צמודה',
  }),
  FinderGroup('🔧', 'אחר', {}), // catch-all
];

final Set<String> _claimedCats = {for (final g in kFinderGroups) ...g.cats};

List<LipskeyCatalogProduct> _productsForGroup(FinderGroup g) {
  if (g.cats.isEmpty) {
    return kLipskeyCatalog
        .where((p) => !_claimedCats.contains(p.categoryHe))
        .toList();
  }
  return kLipskeyCatalog.where((p) => g.cats.contains(p.categoryHe)).toList();
}

/// Readable size tokens found in product names (1/2" · 3/4" · DN40 · 16×20).
final RegExp _sizeRe =
    RegExp(r'DN ?\d+|\d+(?:/\d+)?(?:×\d+(?:/\d+)?)?["׳]|\d+×\d+|\d+/\d+');

/// Size labels a product carries — readable tokens from the name, or (when the
/// name has none, e.g. gray pipes) derived from dims (DN + length in metres).
Set<String> _productSizes(LipskeyCatalogProduct p) {
  final fromName = <String>{};
  for (final m in _sizeRe.allMatches(p.nameHe)) {
    final v = m.group(0)!.trim();
    if (v.length <= 12) fromName.add(v);
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
    final subs = _subTypes(base);
    final pool = _sub == null
        ? base
        : base.where((p) => p.categoryHe == _sub).toList();
    final sizes = _sizesIn(pool);
    final results = _size == null
        ? pool
        : pool.where((p) => _productSizes(p).contains(_size!)).toList();

    return Column(
      children: [
        _header(),
        if (subs.length > 1) _subBar(subs),
        if (sizes.isNotEmpty) _sizeBar(sizes),
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

  // ── step 1: type rows — same WhatsApp-style row as _CatalogList ──────────
  Widget _typeList() {
    return ListView.separated(
      key: const Key('catalog-list'),
      itemCount: kFinderGroups.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        indent: 76,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                    color: _surface, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(g.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.label,
                        style: const TextStyle(
                            color: _ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text('$count מוצרים',
                        style: const TextStyle(color: _mute, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left, color: _mute),
            ]),
          ),
        );
      },
    );
  }

  // ── selected-type header (back to types) — drill-bar style ───────────────
  Widget _header() {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () => setState(() {
          _group = null;
          _sub = null;
          _size = null;
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
            Text(_group!.label,
                style: const TextStyle(
                    color: _ink, fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }

  // ── step 1b: sub-type chips — the categories within the group ────────────
  List<String> _subTypes(List<LipskeyCatalogProduct> base) {
    final counts = <String, int>{};
    for (final p in base) {
      counts[p.categoryHe] = (counts[p.categoryHe] ?? 0) + 1;
    }
    return counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));
  }

  String _cleanSub(String cat) {
    for (final pre in const ['ברזי ', 'אביזרי ', 'מחברי ']) {
      if (cat.startsWith(pre)) return cat.substring(pre.length);
    }
    return cat;
  }

  Widget _subBar(List<String> subs) {
    return Container(
      height: 46,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _surface)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        children: [
          _chip('הכל', _sub == null,
              () => setState(() {
                    _sub = null;
                    _size = null;
                  })),
          for (final c in subs)
            _chip(_cleanSub(c), _sub == c,
                () => setState(() {
                      _sub = c;
                      _size = null;
                    })),
        ],
      ),
    );
  }

  // ── step 2: size chips — catalog chip style ──────────────────────────────
  Widget _sizeBar(List<String> sizes) {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _surface)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        children: [
          _chip('הכל', _size == null, () => setState(() => _size = null)),
          for (final s in sizes)
            _chip(s, _size == s, () => setState(() => _size = s)),
        ],
      ),
    );
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
