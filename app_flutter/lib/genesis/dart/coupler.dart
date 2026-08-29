// ⚛️ אטום-Dart (דרגת-חוזה) · coupler
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/fitting_dims.dart:72-77 (חצב-בינה · חוק-3/4).
// שקע: base ← השכן `base(od)` — מפת-הממדים הבסיסית של אביזר-ריתוך (OD·wall·ID·B·C·F).
//       r1  ← השכן `r1(x)` — עיגול half-to-even לספרה-עשרונית אחת.
// גיאומטריית מצמד PP-R: אורך A = 2·עומק-שקע (F) + מעצור-מרכז (2). מוסיף 'A' על-הבסיס.

Map<String, double> coupler(int od,
    {required Map<String, double> Function(int) base,
    required double Function(double) r1}) {
  final b = base(od);
  b['A'] = r1(2 * b['F']! + 2); // 2 שקעים + מעצור-מרכז
  return b;
}
