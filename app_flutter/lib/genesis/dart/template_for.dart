// ⚛️ אטום-Dart (דרגת-חוזה) · templateFor
// מוצא: buildsmart/app_flutter/lib/logic/studio/component_palette.dart:245-253 (חוק-4 — לוגיקה verbatim).
// אחים-שהוזרקו (חוק-3): ה-const-list `kComponentPalette` (נסרקת, :246) ⇒ שקע `palette`;
//        הטיפוסים `ComponentTemplate`/`ComponentType` (מקור נעדר) הופשטו לגנריים `T`/`K`,
//        וההשוואה `t.type == type` ⇒ שקע `typeOf` (‏K Function(T)). אפס-import, אפס-const-קשיח.
//
// קלט:  type     — ערך-סוג לחיפוש (K).
//       palette  — שקע: רשימת התבניות בסדר (List<T>).
//       typeOf   — שקע: מיצוי הסוג מתבנית (t ⇒ t.type).
// פלט:  התבנית הראשונה ש-typeOf(t) שווה ל-type; אם אין ⇒ null (fail-closed, לא זריקה).

/// The first palette entry whose type equals [type], or `null` when none.
/// Verbatim behaviour of component_palette.dart:245-253 with the palette + the
/// `.type` reader injected (the concrete `ComponentTemplate`/`ComponentType`
/// neighbour types are abstracted to `T`/`K`).
T? templateFor<T, K>(
  K type, {
  required List<T> palette,
  required K Function(T) typeOf,
}) {
  for (final t in palette) {
    if (typeOf(t) == type) return t;
  }
  return null;
}
