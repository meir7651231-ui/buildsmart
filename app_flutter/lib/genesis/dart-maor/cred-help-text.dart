// ⚛️ אטום-Dart (דרגת-חוזה) · credHelpText — טקסט-העזרה הקבוע של מדד-האמינות.
// מוצא: maor/src/components/families/lib.ts:55-60 (`CRED_HELP_TEXT` · 6 שורות) ·
//        המקור: new/atoms/cred-help-text.mjs · קודם במנוע-האוטומטי (צילום-ערך).
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: מחרוזת-קבועה יחידה (173 code-units) המתארת את חוקי-הניקוד של מדד-האמינות.
//        חוק-5 — המחרוזת לא יודעת איפה מוצגת; זו רק ערך-פיגמנט.
// קלט:  אין. פלט: String באורך 173 — ביט-זהה לצילום שבבדיקת-ה-JS.
//
// הערות-המרה (מקור→Dart):
//  • `export const CRED_HELP_TEXT = 'a' + 'b' + 'c'` → getter top-level שמחזיר
//    שרשור שלוש אותן טיוטות-מחרוזת בדיוק (const, פיגמנט-קבוע ביט-זהה).
//  • ⚠️ סימני-RTL בלתי-נראים: המקור מכיל 4 תווי LEFT-TO-RIGHT MARK (U+200E)
//    לפני `<48`, לפני `-10`, לפני `-20`, לפני `-2/יום`. הומרו ל-`\u200E` מפורש
//    כדי שהעתקה לא תבלע אותם (המרה-בטוחה מול תו-בלתי-נראה).
//  • en-dash U+2013 (`–`) בטווח 0.8–1.2 ו-middle-dots U+00B7 (`·`) הושארו כלשונם
//    (תווים-נראים, UTF-8 זהה למקור). אין locale/פורמט/getMonth/truthiness/מודולו.

/// The constant credibility-index help text.
/// Verbatim byte-identical port of new/atoms/cred-help-text.mjs (`CRED_HELP_TEXT`).
String get credHelpText =>
    'נוכחות +5 · דיוק +2 · פעולה קהילתית +15 · ביטול מוקדם 0 · '
    'ביטול מאוחר (\u200E<48ש׳) \u200E-10 · No-Show \u200E-20 · אי-פעילות \u200E-2/יום · '
    'מוכפל ב-TrendFactor (0.8–1.2) לפי 3 הפעולות האחרונות';
