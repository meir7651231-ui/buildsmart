// ⚛️ אטום-Dart (דרגת-חוזה) · sameLoc — זהות שני מיקומי-ניווט (view · selFamilyId · selCourseId).
// מוצא: maor/src/lib/navhist.ts:23-27 (ניווט-אחורה P1.5, shell.navhist) · המקור: new/atoms/same-loc.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אפס שקעים — כמו במקור.
//
// תפקיד: זהים ⇔ שלושת השדות view · selFamilyId · selCourseId שווים. מעבר לאותו
//        מיקום אינו נרשם כצעד-היסטוריה — זו בדיקת-הזהות שמונעת זאת. שדות-נוספים
//        מחוץ לשלושה (scroll וכד') אינם משפיעים.
//
// הערות-המרה (מקור→Dart):
//  • המיקום מיוצג כ-Map (אובייקט-JS ⇒ Map בדארט); גישה a['view'] וכו'.
//  • `===` של JS על מחרוזת/null → `==` בדארט: לערכי String·null הסמנטיקה זהה
//    ('f1'==='f1' ⇒ true, null==='f1' ⇒ false, null===null ⇒ true).
//  • חוזה-הקלט מגדיר ששלושת השדות קיימים תמיד ({view, selFamilyId, selCourseId}) —
//    לכן אין צורך בהבחנת missing-מול-null (כלל-2 של DART-PORTING-RULES רלוונטי רק
//    כשמפתח עשוי להיעדר; כאן שדה-חסר אינו קלט-חוזי).
//  • אין locale/תאריך/מיון — אף כלל-המרה אחר אינו נוגע.

/// Whether two navigation locations are identical: equal on all three of
/// view, selFamilyId, selCourseId (extra fields ignored). Verbatim port of
/// new/atoms/same-loc.mjs (pure, zero sockets).
bool sameLoc(dynamic a, dynamic b) {
  return a['view'] == b['view'] &&
      a['selFamilyId'] == b['selFamilyId'] &&
      a['selCourseId'] == b['selCourseId'];
}
