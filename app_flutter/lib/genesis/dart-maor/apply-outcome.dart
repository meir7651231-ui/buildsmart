// ⚛️ אטום-Dart (דרגת-חוזה) · applyOutcome — החלת תוצאת-שיחה על חזית-תור-הקמפיין.
// מוצא: maor/src/lib/dialer.ts:46-55 · המקור: new/atoms/apply-outcome.mjs.
// חוזה: new/atoms/apply-outcome.contract.md · טוהר: פונקציית top-level עצמאית,
//        אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: מוציאים את המזהה שבראש-התור, רושמים ליומן {id,outcome,at}, ומחזירים
//        קמפיין חדש (immutable). תוצאה שברשימת-החזרה ⇒ המזהה נדחף לסוף-התור.
// שקעים (חוק-1, אפס import פנימי): currentId (השכן שמוציא את מזהה-הראש) ו-
//        requeueOutcomes (רשימת-התוצאות שמחזירות-לתור) — הוזרקו כפרמטרים.
//
// הערות-המרה (מקור→Dart):
//  · truthiness: `if (!id) return c;` — id נפילתי (null/מחרוזת-ריקה) ⇒ no-op,
//    מוחזרת אותה רפרנס בדיוק (=== של JS ⇒ identical). מומש ב-_truthy נאמן-ל-JS.
//  · `note && note.trim()` — שדה note נכתב רק כשה-note לא-ריק ונחתך ללא-ריק.
//  · spread `{...c, queue, log}` ⇒ מפת-ליטרל עם spread; c לא משוכתב (sublist +
//    רשימות-חדשות שומרים immutability). אין locale/פורמט/getMonth כאן.

/// אמת-JS: null/false/0/NaN/'' נפילתיים; שאר הערכים אמיתיים.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !v.isNaN;
  return true;
}

/// Applies a dial outcome to a campaign's queue front. Verbatim behaviour of the
/// JS source `applyOutcome`: pops the head id, appends a log entry, and returns a
/// new immutable campaign; requeue-outcomes push the id to the tail instead.
/// Returns the same campaign reference unchanged when there is no head id.
Map applyOutcome(
  Map c,
  Object? outcome,
  String? note,
  Object? iso,
  Object? Function(Map) currentId,
  List requeueOutcomes,
) {
  final id = currentId(c);
  if (!_truthy(id)) return c;
  final rest = (c['queue'] as List).sublist(1);
  final queue =
      requeueOutcomes.contains(outcome) ? [...rest, id] : rest;
  final entry = <String, Object?>{'id': id, 'outcome': outcome, 'at': iso};
  if (note != null && note.trim().isNotEmpty) entry['note'] = note.trim();
  return {...c, 'queue': queue, 'log': [...(c['log'] as List), entry]};
}
