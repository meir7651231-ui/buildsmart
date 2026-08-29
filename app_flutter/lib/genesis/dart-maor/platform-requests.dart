// ⚛️ אטום-Dart (דרגת-חוזה) · platformRequests — שם-אוסף (CLOUD2).
// מוצא: maor/src/lib/cloudConfig.ts:19-20 (PLATFORM_REQUESTS) · המקור: new/atoms/platform-requests.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש); חוק-5 — ערך בלבד, ללא ידע-הקשר.
//
// תפקיד: הקבוע 'platformRequests' — שם אוסף-שורש ייעודי. ערך בלבד: המחרוזת
//        לא יודעת שהיא "בקשות הרשמה"; הרכבת הנתיב וזרימת האישור = חיווט-הקופסה.
// קלט:  אין. פלט: String קבוע 'platformRequests' (אורך 16, בלי '/').
//
// הערות-המרה (מקור→Dart):
//  • `export const PLATFORM_REQUESTS = 'platformRequests'` → getter top-level
//    שמחזיר `const` String. אין locale/פורמט/getMonth/truthiness/מודולו —
//    מחרוזת-קבועה טהורה. הטיוטה מהמנוע (`var PLATFORM_REQUESTS = '...'`) הוחלפה
//    ב-getter-const כדי לשמור טוהר-קריאה בלי משתנה-מודול מוטבילי.

/// The dedicated root-collection name `'platformRequests'` (CLOUD2).
/// Verbatim port of new/atoms/platform-requests.mjs (`PLATFORM_REQUESTS`).
String get platformRequests => 'platformRequests';
