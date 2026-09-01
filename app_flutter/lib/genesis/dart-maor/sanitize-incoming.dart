// ⚛️ אטום-Dart (דרגת-חוזה) · sanitizeIncoming — חיזוק מסמך-ישות מרוחק: שדות-רשימה תמיד מערכים
// מוצא: maor/src/lib/cloud-merge.ts:18-40 (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/sanitize-incoming.mjs · החוזה: sanitize-incoming.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import. טבלת LIST_FIELDS = קבוע-מנגנון
//        מקובץ-המקור, מוטבעת כלשונה (אפס שקעים — כמו במקור).
//
// תפקיד: מסמך שנכתב בגרסה ישנה / נערך ידנית ב-Firestore עלול להגיע בלי
//        שדות-רשימה (או עם ערך לא-מערך) — צרכני `for (const m of f.members)`
//        היו קורסים. לכל אוסף בטבלה מובטח שכל שדה-רשימה הוא List ([] כשחסר/פגום).
//
// הערות-המרה (מקור→Dart):
//  • `Array.isArray(out[f])` ⇒ `out[f] is List` — אותה סמנטיקה בדיוק: null/חסר/
//    מחרוזת/מספר/מפה ⇒ לא-מערך ⇒ מוחלף; כל List (גם ריק) ⇒ נשמר כמות-שהוא.
//  • `{ ...out, [f]: [] }` ⇒ `{...out, f: <dynamic>[]}` — ב-Dart (LinkedHashMap)
//    השמה למפתח שכבר נכנס מה-spread שומרת את מיקומו המקורי, בדיוק כמו JS
//    (computed-property על אובייקט קיים); מפתח חדש נוסף לסוף — גם כמו JS.
//  • זהות-הפניה: אוסף שאינו בטבלה, או מסמך שכל שדותיו תקינים ⇒ מוחזר אותו
//    אובייקט בדיוק (identical) — אפס שכפול, כמו `return item` / `out = item` במקור.
//  • אין locale/תאריכים/לוח-עברי — אין צורך בשקעים (חוק-11 לא חל).

/// טבלת-המנגנון (LIST_FIELDS) — קבוע מקובץ-המקור, מוטבע כלשונו.
const Map<String, List<String>> _listFields = {
  'families': ['members', 'docs'],
  'enrollments': ['payments', 'absences'],
  'supporters': ['donations'],
  // קופות צדקה — ריקונים ולוג ניקוד (BUILD-ORDER-TZEDAKA)
  'tzBoxes': ['collections'],
  'tzCoordinators': ['scoreLog'],
  // חנות — רכיבי מוצר, מימושים וקריטריונים (BUILD-ORDER-SHOP)
  'shopProducts': ['components'],
  'shopAssignments': ['redemptions', 'criterionIds'],
  // רשימת ההמתנה על הפריט (SHOP6 חנות 27)
  'shopItems': ['waits'],
};

/// Harden a remote entity document: every list-field of the collection is
/// guaranteed to be a List ([] when missing/broken). A field that is already
/// a List is untouched (same reference); a collection not in the table — or a
/// document whose fields are all valid — returns the exact same object
/// (identity, no cloning). Verbatim of new/atoms/sanitize-incoming.mjs.
Map<String, dynamic> sanitizeIncoming(String col, Map<String, dynamic> item) {
  final List<String>? fields = _listFields[col];
  if (fields == null) return item;
  Map<String, dynamic> out = item;
  for (final f in fields) {
    if (out[f] is! List) out = {...out, f: <dynamic>[]};
  }
  return out;
}
