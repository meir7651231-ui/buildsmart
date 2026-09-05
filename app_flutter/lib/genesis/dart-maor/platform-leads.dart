// ⚛️ אטום-Dart (דרגת-חוזה) · platformLeads — שם אוסף-הלידים בענן ('platformLeads').
// מוצא: maor/src/lib/cloudConfig.ts (`PLATFORM_LEADS`, "אוסף לידים — נחזור אליכם";
//        create-only ציבורי, קריאה למיילי-על) · המקור: new/atoms/platform-leads.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: המחרוזת הקבועה 'platformLeads' — ערך בלבד (חוק-5): המחרוזת לא יודעת שהיא
//        "אוסף Firestore"; הפנייה-לענן היא חיווט-קופסה. מקטע-נתיב יחיד (בלי '/').
// קלט:  אין (קבוע). פלט: String באורך 13.
//
// הערות-המרה (מקור→Dart):
//  • `export const PLATFORM_LEADS = 'platformLeads'` → getter top-level שמחזיר `const`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור.
//    (המנוע פלט `var PLATFORM_LEADS = 'platformLeads'` — mutable; תוקן ל-const-getter
//    כדי לשמר את חוסר-המוטביליות של `const` שבמקור, בעקבות תקדים all-modules.)
//  • תוכן מועתק כלשונו — אותו literal בדיוק. אין locale/פורמט/getMonth/truthiness/מודולו.

/// The cloud leads-collection name — the constant string 'platformLeads'.
/// Verbatim port of new/atoms/platform-leads.mjs (`PLATFORM_LEADS`).
String get platformLeads => 'platformLeads';
