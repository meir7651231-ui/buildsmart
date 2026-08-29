// ⚛️ אטום-Dart (דרגת-חוזה) · guideRecipes — טקסט "מתכונים" למדריך 📖 (רצף
//    פעולות נפוצות: תשלום+קבלה · ניקוב · משפחה-חדשה · חוג · תרומה · תדפיס · גיבוי).
// מוצא: maor/src/lib/guide.ts:80-86 (7 שורות) · המקור: new/atoms/guide-recipes.mjs —
//        `export const GUIDE_RECIPES = '...' + '...' + '...' + '...'` (שרשור 4 חלקים).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש); נתון-קבוע בלבד.
//
// תפקיד: ערך-מערכת קבוע יחיד. אין קלט, אין locale/פורמט/getMonth/truthiness/מודולו.
// קלט:  אין. פלט: String — הצירוף המדויק של ארבעת חלקי-המקור.
//
// הערות-המרה (מקור→Dart):
//  • `export const GUIDE_RECIPES = 'a' + 'b' + 'c' + 'd'` → getter top-level שמחזיר
//    `const 'a' + 'b' + 'c' + 'd'` — שרשור-מחרוזות-קבועות בזמן-קומפילציה (const-safe).
//  • המחרוזת נושאת גרשיים-כפולים (") בתוכה ("ניקוב", "לא נמצא/ה במערכת?") ⇒ עוטפים
//    בגרש-יחיד ('...') כדי לשקף בדיוק את בתי-המקור בלי escaping (המקור עצמו ב-JS
//    עטוף גרש-יחיד עם " פנימיים — אותו דין).
//  • כל תו מועתק כלשונו: ← ⚙ 💳 ＋ · ✦ ⬇ (fullwidth plus U+FF0B, לא '+' רגיל).

/// Fixed guide "recipes" text — the common action sequences shown in the 📖 guide.
/// Verbatim port of new/atoms/guide-recipes.mjs (`GUIDE_RECIPES`): exact
/// concatenation of the four source parts, bit-identical to the JS snapshot.
String get guideRecipes =>
    'תשלום + קבלה ← ⚙ ליד השיבוץ ← 💳 ← ＋ קבלת תשלום · ניקוב ← כפתור "ניקוב" בכרטיס · ' +
    'משפחה חדשה תוך כדי שיבוץ ← "לא נמצא/ה במערכת?" · חוג מתאים לילד ← ✦ מצא חוג · ' +
    'תרומה ← תומכות ← לחיצה על השם ← ＋ תרומה · רשימה למורה ← החוג ← ⬇ תדפיס למורה · ' +
    'גיבוי ← הגדרות ← גיבוי מלא.';
