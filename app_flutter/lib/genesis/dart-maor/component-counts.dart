/// חוט · component-counts — ספירת רכיבי מוצר-חנות לפי סוג.
/// המרה נאמנה מ-new/atoms/component-counts.mjs (חוק-4: המקור קדוש).
/// מחזיר תמיד את ארבעת הסוגים (meeting/coupon/gift/holidayGift), גם כשהספירה 0.
/// אפס import (dart-core בלבד).
Map<String, int> componentCounts(Map<String, dynamic> p) {
  final out = <String, int>{'meeting': 0, 'coupon': 0, 'gift': 0, 'holidayGift': 0};
  for (final c in (p['components'] as List)) {
    final kind = (c as Map)['kind'] as String;
    out[kind] = (out[kind] ?? 0) + 1;
  }
  return out;
}
