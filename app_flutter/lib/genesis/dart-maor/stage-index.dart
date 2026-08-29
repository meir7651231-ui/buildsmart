// ⚛️ אטום-Dart (דרגת-חוזה) · stageIndex — מיקום שלב-הטיפול בסדר-השלבים (0..4).
// מוצא: maor/src/lib/ayin.ts:50-53 (מעקב-טיפול / משפך-פרויקטים בורטיקל הסטודיו)
//        · המקור: new/atoms/stage-index.mjs · חוזה: stage-index.contract.md.
// טוהר: פונקציה top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core).
//        סדר-השלבים הוטבע כקבוע-פרטי _ayinStages — נתון של האטום, לא קריאת-שכן
//        (חוק-1; קיים גם כאטום-קבוע ayin-stages — כאן העתק מוטבע, לא import).
//
// תפקיד: אינדקס השלב בסדר הקבוע ['new','lead','eyes','answer','done'].
//        שלב לא-מוכר ⇒ 0 (נפילה בטוחה לתחילת-המשפך, לא ‎-1).
//
// הערות-המרה (מקור→Dart):
//  • ‏JS ‏Array.prototype.indexOf משווה ב-=== (StrictEquals). קלט לא-מחרוזתי
//    (מספר/null/אובייקט) ⇒ אף איבר לא שווה ⇒ ‎-1 ⇒ 0. ‏List<String>.indexOf
//    של Dart היה זורק TypeError על ארגומנט לא-String (כלל-15: קוארציית-ארגומנט
//    ≠ בדיקת-טיפוס) — לכן לולאה ידנית עם ==: ‏String==לא-String הוא false,
//    בדיוק כמו === של JS על הערכים האלה. אין קוארציה ב-indexOf של JS ('New'≠'new').
//  • אין locale/Date/מודולו/truthiness/פורמט-מספר — השוואת-מחרוזות בלבד.

/// סדר השלבים — קבוע-פרטי מוטבע (התוויות נגזרות אצל stage-label).
const List<String> _ayinStages = ['new', 'lead', 'eyes', 'answer', 'done'];

/// Verbatim port of new/atoms/stage-index.mjs (`stageIndex`).
/// Index of [stage] in the fixed funnel order; unknown stage ⇒ 0 (not -1).
int stageIndex(dynamic stage) {
  // שקול ל-AYIN_STAGES.indexOf(stage) של JS: === איבר-איבר, ‎-1 אם אין.
  var i = -1;
  for (var k = 0; k < _ayinStages.length; k++) {
    if (_ayinStages[k] == stage) {
      i = k;
      break;
    }
  }
  return i < 0 ? 0 : i;
}
