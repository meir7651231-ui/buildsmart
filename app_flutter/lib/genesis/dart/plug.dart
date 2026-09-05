// ⚛️ אטום-Dart (דרגת-חוזה) · plug
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/fitting_dims.dart:122-128 (חצב-בינה · חוק-3/4).
// שקע: base ← השכן `base(od)` — מפת-הממדים הבסיסית של אביזר-ריתוך (OD·wall·ID·B·C·F).
//       r1  ← השכן `r1(x)` — עיגול half-to-even לספרה-עשרונית אחת.
// גיאומטריית פקק PP-R: אורך-כולל A = F + 0.4·OD, אורך-כיפה cap = 0.4·OD.

Map<String, double> plug(int od,
    {required Map<String, double> Function(int) base,
    required double Function(double) r1}) {
  final b = base(od);
  b['A'] = r1(b['F']! + od * 0.4); // אורך-כולל
  b['cap'] = r1(od * 0.4); // אורך-הכיפה
  return b;
}
