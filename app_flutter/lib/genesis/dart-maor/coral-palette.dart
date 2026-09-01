// ⚛️ אטום-Dart (דרגת-חוזה) · coralPalette — ערך-מערכת קבוע (פלטת-אלמוג).
// מוצא: maor/src/lib/publicSite.ts:69-120 · המקור: new/atoms/coral-palette.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core).
//
// תפקיד: ערך-מערכת קבוע — פלטת-ברירת-המחדל CORAL_PALETTE. לפי החוזה
//        (coral-palette.contract.md) ההתחייבות היחידה: הערך זהה-ביט לצילום שבבדיקה.
// קלט:  אין. פלט: מפה קבועה String→String (12 מפתחות, בסדר-הליטרל של המקור).
//
// הערות-המרה (מקור→Dart):
//  • ה-JS מייצא `const CORAL_PALETTE = {...}` (object). ב-Dart ⇒ `const Map<String,String>`.
//    סדר-המפתחות נשמר (Dart map literal = insertion-order) — קריטי כי בדיקת-ה-JS
//    משווה `JSON.stringify` שתלוי-בסדר; הזהב מוכיח את אותו סדר-ביט.
//  • ערכי המפה מחרוזות-hex/rgb טהורות — אין locale/פורמט/getMonth/truthiness/מוטביליות.
//  • זנב-המקור (hexToRgb/rgbToHsl/hslToRgb/toHex/rgbStr) הוא קוד-מת לא-מיוצא
//    שנקטע בחילוץ ה-TS→JS (פונקציית-הגזירה עצמה חסרה — נותרה רק כותרת-JSDoc);
//    החוזה מגדיר את האטום כ**קבוע** CORAL_PALETTE בלבד, לכן אינו מובא לפורט.

/// The coral default palette. Constant system value; the only commitment is that
/// the value is bit-identical to the snapshot in the test (see coral-palette.contract.md).
/// Verbatim port of `CORAL_PALETTE` from new/atoms/coral-palette.mjs. Key order matches
/// the JS object literal so `JSON.stringify`-style serialisation is identical.
const Map<String, String> coralPalette = {
  'c1': '#EC9C9C',
  'c2': '#D97F7F',
  'c3': '#B95F5F',
  'word': '#E29392',
  'ink': '#33272A',
  'paper': '#FFFCFA',
  'cream': '#FBF1EF',
  'blush': '#FFF3F0',
  'marquee': '#F9E4E1',
  'rgb1': '236,156,156',
  'rgb2': '217,127,127',
  'inkRgb': '51,39,42',
};
