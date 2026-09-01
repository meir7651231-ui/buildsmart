// ⚛️ אטום-Dart (דרגת-חוזה) · isRtlLang — האם שפת-האתר RTL
// מוצא: maor/src/lib/publicSite.ts:34-37 (isRtlLang; חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/is-rtl-lang.mjs —
//        `export function isRtlLang(lang) { return lang !== 'en'; }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט).
//
// תפקיד: האם שפת-האתר-הציבורי נכתבת מימין-לשמאל. הכלל (כלשון-המקור): כל שפה
//        שאינה 'en' ⇒ RTL. האטום עיוור לרשימת-השפות (חוק-5) — בודק אך ורק ≠'en'.
// קלט:  lang — קוד-שפה, String.
// פלט:  bool: true אם lang שונה מ-'en', אחרת false.
//
// הערת-המרה (מקור→Dart): ה-JS משווה זהות-מחרוזת עם `!==`; ב-Dart `!=` על String
// הוא השוואת-ערך, ולכן שקול בדיוק. אין locale/פורמט/getMonth/truthiness/מוטביליות
// מעורבים — אטום טהור בן שורה אחת, ללא שקעים. הטיוטה השתמשה ב-dynamic; החוזה קובע
// קלט-מחרוזת ⇒ נחתם String (התנהגות זהה למקור על תחום-השפות).

/// Whether the public-site language is right-to-left: every language other than
/// `'en'` is RTL. Verbatim behaviour of the JS source new/atoms/is-rtl-lang.mjs.
bool isRtlLang(String lang) => lang != 'en';
