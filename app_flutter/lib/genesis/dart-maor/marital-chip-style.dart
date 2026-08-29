// ⚛️ אטום-Dart (דרגת-חוזה) · maritalChipStyle — צבע-שבב למצב-משפחתי
// מוצא: maor · המקור: new/atoms/marital-chip-style.mjs (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        const MARITAL_CHIP = { נשואים:[...], 'אלמן/ה':[...], גרושים:[...], פרודים:[...] };
//        const [bg,c] = MARITAL_CHIP[status] ?? ['#eef1f5','#4a5568']; return chipStyle(bg,c);
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). צבע=פיגמנט בלבד (חוק-5).
//
// תפקיד: ממפה מצב-משפחתי לזוג פיגמנטים [רקע, טקסט] ומעביר אותו לשקע-העיצוב chipStyle.
//        מצב לא-מוכר (וגם ריק) נופל לברירת-המחדל האפורה — בדיוק כמו ה-`??` של המקור.
// קלט:  status — מחרוזת מצב-משפחתי · chipStyle — שקע: (bg, c) => T (העיצוב חי בקופסה).
// פלט:  התוצאה של chipStyle(bg, c).
//
// הערות-המרה (מקור→Dart):
//  · המנוע פספס את הפירוק `const [bg,c] = ...` והשאיר `bg`/`c` לא-מוגדרים — תוקן ידנית.
//  · ה-`?? ` של JS נופל רק כש-lookup מחזיר undefined; ב-Dart `Map[key]` על מפתח חסר
//    מחזיר null — סמנטיקה שקולה כאן (אין מפתח עם ערך-null במפה). `?? ` של Dart תואם.
//  · אפס locale/פורמט/getMonth/truthiness/מודולו/תאריך — פיגמנטים סטטיים בלבד.

const Map<String, List<String>> _maritalChip = {
  'נשואים': ['#e6f4ea', '#1e7a3a'],
  'אלמן/ה': ['#eef1f5', '#4a5568'],
  'גרושים': ['#fdecec', '#b4433a'],
  'פרודים': ['#fff4e5', '#a15c00'],
};

/// Marital-status chip pigments → design socket. Verbatim behaviour of the JS
/// source new/atoms/marital-chip-style.mjs: unknown/empty status falls to the
/// grey default, then the [bg, c] pair is handed to [chipStyle].
T maritalChipStyle<T>(String status, T Function(String bg, String c) chipStyle) {
  final pair = _maritalChip[status] ?? const ['#eef1f5', '#4a5568'];
  return chipStyle(pair[0], pair[1]);
}
