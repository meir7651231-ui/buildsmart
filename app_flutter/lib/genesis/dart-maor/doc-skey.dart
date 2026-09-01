// ⚛️ אטום-Dart (דרגת-חוזה) · docSkey — מפתח-skey של מסמך באוסף נאכף-הרשאה.
// מוצא: maor/src/lib/supporterPartition.ts:42-51 · המקור: new/atoms/doc-skey.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד (מסלול-B, אכיפת-תומכים בשכבת-הנתונים):
//   'supporters' ⇒ מפתח-התומך עצמו (דרך השקע supKeyOf — ה-forWho המחוטא).
//   'events'     ⇒ מפתח-התומך-המקושר (spId→skey דרך המפה; spId לא-מחרוזת/ריק
//                  או שאינו במפה ⇒ המפתח-המשותף).
//   כל אוסף אחר  ⇒ '' (לא נאכף — הקורא לא יזריק skey).
// שקעים (חוק-1 — קריאה-לשכן וקבוע-שכן הוזרקו כפרמטרים):
//   supKeyOf(data) ⇒ String · sharedSupKey ⇒ המפתח-המשותף ('_shared_').
//
// הערות-המרה (מקור→Dart, מול המנוע):
//   • data.spId  ⇒ data['spId']            (גישת-שדה של אובייקט-JS = index על Map).
//   • spId ?     ⇒ spId.isNotEmpty         (Rule 7 — string-truthiness של JS: '' הוא falsy).
//   • map.get(k) ⇒ map[k]                  (ל-Dart-Map אין .get; חסר-מפתח ⇒ null ⇒ ?? shared, Rule 2).
//   • typeof===  ⇒ is String.
//   אין locale/פורמט/getMonth/24:00/substring-שלילי כאן — רק הארבעה לעיל.

/// Returns the enforcement skey of a document in a partition-enforced collection.
/// Verbatim behaviour of the JS source `docSkey`.
String docSkey(
  String col,
  Map<String, dynamic> data,
  Map<String, String> supKeyBySpId,
  String Function(Map<String, dynamic>) supKeyOf,
  String sharedSupKey,
) {
  if (col == 'supporters') return supKeyOf(data);
  if (col == 'events') {
    final raw = data['spId'];
    final spId = raw is String ? raw : '';
    return spId.isNotEmpty ? (supKeyBySpId[spId] ?? sharedSupKey) : sharedSupKey;
  }
  return '';
}
