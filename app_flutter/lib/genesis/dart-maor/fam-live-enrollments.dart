// חוט · fam-live-enrollments — השיבוצים ה"חיים" של משפחה (בלי ended/wait).
// המרה מ-JS (new/atoms/fam-live-enrollments.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// השכן famEnrollments מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
// null (סטטוס-חסר) ≠ 'ended'/'wait' בדיוק כמו undefined ב-JS ⇒ נשאר חי.
List<Map<String, dynamic>> famLiveEnrollments(
  dynamic db,
  dynamic fam,
  List<Map<String, dynamic>> Function(dynamic db, dynamic fam) famEnrollments,
) {
  return famEnrollments(db, fam)
      .where((e) => e['status'] != 'ended' && e['status'] != 'wait')
      .toList();
}
