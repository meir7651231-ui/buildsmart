// ⚛️ אטום-Dart (דרגת-חוזה) · templateForName
// מוצא: buildsmart/app_flutter/lib/logic/studio/component_palette.dart:254-270 (חוק-4 — לוגיקה verbatim).
// אחים-שסוקטו: הטיוטה כוללת גם `componentHe` (סוכר מעל templateFor) ותיעוד ל-`matchComponentType`
//        — אטומים נפרדים, לא הועתקו (רק היעד `templateForName` מקודם).
// אחים-שהוזרקו (חוק-3): ה-const-list `kComponentPalette` (:257) ⇒ שקע `palette`; הביטוי
//        `t.type.name` (‏:258 — שם-ה-enum) ⇒ שקע `typeName` (‏String Function(T));
//        `ComponentTemplate` הופשט לגנרי `T` (מקור נעדר).
//
// קלט:  name     — מחרוזת-שם לחיפוש (תיחתך trim תחילה).
//       palette  — שקע: רשימת התבניות בסדר.
//       typeName — שקע: שם-הסוג מתבנית (t ⇒ t.type.name).
// פלט:  name ריק-אחרי-trim ⇒ null; אחרת ⇒ התבנית הראשונה ש-typeName(t)==trim(name); אחרת null.

/// The first palette entry whose type-name equals `name.trim()`, or `null`
/// (blank name ⇒ `null`; no match ⇒ `null`; NEVER throws — fail-closed).
/// Verbatim behaviour of component_palette.dart:254-270 with palette + `typeName` injected.
T? templateForName<T>(
  String name, {
  required List<T> palette,
  required String Function(T) typeName,
}) {
  final n = name.trim();
  if (n.isEmpty) return null;
  for (final t in palette) {
    if (typeName(t) == n) return t;
  }
  return null;
}
