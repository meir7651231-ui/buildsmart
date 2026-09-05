// ⚛️ אטום-Dart (דרגת-חוזה) · campaignCsvRows — שורות-CSV לסיכום קמפיין-חיוג.
// מוצא: maor/src/lib/dialer.ts:159-169 · המקור: new/atoms/campaign-csv-rows.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה מטריצת-CSV — שורת-כותרת קבועה ואז שורה פר-רשומת-יומן, בסדר-היומן.
// שקעים (חוק-1/חוק-3):
//   c            — אובייקט-הקמפיין; c.log = מערך-רשומות (id · outcome · note? · at).
//   nameOf       — פונקציית-שקע id ⇒ שם-להצגה (השכן nameOf הוזרק כפרמטר).
//   outcomeLabels— מפת-שקע outcome ⇒ תווית (השכן OUTCOME_LABELS הוזרק כפרמטר).
// קלט: השקעים לעיל. פלט: List<List<String>> — כותרת + שורה לכל רשומה.
//
// הערת-המרה (מקור→Dart):
//   • `e.note ?? ''` (null-coalescing) ⇒ `(e['note'] ?? '')` — חסר/null ⇒ '' (חוק-4).
//   • גישת-שדה JS (e.id/e.outcome/e.at, c.log) ⇒ מפתחות-Map ['id']/['outcome']/['at']/['log'].
//   • המרת-מפורש ל-String על כל תא — המקור מייצר מחרוזות; שומר טיפוס-פלט הדוק.
//   • אין locale/פורמט/getMonth/truthiness מיוחדים.

/// Builds the CSV matrix for a dialing-campaign summary: a fixed header row,
/// then one row per log entry in log order. Verbatim behaviour of the JS source.
/// Sockets (Law-1): [nameOf] maps an entry id to a display name; [outcomeLabels]
/// maps an outcome to its label. Missing note ⇒ '' (JS `?? ''`).
List<List<String>> campaignCsvRows(
  Map<String, dynamic> c,
  String Function(dynamic) nameOf,
  Map<dynamic, dynamic> outcomeLabels,
 {required String Function(String) term}) {
  final List<List<String>> rows = [
    [term('shm'), term('tvtsah'), term('harh'), term('mty')],
  ];
  for (final e in (c['log'] as List)) {
    rows.add([
      nameOf(e['id']),
      outcomeLabels[e['outcome']] as String,
      (e['note'] ?? '') as String,
      e['at'] as String,
    ]);
  }
  return rows;
}
