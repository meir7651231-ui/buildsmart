// ⚛️ אטום-Dart (דרגת-חוזה) · orgSizes — שלוש דרגות-גודל-ארגון לאשף ההרשמה.
// מוצא: maor/src/lib/signupWizard.ts (VERTICAL/גודל) · המקור: new/atoms/org-sizes.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של שלוש דרגות-הגודל, בסדר-המקור בדיוק, כל אחת {id,label,sub}.
// קלט:  אין. פלט: List<Map<String,String>> באורך 3 — small/medium/large.
//
// הערות-המרה (מקור→Dart):
//  • `export const ORG_SIZES = [{...},{...},{...}]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותם מזהים/תוויות/כתוביות, אותו סדר. הכתוביות מכילות
//    en-dash '–' ('5–20') ו-'+' ('20+') כמו במקור — הועתקו verbatim.
//  • אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד. מפת-const ⇒ בלתי-משתנה.

/// The three fixed org-size tiers, in source order, each {id,label,sub}.
/// Verbatim port of new/atoms/org-sizes.mjs (`ORG_SIZES`).
List<Map<String, String>> get orgSizes => const [
      {'id': 'small', 'label': 'קטן', 'sub': 'עד 5 אנשי צוות'},
      {'id': 'medium', 'label': 'בינוני', 'sub': '5–20 אנשי צוות'},
      {'id': 'large', 'label': 'גדול', 'sub': '20+ אנשי צוות'},
    ];
