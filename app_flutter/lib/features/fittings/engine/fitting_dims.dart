// 🔌 מנוע-אביזרים PP-R — פורט טהור 1:1 מ-`knowledge/catalog-3d/pure_engine.py`.
//
// כל אות נגזרת מ*קונסטרוקציה הנדסית* (OD · SDR · עומק-ריתוך + z) — אפס נתוני-קטלוג,
// אפס תלויות, אפס async/I/O. הבדיקה `test/fittings/fitting_engine_golden_test.dart`
// מאמתת שֶׁכל מספר כאן זהה byte-ל-byte לפלט של `pure_engine.py` (golden 1:1).
//
// ⚠️ אין להמציא/לכוונן יחסים כאן — המקור-היחיד הוא `pure_engine.py`. שינוי-יחס =
// עדכון ה-Python + חידוש ה-fixture, לעולם לא ידני.

import 'dart:math' as math;

/// SDR (Standard Dimension Ratio) לפי PN. PN20 ⇒ SDR 6.
const Map<int, double> kSdr = {20: 6.0, 16: 7.4, 10: 11.0};

/// עומק-שקע (ריתוך) — טבלת DIN 8077. ידע הנדסי, לא נתוני-קטלוג.
const Map<int, double> kDepth = {
  20: 14.5, 25: 16.0, 32: 18.0, 40: 20.5, 50: 23.5,
  63: 27.5, 75: 30.0, 90: 33.0, 110: 37.0, 125: 40.0,
};

/// עיגול לספרה-עשרונית אחת, **זהה ל-Python `round(x, 1)`** — half-to-even על
/// *הערך-האמיתי* של ה-double. מאומת golden 1:1 מול `pure_engine.py` (140 שורות).
///
/// למה לא `x*10`/`toStringAsFixed(1)`: הכפל ב-10 הופך ערך כמו 26.7/2=13.34999… ל-
/// תיקו-שקרי (133.5) ומעגל להיפך; `toStringAsFixed(1)` סוטה מ-half-even על עשרות
/// ערכים. הפתרון: הרחבה ל-15 ספרות (נאמנה לערך-האמיתי) + עיגול-לזוגי ידני מדויק.
double r1(double x) {
  final neg = x.isNegative;
  final ax = neg ? -x : x;
  // 18 ספרות — נאמן ל*צד* של הערך-האמיתי מול גבול-ה-.05 לכל גודל כאן (ulp ≪ 1e-13
  // עד ~1200). 15 היה מעט-מדי: 26.7/2=13.34999…964 (מתחת ל-13.35) עוגל שקרית ל-13.350.
  final s = ax.toStringAsFixed(18);
  final dot = s.indexOf('.');
  var intVal = int.parse(s.substring(0, dot));
  final frac = s.substring(dot + 1);
  var keep = frac.codeUnitAt(0) - 48; // הספרה הנשמרת (עשירית)
  final firstDrop = frac.codeUnitAt(1) - 48; // הספרה שמחליטה
  var restNonZero = false;
  for (var i = 2; i < frac.length; i++) {
    if (frac.codeUnitAt(i) != 48) {
      restNonZero = true;
      break;
    }
  }
  final roundUp = firstDrop > 5 ||
      (firstDrop == 5 && restNonZero) ||
      (firstDrop == 5 && !restNonZero && keep.isOdd); // תיקו → לזוגי
  if (roundUp && ++keep == 10) {
    keep = 0;
    intVal += 1;
  }
  final v = intVal + keep / 10.0;
  return neg ? -v : v;
}

/// הבסיס האוניברסלי — כל אביזר-ריתוך. מקביל ל-`base(od, pn)` ב-Python.
/// מפה עם סדר-הכנסה זהה למקור (`OD·wall·ID·B·C·F`).
Map<String, double> base(int od, {int pn = 20}) {
  final wall = od / kSdr[pn]!;
  return {
    'OD': od.toDouble(),
    'wall': r1(wall),
    'ID': r1(od - 2 * wall), // קדח-זרימה
    'B': r1(od * (1 + 2 / 6)), // קוטר-חוץ (PN20)
    'C': r1(od * 0.97), // קדח-שקע (הצינור נכנס)
    'F': kDepth[od] ?? double.nan, // עומק-שקע (ריתוך)
  };
}

// ===== צורה פר-משפחה (z = מרכז→פנים, מגיאומטריה) =====

Map<String, double> coupler(int od) {
  final b = base(od);
  b['A'] = r1(2 * b['F']! + 2); // 2 שקעים + מעצור-מרכז
  return b;
}

Map<String, double> elbow(int od, {int angle = 90}) {
  final b = base(od);
  final f = b['F']!;
  final r = 0.52 * od; // רדיוס-כיפוף (short radius)
  b['z'] = r1(r * math.tan(_rad(angle / 2))); // z = R·tan(θ/2)
  b['l'] = r1(f + b['z']!); // מרכז-לקצה = עומק + z
  b['D'] = b.remove('B')!; // בברך קוראים לקוטר-החוץ D
  return b;
}

Map<String, double> tee(int od) {
  final b = base(od);
  final f = b['F']!;
  final z = r1(b['B']! / 2); // מרכז-לפנים ≈ רדיוס-החוץ
  b['E'] = r1(2 * (z + f)); // רוחב-הרַץ
  b['A'] = r1(z + f + b['B']! / 2); // גובה-ההסתעפות
  return b;
}

Map<String, double> adapter(int od) {
  final b = base(od);
  final f = b['F']!;
  final hex = r1(od * 1.95); // מפתח-על-פינות
  b['SW'] = r1(hex * 0.87); // מפתח-על-שטוחים
  b['hex'] = hex;
  b['thread'] = r1(od * 1.05); // קוטר-חיצוני של התבריג
  b['thL'] = r1(od * 0.9); // אורך-התבריג
  b['z'] = r1(f + od * 0.3); // מרכז-המשושה
  b['l'] = r1(f + b['z']! + b['thL']!); // שקע→קצה-תבריג
  return b;
}

Map<String, double> valve(int od) {
  final b = base(od);
  final f = b['F']!;
  b['D'] = r1(od * 1.6); // קוטר-גוף
  b.remove('B');
  b['z'] = r1(od * 1.05); // מרכז-לפנים
  b['l'] = r1(f + b['z']!); // מרכז-לקצה-שקע
  b['dk'] = r1(od * 0.67); // קדח-הכדור ≈ DN
  b['h'] = r1(od * 2.9); // גובה (גוף+ידית)
  return b;
}

Map<String, double> plug(int od) {
  final b = base(od);
  b['A'] = r1(b['F']! + od * 0.4); // אורך-כולל
  b['cap'] = r1(od * 0.4); // אורך-הכיפה
  return b;
}

Map<String, double> saddle(int od) {
  final b = base(od);
  final f = b['F']!;
  b.remove('B');
  b['D'] = r1(od * 1.333); // קוטר-חוץ של שקע-ההסתעפות
  b['d1'] = r1(od * 2); // קוטר הצינור-הראשי
  b['z'] = r1(od * 0.64); // מרכז-לפנים
  b['l'] = r1(f + b['z']!); // גובה-ההסתעפות
  return b;
}

Map<String, double> collar(int od) {
  final b = base(od)..remove('B');
  b['D'] = r1(od * 1.15); // קוטר-צוואר
  b['D1'] = r1(od * 1.619); // קוטר-אוגן חיצוני
  b['A'] = r1(od * 1.478); // אורך-כולל
  b['E'] = r1(od * 0.6); // עובי-האוגן
  return b;
}

/// מצרה (d1×d2) — קומפוזיציה: כל צד לפי חוקי-הבסיס של הקוטר שלו.
Map<String, double> reducer(int d1, int d2) {
  final s1 = base(d1);
  final s2 = base(d2);
  return {
    'B1': s1['B']!, 'C1': s1['C']!, 'F1': s1['F']!,
    'B2': s2['B']!, 'C2': s2['C']!, 'F2': s2['F']!,
    'A': r1(s1['F']! + s2['F']! + 3), // שני שקעים + מעבר
  };
}

/// ברך מחותכת גדולה (מודל B, 160–400) — מגזרים = יחס נקי לרדיוס-הכיפוף (∝d).
Map<String, double> miteredElbow(int d) => {
      'A': r1(3.0 * d),
      'G': r1(1.377 * d),
      'F': r1(1.186 * d),
      'E': r1(0.765 * d),
      'D': r1(0.986 * d),
    };

/// בורר-דיאגרמה: משפחה × טווח-גודל → קונסטרוקציה.
Map<String, double> elbowAuto(int d, {int angle = 90}) =>
    d >= 160 ? miteredElbow(d) : elbow(d, angle: angle);

double _rad(num deg) => deg * math.pi / 180.0;

/// שמות-המשפחות החד-קוטריות — זהים למפתחות `ENGINE` ב-`pure_engine.py`.
/// (מצרה דו-קוטרית + ברך-מחותכת אינן כאן — נבחרות דרך `generate`.)
const List<String> kFittingFamilies = [
  'מצמד', 'ברך 90°', 'ברך 45°', 'מסעף (טי)',
  'מתאם תבריג', 'ברז כדורי', 'פקק', 'רוכב', 'צווארון',
];

/// חוזה-המנוע — פונקציה טהורה אחת. משפחה (שם עברי, כמו `pure_engine.ENGINE`)
/// + קוטר ⇒ מפת-מידות. דו-קוטרי (מצרה) דרך [od2]; ברך≥160 → מחותכת אוטומטית.
Map<String, double> generate(String family, int od, {int? od2}) {
  switch (family) {
    case 'מצמד':
      return coupler(od);
    // 1:1 עם `pure_engine.ENGINE`: 90°/45° = `elbow(d, angle)` תמיד (תקף ל-OD
    // שב-DEPTH, ≤125). ברך-גדולה ≥160 היא משפחה נפרדת ('ברך מחותכת') — לא מיתוג
    // אוטומטי כאן. `elbowAuto` (הבורר) נשאר helper מיוצא ל-פאזה-C, עם כיסוי-ישיר.
    case 'ברך 90°':
      return elbow(od); // angle=90 (ברירת-מחדל)
    case 'ברך 45°':
      return elbow(od, angle: 45);
    case 'ברך מחותכת':
      return miteredElbow(od);
    case 'מסעף (טי)':
      return tee(od);
    case 'מתאם תבריג':
      return adapter(od);
    case 'ברז כדורי':
      return valve(od);
    case 'פקק':
      return plug(od);
    case 'רוכב':
      return saddle(od);
    case 'צווארון':
      return collar(od);
    case 'מצרה':
      return reducer(od, od2 ?? od);
    default:
      throw ArgumentError('unknown fitting family: $family');
  }
}
