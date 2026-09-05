/// חוט · find-duplicate-groups — רכיבי-קשירות של משפחות כפולות (טלפון/שם+עיר).
/// חוזה: find-duplicate-groups.contract.md
/// המרה זהה-לחלוטין מ-new/atoms/find-duplicate-groups.mjs (חוק-4 — המקור קדוש).
/// השכנים phonesOf·nameCityKey שקעים מוזרקים (חוק-1 — אפס import פנימי).
/// אפס import (dart-core בלבד).
List<List<String>> findDuplicateGroups(
  List<dynamic> families,
  List<String> Function(dynamic) phonesOf,
  String Function(dynamic) nameCityKey,
) {
  final parent = <String, String>{};
  String find(String x) {
    var r = x;
    while (parent[r] != r) {
      r = parent[r] as String;
    }
    // דחיסת-נתיב
    var c = x;
    while (parent[c] != r) {
      final nx = parent[c] as String;
      parent[c] = r;
      c = nx;
    }
    return r;
  }

  void union(String a, String b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) {
      parent[ra] = rb;
    }
  }

  for (final f in families) {
    parent[f['id'] as String] = f['id'] as String;
  }
  final byPhone = <String, String>{};
  final byNameCity = <String, String>{};
  for (final f in families) {
    final fid = f['id'] as String;
    for (final p in phonesOf(f)) {
      final prev = byPhone[p];
      if (prev != null) {
        union(prev, fid);
      } else {
        byPhone[p] = fid;
      }
    }
    final nk = nameCityKey(f);
    // JS truthiness: מחרוזת ריקה = falsy (חוק-7 DART-PORTING)
    if (nk != '') {
      final prev = byNameCity[nk];
      if (prev != null) {
        union(prev, fid);
      } else {
        byNameCity[nk] = fid;
      }
    }
  }
  final groups = <String, List<String>>{};
  for (final f in families) {
    final r = find(f['id'] as String);
    groups.putIfAbsent(r, () => <String>[]).add(f['id'] as String);
  }
  return groups.values.where((g) => g.length >= 2).toList();
}
