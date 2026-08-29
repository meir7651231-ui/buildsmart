// ⚛️ אטום-Dart (דרגת-חוזה) · compliance
// מוצא: buildsmart/app_flutter/lib/logic/install_engine.dart:972-973
//        (‏InstallationPlan.compliance; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט). האטום
//        הוא האצלה-טהורה: מעביר את הארגומנטים לשקע-הבדיקה ומחזיר את תוצאתו כפי-שהיא.
//
// שקעים שהוזרקו (קריאה-לשכן / שדה-מחלקה ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `items` — שדה-המחלקה InstallationPlan.items (install_engine.dart:945),
//               הנקרא ומועבר כארגומנט-ראשון לבדיקה (:973) ⇒ שקע-קלט `items`.
//   • `lineComplianceChecklist` — הפונקציה-השכנה (install_engine.dart:194)
//               הנקראת ב-:973 ⇒ שקע-פונקציה `checklist`. חתימת-המקור:
//               ‏lineComplianceChecklist(items, tempC, accessories) — סדר-הארגומנטים נשמר.
// טוהר-גנרי: LineCheck / LipskeyCatalogProduct הם טיפוסי-דומיין; ההאצלה עצמה
//        אגנוסטית-לטיפוס ⇒ גנריקה <P, C> (‏P=פריט, C=בדיקה). זו ההתנהגות-בדיוק
//        (מסירת-דרך), לא שיפור.
//
// קלט:  tempC        — טמפרטורת-הפעלה (int; במקור מועבר verbatim לבדיקה, לא נבדק כאן).
//       items        — שקע: פריטי-ההתקנה (List<P>), הארגומנט-הראשון לבדיקה.
//       checklist    — שקע: List<C> Function(List<P> items, int tempC, Set<String> accessories).
//       accessories  — Set<String>; ברירת-מחדל const {} (install_engine.dart:972).
// פלט:  List<C> — בדיוק תוצאת checklist(items, tempC, accessories) (אותה הפניה, ללא-העתקה).

/// Compliance checklist for a plan at [tempC] — verbatim delegation of
/// install_engine.dart:972-973. Passes `items`, `tempC`, `accessories` (in that
/// order) to the injected [checklist] and returns its result unchanged.
List<C> compliance<P, C>(
  int tempC, {
  required List<P> items,
  required List<C> Function(List<P> items, int tempC, Set<String> accessories)
      checklist,
  Set<String> accessories = const {},
}) =>
    checklist(items, tempC, accessories);
