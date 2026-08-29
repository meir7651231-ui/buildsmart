// ⚛️ אטום-Dart (דרגת-חוזה) · maritalOptions — מצבי-משפחה לבורר.
// מוצא: maor/src/components/families/lib.ts · המקור: new/atoms/marital-options.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של ארבעת מצבי-המשפחה לבורר, בסדר-המקור בדיוק.
// קלט:  אין. פלט: List<String> באורך 4 — ['נשואים','גרושים','אלמן/ה','פרודים'].
//
// הערות-המרה (מקור→Dart):
//  • `export const MARITAL_OPTIONS = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותם ארבעה מחרוזות, אותו סדר (index 0='נשואים' … 3='פרודים').
//    אין locale/פורמט/getMonth/truthiness/מודולו/תאריך — נתון-קבוע בלבד.

/// The four fixed marital-status options for the picker, in source order.
/// Verbatim port of new/atoms/marital-options.mjs (`MARITAL_OPTIONS`).
List<String> get maritalOptions =>
    const ['נשואים', 'גרושים', 'אלמן/ה', 'פרודים'];
