// ⚛️ אטום-Dart (דרגת-חוזה) · planLabelOf — תווית-המסלול בשורת-תלמיד/ה (הקפאה/סיום/חיסורים/חוב).
// מוצא: maor/src/components/courses/lib.ts:421-431 · המקור: new/atoms/plan-label-of.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכנים planWord/payBal הוזרקו כשקעים (חוק-1/חוק-3).
//
// תפקיד: בסיס — plan='punch' ⇒ 'כרטיסייה · <purchased>', אחרת planWord(plan). תוספות בסדר
//        קבוע מופרד ' · ': status='paused' ⇒ 'מוקפא ⏸' / 'ended' ⇒ 'הסתיים' (רק אחד — else-if) ·
//        יש חיסורים ⇒ '<N> חיס׳' · payBal>0 ⇒ '💳 ₪<bal>'.
// קלט:  e (Map: plan · purchased? · status? · absences[]) + השקעים planWord(plan)→String,
//        payBal(e)→num. פלט: String.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • שרשור-מספר-למחרוזת של JS (`'…' + e.purchased`, `+ e.absences.length`, `+ bal`) מודל
//    ב-`_numStr` — JS `String(num)` על שלם-שלם נותן '150' (בלי '.0'); Dart `(150.0).toString()`
//    היה '150.0'. ⇒ שלם-דאבל נדפס כ-int (כלל-פורמט 6, בהיטל על concat-לא-locale).
//  • `if (e.absences.length)` = truthiness של JS (0 ⇒ שקר) ⇒ `absences.isNotEmpty`.
//  • `if(paused) … else if(ended)` — בלעדיות נשמרת (else-if); סטטוס אחר לא מוסיף כלום.
//  • הענף `e.plan==='punch'` בטרנר קצר-נסיגה ⇒ `_numStr(e['purchased'])` מחושב רק בכרטיסייה
//    (בשאר-המסלולים purchased עשוי להיעדר — לא נוגעים בו). ⇒ ביט-זהה למקור.
//  • מוטביליות: `s` הוא var (מוטבל דרך +=, כמו `let s` במקור); absences/bal הם final.
//    אין locale/getMonth/מודולו — הפורמט-האמיתי (מילת-מסלול, חישוב-חוב) חי בשקעים.

/// חיקוי `String(n)` של JS על concat-לא-locale: שלם ⇒ בלי '.0' (150, לא 150.0).
String _numStr(num n) {
  if (n is int) return n.toString();
  if (n.isFinite && n == n.roundToDouble()) return n.toInt().toString();
  return n.toString();
}

/// Plan label for a student row: punch ⇒ 'כרטיסייה · <purchased>', else planWord(plan);
/// then ' · מוקפא ⏸' | ' · הסתיים' (paused/ended, exclusive), ' · <N> חיס׳' when absences,
/// ' · 💳 ₪<bal>' when payBal(e) > 0. Verbatim port of new/atoms/plan-label-of.mjs
/// (`planLabelOf`); neighbours planWord/payBal injected as sockets (Law 1/3).
String planLabelOf(
  Map<String, dynamic> e,
  String Function(String) planWord,
  num Function(Map<String, dynamic>) payBal,
) {
  var s = e['plan'] == 'punch'
      ? 'כרטיסייה · ' + _numStr(e['purchased'] as num)
      : planWord(e['plan'] as String);
  if (e['status'] == 'paused') {
    s += ' · מוקפא ⏸';
  } else if (e['status'] == 'ended') {
    s += ' · הסתיים';
  }
  final absences = e['absences'] as List;
  if (absences.isNotEmpty) {
    s += ' · ' + absences.length.toString() + ' חיס׳';
  }
  final bal = payBal(e);
  if (bal > 0) {
    s += ' · 💳 ₪' + _numStr(bal);
  }
  return s;
}
