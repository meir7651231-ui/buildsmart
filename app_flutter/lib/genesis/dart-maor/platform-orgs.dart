// ⚛️ אטום-Dart (דרגת-חוזה) · platformOrgs — שם-אוסף-השורש 'platformOrgs' (CLOUD2).
// מוצא: maor/src/lib/cloudConfig.ts:17-18 · המקור: new/atoms/platform-orgs.mjs
//        (`PLATFORM_ORGS`). קבוע-מחרוזת בלבד.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: שם-האוסף הקבוע. חוק-5 — המחרוזת לא יודעת שהיא "אוסף מסמכי-הארגונים";
//        הרכבת הנתיב `platformOrgs/{slug}` והקריאה מ-Firestore הן חיווט-הקופסה.
// קלט:  אין. פלט: String באורך 12, מקטע-נתיב יחיד (בלי '/').
//
// הערות-המרה (מקור→Dart):
//  • `export const PLATFORM_ORGS = 'platformOrgs'` → getter top-level שמחזיר `const`.
//    המנוע פלט `var PLATFORM_ORGS = ...` (מוטבילי + לא-top-level-נקי) — תוקן ל-getter
//    שמחזיר const, פיגמנט-קבוע ביט-זהה, בהתאם לדפוס entity-collections.
//  • נתון-קבוע בלבד — אין locale/פורמט/getMonth/truthiness/מודולו/תאריך.

/// The platform-orgs root collection name. Verbatim port of
/// new/atoms/platform-orgs.mjs (`PLATFORM_ORGS`).
String get platformOrgs => 'platformOrgs';
