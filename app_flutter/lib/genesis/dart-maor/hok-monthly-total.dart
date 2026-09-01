// ⚛️ אטום-Dart (דרגת-חוזה) · hokMonthlyTotal — סה"כ הו"ק חודשי פעיל בש"ח-שקול.
// מוצא: maor/src/components/supporters/lib.ts:734-742 · המקור: new/atoms/hok-monthly-total.mjs
// חוזה: new/atoms/hok-monthly-total.contract.md · טוהר: פונקציית top-level, אפס import (dart-core).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// המקור (JS):
//   const active = (sp) => (todayIso ? hokEffectivelyActive(sp, todayIso) : !!sp.hok?.active);
//   return Math.round(supporters.reduce((a, sp) => {
//     if (!active(sp) || !sp.hok) return a;
//     return a + (sp.hok.cur === '$' ? sp.hok.amount * usdRate : sp.hok.amount);
//   }, 0));
//
// שקע (חוק-1, הוזרק כפרמטר במקום קריאת-שכן):
//   hokEffectivelyActive : (sp, todayIso) ⇒ bool — נקרא **רק** כש-todayIso "אמיתי" (truthy).
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · אובייקטי-JS (sp, hok) ⇒ Map; גישת-שדה sp.hok?.active/amount/cur דרך המפה.
//  · truthiness (כלל-7): `todayIso ?` ו-`!active(sp)` הם falsy-של-JS, לא bool-של-Dart —
//    מחרוזת-ריקה/null/undefined = falsy. שקע `_truthy` מחקה את המקור; active מחזיר
//    bool דרך _truthy ⇒ `!active` שקול ל-`!<falsy-של-הערך-הגולמי>` במקור.
//  · `!!sp.hok?.active` (else-ענף): hok חסר או active חסר/falsy ⇒ false — hok['active']
//    דרך _truthy (null≠undefined, כלל-2 — בודקים falsy-של-הערך, לא נוכחות-מפתח).
//  · `!sp.hok` (המקור): hok חסר/null ⇒ דילוג. במפה: hok שאינו Map ⇒ דילוג.
//  · Math.round (כלל: half-up כלפי +∞) = `(x + 0.5).floor()`, לא `num.round()`
//    (ש-half-away-from-zero; נבדל בחצאים-שליליים). 36.85 ⇒ floor(37.35) = 37.
//  · אי-מוטביליות: reduce ⇒ fold מקומי; מערך-הקלט לא נוגע.

/// Falsy-of-JS: null/false/מחרוזת-ריקה/0/NaN ⇒ false; אחרת true.
/// מחקה את `todayIso ?`, `!active(sp)` ו-`!!sp.hok?.active` של המקור.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// Math.round של JS: half-up כלפי +∞ (לא half-away-from-zero של num.round).
int _round(num x) => (x + 0.5).floor();

/// Total active monthly standing-order income in shekel-equivalent, rounded.
/// Without [todayIso] "active" = the `hok.active` flag only; with a truthy
/// [todayIso] "active" flows through the injected [hokEffectivelyActive] socket
/// (which is called only then). Verbatim behaviour of the JS source
/// `hokMonthlyTotal`. Input list is never mutated.
int hokMonthlyTotal(
  List supporters,
  num usdRate, [
  Object? todayIso,
  bool Function(dynamic, dynamic)? hokEffectivelyActive,
]) {
  bool active(dynamic sp) {
    if (_truthy(todayIso)) {
      return _truthy(hokEffectivelyActive!(sp, todayIso));
    }
    final hok = sp['hok'];
    if (hok is Map) return _truthy(hok['active']);
    return false;
  }

  num sum = 0;
  for (final sp in supporters) {
    final hok = sp['hok'];
    if (!active(sp) || hok is! Map) continue;
    final amount = hok['amount'] as num;
    sum += hok['cur'] == '\$' ? amount * usdRate : amount;
  }
  return _round(sum);
}
