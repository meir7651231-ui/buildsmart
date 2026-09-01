// ⚛️ אטום-Dart (דרגת-חוזה) · orgEnabledFeatures — תת-הדגלים שהמנהל מחלק לעובדות (עקרון-התקרה).
// מוצא: המקור new/atoms/org-enabled-features.mjs (חולץ כלשונו מ-maor/src/components/platform/lib.ts;
//        קריאות-השכנים allModules/orgEnabledModules שוקעו לפרמטרים).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// שקעים (מוזרקים ע"י הקופסה):
//   allModules          — List<String> של מזהי-המודולים הקיימים במרשם.
//   orgEnabledModules   — פונקציה (orgConfig, allModules) => List<String> של המודולים הדלוקים לארגון.
//
// הערות-המרה (מקור→Dart) — כללי DART-PORTING-RULES שהוחלו:
//  • כלל-2 (null≠undefined): במקור `orgConfig.features?.[f.key]` — optional-chaining.
//    ב-Dart המפה עשויה להיות null (מפתח חסר) ⇒ `feats is Map ? feats[key] : null`.
//    הן ל-opt-in (`== true`) והן לרגיל (`!= false`) הערך null מתנהג בדיוק כמו undefined ב-JS:
//    `undefined === true` ≡ `null == true` == false ; `undefined !== false` ≡ `null != false` == true.
//  • כלל-7 (truthiness): המקור משתמש ב-`=== true`/`!== false` — השוואות-שוויון מדויקות, לא
//    truthiness-של-JS. ‏Dart `== true`/`!= false` מזהות רק את הבוליאני האמיתי ⇒ שקע-זהה
//    (קלט `1` אינו מדליק opt-in; ‏`1 != false` == true נשאר דלוק לרגיל — כמו JS).
//  • זהות-הפלט: `filter` ב-JS מחזיר מערך עם **אותן הפניות**. ‏`.where(...).toList()` שומר
//    את אותן הפניות-מפה ⇒ `identical(result[0], A)` (חוזה: "אותם אובייקטים בפלט").
//  • מוטביליות: `final` בלבד; אין הקצאה-מחדש.

/// Filter [features] to those a manager may hand to staff, honoring the module
/// ceiling and opt-in / regular flag contracts. Verbatim port of
/// new/atoms/org-enabled-features.mjs — identical behavior to the JS source.
List<Map<String, dynamic>> orgEnabledFeatures(
  Map<String, dynamic> orgConfig,
  List<Map<String, dynamic>> features,
  List<String> allModules,
  List<String> Function(Map<String, dynamic> orgConfig, List<String> allModules)
      orgEnabledModules,
) {
  final enabledMods = orgEnabledModules(orgConfig, allModules).toSet();
  return features.where((f) {
    final isRealModule = allModules.contains(f['module']);
    if (isRealModule && !enabledMods.contains(f['module'])) {
      return false; // מודול-אב כבוי
    }
    final feats = orgConfig['features'];
    final val = feats is Map ? feats[f['key']] : null;
    // דגל-opt-in: חסר = כבוי — רק true מפורש מדליק (כמו `=== true` במקור).
    if (f['optIn'] == true) return val == true;
    // דגל רגיל: רק false מכבה (כמו `!== false` במקור); חסר/כל-ערך-אחר = דלוק.
    return val != false;
  }).toList();
}
