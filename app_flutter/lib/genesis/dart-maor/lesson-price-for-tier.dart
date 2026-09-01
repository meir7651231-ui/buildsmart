// ⚛️ אטום-Dart (דרגת-חוזה) · lessonPriceForTier — מחיר-לשיעור לפי רמת-ההנחה.
// מוצא: maor/src/components/courses/lib.ts:262-267 · המקור: new/atoms/lesson-price-for-tier.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: רמה '1'/'2'/'3' עם מחיר מוגדר-ואמת (truthy) ⇒ המחיר שלה; אחרת נפילה
//        למחיר המלא lessonPrice; חסר גם הוא ⇒ 0. מחיר-רמה 0 = falsy ⇒ נופל למלא.
// קלט:  c — אובייקט-חוג (Map) עם lessonPrice ו-lessonPrice1..3 אופציונליים;
//        tier — '' | '1' | '2' | '3'. פלט: num (₪ לשיעור).
//
// הערות-המרה (מקור→Dart):
//  • גישת-מאפיין `c.lessonPrice1` (JS) → אינדוקס-מפה `c['lessonPrice1']` (Dart);
//    מפתח-חסר ⇒ null (כמו undefined ב-JS).
//  • truthiness של JS (`c.lessonPrice1` / `c.lessonPrice || 0`) → שקע `_truthy`:
//    null/undefined · 0 · NaN · '' · false = falsy; מספר-לא-אפס = truthy. זהה-ביט
//    למקור, ובכך מחיר-רמה 0 נופל למלא (דוגמה 5). (DART-PORTING-RULES §7)

/// Lesson price for the chosen discount tier. Tier '1'/'2'/'3' with a defined,
/// truthy price ⇒ that price; otherwise falls back to the full `lessonPrice`,
/// and 0 when that is missing too. A tier price of 0 is falsy ⇒ falls to full.
/// Verbatim port of new/atoms/lesson-price-for-tier.mjs (`lessonPriceForTier`).
num lessonPriceForTier(Map<String, dynamic> c, String tier) {
  final p1 = c['lessonPrice1'];
  if (tier == '1' && _truthy(p1)) return p1 as num;
  final p2 = c['lessonPrice2'];
  if (tier == '2' && _truthy(p2)) return p2 as num;
  final p3 = c['lessonPrice3'];
  if (tier == '3' && _truthy(p3)) return p3 as num;
  final full = c['lessonPrice'];
  return _truthy(full) ? full as num : 0;
}

/// JS-truthiness socket: falsy for null/0/NaN/''/false, truthy otherwise.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  return true;
}
