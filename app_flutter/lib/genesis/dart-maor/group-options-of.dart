// ⚛️ אטום-Dart (דרגת-חוזה) · groupOptionsOf — אפשרויות שיוך-קבוצה (רק כשיש יותר ממפגש אחד).
// מוצא: maor/src/components/courses/lib.ts:173-181 · המקור: new/atoms/group-options-of.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1 — אפס import פנימי; השכנים הוזרקו כפרמטרים):
//   sessionsOf(c)         → List של מפגשי-החוג.
//   groupLabelOf(s, i)    → תווית-הקבוצה (String).
//   dayNames              → List<String> שמות-הימים, ממופה ב-s['day'].
// קלט: c (אובייקט-החוג) + שלושת השקעים. פלט: List של Map {'v','t'} — או [] אם ≤1 מפגש.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  • ss.map((s, i) => ...) של JS נותן אלמנט+אינדקס; Dart's Iterable.map חד-ארגומנטי
//    ⇒ List.generate(ss.length, (i) {...}) לשימור סמנטיקת-האינדקס.
//  • שדות-המפגש הם מפתחות-מפה: s.day/s.time ⇒ s['day']/s['time'].
//  • s.time || '' — truthiness של JS (כלל-7): '' ו-null שניהם falsy ⇒ '';
//    ממומש כ-_truthy מפורש (לא ?? — כדי לשמר סמנטיקת-|| לכל טיפוס-falsy).
//  • ה-template + .trim() זהים בין השפות (רווח-זנב נגזם כשאין שעה).


/// ‏truthiness של JS (חוק 7): '' / 0 / -0 / NaN / null / false כוזבים. (הוזרק ע"י מתקן-ההסגר)
bool _rqTruthy(dynamic v) =>
    !(v == null || v == false || v == '' || (v is num && (v == 0 || v.isNaN)));

bool _truthy(Object? x) {
  if (x == null) return false;
  if (x is bool) return x;
  if (x is num) return x != 0 && !x.isNaN;
  if (x is String) return x.isNotEmpty;
  return true;
}

/// אפשרויות שיוך-קבוצה. מחזיר [] אם למפגש יחיד (או פחות); אחרת {'v','t'} לכל מפגש.
/// התנהגות verbatim של המקור groupOptionsOf ב-JS.
List<dynamic> groupOptionsOf(dynamic c,
  dynamic Function(dynamic) sessionsOf,
  dynamic Function(dynamic, int) groupLabelOf,
  List<dynamic> dayNames, Map<String, String> T) {
  final ss = sessionsOf(c);
  if (_rqTruthy(ss.length <= 1)) return [];
  return List.generate(((ss.length) as int), (i) {
    final s = ss[i];
    final v = groupLabelOf(s, i);
    final timeStr = _truthy(s['time']) ? s['time'] : '';
    return {'v': v, 't': '$v${T['k1']!}${dayNames[((s['day']) as int)]} $timeStr'.trim()};
  });
}
