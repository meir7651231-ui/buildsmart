// Rough wholesale-grade ILS price estimates per catalog category. The catalog
// itself doesn't carry per-SKU pricing, so this is a category-level proxy
// good enough for a "budget ballpark" total on the BOM sheet. Real billing
// must always come from the supplier's price list — these numbers exist so
// the user can compare two alternative paths and pick the cheaper one.
//
// Numbers reflect mid-2025 Israeli plumbing-supply market for AQUATEC / Lipskey
// brand parts (mass-market wholesale, before contractor margin and VAT).

import 'package:buildsmart/data/lipskey_catalog.dart';

const Map<String, int> _categoryPriceILS = {
  // Brass / supply fittings (small, threaded)
  'אביזרי נחושת':          18,
  'אביזרי תבריג':          15,
  'אביזרי ברזים':          12,
  // HDPE / NTM compression — plastic, sized by DN
  'מחברי HDPE':            14,
  'מחברי NTM':             20,
  // Drainage pipes & sockets
  'צינורות אפורות':         28,
  'צינורות PP':            42,
  'צינורות גמישים':         55,
  'צינורות רב שכבתי':       65,
  'אביזרי שקע-תקע':         22,
  'ברכיים':                18,
  'סיפונים':               35,
  'מסעפים וחיבורי אסלה':     45,
  // Valves
  'ברזי מעבר':             65,
  'ברזי ניל':              45,
  'ברזי גן':               55,
  'ברזי דלי':              35,
  // Faucets — finished products
  'ברזי כיור':             280,
  'ברזי מטבח':             420,
  'ברזי קיר':              190,
  'ברזי אמבטיה':           520,
  'ברזי מקלחת':            390,
  // Shower system
  'ראשי מקלחת':            180,
  'מזלפי יד':              110,
  'זרועות דוש':             45,
  'צינורות מקלחת':           40,
  'אביזרי מקלחת':           28,
  'מערכות אמבטיה':         950,
  'ערכות רחצה':           1200,
  // Toilets & cisterns
  'אסלות וכיורים':         480,
  'מושבי אסלה':            150,
  'אביזרי אסלה':            55,
  'מערכות שטיפה':          320,
  'מנגנונים':              210,
  'חלקים סניטריים':         85,
  // Drainage points
  'מחסומים גלויים':         70,
  'מחסומי רצפה':           110,
  'מאספי רצפה':           160,
  'מאספים וקולטים':        140,
  'תעלות ניקוז':           250,
  'מכסים ורשתות':          85,
  'כיסויים':              50,
  'ניקוז גג':              190,
  'אביזרי ביוב':            65,
  'זקיף אסלה':             35,
  // Manifolds & water points
  'מחלקים':              480,
  'נקודות מים':           120,
  'אטמים ופקקים':           8,
  // Catch-all / Hot-water synthetic SKUs
  'מתאמי תבריג':          14,
};

class PriceEstimate {
  const PriceEstimate({
    required this.totalILS,
    required this.itemCount,
    required this.lowConfidence,
  });
  final int totalILS;
  final int itemCount;
  /// True when more than half the items had no category match — total is a
  /// very rough lower bound and the UI should label it accordingly.
  final bool lowConfidence;
}

/// Sum approximate price per the catalog category of each product. Quantities
/// are not folded in (the BOM may carry [qty] separately); pass the already-
/// expanded item list when you want a unit-count total.
PriceEstimate estimatePrice(List<LipskeyCatalogProduct> items) {
  if (items.isEmpty) {
    return const PriceEstimate(totalILS: 0, itemCount: 0, lowConfidence: true);
  }
  var total = 0;
  var matched = 0;
  for (final p in items) {
    final v = _categoryPriceILS[p.categoryHe];
    if (v != null) {
      total += v;
      matched++;
    } else {
      total += 25; // generic fallback so unmatched items still register
    }
  }
  final lowConf = matched < items.length / 2;
  return PriceEstimate(
      totalILS: total, itemCount: items.length, lowConfidence: lowConf);
}
