// ⚛️ אטום-Dart (דרגת-חוזה) · componentRedeemedNow — האם רכיב-שיוך מומש עכשיו
// (מתנת-חג: פר-שנה-עברית). מוצא: maor/src/components/shop/lib.ts:466-481 ·
// המקור: new/atoms/component-redeemed-now.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מתנת-חג ('holidayGift') נבחנת מול מופע-החג הראשון-המותר ברשימה (הכרעה 17);
//        כל שאר המקרים — רכיב שאינו מתנת-חג, מתנת-חג בלי חג-מותר, ובלי holidays —
//        נופלים לנתיב-המימוש ההיסטורי (בלי מופע-חג).
// שקעים (חוק-1): itemOf(db, comp) → הפריט · holidayAllowed(ri, name) → bool ·
//        assignmentRedeemed(a, compId, [holiday]) → הכרעת-המימוש (במקור שכנים שהוזרקו).
// קלט: db · a · comp ({id}) · holidays (List|null) · שלושת השקעים.
// פלט: הערך שמחזיר assignmentRedeemed (bool במקור).
//
// הערות-המרה (מקור→Dart):
//   · truthiness — JS `if (holidays)` שוקף ב-_truthy (null=כוזב, List=אמת; גם List ריקה=אמת כמו-JS).
//   · `.find(pred)` → לולאה עם break: עצירה-במופע-הראשון-המותר, זהה למקור; לא-נמצא ⇒ null (=undefined).
//   · `if (next)` → next הוא Map-חג או null; אובייקט תמיד-truthy ב-JS ⇒ `next != null` נאמן.
//   · property-access `comp.id`/`ri.kind`/`h.name` → Map-access (מוסכמת-הפורט).
//   · קריאה בת-2-ארגומנטים `assignmentRedeemed(a, comp.id)` → הפרמטר השלישי null
//     (מקביל ל-undefined של JS). אין locale/פורמט/getMonth/מוטביליות בקוד-זה.

/// כפייה-לבוליאני נאמנה ל-JS `if (x)`: null/false/0/NaN/'' כוזב, השאר אמת.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true; // Map / List / כל אובייקט = truthy במקור-ה-JS
}

/// מחזיר את הכרעת-המימוש של רכיב-השיוך. התנהגות זהה-ביט למקור-ה-JS.
Object? componentRedeemedNow(
  Object? db,
  Object? a,
  Object? comp,
  Object? holidays,
  Map Function(Object?, Object?) itemOf,
  bool Function(Object?, Object?) holidayAllowed,
  Object? Function(Object?, Object?, [Object?]) assignmentRedeemed,
) {
  final compId = (comp as Map)['id'];
  if (_truthy(holidays)) {
    final ri = itemOf(db, comp);
    if (ri['kind'] == 'holidayGift') {
      // חגים נבחרים (הכרעה 17) — רק חג שסומן על הפריט רלוונטי
      Object? next;
      for (final h in (holidays as List)) {
        if (holidayAllowed(ri, (h as Map)['name'])) {
          next = h;
          break;
        }
      }
      if (next != null) return assignmentRedeemed(a, compId, next);
    }
  }
  return assignmentRedeemed(a, compId);
}
