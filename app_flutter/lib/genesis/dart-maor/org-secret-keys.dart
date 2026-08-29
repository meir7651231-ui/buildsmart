// ⚛️ אטום-Dart (דרגת-חוזה) · orgSecretKeys — רשימת-מפתחות-הסודות של הארגון.
// מוצא: maor/src/lib/cloudConfig.ts:138-142 · המקור: new/atoms/org-secret-keys.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). חוק-6: אלה שמות-שקעים, לא סודות עצמם.
//
// תפקיד: הרשימה הקבועה של ששת מפתחות-הסודות (yemotToken … solaXKey), בסדר-המקור בדיוק.
// קלט:  אין. פלט: List<String> באורך 6.
//
// הערות-המרה (מקור→Dart):
//  • `export const ORG_SECRET_KEYS = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותם שישה מחרוזות, אותו סדר (index 0='yemotToken' … 5='solaXKey').
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// The six fixed org secret-key names, in source order.
/// Verbatim port of new/atoms/org-secret-keys.mjs (`ORG_SECRET_KEYS`).
List<String> get orgSecretKeys => const [
      'yemotToken',
      'nedarimMosad',
      'nedarimApiPass',
      'smsApiKey',
      'smtpUrl',
      'solaXKey',
    ];
