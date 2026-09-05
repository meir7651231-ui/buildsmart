// חוט · paid-in-range — סכום-ששולם-בטווח של שיבוץ (מגן-מספר). חוזה: new/atoms/paid-in-range.contract.md
// המרה מ-JS (new/atoms/paid-in-range.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// המקור: (e.payments || []).filter((p) => inRange(p.date, r))
//          .reduce((a, p) => a + (Number.isFinite(p.amount) ? p.amount : 0), 0).
// השכן inRange מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · אובייקטי-JS (e, p) ⇒ Map; גישת-שדה p.date/p.amount דרך המפה.
//  · `e.payments || []`: payments חסר/null ⇒ []. מערך-ריק ב-JS truthy ⇒ נשמר;
//    `(e['payments'] as List?) ?? const []` שקול (חסר-מפתח⇒null⇒[], ריק נשמר).
//  · `Number.isFinite(p.amount)` — **לא מקודד-מחדש-לקואורס**: אמת רק כשהערך הוא
//    מספר-סופי ממש. מחרוזת ('80') / bool / null אינם num ⇒ false ⇒ 0; NaN/Infinity
//    הם num אך לא-סופיים ⇒ false ⇒ 0. ‏`amt is num && amt.isFinite` שעתוק-אמת.
//  · אי-מוטביליות: reduce ⇒ fold מקומי; מערך-הקלט לא נוגע.
num paidInRange(
  Map<String, dynamic> e,
  Map<String, dynamic> r,
  bool Function(Object?, Map<String, dynamic>) inRange,
) {
  final List payments = (e['payments'] as List?) ?? const [];
  return payments.where((p) => inRange((p as Map)['date'], r)).fold<num>(0, (a, p) {
    final Object? amt = (p as Map)['amount'];
    return a + (amt is num && amt.isFinite ? amt : 0);
  });
}
