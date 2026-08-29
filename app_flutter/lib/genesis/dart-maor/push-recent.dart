// ⚛️ אטום-Dart (דרגת-חוזה) · pushRecent — קידום מזהה לראש "נפתחו לאחרונה".
// מוצא: maor/src/lib/navhist.ts:34-37 (פיצ'ר shell.navhist P1.5) · המקור: new/atoms/push-recent.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מקדם id לראש רשימה, ייחודי (מופע קודם מוסר), תקרה RECENT_MAX=6.
//        מחזיר רשימה חדשה — הקלט לא משתנה (טהור).
// קלט:  ids (List<String>) · id (String). פלט: List<String> חדש, אורך ≤6.
//
// הערות-המרה (מקור→Dart):
//  • המקור: `[id, ...ids.filter(x => x !== id)].slice(0, 6)`.
//  • ⚠️ סטיית-הזנב שהמנוע פספס: הטיוטה תרגמה `.slice(0,6)` ל-`.sublist(0, RECENT_MAX)`.
//    ‏Dart `sublist(0,6)` **זורק RangeError** כשהאורך <6 (JS `.slice(0,6)` סלחן) —
//    משפחת "substring-שלילי" מ-DART-PORTING-RULES §5. ⇒ `.take(6).toList()`, סלחן
//    כמו slice: לוקח עד-6 בלי לזרוק. (שובר דוגמאות 1/2/3 שאורכן <6.)
//  • `!==` → `!=` (מחרוזות; זהה-ערך). `[id, ...spread]` → literal-spread של Dart.
//  • `where` מחזיר Iterable-עצל ⇒ הרשימה-החדשה נוצרת מה-literal; הקלט ids לא נגרע (טוהר).

const int _recentMax = 6;

/// Promotes [id] to the head of a de-duplicated recents list, capped at 6.
/// Verbatim port of new/atoms/push-recent.mjs (`pushRecent`). Returns a new list.
List<String> pushRecent(List<String> ids, String id) =>
    [id, ...ids.where((x) => x != id)].take(_recentMax).toList();
