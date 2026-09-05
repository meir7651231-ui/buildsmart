// ⚛️ אטום-Dart (דרגת-חוזה) · retentionPct
// מוצא: buildsmart/app_flutter/lib/logic/intel/segments.dart:176-177
//        (‏RetentionCohort.retentionPct; חוק-4). מתודה על מחלקה-שכנה; שאר-הטיוטה
//        (‏retentionCohorts, ActorSegment) אינו היעד. הקובץ אינו קיים עוד; הטיוטה = מקור-האמת.
// טוהר: אחוז טהור. מצב-המחלקה הוסב לשקעים (חוק-3):
//        · `size` (‏RetentionCohort.size) ⇒ שקע `size` (int).
//        · `returning(dayOffset)` (מתודה-אחות) ⇒ שקע-פונקציה `returning`.
//        · `_kPercentScale` (const-שכן לא-ניתן-לשחזור) ⇒ שקע `percentScale`; ברירת-המחדל
//          `100` מוסקת מהסמנטיקה ("percent") ומתועדת.
//
// פלט:  אחוז-החזרה: `size==0 ? 0 : returning(dayOffset) / size * percentScale`.

/// Percent of a cohort of [size] active on day [dayOffset]
/// (`returning(dayOffset) / size × percentScale`); `0` for an empty cohort.
/// Verbatim behaviour of segments.dart:176-177 with the cohort's `size`, the
/// sibling `returning(...)` method, and the percent scale injected as sockets.
double retentionPct(
  int dayOffset, {
  required int size,
  required int Function(int dayOffset) returning,
  double percentScale = 100,
}) =>
    size == 0 ? 0 : returning(dayOffset) / size * percentScale;
