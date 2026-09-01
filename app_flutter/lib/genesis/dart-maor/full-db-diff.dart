// ⚛️ אטום-Dart (דרגת-חוזה) · fullDbDiff — ה-DB המלא כ-diff להעלאה ראשונה לענן ריק.
// מוצא: maor/src/lib/cloud-diff.ts:173-181 · המקור: new/atoms/full-db-diff.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: סורק את כל אוספי-הישויות (השקע entityCollections) ולכל פריט בונה
//        רשומת-set {col, id, data}; data = **אותה רפרנס** של הפריט (לא עותק).
//        deletes ריק תמיד (העלאה-ראשונה); meta נבנה דרך השקע metaOf.
// שקעים (חוק-1 — אפס import פנימי): entityCollections (רשימת-שמות-אוספים) ו-metaOf
//        (בונה-meta) הוזרקו כפרמטרים; במקור הם שכנים-מיובאים.
//
// הערות-המרה (מקור→Dart, המנוע פספס):
//   • ‏db[col] — במקור אינדוקס-אובייקט; ב-Dart db הוא Map ⇒ db[col] as List.
//   • ‏item.id — במקור גישת-שדה; ב-Dart item הוא Map ⇒ item['id'] (המנוע השאיר item.id — שגוי).
//   • ‏data: item — זהות-רפרנס נשמרת (Map/List של Dart = טיפוס-רפרנס, מקביל ל-=== של JS).
//   • אין locale/פורמט/getMonth/truthiness/substring — רק סריקה והרכבה.

/// The full DB as an upload diff for a first push to an empty cloud.
/// Verbatim behaviour of the JS source `fullDbDiff`.
/// [db] — the database map (keyed by collection name).
/// [entityCollections] — the collection names to scan (injected neighbour).
/// [metaOf] — builds the meta object from [db] (injected neighbour).
Map<String, dynamic> fullDbDiff(
  Map<String, dynamic> db,
  List<String> entityCollections,
  dynamic Function(Map<String, dynamic>) metaOf,
) {
  final sets = <Map<String, dynamic>>[];
  for (final col in entityCollections) {
    for (final item in (db[col] as List)) {
      sets.add({'col': col, 'id': (item as Map)['id'], 'data': item});
    }
  }
  return {'sets': sets, 'deletes': [], 'meta': metaOf(db)};
}
