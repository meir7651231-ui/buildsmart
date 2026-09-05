// ⚛️ אטום-Dart (דרגת-חוזה) · fmtDuration
// מוצא: buildsmart/app_flutter/lib/screens/courier_attendance_screen.dart:661
//        (‏_fmtDur; חוק-4 — התנהגות verbatim, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart:core — Duration).
//
// אין שקעים: הקלט Duration הוא טיפוס-שפה טהור. אין זמן/זהות/שכן.
//
// קלט:  d — Duration (משך-משמרת).
// פלט:  String — `H:mm` (שעות ללא-ריפוד : דקות-בתוך-השעה בריפוד-שתיים).

/// `H:mm` — אורך-משמרת (למשל 7:45) · verbatim של courier_attendance_screen.dart:661.
String fmtDuration(Duration d) =>
    '${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}';
