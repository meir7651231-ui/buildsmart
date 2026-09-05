// ⚛️ אטום-Dart (דרגת-חוזה) · guideIntro — קבוע: פסקת-פתיחת-המדריך (צילום-ערך).
// מוצא: המקור new/atoms/guide-intro.mjs (`GUIDE_INTRO`) — תורגם TS→JS מכונה
//        מ-maor/src/lib/guide.ts:26-30 (5 שורות, שורה לכל מסך בסדר-הלגאסי).
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
// טוהר: ערך top-level עצמאי, אפס import (רק dart:core). אין שכן; אין
//        locale/פורמט/getMonth/truthiness מעורבים — קבוע-מחרוזת בלבד.
//
// תפקיד: פסקת-הדרכה שמופיעה בראש המדריך — חמישה טיפים מופרדים ב-' · ',
//        שורה לכל מסך כסדר המסכים בלגאסי. קלט: אין (קבוע). פלט: String.
//
// הערות-המרה (מקור→Dart · מול DART-PORTING-RULES.md):
//  • הטיוטה של המנוע: `var GUIDE_INTRO = '…' + '…';` — תוקנו שני דברים:
//    (1) מוטביליות — `var` (מוקצה-מחדש) ⇒ `const String` (immutable מוחלט; אין
//        הקצאה-חוזרת במקור, `export const`).
//    (2) שם — `GUIDE_INTRO` (SCREAMING) ⇒ `guideIntro` (lowerCamel, מוסכמת-Dart).
//  • שיטמור-שני-הליטרלים נשמר כמו במקור (adjacent string concat) — ב-const-context
//    של Dart שני ליטרלים סמוכים מתלכדים בזמן-קומפילציה, ערך זהה-ביט.
//  • המחרוזת עברית + סמלים (·, ↩, ⌕, ▶, —) — כולם ב-BMP (U+2000..U+25B6),
//    מועתקים verbatim; אין substring/slice/מודולו/פירוק-מספר ⇒ אף כלל-המרה נוסף
//    לא חל. חוק-5: פיגמנט-ערך בלבד — פרשנותו כ"פתיח-מדריך" חיה בקופסה, לא באטום.

/// Guide intro paragraph — five hint tips separated by ' · ', one line per
/// screen in legacy order. Verbatim port of new/atoms/guide-intro.mjs
/// (`GUIDE_INTRO`).
const String guideIntro =
    'אי אפשר לקלקל — הכל נשמר לבד · ↩ חזרה מחזיר אחורה · Esc סוגר כל חלון · '
    'אבודים? ⌕ חיפוש מוצא הכל (גם עם שגיאות כתיב) · ▶ הדמיה מראה את המערכת לבד.';
