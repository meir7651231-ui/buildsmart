// חוט · filter-ayin-board — סינון מסך-הטיפול של העין (טקסט/סטטוס/שלב).
// המרה מ-JS (new/atoms/filter-ayin-board.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// normSearch מוזרק כשקע (חוק-1 — אפס import פנימי). אפס-import (dart-core בלבד).
//
// תיקוני-מנוע (הזנב שהמנוע פספס):
//   • it.done/it.stage/it.supporter... ⇒ גישת-מפה it['done'] (הפריטים = Map, לא אובייקטים).
//   • JS truthiness `it.done`/`!it.done`/`stage &&`/`!nq` ⇒ _truthy/_falsy מפורש (§7).
//     במיוחד `_truthy(stage)`: stage=null (undefined ב-JS) = falsy ⇒ אינו מסנן.
//   • _falsy מכבד את כל ה-falsy של JS (null/false/''/0/NaN) — לא רק ריק-מחרוזת.
List<Map<String, dynamic>> filterAyinBoard(
  List<Map<String, dynamic>> items,
  dynamic q,
  dynamic status,
  dynamic stage,
  String Function(dynamic) normSearch,
) {
  final nq = normSearch(q);
  return items.where((it) {
    if (status == 'wait' && _truthy(it['done'])) return false;
    if (status == 'done' && _falsy(it['done'])) return false;
    if (_truthy(stage) && it['stage'] != stage) return false;
    if (_falsy(nq)) return true;
    return normSearch([it['supporter'], it['name'], it['note']].join(' '))
        .contains(nq);
  }).toList();
}

// JS falsy: null/undefined/false/0/NaN/'' ⇒ falsy.
bool _falsy(dynamic v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is String) return v.isEmpty;
  if (v is num) return v == 0 || v.isNaN;
  return false;
}

bool _truthy(dynamic v) => !_falsy(v);
