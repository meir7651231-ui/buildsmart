// ⚛️ אטום-Dart (דרגת-חוזה) · findSupporterDupGroups — קבוצות כפולי-תורמים (Union-Find).
// מוצא: maor/src/lib/dedup.ts:286-341 · המקור: new/atoms/find-supporter-dup-groups.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS
//        (המקור קדוש). השכנים normPhone/normId/supNameCityKey/nameSortKey הוזרקו כשקעים (חוק-1/3).
//
// תפקיד: רכיבי-קשירות (Union-Find עם דחיסת-נתיב) של תומכים שחולקים ≥ מפתח-שיוך אחד:
//        טלפון-מנורמל (≥7 ספרות) · אימייל (trim+lowercase) · ת"ז · מזהה-חיצוני (extId) ·
//        שם|עיר · שם חסין-סדר (≥2 מילים). מפתח-ריק אינו מקשר. טרנזיטיבי. רק קבוצות ≥2 מוחזרות.
// קלט:  supporters — List<Map>: {id, phone?, email?, idNum?, extId?, name?, city?} ·
//        4 שקעים. פלט: List<List> — קבוצות-מזהים, כל קבוצה ≥2.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע פספס/סטה):
//  • השקעים: המקור מקבל אובייקט-שקעים מפורק `{normPhone,normId,supNameCityKey,nameSortKey}`;
//    המנוע פלט `dynamic undefined`. כאן — 4 פרמטרי-פונקציה מפורשים (חוק-1/3).
//  • Map API: המנוע פלט `.get()/.set()` של JS; ב-Dart זה `map[k]` / `map[k]=v`.
//  • truthiness ב-link: `if (!key) return` ⇒ key הוא תמיד String מהשקעים ⇒ `key.isEmpty`.
//    `if (prev)` ⇒ prev הוא id-String או absent(undefined→null); JS-truthy = לא-null ולא-ריק.
//  • יצירת-קבוצה: `groups.get(r) ?? groups.set(r,[]).get(r)` ⇒ `putIfAbsent(r, () => [])`.
//  • `[...groups.values()].filter(...)` ⇒ `groups.values.where(...).toList()` (המנוע השמיט toList).
//  • סדר: Map של Dart (LinkedHashMap) שומר סדר-הכנסה כמו JS-Map ⇒ סדר-הקבוצות זהה. אין
//    מיון פנימי באטום (כלל-מיון-יציב לא רלוונטי כאן). אין locale/getMonth/מוטביליות-נסתרת.

/// Connected-components (Union-Find, path-compressed) of supporters sharing at least
/// one match key: normalized phone (≥7 digits) · email (trim+lowercase) · idNum · extId ·
/// name|city · order-insensitive name (≥2 words). Empty keys never link. Transitive.
/// Only groups of size ≥2 are returned. Verbatim behaviour of the JS source
/// `findSupporterDupGroups`; the four neighbour calls are injected as sockets (Law 1/3).
List<List<dynamic>> findSupporterDupGroups(
  List<Map<String, dynamic>> supporters, {
  required String Function(dynamic) normPhone,
  required String Function(dynamic) normId,
  required String Function(Map<String, dynamic>) supNameCityKey,
  required String Function(dynamic) nameSortKey,
}) {
  final parent = <dynamic, dynamic>{};
  dynamic find(dynamic x) {
    var r = x;
    while (parent[r] != r) {
      r = parent[r];
    }
    var c = x;
    while (parent[c] != r) {
      final nx = parent[c];
      parent[c] = r;
      c = nx;
    }
    return r;
  }

  void union(dynamic a, dynamic b) {
    final ra = find(a);
    final rb = find(b);
    if (ra != rb) parent[ra] = rb;
  }

  for (final sp in supporters) {
    parent[sp['id']] = sp['id'];
  }
  final byPhone = <dynamic, dynamic>{};
  final byEmail = <dynamic, dynamic>{};
  final byId = <dynamic, dynamic>{}; // ת"ז
  final byExt = <dynamic, dynamic>{}; // מזהה-חיצוני (ToremId)
  final byNameCity = <dynamic, dynamic>{};
  final byNameSorted = <dynamic, dynamic>{}; // שם חסין-סדר (בלי חובת-עיר)
  void link(Map<dynamic, dynamic> map, String key, dynamic id) {
    if (key.isEmpty) return; // JS: `if (!key) return` — key is always a String
    final prev = map[key];
    if (prev != null && prev != '') {
      union(prev, id); // JS: `if (prev)` — truthy id
    } else {
      map[key] = id;
    }
  }

  for (final sp in supporters) {
    final p = normPhone(sp['phone']);
    link(byPhone, p.length >= 7 ? p : '', sp['id']);
    link(byEmail, ((sp['email'] ?? '') as String).trim().toLowerCase(), sp['id']);
    link(byId, normId(sp['idNum']), sp['id']);
    link(byExt, ((sp['extId'] ?? '') as String).trim(), sp['id']);
    link(byNameCity, supNameCityKey(sp), sp['id']);
    // מפתח-שם חסין-סדר: תופס כפילות נדרים ("בן צבי רחל"↔"רחל בן צבי") ללא עיר/ת"ז.
    // דורש ≥2 מילים (רווח) כדי לא לקבץ שמות-בודדים נפוצים. תוצאה = הצעה לסקירה-ידנית.
    final ns = nameSortKey(sp['name']);
    link(byNameSorted, ns.contains(' ') ? ns : '', sp['id']);
  }
  final groups = <dynamic, List<dynamic>>{};
  for (final sp in supporters) {
    final r = find(sp['id']);
    groups.putIfAbsent(r, () => []).add(sp['id']);
  }
  return groups.values.where((g) => g.length >= 2).toList();
}
