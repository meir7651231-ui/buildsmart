/// חוט · enroll-count — משובצים תופסי-מקום בחוג (לא 'ended', לא 'wait').
/// חוזה: enroll-count.contract.md · חולץ כלשונו מ-maor/src/components/courses/lib.ts:333-339.
/// טהור — אפס import (dart-core בלבד). התנהגות זהה-לחלוטין למקור-ה-JS.
///
/// 'wait' (רשימת-המתנה) אינו תופס מקום — אחרת רשימת-המתנה הייתה חוסמת שיבוץ אמיתי.
/// חסר-סטטוס נספר: ב-JS `status !== 'ended'` על undefined ⇒ true; ב-Dart מפתח-חסר ⇒ null, null != 'ended' ⇒ true.
int enrollCount(dynamic db, dynamic courseId) {
  final List enrollments = db['enrollments'] as List;
  var n = 0;
  for (final e in enrollments) {
    final status = e['status'];
    if (e['courseId'] == courseId && status != 'ended' && status != 'wait') {
      n++;
    }
  }
  return n;
}
