// ⚛️ אטום-Dart (דרגת-חוזה) · dayBucket
// תפקיד: כימוס-רגע ל"תא-יום" (UTC-midnight) לפי היסט-אזור נתון — לצורך אגירה יומית.
// מוצא: buildsmart/app_flutter/lib/logic/intel/segments.dart:249-313 (‏_dayBucket, :249-252; חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד). פרטי-במקור ⇒ הופך public.
// אחים-שהוטבעו: — · אחים-שסוקטו: — (אין קריאה-לשכן; שאר הקובץ = joinSegmentsToCustomers וכו', לא-כלול).
//
// קלט:  at     — הרגע (DateTime, כל-אזור). המקור מנרמל דרך `at.toUtc()`.
//       offset — היסט-האזור העסקי (Duration) שמוסיפים לפני חיתוך-היום.
// פלט:  DateTime.utc של תחילת-היום (00:00:00Z) של הרגע-המוסט.

/// UTC day-bucket: shift [at] (normalised to UTC) by [offset], then floor to
/// UTC midnight `DateTime.utc(y, m, d)`. Verbatim behaviour of segments.dart:250-252.
DateTime dayBucket(DateTime at, Duration offset) {
  final shifted = at.toUtc().add(offset);
  return DateTime.utc(shifted.year, shifted.month, shifted.day);
}
