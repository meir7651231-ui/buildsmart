// ⚛️ אטום-Dart (דרגת-חוזה) · orbitBlue — ערך-מערכת קבוע (ערכת "אורביט", כחול קוסמי).
// מוצא: maor/src/lib/orbitTheme.ts:17-36 · המקור: new/atoms/orbit-blue.mjs.
//        חוק-4 — התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
// טוהר: קבוע top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core).
//
// תפקיד: זהות-הפלטפורמה של מסך ההרשמה — קבוע `{vars, scene}`:
//        vars = מפת 15 משתני-CSS · scene = שם פלטת-הכדור ('Aurora').
// קלט:  אין. פלט: מפה קבועה — 'vars' (Map<String,String>, 15 מפתחות בסדר-הליטרל) + 'scene' (String).
//
// הערות-המרה (מקור→Dart):
//  • ה-JS מייצא `const ORBIT_BLUE = {vars:{...}, scene:'Aurora'}` (object מקונן).
//    ב-Dart ⇒ `const Map<String,Object>` עם 'vars'=Map<String,String> ו-'scene'=String.
//    סדר-המפתחות של vars נשמר (Dart map literal = insertion-order) — נאמן למקור.
//  • כל הערכים מחרוזות-hex/rgb/rgba טהורות — אין locale/פורמט/getMonth/truthiness/מוטביליות.
//    אין זנב-קוד להמיר (קבוע בלבד).

/// The "Orbit" (cosmic blue) theme. Constant system value: `{vars, scene}` where
/// `vars` is the 15-entry CSS-variable map (injected into `.orbit-screen`) and
/// `scene` names the sphere palette. Verbatim port of `ORBIT_BLUE` from
/// new/atoms/orbit-blue.mjs; key order matches the JS object literal.
const Map<String, Object> orbitBlue = {
  'vars': <String, String>{
    '--o-g1': '#1a2340',
    '--o-g2': '#0d1120',
    '--o-g3': '#070a12',
    '--o-a1': 'rgba(110,168,254,0.30)',
    '--o-a2': 'rgba(140,150,255,0.20)',
    '--o-a3': 'rgba(120,200,255,0.15)',
    '--o-a4': 'rgba(110,168,254,0.12)',
    '--o-accent': '#6ea8fe',
    '--o-accent-rgb': '110,168,254',
    '--o-accent2': '#8fa8ff',
    '--o-glow': 'rgba(120,150,255,0.30)',
    '--o-btn-a': '#7d9bff',
    '--o-btn-b': '#5570ff',
    '--o-btn-text': '#ffffff',
    '--accent': '#6ea8fe',
  },
  'scene': 'Aurora',
};
