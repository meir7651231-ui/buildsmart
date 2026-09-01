// ⚛️ אטום-Dart (דרגת-חוזה) · cockpitWorkListText — רשימת-המשימות כטקסט (שורה למשימה).
// מוצא: maor/src/components/supporters/cockpit.ts:289 + KIND_ICON:278 (הוטבע inline).
//        המקור-הקדוש: new/atoms/cockpit-work-list-text.mjs. חוק-4 — זהה-ביט למקור-JS.
// טוהר: פונקציית top-level עצמאית, אפס import (dart:core בלבד).
//
// קלט: queue (Map{tasks:List<Map{kind,name,phone,reason}>}). פלט: String (join '\n').
// הערות-המרה:
//  • KIND_ICON הוטבע inline (Map-literal קבוע).
//  • JS `t.name || 'ללא שם'` — ריק/חסר ⇒ 'ללא שם' (truthiness) ⇒ null/'' בדיקה.
//  • JS `t.phone ? ' · '+t.phone : ''` — טלפון ריק ⇒ מדולג.

/// Task list as text (one line per task) — for copy/share.
/// Verbatim port of new/atoms/cockpit-work-list-text.mjs (KIND_ICON inlined).
String cockpitWorkListText(Map queue) {
  const kindIcon = {'call': '📞 שיחה', 'thanks': '💛 תודה', 'hok': '🔁 הו״ק'};
  return (queue['tasks'] as List).map((tt) {
    final t = tt as Map;
    final name = t['name'];
    final nm = (name == null || name == '') ? 'ללא שם' : name;
    final phone = t['phone'];
    final ph = (phone == null || phone == '') ? '' : ' · ' + (phone as String);
    return kindIcon[t['kind']]! + ' · ' + (nm as String) + ph + ' — ' + (t['reason'] as String);
  }).join('\n');
}
