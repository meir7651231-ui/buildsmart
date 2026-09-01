// חוט · merge-donations-preserving — מיזוג-תרומות חסין-אובדן (איחוד לפי rid, מונים רק עולים).
// חוזה: merge-donations-preserving.contract.md
// המרה מ-JS (new/atoms/merge-donations-preserving.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// חולץ כלשונו מ-maor/src/lib/cloud-merge.ts:51-71. טהור, אפס שקעים, אפס import פנימי.
//   • col זר ⇒ incoming עצמו (אותה הפניה — identical, כמו === ב-JS).
//   • filter(Boolean) על rid = truthiness של JS ('' /0/null/NaN ⇒ נופל).
//   • num(v) = מספר-סופי בלבד, אחרת 0 (Number.isFinite).
//   • ללא שימור-מקומי וללא גידול-מונה ⇒ אותה הפניית-incoming (===).
//   • {...incoming, ...} משמר את סדר-המפתחות של incoming (כמו spread ב-JS).
import 'dart:math' as math;

Map<String, dynamic> mergeDonationsPreserving(
  String col,
  Map<String, dynamic> local,
  Map<String, dynamic> incoming,
) {
  if (col != 'supporters') return incoming;

  // truthiness של JS: filter(Boolean) על ה-rid — '' / 0 / null / NaN נופלים.
  bool truthy(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0 && !v.isNaN;
    if (v is String) return v.isNotEmpty;
    return true;
  }

  // Array.isArray(...) ? ... : []
  final List localDon =
      local['donations'] is List ? local['donations'] as List : const [];
  final List incDon =
      incoming['donations'] is List ? incoming['donations'] as List : const [];

  // incRids = new Set(incDon.map(d => d && d.rid).filter(Boolean))
  final incRids = <dynamic>{};
  for (final d in incDon) {
    final rid = d == null ? null : (d as Map)['rid'];
    if (truthy(rid)) incRids.add(rid);
  }

  // localOnly = localDon.filter(d => d && d.rid && !incRids.has(d.rid))
  final localOnly = <dynamic>[];
  for (final d in localDon) {
    if (d == null) continue;
    final rid = (d as Map)['rid'];
    if (truthy(rid) && !incRids.contains(rid)) localOnly.add(d);
  }

  // num(v) = (typeof v === 'number' && Number.isFinite(v)) ? v : 0
  num numOf(dynamic v) => (v is num && v.isFinite) ? v : 0;

  final count = math.max(numOf(incoming['count']), numOf(local['count']));
  final ils = math.max(numOf(incoming['ils']), numOf(local['ils']));
  final usd = math.max(numOf(incoming['usd']), numOf(local['usd']));

  // אין תרומה מקומית-בלבד והמונים לא גדלו ⇒ הענן כמות-שהוא (אותה הפניה).
  if (localOnly.isEmpty &&
      count == numOf(incoming['count']) &&
      ils == numOf(incoming['ils']) &&
      usd == numOf(incoming['usd'])) {
    return incoming;
  }

  return {
    ...incoming,
    'donations': [...incDon, ...localOnly],
    'count': count,
    'ils': ils,
    'usd': usd,
  };
}
