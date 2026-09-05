/// חוט · component-remaining — הנותר במלאי לרכיב מוצר-חנות.
/// המרה נאמנה מ-new/atoms/component-remaining.mjs (חוק-4: המקור קדוש).
/// חולץ כלשונו מ-maor/src/components/shop/lib.ts:200-220 (SHOP2).
/// השכן liveRedemptions הוזרק כשקע (חוק-1 — אפס import פנימי).
///
/// מיפוי JS→Dart: stock===undefined ⇒ stock==null (num?); ה-null מייצג
/// "אין מעקב-מלאי", stock=0 הוא ערך-מעקב תקין. liveRedemptions הוא שקע-פונקציה
/// שמחזיר את המימושים החיים של שיוך (המקור מסנן voidedAt). ההשוואות שומרות
/// על סמנטיקת === של המקור (שוויון-ערך).
num? componentRemaining(
  Object? componentId,
  Object? productId,
  List<dynamic> assignments,
  num? stock,
  List<dynamic> Function(dynamic a) liveRedemptions,
) {
  if (stock == null) return null;
  var used = 0;
  for (final a in assignments) {
    if ((a as dynamic).productId != productId) continue;
    for (final r in liveRedemptions(a)) {
      if ((r as dynamic).componentId == componentId) used++;
    }
  }
  final remaining = stock - used;
  return remaining > 0 ? remaining : 0;
}
