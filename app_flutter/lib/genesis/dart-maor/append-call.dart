// ⚛️ אטום-Dart (דרגת-חוזה) · appendCall — הוספת רישום-שיחה ליומן-טבעת פר-תומך.
// מוצא: maor/src/lib/dialer.ts:126-132 · המקור: new/atoms/append-call.mjs —
//        `export function appendCall(calls, outcome, iso, cap) { ... }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: כל סיווג = שיחה שבוצעה ⇒ מצורף {at, outcome} לסוף היומן, חוץ מ-'skip'
//        (לא חויג ⇒ מוחזר היומן כמו-שהוא, אותה הפניה). שומר טבעת בגודל cap —
//        ותיקות נשמטות, האחרונות נשמרות. טהור — מחזיר מערך חדש (המקור לא משתנה).
// שקע (חוק-1): cap — תקרת-הטבעת (במקור הקבוע CALL_LOG_CAP=200; קיים כאטום call-log-cap).
// קלט: calls (List<Map<String,String>> או null) · outcome · iso · cap. פלט: אותו טיפוס nullable.
//
// הערת-המרה (מקור→Dart):
//   * אין locale/פורמט/getMonth מעורבים.
//   * truthiness: ה-JS `calls ?? []` הוא nullish-coalescing — זהה ל-`??` של Dart (null בלבד).
//   * skip מחזיר את `calls` כלשונו כולל null ⇒ טיפוס-הפלט nullable, ההפניה נשמרת (===).
//   * `[...(calls ?? []), {...}]` בונה רשימה חדשה ⇒ אימוטביליות המקור נשמרת אוטומטית.
//   * `next.slice(next.length - cap)` ⇒ `next.sublist(next.length - cap)`.
//   * אפס מוטביליות מיותרת — `next` הוא final.

/// Appends a call record {at: iso, outcome} to the ring log [calls], keeping at
/// most [cap] entries (oldest dropped). Verbatim behaviour of the JS source
/// new/atoms/append-call.mjs (`appendCall`).
/// 'skip' returns [calls] unchanged (same reference, including null).
/// [cap] is an injected socket (חוק-1 — no internal imports).
List<Map<String, String>>? appendCall(
  List<Map<String, String>>? calls,
  String outcome,
  String iso,
  int cap,
) {
  if (outcome == 'skip') return calls;
  final List<Map<String, String>> next = [
    ...(calls ?? const []),
    {'at': iso, 'outcome': outcome},
  ];
  return next.length > cap ? next.sublist(next.length - cap) : next;
}
