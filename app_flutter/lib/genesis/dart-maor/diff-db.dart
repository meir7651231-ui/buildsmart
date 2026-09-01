// חוט · diff-db — השוואת שני מצבי-DB לסט-פעולות מינימלי (sets/deletes/meta).
// חוזה: new/atoms/diff-db.contract.md · המרה מ-JS (new/atoms/diff-db.mjs) —
// התנהגות זהה-לחלוטין למקור (חוק-4). חולץ כלשונו מ-maor/src/lib/cloud-diff.ts:147-172.
// השכנים entityCollections/metaKeys/sameJson/metaOf הוזרקו כשקעים (חוק-1 — אפס import).
// אפס-import (dart-core בלבד). prev/next = Map; פריטי-אוסף = Map עם 'id'.
// שקעי-JS ⇒ Dart: === רפרנס ⇒ identical · Map.get/delete ⇒ []/remove ·
// !old (אובייקט-אמיתי תמיד truthy) ⇒ old == null · meta=null ⇒ dynamic meta.
Map<String, dynamic> diffDb(
  Map<String, dynamic> prev,
  Map<String, dynamic> next,
  List<String> entityCollections,
  List<String> metaKeys,
  bool Function(dynamic a, dynamic b) sameJson,
  dynamic Function(Map<String, dynamic> db) metaOf,
) {
  final sets = <Map<String, dynamic>>[];
  final deletes = <Map<String, dynamic>>[];
  for (final col in entityCollections) {
    final prevList = prev[col];
    final nextList = next[col];
    if (identical(prevList, nextList)) continue;
    final prevById = <dynamic, dynamic>{};
    for (final x in (prevList as List)) {
      prevById[(x as Map)['id']] = x;
    }
    for (final item in (nextList as List)) {
      final id = (item as Map)['id'];
      final old = prevById[id];
      prevById.remove(id);
      if (old == null || !sameJson(old, item)) {
        sets.add({'col': col, 'id': id, 'data': item});
      }
    }
    for (final id in prevById.keys) {
      deletes.add({'col': col, 'id': id});
    }
  }
  dynamic meta;
  for (final k in metaKeys) {
    if (!sameJson(prev[k], next[k])) {
      meta = metaOf(next);
      break;
    }
  }
  return {'sets': sets, 'deletes': deletes, 'meta': meta};
}
