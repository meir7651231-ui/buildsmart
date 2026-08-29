// ⚛️ אטום-Dart (דרגת-חוזה) · applyAyinNames — שמות-מהייבוא לתיק-המעקב (ayin) פר-תומך.
// מוצא: maor/src/components/supporters/lib.ts:534-548 · המקור: new/atoms/apply-ayin-names.mjs —
//        `export function applyAyinNames(sp, names, mkId, emptyAyin, planAddName) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מוסיף לתיק-המעקב של תומך/ת את השמות שהגיעו מהייבוא. כפילות/שם-ריק
//        מדולגים בשקט — בלי לשרוף מזהה (בדיקת-היתכנות עם id='' לפני mkId).
//        תיק חסר נפתח (emptyAyin); eyes נשאר '' (ממתין לשלב-הטיפול).
//        בלי אף תוספת ⇒ מוחזר sp המקורי (אותה הפניה). טהור — אימוטביליות המקור נשמרת.
// שקעים (חוק-1): mkId()→מזהה חדש · emptyAyin()→תיק-ריק · planAddName(a,rawName,eyes,id)→
//        {ok:true,names}|{ok:false,error} (dedup לפי שם-מנורמל; ריק ⇒ ok:false).
// קלט: sp (Map, 'ayin' אופציונלי) · names (List<String>) · שלושת השקעים.
// פלט: Map — תומך/ת חדש/ה עם 'ayin' מעודכן, או sp עצמו כשאין שינוי.
//
// הערת-המרה (מקור→Dart):
//   * אין locale/פורמט/getMonth מעורבים.
//   * `sp.ayin ?? emptyAyin()` — nullish-coalescing ⇒ `sp['ayin'] ?? emptyAyin()` (null בלבד ב-Dart).
//   * truthiness: ה-JS `if (!plan.ok)` על תוצאה בוליאנית ⇒ `plan['ok'] != true`;
//               `if (plan.ok)` ⇒ `plan['ok'] == true`.
//   * `{ ...a, names: ... }` / `{ ...sp, ayin: a }` ⇒ spread של Map ⇒ מפה חדשה, המקור נשמר.
//   * `a`/`changed` משתנים (מוקצים-מחדש) ⇒ var; שאר הערכים final.
//   * ההחזרה כשאין שינוי היא `sp` עצמו ⇒ identical(out, sp) נשמר.

/// Adds imported [names] to the supporter [sp]'s tracking file (`ayin`).
/// Verbatim behaviour of the JS source new/atoms/apply-ayin-names.mjs
/// (`applyAyinNames`). Empty/duplicate names are skipped silently without
/// burning an id (feasibility probe with id=''). Returns [sp] unchanged (same
/// reference) when nothing was added. [mkId], [emptyAyin], [planAddName] are
/// injected sockets (חוק-1 — no internal imports).
Map<String, dynamic> applyAyinNames(
  Map<String, dynamic> sp,
  List<String> names,
  String Function() mkId,
  Map<String, dynamic> Function() emptyAyin,
  Map<String, dynamic> Function(
    Map<String, dynamic> a,
    String rawName,
    String eyes,
    String id,
  ) planAddName,
) {
  var a = (sp['ayin'] as Map<String, dynamic>?) ?? emptyAyin();
  var changed = false;
  for (final nm in names) {
    // כפילות/ריק — דילוג שקט, בלי לשרוף מזהה
    if (planAddName(a, nm, '', '')['ok'] != true) continue;
    final plan = planAddName(a, nm, '', mkId());
    if (plan['ok'] == true) {
      a = {...a, 'names': plan['names']};
      changed = true;
    }
  }
  return changed ? {...sp, 'ayin': a} : sp;
}
