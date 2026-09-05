// ⚛️ אטום-Dart (דרגת-חוזה) · validDateRange
// מוצא: buildsmart/app_flutter/lib/logic/input_validators.dart:95-96 (חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). ה-DateTime-ים
//        מגיעים כפרמטרים — אין DateTime.now (טהור, דטרמיניסטי).
//
// קלט:  start, end. פלט: true אם end מאוחר-ממש מ-start.

/// Date range: [end] must be strictly after [start].
bool validDateRange(DateTime start, DateTime end) => end.isAfter(start);
