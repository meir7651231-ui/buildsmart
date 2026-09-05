// ⚛️ אטום-Dart (דרגת-חוזה) · lockZones — ערך-מערכת קבוע (צילום-ערך).
// מוצא: maor/src/lib/lock.ts:13-20 · המקור: new/atoms/lock-zones.mjs —
//        export const LOCK_ZONES = [
//          { key: 'wizard',     label: 'אשף ההרכבה' },
//          { key: 'settings',   label: 'הגדרות' },
//          { key: 'supporters', label: 'תורמים' },
//          { key: 'reports',    label: 'דוחות' },
//        ];
// טוהר: ערך top-level עצמאי, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: ברירת-מחדל להגנת-המנהל — האשף וההגדרות (הקונפיגורציה); רשימת האזורים
//        הנתונים-לנעילה עם התווית שלהם.
// קלט:  אין. פלט: רשימת רשומות {key,label} בסדר-מקור.
//
// הערת-המרה (מקור→Dart): ה-JS הוא מערך-קבוע של אובייקטים {key,label}; ב-Dart
// רשימה-literal קבועה `const` של מפות `Map<String,String>` שומרת על הסדר ועל
// זוגות-המפתח/ערך ⇒ ביט-זהה לצילום שבבדיקה (JSON.stringify של אותו מבנה).
// אין locale/פורמט/getMonth/truthiness/מוטביליות מעורבים — קבוע טהור, ללא שקעים.

/// Manager-protection lock zones — the assembly wizard, settings, supporters and
/// reports, each with its Hebrew label. Verbatim value of the JS source
/// new/atoms/lock-zones.mjs (`LOCK_ZONES`). Element order and key/label pairs are
/// preserved so the list is bit-identical to the JS snapshot.
const List<Map<String, String>> lockZones = [
  {'key': 'wizard', 'label': 'אשף ההרכבה'},
  {'key': 'settings', 'label': 'הגדרות'},
  {'key': 'supporters', 'label': 'תורמים'},
  {'key': 'reports', 'label': 'דוחות'},
];
