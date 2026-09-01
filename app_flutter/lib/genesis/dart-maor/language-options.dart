// ⚛️ אטום-Dart (דרגת-חוזה) · languageOptions — שפות-בית לבורר.
// מוצא: maor/src/components/families/lib.ts · המקור: new/atoms/language-options.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של חמש שפות-הבית, בסדר-המקור בדיוק.
// קלט:  אין. פלט: List<String> באורך 5 — ['עברית','יידיש','רוסית','צרפתית','אנגלית'].
//
// הערות-המרה (מקור→Dart):
//  • `export const LANGUAGE_OPTIONS = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותן חמש מחרוזות, אותו סדר (index 0='עברית' … 4='אנגלית').
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// The five fixed home-language options, in source order.
/// Verbatim port of new/atoms/language-options.mjs (`LANGUAGE_OPTIONS`).
List<String> get languageOptions =>
    const ['עברית', 'יידיש', 'רוסית', 'צרפתית', 'אנגלית'];
