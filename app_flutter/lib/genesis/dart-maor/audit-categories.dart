// ⚛️ אטום-Dart (דרגת-צילום-ערך) · AUDIT_CATEGORIES — קטגוריות-האבחון של רשימת-התורמים.
// מוצא: new/atoms/audit-categories.mjs (export const AUDIT_CATEGORIES) · חוזה: אותו קובץ.
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — ערך
//        זהה-ביט למקור-ה-JS (המקור קדוש). זהו אטום-קבוע (צילום-ערך), לא פונקציה.
//
// תפקיד: שמונה קטגוריות-האבחון הקבועות, בסדר-המקור. פלט: List<String> קפוא.
//
// הערות-המרה (מקור→Dart):
//  • `export const AUDIT_CATEGORIES = [...]` → `const List<String> auditCategories = [...]`.
//    שמונה מחרוזות עברית, בסדר-המקור בדיוק. הפריט השני 'ת"ז' מכיל גרש-כפול —
//    ב-Dart נעטף במרכאות-יחיד כך שהגרש-הכפול נשאר תו-מילולי (זהה למקור).
//  • המנוע גזר גם EMAIL_RE/digits מזנב-הקובץ — אלה שורות-מתות (הקובץ נקטע, אינן
//    מיוצאות ואינן בחוזה/בבדיקה) ⇒ הושמטו (חוק-4: החוזה קדוש, לא הזנב הקטוע).
//  • מוטביליות: `const` (בלתי-משתנה מוחלט). אין var/locale/פורמט/getMonth/truthiness.

/// The eight fixed donor-audit categories, in source order.
/// Value-snapshot port of new/atoms/audit-categories.mjs (`AUDIT_CATEGORIES`).
const List<String> auditCategories = [
  'כפילות',
  'ת"ז',
  'טלפון',
  'אימייל',
  'כתובת',
  'לוגיקה',
  'ילדים',
  'קשר',
];
