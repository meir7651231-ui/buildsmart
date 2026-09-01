// ⚛️ אטום-Dart (דרגת-חוזה) · relabelHistByTxn — ריפוי-תוויות רטרואקטיבי ב-hist לפי txn/ref.
// מוצא: maor/src/lib/nedarimSync.ts:344-366 · המקור: new/atoms/relabel-hist-by-txn.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: על פני רשימת-תומכים, לכל רשומת-hist שמפתחה (txn ⇐ נפילה-ל-ref, שניהם trim)
//        נמצא בקבוצת-ה-txns — קובעים clearer=label. שימור-זהות מוחלט: מערך/עצם שלא
//        נגע מוחזר באותה רפרנס בדיוק (=== במקור ⇒ identical ב-Dart), אפס-מוטציה של הקלט.
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · truthiness (כלל 7): JS `(h.txn || '').trim() || (h.ref || '').trim()` — נפילה
//    כשהמחרוזת-אחרי-trim ריקה. שוקף מפורשות: txnT ריק ⇒ refT.
//  · null מול undefined (כלל 2): שדה-חסר במפה = null; `_trimOr(null) => ''` (כמו `x||''` ב-JS).
//  · מוטביליות: `{...h, clearer:label}` ⇒ `{...m, 'clearer': label}` — מפה חדשה, המקור לא נוגע.
//  · שימור-זהות: מפת-Set על ה-txns; רשומה/תומך לא-נגוע מוחזר identical.
//  אין locale/פורמט/getMonth/substring/מודולו/פירוק-מספר בקוד-זה.

/// תוצאת relabelHistByTxn — רשימת-התומכים (אולי אותה רפרנס) + מונה-השינויים.
class RelabelResult {
  final List<dynamic> supporters;
  final int changed;
  const RelabelResult(this.supporters, this.changed);
}

// שקע-פנימי טהור: מקביל ל-`(v || '').trim()` של JS — null/חסר ⇒ '', אחרת toString().trim().
String _trimOr(dynamic v) => v == null ? '' : v.toString().trim();

/// Verbatim behaviour of the JS source `relabelHistByTxn`.
/// Retroactively relabels hist entries whose txn (falling back to ref, both
/// trimmed) is in `txns`, setting `clearer = label`. Untouched supporters and
/// entries are returned by identity (=== in JS ⇒ identical in Dart); the input
/// is never mutated.
RelabelResult relabelHistByTxn(
    List<dynamic> supporters, List<dynamic> txns, String label) {
  // Set = txns.map(trim).filter(Boolean) — trim דו-צדדי + החרגת-ריקים.
  final set = <String>{};
  for (final t in txns) {
    final s = (t as String).trim();
    if (s.isNotEmpty) set.add(s);
  }
  if (set.isEmpty) return RelabelResult(supporters, 0); // זהות-עצם של המערך.

  var changed = 0;
  final out = supporters.map((sp) {
    final m = sp as Map;
    final hist = m['hist'];
    if (hist == null || (hist as List).isEmpty) return sp; // בלי-hist ⇒ זהות-עצם.
    var touched = false;
    final next = hist.map((h) {
      final hm = h as Map;
      final txnT = _trimOr(hm['txn']);
      final key = txnT.isNotEmpty ? txnT : _trimOr(hm['ref']);
      if (key.isEmpty || !set.contains(key) || hm['clearer'] == label) return h;
      touched = true;
      changed++;
      return {...hm, 'clearer': label};
    }).toList();
    return touched ? {...m, 'hist': next} : sp;
  }).toList();

  return RelabelResult(out, changed);
}
