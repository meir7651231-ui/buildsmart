// ⚛️ אטום-Dart (דרגת-חוזה) · priLabels — תוויות-עדיפות קבועות למשימות.
// מוצא: maor/src/lib/worktasks.ts:65-71 (תורגם TS→JS מכונה) · המקור: new/atoms/pri-labels.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: המפה הקבועה priority→label, שלוש רמות בסדר-המקור בדיוק.
// קלט:  אין. פלט: Map<String,String> באורך 3 — {'1':'🔴 דחוף','2':'🟡 רגיל','3':'⚪ בהמשך'}.
//
// הערות-המרה (מקור→Dart):
//  • מקור-JS: `export const PRI_LABELS = { 1: '🔴 דחוף', 2: '🟡 רגיל', 3: '⚪ בהמשך' };`.
//    מפתחות-אובייקט ב-JS הם **מחרוזות** תמיד — `{1: …}` הופך למפתח "1"; ‏JSON.stringify
//    מסדר מפתחות-מספריים בעלייה ⇒ הצילום הוא `{"1":…,"2":…,"3":…}`. לכן המפה כאן
//    היא Map<String,String> עם מפתחות '1'/'2'/'3' — זהה-ביט לצילום.
//  • const map ⇒ פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • Dart Map (LinkedHashMap) שומר סדר-הכנסה ⇒ סדר '1','2','3' נשמר כמו סדר-המפתחות ב-JSON.
//  • אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// The fixed priority→label map, in source key order ('1','2','3').
/// Verbatim port of new/atoms/pri-labels.mjs (`PRI_LABELS`).
Map<String, String> get priLabels => const {
      '1': '🔴 דחוף',
      '2': '🟡 רגיל',
      '3': '⚪ בהמשך',
    };
