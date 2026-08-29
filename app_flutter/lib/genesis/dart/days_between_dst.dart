// ⚛️ אטום-Dart (דרגת-חוזה) · daysBetweenDst
// תפקיד: הפרש-ימים-קלנדרי בין שני תאריכים, חסין-DST — בונה חצות-UTC משני הצדדים
//        וסופר inDays, כך ששעון-הקיץ לא גורע/מוסיף יום שגוי.
// מוצא: buildsmart/app_flutter/lib/logic/calendar_days.dart:21-24 (חוק-4).
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
// אחים-שהוטבעו: — · אחים-שסוקטו: — (אין קריאה-לשכן; שאר הקובץ = תחילת-שבוע, לא-כלול).
//
// קלט:  from, to — שני DateTime (שעת-היום נזרקת; רק year/month/day נספרים).
// פלט:  int — מספר-הימים מ-from ל-to (חיובי אם to מאוחר; יכול להיות שלילי).

/// DST-safe calendar day delta: build UTC midnight from both dates' y/m/d and
/// take `.difference(...).inDays`. Verbatim behaviour of calendar_days.dart:21-24.
int daysBetweenDst(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;
