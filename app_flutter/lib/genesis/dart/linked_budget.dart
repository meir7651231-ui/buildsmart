// ⚛️ אטום-Dart (דרגת-חוזה) · linkedBudget
// מוצא: buildsmart/app_flutter/lib/data/phaseb_seeds.dart:421-426 (חצב-בינה · חוק-3/4).
// שקע: buildIndexDeltaPct ← השכן `buildIndexDeltaPct()` — אחוז-שינוי מדד-הבנייה (double).
// תקציב צמוד-מדד — round(total*(1+pct/100)). index.html:19524 (`finIndex`).

int linkedBudget(int budget, {required double Function() buildIndexDeltaPct}) =>
    (budget * (1 + buildIndexDeltaPct() / 100)).round();
