// ⚛️ אטום-Dart (דרגת-חוזה) · startOfWeekSunday
// מוצא: buildsmart/app_flutter/lib/logic/calendar_days.dart:33-35 (‏startOfWeekSunday; חוק-4 — התנהגות verbatim).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). אין שכנים/const —
//        הכול חשבון-תאריך על DateTime מובנה.
//
// קלט:  d — תאריך כלשהו (DateTime; weekday: שני=1 … ראשון=7).
// פלט:  חצות תחילת-השבוע-שמתחיל-בראשון: DateTime(שנה, חודש, יום - (weekday % 7)).
//        weekday % 7: ראשון⇒0, שני⇒1, … שבת⇒6 ⇒ מספר-הימים לחזור אחורה עד ראשון.
//        DateTime מנרמל יום-שלילי/גלישת-חודש לבד (ראשון-השבוע יכול ליפול בחודש הקודם).

/// Midnight of the Sunday-anchored week containing [d].
/// Verbatim behaviour of calendar_days.dart:33-35.
DateTime startOfWeekSunday(DateTime d) =>
    DateTime(d.year, d.month, d.day - (d.weekday % 7));
