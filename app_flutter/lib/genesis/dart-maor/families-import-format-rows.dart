// ⚛️ אטום-Dart (דרגת-חוזה) · familiesImportFormatRows — משפחות בפורמט ייבוא 13 העמודות.
// מוצא: maor/src/lib/exportRows.ts:33-46 (תורגם TS→JS) · המקור: new/atoms/families-import-format-rows.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: בונה מטריצת-שורות לייצוא-משפחות — שורת-כותרת בת 13 תאים, ואז שורה
//        פר-משפחה באותו סדר-מקור. תא-9 = 'אלמן' רק אם הסטטוס-משפחתי מכיל 'אלמן'
//        (נו"ן-סופית ן) — אחרת ריק.
// קלט:  db — מפה עם המפתח 'families' (רשימת-מפות-משפחה). כל משפחה: מפתחות
//        name/fatherId/phone/mother/motherId/phone2/city/address/maritalStatus/
//        community/notes (כולם אופציונליים). פלט: List<List<dynamic>> — כותרת + שורות.
//
// הערות-המרה (מקור→Dart, לפי DART-PORTING-RULES):
//  • מפתח-חסר: JS `f.name` על מפתח-חסר ⇒ undefined; ב-Dart `f['name']` ⇒ null.
//    null הוא המקבילה-האמונה ל-undefined בתא-פלט (התא לא נבדק בחוזה כשהוא חסר —
//    רק תא-9 והשם נבדקים). ⇒ מוצג כ-null, זהה-משמעות ל-undefined.
//  • truthiness (כלל 7): `(f.maritalStatus || '')` — ב-JS undefined/null/'' ⇒ ''.
//    ב-Dart `(f['maritalStatus'] ?? '')` תופס null; '' עצמו לא-נתפס אך '' .contains
//    ⇒ false ⇒ אותה תוצאה בדיוק. ⇒ ((f['maritalStatus'] ?? '') as String).
//  • `.includes('אלמן')` ⇒ `.contains('אלמן')` — זהה. 'אלמן' עם ן-סופית (U+05DF);
//    'אלמנה' עם נ-רגילה (U+05E0) ⇒ code-points שונים ⇒ contains=false (כמו JS).
//  • מוטביליות: rows הוא final; מתווסף דרך .add (המקבילה ל-push). אין locale/getMonth.

/// Builds the 13-column families import/export matrix — a header row plus one row
/// per family in source order. Column 9 is 'אלמן' only when maritalStatus contains
/// 'אלמן' (final-nun), otherwise empty. Verbatim port of
/// new/atoms/families-import-format-rows.mjs (`familiesImportFormatRows`).
List<List<dynamic>> familiesImportFormatRows(Map<String, dynamic> db, {required String Function(String) term}) {
  final rows = <List<dynamic>>[
    [
      term('shm'), term('tz-ab'), term('tlpvn'), term('shm-ham'), term('tz-am'), term('t5'),
      term('ayr'), term('ktvbt'), '', term('almn'), term('khylh'), '', term('harvt'),
    ],
  ];
  final families = (db['families'] as Iterable?) ?? const [];
  for (final f in families) {
    final fam = f as Map;
    final maritalStatus = (fam['maritalStatus'] ?? '') as String;
    rows.add([
      fam['name'], fam['fatherId'], fam['phone'], fam['mother'],
      fam['motherId'], fam['phone2'], fam['city'], fam['address'], '',
      maritalStatus.contains(term('almn')) ? term('almn') : '',
      fam['community'], '', fam['notes'],
    ]);
  }
  return rows;
}
