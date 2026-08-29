// חוט · mat-cost-total — עלות-החומרים: סכום (כמות × מחיר-יחידה) של רשומות-החומרים.
// חוזה: new/atoms/mat-cost-total.contract.md · מוצא: maor/src/lib/ayin.ts:114-116.
// המרה מ-JS (new/atoms/mat-cost-total.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (רק dart-core). טהור, לא משנה קלט.
//
// הערות-המרה (JS→Dart, לפי DART-PORTING-RULES):
//  · המנוע פלט `(+m.qty || 0)` — אידיום-JS שלא קיים ב-Dart; שוכתב לשקע-כפיית-מספר.
//  · JS `+v`: מספר→עצמו · מחרוזת-מספרית→ערך · מחרוזת-זבל/undefined→NaN · null→0.
//    ואז `|| 0` הופך כל falsy (NaN/0) ל-0. ⇒ _num מחקה: num.tryParse (כלל 10),
//    כשל-פרסור/NaN ⇒ 0; null ו-מפתח-חסר ⇒ 0.
//  · `a.mat || []` — mat חסר/null ⇒ ריק. כאן: לא-List ⇒ 0 (אין מה לסכם).
num matCostTotal(Map a) {
  final mat = a['mat'];
  if (mat is! List) return 0;
  num total = 0;
  for (final m in mat) {
    final row = m is Map ? m : const {};
    total += _num(row['qty']) * _num(row['cost']);
  }
  return total;
}

// שקע-כפיית-מספר: מחקה את `+v || 0` של JS (מחרוזת-מספרית נספרת, זבל/חסר/null ⇒ 0).
num _num(Object? v) {
  if (v is num) return v; // 0 || 0 == 0 — אין הבדל בתוצאה
  if (v is String) {
    final p = num.tryParse(v);
    return p == null ? 0 : p;
  }
  return 0; // null / מפתח-חסר / טיפוס-אחר ⇒ +v הוא 0 או NaN, ואז ||0 ⇒ 0
}
