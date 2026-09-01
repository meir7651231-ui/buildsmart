// ⚛️ אטום-Dart (דרגת-חוזה) · activeDriver — בורר נהג-החיוג הפעיל.
// מוצא: maor/src/lib/telephony/driver.ts:45-48 · המקור: new/atoms/active-driver.mjs —
//        `export function activeDriver(manualDriver) { return manualDriver; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: המדיניות הנוכחית (downstream) = תמיד הנהג-הידני; מוחזר כמו-שהוא, אותה
//        רפרנס בדיוק, בלי העתקה ובלי שינוי. בחירת-נהג-לפי-קונפיג = חיווט-קופסה עתידי.
// שקע (חוק-1): manualDriver — אובייקט-הנהג-הידני (במקור קבוע-שכן שהוזרק כפרמטר).
// קלט: השקע manualDriver. פלט: אותו ערך בדיוק (===  ⇒  identical ב-Dart).
//
// הערת-המרה (מקור→Dart): ה-JS עיוור-לתוכן (מחזיר גם מספר-זקיף 7). כדי לשמר
// זהות-רפרנס לכל טיפוס (Map או int), החתימה `Object? → Object?` והזהות נבדקת
// ב-identical (מקביל ל-=== של JS). אין locale/פורמט/getMonth/truthiness/מוטביליות.

/// Returns the active dial driver. Current policy (downstream): always the manual
/// driver — returned as-is, the exact same reference, no copy, no mutation.
/// Verbatim behaviour of the JS source `activeDriver` (identity function).
Object? activeDriver(Object? manualDriver) {
  return manualDriver;
}
