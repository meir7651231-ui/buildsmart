// ⚛️ אטום-Dart (דרגת-חוזה) · punchConfirmStep — צעד במכונת-המצבים של אישור-הניקוב-הכפול.
// מוצא: maor/src/components/courses/lib.ts:572-591 · המקור: new/atoms/punch-confirm-step.mjs.
// ratchet מלגאסי: legacy-main-script.js:330-342. טוהר: פונקציית top-level עצמאית,
// אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: לחיצה ראשונה "מזיינת" (arms) את השיבוץ; לחיצה שנייה על אותו שיבוץ בתוך
//        חלון PUNCH_CONFIRM_MS (3000ms, קצה-כולל ≤) מבצעת ומנקה את הזריון (next=null);
//        שיבוץ אחר / חלון פג ⇒ זריון-מחדש מ-now. דגל כבוי ⇒ ביצוע מיידי.
// שקע (חוק-1): now מוזרק (אין Date.now/DateTime.now באטום).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · JS `!confirmOn` על boolean ⇒ `!confirmOn` מפורש (חוק-7 truthiness; confirmOn מוקלד bool).
//  · JS `armed && armed.id === enrollmentId` — armed הוא Map|null; ב-Dart:
//    `armed != null && armed['id'] == enrollmentId` (null≠undefined, DART-RULE 2 —
//    כאן armed נכנס null-מפורש, ולכן בדיקת-null היא הנכונה, לא containsKey).
//  · `now - armedAt <= 3000` — חשבון-int, זהה בשתי השפות (ללא מודולו/שלילי).
//  · פלט {fire, next} ⇒ Map<String,Object?>; next או null או Map חדש-ומובחן (מוטביליות:
//    מוחזרת מפה טרייה בכל קריאה, כמו object-literal של JS).

const int PUNCH_CONFIRM_MS = 3000;

/// One step of the double-punch-confirm state machine (pure).
/// Verbatim behaviour of the JS source `punchConfirmStep`.
/// Returns `{'fire': bool, 'next': {'id', 'armedAt'} | null}`.
Map<String, Object?> punchConfirmStep(
  bool confirmOn,
  Map<String, Object?>? armed,
  String enrollmentId,
  int now,
) {
  if (!confirmOn) return {'fire': true, 'next': null};
  if (armed != null &&
      armed['id'] == enrollmentId &&
      now - (armed['armedAt'] as int) <= PUNCH_CONFIRM_MS) {
    return {'fire': true, 'next': null};
  }
  // אין זריון / שיבוץ אחר / החלון פג — מזיינים (מחדש) את השיבוץ הנוכחי.
  return {
    'fire': false,
    'next': {'id': enrollmentId, 'armedAt': now},
  };
}
