// "מאתר" — a non-technical product finder. Instead of navigating the plumber
// taxonomy, the user answers the two questions a layman CAN answer:
//   1. מה זה? (a plain-language type tile — not "אביזרי נחושת"/"מחברי HDPE")
//   2. איזה גודל? (a size chip read straight off their list)
// then taps a result to add it (with the existing card's variant picker + cart).
// Renders results through the shared LipskeyProductsList so cards behave exactly
// like the rest of the catalog (variant families, add-to-cart).
import 'package:buildsmart/data/lipskey_catalog.dart';
import 'package:buildsmart/screens/lipskey_products_screen.dart';
import 'package:buildsmart/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Every category claimed by a non-catch-all group.
final Set<String> _claimedCats = {
  for (final g in kFinderGroups) ...g.cats,
};

List<LipskeyCatalogProduct> _productsForGroup(FinderGroup g) {
  if (g.cats.isEmpty) {
    return kLipskeyCatalog
        .where((p) => !_claimedCats.contains(p.categoryHe))
        .toList();
  }
  return kLipskeyCatalog.where((p) => g.cats.contains(p.categoryHe)).toList();
}

/// Readable size tokens found in product names (1/2" · 3/4" · DN40 · 16×20 · 2").
final RegExp _sizeRe = RegExp(
    r'DN ?\d+|\d+(?:/\d+)?(?:×\d+(?:/\d+)?)?["׳]|\d+×\d+|\d+/\d+');

List<String> _sizesIn(List<LipskeyCatalogProduct> ps) {
  final set = <String>{};
  for (final p in ps) {
    for (final m in _sizeRe.allMatches(p.nameHe)) {
      final s = m.group(0)!.trim();
      if (s.length <= 12) set.add(s);
    }
  }
  final list = set.toList()..sort((a, b) => a.compareTo(b));
  return list;
}

class FinderScreen extends ConsumerStatefulWidget {
  const FinderScreen({super.key});
  @override
  ConsumerState<FinderScreen> createState() => _FinderScreenState();
}

class _FinderScreenState extends ConsumerState<FinderScreen> {
  FinderGroup? _group;
  String? _size;

  @override
  Widget build(BuildContext context) {
    if (_group == null) return _groupGrid();

    final base = _productsForGroup(_group!);
    final sizes = _sizesIn(base);
    final results = _size == null
        ? base
        : base.where((p) => p.nameHe.contains(_size!)).toList();

    return Column(
      children: [
        _groupBar(),
        if (sizes.isNotEmpty) _sizeChips(sizes),
        Expanded(
          child: results.isEmpty
              ? const Center(
                  child: Text('לא נמצאו מוצרים',
                      style: TextStyle(color: Color(0xFF888888))))
              : LipskeyProductsList(products: results),
        ),
      ],
    );
  }

  // ── step 1: "מה אתה צריך?" — plain type tiles ────────────────────────────
  Widget _groupGrid() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('מה אתה צריך?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          const Text('בחר סוג — ואז גודל. בלי לדעת איפה זה בקטלוג.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.7,
            ),
            itemCount: kFinderGroups.length,
            itemBuilder: (_, i) {
              final g = kFinderGroups[i];
              final count = _productsForGroup(g).length;
              return GestureDetector(
                onTap: () => setState(() {
                  _group = g;
                  _size = null;
                }),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: BsTokens.brand.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(g.emoji, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(g.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w800)),
                      Text('$count מוצרים',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF888888))),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ── selected-group bar (with back to types) ─────────────────────────────
  Widget _groupBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(children: [
        GestureDetector(
          onTap: () => setState(() {
            _group = null;
            _size = null;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: BsTokens.brand,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_group!.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(_group!.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800)),
              const SizedBox(width: 6),
              const Icon(Icons.close, color: Colors.white, size: 16),
            ]),
          ),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('בחר גודל:',
              style: TextStyle(fontSize: 13, color: Color(0xFF888888))),
        ),
      ]),
    );
  }

  // ── step 2: size chips ───────────────────────────────────────────────────
  Widget _sizeChips(List<String> sizes) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
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
            color: active ? BsTokens.brand : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: active ? BsTokens.brand : const Color(0x33888888)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: active ? Colors.white : null,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}
