// ⚛️ אטום-Dart (דרגת-חוזה) · enrollmentsForSession — המשובצים למפגש ביומן.
// מוצא: maor/src/components/diary/lib.ts:228-236 · המקור: new/atoms/enrollments-for-session.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). השכנים sessionsOf ו-groupLabelOf הוזרקו כשקעים
//        (חוק-1/חוק-3 — אפס import פנימי).
//
// תפקיד: כל שיבוצי-הקורס; כשיש כמה קבוצות (מפגשים) — רק מי ששויך/ה לקבוצת-המפגש הזה,
//        בתוספת מי שעדיין ללא שיוך-קבוצה. sessionIndex מעבר-לטווח נצמד למפגש-האחרון.
// קלט:  db (Map: enrollments = List של {id,courseId,group?}) · c (Map: id · sessions? ·
//        weekday? · time?) · sessionIndex (int) · השקעים sessionsOf(c) ⇒ List ·
//        groupLabelOf(ss, i) ⇒ String. פלט: List<Map> מסונן.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • truthiness: `!e.group` הוא בדיקת-אמת של JS (undefined/null/מחרוזת-ריקה ⇒ true).
//    מומש ב-`_truthy` שמחקה `!!` לתחום — כך חסרי-שיוך וגם group='' מוכללים בדיוק כמקור.
//  • Math.min(sessionIndex, ss.length-1) → תנאי-מפורש (ss.length ≥ 2 כאן, אחרי השער ≤1).
//  • `e.courseId === c.id` / `e.group === label` → `==` (השוואת-מחרוזות). מוטביליות: כל
//    המקומיים final; אין locale/פורמט/getMonth ⇒ אף כלל-פורמט לא רלוונטי כאן.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/false/NaN ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// The enrollments shown for one diary session: all of the course's enrollments,
/// but when there are several groups (sessions) — only those matched to this session's
/// group, plus anyone still without a group (so they never vanish from the diary).
/// sessionIndex past range clamps to the last session. Verbatim port of
/// new/atoms/enrollments-for-session.mjs; sessionsOf/groupLabelOf injected as sockets (Law 1/3).
List<Map<String, dynamic>> enrollmentsForSession(
  Map<String, dynamic> db,
  Map<String, dynamic> c,
  int sessionIndex,
  List<dynamic> Function(Map<String, dynamic>) sessionsOf,
  String Function(dynamic, int) groupLabelOf,
) {
  final all = (db['enrollments'] as List)
      .cast<Map<String, dynamic>>()
      .where((e) => e['courseId'] == c['id'])
      .toList();
  final ss = sessionsOf(c);
  if (ss.length <= 1) return all;
  final idx = sessionIndex < ss.length - 1 ? sessionIndex : ss.length - 1;
  final label = groupLabelOf(ss[idx], sessionIndex);
  return all.where((e) => !_truthy(e['group']) || e['group'] == label).toList();
}
