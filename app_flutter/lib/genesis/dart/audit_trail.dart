// ⚛️ אטום-Dart (דרגת-חוזה) · auditTrail / renderAuditTrail
// תפקיד: הופך רשימת-רשומות-חסימה (verdict.blocked) לעקבת-ביקורת — רשימת-שורות
//        (auditTrail) או בלוק-טקסט אחד מופרד-שורות (renderAuditTrail). טהור, אפס IO.
// מוצא: buildsmart/app_flutter/lib/logic/studio/edit_safety.dart:489-495 (7 שורות) · Dart-טהור,
//        לא-מתורגם (חוק-4 — התנהגות זהה, לא-משופרת). המקור החי אינו בעץ-העבודה הנוכחי;
//        הלוגיקה (list-comprehension על blocked + join('\n')) חולצה verbatim מטיוטת-המחצב.
// טוהר: שתי פונקציות top-level עצמאיות, אפס import (רק שפה/סטנדרט). אין מחלקות.
//
// אחים שסוקטו (חוק-3/דיבר-3: קריאה-לשכן ⇒ פרמטר-שקע):
//   • `auditLine(e)` — קריאה-לשכן (אטום-אח `audit_line`, edit_safety.dart:484-488) ⇒
//     שקע-פונקציה `auditLine` (String Function(E)); מיפוי רשומה→שורה שייך לאטום-audit_line.
//   • `verdict.blocked` — קריאת-שדה על טיפוס-השכן `SafetyVerdict` (מחלקה-גדולה) ⇒ שקע-רשימה
//     `blocked` (ערך-השדה מוזרק ישירות, כדוגמת שקע-הקבוע ב-branch_label).
// טיפוסי-שכן שלא-הוטבעו (אי-אפשר-כטהור):
//   • `SafetyVerdict` — מחלקה-גדולה; רק שדה-ה-blocked נצרך ⇒ סוקט כרשימה, לא הוטבע.
//   • `BlockedEntry`/`ConfigOp` — היררכיה-אטומה בת 6 גרסאות; אלמנט-הרשימה נשאר גנרי `<E>`.
//   • `renderAuditTrail` מוגדר כאן (אטום-פנימי, נוחות מעל auditTrail) — אינו שקע.
//
// קלט:  blocked   — רשימת-רשומות-החסימה (verdict.blocked; סדר נשמר).
//       auditLine — שקע: מרנדר רשומה-בודדת לשורה (String Function(E)).
// פלט:  auditTrail       — List<String>: שורה לכל רשומה, בסדר. ריק ⇒ [].
//       renderAuditTrail — String: השורות מחוברות ב-'\n' (בלי שורה-נגררת). ריק ⇒ ''.

/// The whole blocked list as audit lines — pure, dumpable to a log by the caller.
/// Empty when nothing was blocked. Verbatim behaviour of edit_safety.dart:489-491
/// with the neighbour call (`auditLine`) and field (`verdict.blocked`) socketed.
List<String> auditTrail<E>(
  List<E> blocked, {
  required String Function(E) auditLine,
}) =>
    [for (final e in blocked) auditLine(e)];

/// The audit trail joined into one newline-delimited block (convenience over
/// [auditTrail]). Pure — the caller decides where/whether to persist it.
/// Verbatim behaviour of edit_safety.dart:493-495.
String renderAuditTrail<E>(
  List<E> blocked, {
  required String Function(E) auditLine,
}) =>
    auditTrail(blocked, auditLine: auditLine).join('\n');
