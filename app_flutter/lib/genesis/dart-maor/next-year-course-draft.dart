/// חוט · next-year-course-draft — טיוטת-חוג טהורה לשנה הבאה (רישום-לשנה-הבאה).
/// חוזה: next-year-course-draft.contract.md
/// המרה נאמנה מ-new/atoms/next-year-course-draft.mjs (חוק-4: המקור קדוש).
/// השכנים nextYearDates (הזזת-תאריכים) ו-academicYearLabel (תווית-שנה"ל) מוזרקים
/// כשקעים (חוק-1 — אפס import פנימי). ה-id מוזרק מבחוץ; המקור לא נגע (spread ⇒ מפה חדשה).
/// אפס-import (dart-core בלבד).
Map<String, Object?> nextYearCourseDraft(
  Map<String, Object?> src,
  Object? newId,
  Map<String, String> Function(Object? start, Object? end) nextYearDates,
  String Function(Object? start) academicYearLabel,
) {
  final dates = nextYearDates(src['start'], src['end']);
  final start = dates['start'];
  final end = dates['end'];
  // JS: `{ ...src, ... }` — עותק חדש; המקור לא משתנה, המפתחות שנדרסים גוברים.
  return <String, Object?>{
    ...src,
    'id': newId,
    'start': start,
    'end': end,
    'year': academicYearLabel(start),
    'prevYearId': src['id'],
  };
}
