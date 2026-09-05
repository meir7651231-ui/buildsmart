// ⚛️ אטום-Dart (דרגת-חוזה) · orgEnabledModules — המודולים הדלוקים בארגון (רק false מכבה).
// מוצא: maor/src/components/platform/lib.ts (ALL_MODULES שוקע) · המקור: new/atoms/org-enabled-modules.mjs —
//        `allModules.filter((m) => orgConfig.modules?.[m] !== false)`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מסנן את מרשם-המודולים (allModules, שקע) — מודול נשאר דלוק אלא אם
//        orgConfig.modules[m] הוא בדיוק false. חסר / null / true / ריק ⇒ דלוק.
// שקעים (חוק-1): orgConfig (קונפיג-הארגון) · allModules (מרשם-המודולים).
//
// הערות-המרה (מקור→Dart):
//  • optional-chaining `orgConfig.modules?.[m]`: אם modules חסר/לא-Map ⇒ הערך undefined,
//    ו-`undefined !== false` ⇒ true (המודול נשאר). ב-Dart: `modules is Map ? modules[m] : null`.
//  • השוואת JS `!== false` היא strict: רק הערך-הבוליאני false מכבה. null/undefined/true/מספר
//    כולם `!= false` ⇒ true. ב-Dart `v != false` נותן אותה תוצאה (null!=false⇒true).
//    לכן אין צורך בהבחנת null≠undefined (כלל-2): שני המצבים נשארים דלוקים גם ב-JS.
//  • filter מחזיר List חדשה סדורה; ב-Dart `.where(...).toList()` (לא Iterable עצל).
//  אין locale/פורמט/getMonth/מודולו/substring — רק סינון-שוויון.

/// Returns the org's enabled modules: every module from [allModules] stays on
/// unless `orgConfig['modules'][m]` is exactly `false`. Missing map, missing key,
/// null, true, or a non-map `modules` all leave the module enabled — verbatim
/// behaviour of the JS source `orgEnabledModules`.
List<String> orgEnabledModules(Map orgConfig, List<String> allModules) {
  final modules = orgConfig['modules'];
  return allModules.where((m) {
    final v = (modules is Map) ? modules[m] : null;
    return v != false;
  }).toList();
}
