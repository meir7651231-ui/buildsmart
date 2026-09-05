// ⚛️ אטום-Dart (דרגת-חוזה) · isGrantableFeature — האם מפתח הוא יכולת-הדלקה-פר-עובד.
// מוצא: maor/src/components/platform/lib.ts:194-196 · המקור: new/atoms/is-grantable-feature.mjs —
//        `export function isGrantableFeature(key, grantableSet) { return grantableSet.has(key); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: האם מפתח-דגל שייך לרשימה-הסגורה שעבורה true בכרטיס-העובד מדליק (החריג
//        היחיד; כל שאר המפתחות = הגבלה-בלבד). בדיקת-שייכות טהורה לשקע-הקבוצה.
// שקע (חוק-1): grantableSet — קבוצת-המפתחות (במקור הקבוע-שכן GRANTABLE_STAFF_FEATURES,
//        הוזרק כפרמטר). קלט: key (מחרוזת) · grantableSet. פלט: bool.
//
// הערת-המרה (מקור→Dart): ה-JS Set.has ⇒ Dart Set.contains (אותה סמנטיקת-שייכות).
// השוואה רגישת-רישיות (String equality של Dart = case-sensitive, כמו JS) ⇒ אין
// נירמול; '' לעולם אינו בקבוצה ⇒ false. אין locale/פורמט/getMonth/truthiness/מוטביליות.

/// Returns whether [key] is a per-staff grantable feature — i.e. it belongs to
/// the closed [grantableSet]. Verbatim behaviour of the JS source
/// `isGrantableFeature` (set-membership; case-sensitive, no normalization).
bool isGrantableFeature(String key, Set<String> grantableSet) {
  return grantableSet.contains(key);
}
