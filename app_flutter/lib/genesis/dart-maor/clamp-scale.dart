// ⚛️ אטום-Dart (דרגת-חוזה) · clampScale — הצמדת ערך-זום לגבולות
// מוצא: maor/src/lib/a11y.ts:35-38 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/clamp-scale.mjs —
//        `if (!Number.isFinite(v)) return 1; return Math.min(max, Math.max(min, v));`
// טוהר: פונקציית top-level עצמאית, import יחיד של dart:math (ספריית-שפה בלבד — מותר בחוק-1).
//
// תפקיד: הצמדת ערך-זום לגבולות-הסולם; ערך לא-מספרי (NaN/∞/מחרוזת/null) ⇒ 1
//        (ברירת-המחדל של הלגאסי).
// שקעים (חוק-1 — קבועי-שכן SCALE_MIN/SCALE_MAX הוזרקו כפרמטרים עם ברירת-המחדל של הלגאסי):
//   min — גבול-תחתון (לגאסי SCALE_MIN=0.8) · max — גבול-עליון (SCALE_MAX=1.6).
// קלט:  v — ערך כלשהו (dynamic, כמו ב-JS הדינמי) · min · max.
// פלט:  מספר בטווח [min,max], או 1 ללא-מספרי.
//
// הערת-המרה (מקור→Dart):
//   • JS `Number.isFinite(v)` קפדני — true רק אם v הוא **מספר** וסופי; מחרוזת/null/NaN/∞ ⇒
//     false. ב-Dart מדמים זאת ב-`v is num && v.isFinite` (מחרוזת אינה num ⇒ 1; NaN/∞ אינם
//     isFinite ⇒ 1). לכן הפרמטר v הוא dynamic — כדי לקבל את קלט-המחרוזת של דוגמת-החוזה 5.
//   • Math.min/Math.max ⇒ dart:math min/max (זהים על num סופי).
//   • אין locale/פורמט/getMonth/truthiness מעורבים.

import 'dart:math' as math;

/// Clamp a zoom value to the scale bounds. Non-numeric input (NaN, Infinity,
/// a String, null) yields `1` — the legacy default. Verbatim behaviour of the
/// JS source new/atoms/clamp-scale.mjs (`Number.isFinite` strict check).
num clampScale(dynamic v, [num min = 0.8, num max = 1.6]) {
  if (!(v is num && v.isFinite)) return 1;
  return math.min(max, math.max(min, v));
}
