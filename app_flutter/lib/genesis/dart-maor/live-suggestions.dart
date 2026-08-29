/// חוט · live-suggestions — ההצעות החיות (בלי המסומנות "טופל" ב-attnDone).
/// המרה נאמנה מ-new/atoms/live-suggestions.mjs (חוק-4: המקור קדוש).
/// חולץ כלשונו מ-maor/src/components/shop8/lib.ts:140-143; השכן suggestions
/// הוזרק כשקע (חוק-1 — אפס import פנימי).
///
/// תיקוני-המרה מעבר לטיוטת-המנוע:
///  · db.attnDone / s.key → גישת-מפה db['attnDone'] / s['key'] (JS-object → Map).
///  · !done[key] ⇒ _falsy (כלל-המרה 7): truthiness של JS ≠ Dart — falsy = null/false/0/''/NaN.
///  · .filter → .where(...).toList() כדי שיהיה אינדקסבל (JS filter מחזיר מערך).
List<dynamic> liveSuggestions(
    dynamic db, dynamic todayIso, dynamic config, dynamic suggestions) {
  final done = db['attnDone'] ?? {};
  final result = suggestions(db, todayIso, config) as List;
  return result.where((s) => _falsy(done[s['key']])).toList();
}

/// falsy של JS: undefined/null · false · 0 · '' · NaN. כל השאר truthy.
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}
