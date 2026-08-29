// ⚛️ אטום-Dart · absenceReasonChips — נורמל מ-const-דאטה לפונקציה (מנוע-טהור; העברית תחולץ למטרה).
// ignore_for_file: non_constant_identifier_names
// ⚛️ אטום-Dart (דרגת-חוזה) · absenceReasonChips — צ'יפי-נימוק לחיסור.
// מוצא: maor/src/components/diary/lib.ts (שימש שני מודאלי-חיסור) · המקור: new/atoms/absence-reason-chips.mjs.
// טוהר: getter top-level עצמאי, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: הרשימה הקבועה של חמשת נימוקי-החיסור, בסדר-המקור בדיוק.
// קלט:  אין. פלט: List<String> באורך 5 — ['מחלה','אירוע משפחתי','שמחה','נסיעה','מזג אוויר'].
//
// הערות-המרה (מקור→Dart):
//  • `export const ABSENCE_REASON_CHIPS = [...]` → getter top-level שמחזיר `const [...]`.
//    ה-const מבטיח פיגמנט-קבוע ביט-זהה; getter נותן ממשק-קריאה טהור בלי משתנה-מודול משותף.
//  • התוכן מועתק כלשונו — אותם חמישה מחרוזות, אותו סדר (index 0='מחלה' … 4='מזג אוויר').
//    אין locale/פורמט/getMonth/truthiness/מודולו — נתון-קבוע בלבד.

/// The five fixed absence-reason chips, in source order.
/// Verbatim port of new/atoms/absence-reason-chips.mjs (`ABSENCE_REASON_CHIPS`).
List<String> absenceReasonChips({required String Function(String) term}) => [term('mchlh'), term('ayrva-mshpchty'), term('shmchh'), term('nsyah'), term('mzg-avvyr')];