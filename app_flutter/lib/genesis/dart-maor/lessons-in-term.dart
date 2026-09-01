// ⚛️ אטום-Dart (דרגת-חוזה) · lessonsInTerm — מספר-שיעורים בתקופת-תמחור לפי תדירות.
// מוצא: maor/src/components/courses/lib.ts:213+236-259 · המקור: new/atoms/lessons-in-term.mjs
// טוהר: פונקציית top-level עצמאית, אפס import פנימי (רק dart-core + dart:math). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: תרגום תדירות (freq בכל week/month) לסך-שיעורים לפי מונח-התמחור (term).
// שקע-שכן (חוק-1): WEEKS_PER_MONTH — קבוע שהוזרק מקומית במקור (ערך, לא import).
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//   • truthiness (כלל 7): JS `Number.isFinite(freq) ? freq : 0` — קלט לא-מספרי/NaN/אינסוף ⇒ 0.
//     ב-Dart: `freq is num && freq.isFinite`. double.nan.isFinite==false ⇒ נופל ל-0, זהה ל-JS.
//   • `months || 1` (כלל 7): JS falsy למספרים = 0 / NaN ⇒ 1. משוקף מפורשות ב-_orOne.
//   • Math.max(0,…) / Math.max(1,…): max<num> מ-dart:math, מוצמד ל-num כדי לגשר int↔double.
//   • ערכי-החזרה: JS מחזיר double תמיד; Dart מחזיר int במקומות שלמים — שקול-ביט ב-==
//     (2==2.0, 52/12==52/12). אין locale/פורמט/getMonth/מוטביליות בחוט הזה.

import 'dart:math';

/// שבועות-בחודש ממוצע — 52/12. ערך-שכן שהוזרק מקומית במקור (חוק-1).
const double WEEKS_PER_MONTH = 52 / 12;

/// truthiness של `x || 1` בהקשר-מספרי: 0 ו-NaN ⇒ נופלים ל-1 (כמו JS falsy).
num _orOne(dynamic x) {
  if (x is num && x != 0 && !x.isNaN) return x;
  return 1;
}

/// מספר-שיעורים בתקופת-תמחור. התנהגות זהה-ביט למקור-ה-JS `lessonsInTerm`.
num lessonsInTerm(dynamic freq, dynamic unit, dynamic term, [dynamic months = 1]) {
  final num f = max<num>(0, (freq is num && freq.isFinite) ? freq : 0);
  final num perWeek = unit == 'week' ? f : f / WEEKS_PER_MONTH;
  final num perMonth = unit == 'month' ? f : f * WEEKS_PER_MONTH;
  final num n = max<num>(1, _orOne(months));
  switch (term) {
    case 'once':
      return 1;
    case 'weekly':
      return perWeek;
    case 'biweekly':
      return perWeek * 2;
    case 'monthly':
      return perMonth;
    case 'months':
      return perMonth * n;
    case 'half_year':
      return perMonth * 6;
    case 'year':
      return perMonth * 12;
    default:
      return 0;
  }
}
