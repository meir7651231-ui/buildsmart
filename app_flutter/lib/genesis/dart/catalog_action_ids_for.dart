// ⚛️ אטום-Dart (דרגת-חוזה) · catalogActionIdsFor
// מוצא: buildsmart/app_flutter/lib/logic/studio/action_catalog.dart:280-286
//        (‏catalogActionIdsFor; חוק-4 — התנהגות זהה בדיוק, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק שפה/סטנדרט — Set literal).
//
// שקע שהוזרק (קריאה-לשכן ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • kActionCatalog (action_catalog.dart:283) — הקטלוג-השכן הגלובלי. המקור סורק
//     אותו וקורא שני שדות בלבד לכל פריט: `a.id` (String) ו-`a.mutates` (bool).
//     לכן הוא קורס לשקע `catalog` — Iterable של מחזיק-קלט טהור `CatalogAction`
//     (id · mutates). אפס תלות ב-ActionDescriptor / ב-enum / בשדות האחרים.
//
// קלט:  elementId — מזהה-האלמנט. ריק/רווחים-בלבד (אחרי trim) ⇒ fail-closed.
//       readOnly  — true = הקשר-קריאה-בלבד: לעולם לא חושף מוטטור.
//       catalog   — שקע: הקטלוג-הסגור, כל פריט (id · mutates).
// פלט:  Set<String> — ה-id-ים החוקיים להקשר-העריכה של האלמנט (בסדר-הכנסה).
//
// התנהגות (verbatim · action_catalog.dart:281-285):
//   • elementId.trim().isEmpty ⇒ Set ריק (fail-closed).
//   • אחרת ⇒ כל id שעבורו NOT(readOnly && mutates):
//       readOnly=false ⇒ כל ה-id-ים; readOnly=true ⇒ בלי המוטטורים.
//   • elementId אינו משמש מעבר לבדיקת-הריקוּת (זהה למקור — לא "משפרים").

/// מחזיק-קלט טהור: רק שני השדות ש-catalogActionIdsFor קורא מכל
/// ActionDescriptor (action_catalog.dart:283-284). id = מזהה-הפעולה הסגור;
/// mutates = האם הפעולה כותבת state-עסקי (רק `cart.add` כזה).
class CatalogAction {
  final String id;
  final bool mutates;
  const CatalogAction({required this.id, this.mutates = false});
}

/// תת-קבוצת-הקטלוג החוקית להקשר-העריכה של אלמנט — התנהגות verbatim של
/// action_catalog.dart:280-286. הקשר-קריאה-בלבד ([readOnly]=true) לעולם לא
/// חושף מוטטור; הקשר-כתיבה רואה את הקטלוג במלואו. [elementId] ריק ⇒ fail-closed.
Set<String> catalogActionIdsFor(
  String elementId, {
  required bool readOnly,
  required Iterable<CatalogAction> catalog,
}) {
  if (elementId.trim().isEmpty) return const <String>{}; // fail-closed
  return {
    for (final a in catalog)
      if (!(readOnly && a.mutates)) a.id,
  };
}
