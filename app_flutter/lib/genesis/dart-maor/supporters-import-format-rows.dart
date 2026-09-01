// ⚛️ אטום-Dart (דרגת-חוזה) · supportersImportFormatRows — תומכות בפורמט-ייבוא 7 העמודות.
// מוצא: maor/src/lib/exportRows.ts:47-55 · המקור: new/atoms/supporters-import-format-rows.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-4 — התנהגות זהה-ביט
//        למקור-ה-JS (המקור קדוש). אפס שקעים — כמו במקור.
//
// תפקיד: שורות-ייצוא של התומכות בפורמט-הייבוא של SupporterImport (round-trip):
//        שורת-כותרת קבועה ['שם','טלפון','אימייל','ת"ז','כתובת','קטגוריה','עבור'] +
//        שורה לכל תורם בסדר-המערך, 7 תאים: name·phone·email·idNum·address·cat·forWho.
// קלט:  db (Map עם supporters = List של Map-י-תורם). פלט: List<List<dynamic>>.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • שדה-חסר עובר כמות-שהוא: undefined של JS ⇒ null של Dart (m['key'] על מפתח-חסר).
//    עמוד-הייצוא במורד מרנדר ריק — אותה סמנטיקה. אורך-השורה תמיד 7 (מפורש בקוד).
//  • אין truthiness/מיון/תאריכים/locale — העתקה ישירה; אין קוארציה בגישת-שדות.
//  • `db.supporters` (גישת-נקודה ב-JS) ⇒ `db['supporters'] as List` — איטרציה בסדר-המערך.

/// Supporter export rows in the 7-column SupporterImport format: a fixed header row
/// then one 7-cell row per supporter in array order, field values passed through as-is
/// (missing field ⇒ null, the JS `undefined`). Verbatim port of
/// new/atoms/supporters-import-format-rows.mjs (`supportersImportFormatRows`).
List<List<dynamic>> supportersImportFormatRows(Map<String, dynamic> db, {required String Function(String) term}) {
  final rows = <List<dynamic>>[
    [term('shm'), term('tlpvn'), term('aymyyl'), term('tz'), term('ktvbt'), term('ktgvryh'), term('abvr')],
  ];
  for (final sp in db['supporters'] as List) {
    final m = sp as Map<String, dynamic>;
    rows.add([
      m['name'],
      m['phone'],
      m['email'],
      m['idNum'],
      m['address'],
      m['cat'],
      m['forWho'],
    ]);
  }
  return rows;
}
