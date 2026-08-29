// ⚛️ אטום-Dart (דרגת-חוזה) · actionLabelHe
// תפקיד: תרגום מזהה-פעולה-של-כלל (id) לתווית עברית לתצוגה; חוסר-התאמה ⇒ מחזיר את ה-id כפי-שהוא.
// מוצא: buildsmart/app_flutter/lib/logic/studio/rules_model.dart:452-459 (‏actionLabelHe;
//        חוק-4 — התנהגות זהה למקור, לא-משופרת. ‏גוף-המקור מלא בטיוטה: לולאה לינארית על
//        kRuleActions, התאמת a.id==id ⇒ a.labelHe, אחרת return id).
//        ⚠️ קובץ-המקור אינו קיים בעץ הנוכחי (אף ענף) — האטום חולץ verbatim לטיוטה; החציבה
//        מספיקה שכן כל ההתנהגות גלויה בגוף בן-8-השורות (המופחת-האפשרי, דיבר-9).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core).
// אחים שסוקטו:
//   `kRuleActions` (const-רשימת-אחות, ציבורית/משותפת — לא פרטית לאטום) ⇒ שקע `actions`
//                  (חוק-3/דיבר-3: קריאה-לשכן ⇒ פרמטר-שקע, named required).
// טיפוס-שכן שהוטבע:
//   טיפוס-האיבר (במקור `RuleAction`, מחלקה עם השדות id/labelHe) הוטבע inline כ-record
//   מבני קטן `({String id, String labelHe})` — בדיוק שני השדות שהאטום נוגע בהם.
//
// קלט:  id       — מזהה-הפעולה לחיפוש (String).
//       actions  — שקע: קטלוג-הפעולות (רשימת {id, labelHe}). במקור מוזרק כ-kRuleActions.
// פלט:  labelHe של הפעולה הראשונה ש-id שלה שווה לקלט; אם אין התאמה — הקלט id כפי-שהוא.

/// Hebrew label for a rule-action id. First `a.id == id` match returns `a.labelHe`;
/// no match returns the raw `id`. Verbatim behaviour of rules_model.dart:452-459
/// with the sibling catalog `kRuleActions` injected as the `actions` socket.
String actionLabelHe(
  String id, {
  required List<({String id, String labelHe})> actions,
}) {
  for (final a in actions) {
    if (a.id == id) return a.labelHe;
  }
  return id;
}
