// חוט · max-discount-pct — אחוז-ההנחה האפקטיבי: הגבוה מבין קריטריוני-המוטב (0..100).
// המרה מ-JS (new/atoms/max-discount-pct.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חולץ כלשונו מ-maor/src/components/shop/lib.ts:116-123. אפס-import (dart-core + dart:math בלבד).
import 'dart:math';

num maxDiscountPct(List<String> criterionIds, List<Map<String, dynamic>> criteria) {
  num pct = 0;
  for (final id in criterionIds) {
    // JS: criteria.find(x => x.id === id) — undefined אם לא-קיים (⇒ null ב-Dart).
    Map<String, dynamic>? c;
    for (final x in criteria) {
      if (x['id'] == id) {
        c = x;
        break;
      }
    }
    // JS: if (c && Number.isFinite(c.discountPct) && c.discountPct > pct)
    // Number.isFinite כוזב על NaN/Infinity/לא-מספר ⇒ (dp is num && dp.isFinite).
    if (c != null) {
      final dp = c['discountPct'];
      if (dp is num && dp.isFinite && dp > pct) {
        pct = dp;
      }
    }
  }
  return min(100, max(0, pct));
}
