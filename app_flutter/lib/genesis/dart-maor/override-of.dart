// ⚛️ אטום-Dart (דרגת-חוזה) · overrideOf — כרטיס-העובד של מייל ממסמך-הארגון (ריק כשאין).
// מוצא: maor/src/components/platform/lib.ts:170-172 · המקור: new/atoms/override-of.mjs —
//        `return org.memberConfigs?.[normEmail(email)] ?? {};`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: שולף את כרטיס-ההגדרות-הפר-מייל (memberConfigs[normEmail(email)]) ממסמך-הארגון.
//        אין memberConfigs, אין ערך, או ערך null ⇒ מפה-ריקה חדשה {}. יש ערך ⇒ אותה רפרנס.
// שקע (חוק-1): normEmail — פונקציית-נירמול (trim+lowercase במקור), הוזרקה כפרמטר (אפס import פנימי).
// קלט: email (מחרוזת) · org (מפת-הארגון) · normEmail (שקע-נירמול). פלט: Map — הכרטיס או {}.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • ‏?.[] של JS על memberConfigs חסר ⇒ בדיקת `is! Map` (org בלי memberConfigs / לא-מפה ⇒ {}).
//  • ‏`?? {}` תופס במקור גם undefined (מפתח חסר) וגם null. ב-Dart `mc[key]` מחזיר null בשני
//    המקרים כאחד ⇒ `v == null` נכון כאן (זהו ??, לא ===undefined; כלל-2 לא חל — רצוי לתפוס שניהם).
//  • זהות-רפרנס נשמרת: ערך-קיים מוחזר כמו-שהוא (=== של JS ⇒ identical ב-Dart). {} = מפה חדשה.
//  • אין locale/פורמט/getMonth/מודולו-שלילי/substring — המרה מבנית טהורה.

/// Returns the per-email member override card from the org document, or an empty
/// map when there is no `memberConfigs`, no entry, or a null entry.
/// Verbatim behaviour of the JS source `org.memberConfigs?.[normEmail(email)] ?? {}`.
Map overrideOf(String email, Map org, String Function(String) normEmail) {
  final mc = org['memberConfigs'];
  if (mc is! Map) return {};
  final v = mc[normEmail(email)];
  if (v == null) return {};
  return v as Map;
}
