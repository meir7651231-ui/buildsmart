// ⚛️ אטום-קבוע · ayin-stages — ערך-מערכת (צילום-ערך). חוזה: ayin-stages.contract.md
// מוצא: maor/src/lib/ayin.ts:18-29 → new/atoms/ayin-stages.mjs
//        (חוק-4 — התנהגות/ערך זהים-ביט למקור-ה-JS, לא-משופרים).
// טוהר: קבועים top-level עצמאיים, אפס import (רק שפה/סטנדרט).
//
// תפקיד: AYIN_STAGES — רשימת מזהי-שלבים קבועה של "העין" (משפך מסחרי).
//        STAGE_FALLBACK — תוויות-ברירת-מחדל ניטרליות (ניתנות לשינוי-שם באשף);
//        במקור-ה-JS זהו `const` שאינו מיוצא ⇒ כאן library-private (קידומת _).
// קלט:  אין (ערך קבוע).
// פלט:  AYIN_STAGES — List<String> בת 5 מזהים; _stageFallback — Map<String,String>.
//
// הערת-המרה (מקור→Dart): אין locale/פורמט/getMonth/truthiness/מודולו מעורבים —
// צילום-ערך טהור. המערך מוצהר `const` (בלתי-משתנה, מוטביליות זהה לצילום הקפוא).

/// Constant stage ids for the commercial funnel ("העין").
/// Bit-identical to the JS source new/atoms/ayin-stages.mjs.
const List<String> ayinStages = ['new', 'lead', 'eyes', 'answer', 'done'];

/// Neutral fallback labels for the stages (renameable in the wizard).
/// Library-private — the JS source keeps this `const` un-exported.
const Map<String, String> _stageFallback = {
  'new': 'חדש',
  'lead': 'בהכנה',
  'eyes': 'רישום',
  'answer': 'מסירה',
  'done': 'הושלם',
};
