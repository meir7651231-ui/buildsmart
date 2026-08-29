// ⚛️ אטום-Dart (דרגת-חוזה) · filterCommands — סינון+דירוג פקודות לפי שאילתה.
// מוצא: maor-system/src/components/supporters/commands.ts:85 · המקור: new/atoms/commands-filter-commands.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import-אטום (dart:core בלבד). חוק-4 — זהה-ביט למקור-JS.
//        טהור, אפס-שקעים; העוזר `norm` מוטבע inline.
//
// הערות-המרה (JS→Dart):
//  • `norm` כמו ב-build-commands. `q.split(' ')` ⇒ `q.split(' ')`.
//  • `c.keywords.includes(t)` ⇒ `(c['keywords'] as String).contains(t)`.
//  • `nl === q` ⇒ `==` · `nl.startsWith(q)` ⇒ `.startsWith` · `nl.includes(q)` ⇒ `.contains`.
//  • `tokens.every(...)` ⇒ `.every(...)`. ריק ⇒ `where(kind!='openDonor').take(limit)`.
//  • ⚠️ `Array.sort` יציב ב-JS · `List.sort` **לא-יציב** ב-Dart ⇒ שובר-שוויון = אינדקס-מקורי
//    עולה (decorate-sort) כדי לשחזר את סדר-ההוספה בשוויון-ציון (חוק-4, יציבות-JS).
//  • `.slice(0,limit)` ⇒ `.take(limit)` · `.map(s=>s.c)` ⇒ החזרת הפקודה המקורית.

/// Filters+ranks commands by query. Empty query ⇒ actions (no donor cards)
/// capped at [limit]. Verbatim port of new/atoms/commands-filter-commands.mjs
/// (`filterCommands`); JS-stable ordering preserved via original-index tiebreak.
List<Map<String, dynamic>> filterCommands(
  List<Map<String, dynamic>> commands,
  String query, [
  int limit = 12,
]) {
  String norm(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  final q = norm(query);
  if (q.isEmpty) {
    return commands
        .where((c) => c['kind'] != 'openDonor')
        .take(limit)
        .toList();
  }
  final tokens = q.split(' ');
  final scored = <Map<String, dynamic>>[];
  var idx = 0;
  for (final c in commands) {
    final kw = c['keywords'] as String;
    if (!tokens.every((t) => kw.contains(t))) {
      idx++;
      continue;
    }
    final nl = norm(c['label'] as String);
    var score = nl == q
        ? 100
        : nl.startsWith(q)
            ? 60
            : nl.contains(q)
                ? 40
                : 20;
    if (c['kind'] != 'openDonor') score += 5;
    scored.add({'c': c, 'score': score, 'i': idx});
    idx++;
  }
  scored.sort((a, b) {
    final d = (b['score'] as int) - (a['score'] as int);
    if (d != 0) return d;
    return (a['i'] as int) - (b['i'] as int);
  });
  return scored
      .take(limit)
      .map((s) => s['c'] as Map<String, dynamic>)
      .toList();
}
