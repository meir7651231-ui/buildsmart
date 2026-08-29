// ⚛️ אטום-Dart (דרגת-חוזה) · repairCardsFromRows — ריפוי-כרטיסים מרשומות-ספק:
// תיקון תווית-סליקה + מילוי-אם-ריק של פרטי-קשר. אידמפוטנטי; לעולם לא דורס ערך קיים.
// מוצא: maor/src/lib/nedarimSync.ts:367-404 (חולץ כלשונו ל-new/atoms/repair-cards-from-rows.mjs).
// חוזה: new/atoms/repair-cards-from-rows.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקע (חוק-1): fillCardFromCharge(sp, row) — קריאת-השכן הוזרקה כפרמטר; מחזירה את
//              **אותה הפניה** כשאין מה למלא (זה המנגנון שמאחוריו ספירת-enriched עובדת).
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  · `===` של JS ⇒ `identical()` ב-Dart (זהות-הפניה שמניעה relabeled/enriched ואת
//    ההחזרה-באותה-הפניה של כרטיס-שלא-נגעו-בו).
//  · `(x || '').trim()` על ערך-שדה: מחרוזת-לא-ריקה כמות-שהיא, אחרת '' (undefined/null/''
//    ⇒ '') — משוקף ב-`_str`. `a || b` על שתי מחרוזות-trim ⇒ הראשונה אם לא-ריקה.
//  · `!hist?.length` ⇒ `hist is! List || hist.isEmpty` (null גם נתפס).
//  · `{...h, clearer: label}` ⇒ literal-map עם spread — הפניה חדשה (touched), מול
//    ההפניה-הישנה שנשמרת כשהתווית כבר תואמת.
//  · אין locale/פורמט/getMonth/מודולו-שלילי/substring כאן.

/// Returns `{supporters, relabeled, enriched}`. Verbatim behaviour of the JS source.
Map<String, dynamic> repairCardsFromRows(
  List<dynamic> supporters,
  List<dynamic> rows,
  String label,
  dynamic Function(dynamic sp, dynamic row) fillCardFromCharge,
) {
  final map = <String, dynamic>{};
  for (final r in rows) {
    final k = _key(r['txnId'], r['reference']);
    if (k.isNotEmpty && !map.containsKey(k)) map[k] = r;
  }
  if (map.isEmpty) {
    return {'supporters': supporters, 'relabeled': 0, 'enriched': 0};
  }
  var relabeled = 0;
  var enriched = 0;
  final out = supporters.map((sp) {
    final hist = sp['hist'];
    if (hist is! List || hist.isEmpty) return sp;
    var touched = false;
    final mine = <dynamic>[];
    final next = hist.map((h) {
      final key = _key(h['txn'], h['ref']);
      final row = key.isNotEmpty ? map[key] : null;
      if (row == null) return h;
      mine.add(row);
      if (h['clearer'] == label) return h;
      touched = true;
      relabeled++;
      return {...h, 'clearer': label};
    }).toList();
    if (mine.isEmpty) return touched ? {...sp, 'hist': next} : sp;
    var filled = {...sp, 'hist': next};
    final before = filled;
    for (final row in mine) {
      filled = fillCardFromCharge(filled, row);
    }
    if (!identical(filled, before)) enriched++;
    if (!identical(filled, before) || touched) return filled;
    return sp;
  }).toList();
  return {'supporters': out, 'relabeled': relabeled, 'enriched': enriched};
}

// `(a || '').trim() || (b || '').trim()` — מחרוזת-לא-ריקה אחרי trim, אחרת נפילה ל-b, אחרת ''.
String _key(dynamic a, dynamic b) {
  final ka = (a is String ? a : '').trim();
  if (ka.isNotEmpty) return ka;
  return (b is String ? b : '').trim();
}
