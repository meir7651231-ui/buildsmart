// ⚛️ אטום-Dart (דרגת-חוזה) · requeueOutcomes — תוצאות-חיוג לא-סופיות.
// מוצא: maor/src/lib/dialer.ts:9-10 (מנוע-החייגן — תוצאות שמחזירות מתקשר לסוף-התור) ·
//        המקור: new/atoms/requeue-outcomes.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של שתי התוצאות הלא-סופיות, בסדר-המקור בדיוק.
//        חוק-5 (טוהר): הרשימה לא יודעת שהיא "תוצאות שמחזירות מתקשר לסוף-התור" —
//        ההשוואה includes וסיבוב-התור הם חיווט-הקופסה (מנוע-החייגן).
// קלט:  אין. פלט: List<String> באורך 2 — ['noanswer', 'skip'].
//
// הערות-המרה (מקור→Dart):
//  • `export const REQUEUE_OUTCOMES = ['noanswer', 'skip']` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותם שני מחרוזות ASCII, אותו סדר (index 0='noanswer', 1='skip').
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד (DART-PORTING-RULES: כלום לא חל).

/// The two fixed non-terminal dialer outcomes, in source order.
/// Verbatim port of new/atoms/requeue-outcomes.mjs (`REQUEUE_OUTCOMES`).
List<String> get requeueOutcomes => const ['noanswer', 'skip'];
