// ⚛️ אטום-Dart (דרגת-חוזה) · hokEffectivelyActive — האם הו"ק אפקטיבית-פעילה.
// מוצא: maor/src/components/supporters/lib.ts:694-704 · המקור: new/atoms/hok-effectively-active.mjs
// העוזר-הפרטי monthsAgoIso (מקור 682-687) הוטמע כלשונו — לא שקע.
// חוזה: new/atoms/hok-effectively-active.contract.md · טוהר: top-level, אפס import (dart-core בלבד).
// חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// הערות-המרה (מקור→Dart · DART-PORTING-RULES):
//  · אובייקטי-JS (sp, hok, hist-entry) ⇒ Map<String, Object?>; sp.hok ⇒ sp['hok'].
//  · truthiness (כלל-7): JS `!h`/`!h.active`/`!h.kevaId`/`!last`/`!iso` ≠ Dart.
//    ⇒ שקע פנימי `_truthy` שמחקה JS-falsy (false/0/NaN/''/null).
//  · `sp.hist ?? []` (כלל-2, null≠undefined): fallback רק על היעדר/null, לא על falsy אחר.
//  · `e.d || ''` (JS ||): מחזיר את e.d אם truthy, אחרת '' — משמש להשוואה **וגם** להשמה.
//  · השוואת-מחרוזות `>` ⇒ `compareTo(...) > 0` (סדר-לקסיקוגרפי, סמנטיקת-JS על ISO).
//  · Infinity ⇒ double.infinity; `.slice(0,7)` ⇒ substring בטוח-אורך (כלל-5).

/// מחקה JS-truthiness: false/0/NaN/''/null ⇒ false; כל השאר ⇒ true.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// חודשים-אזרחיים מאז תאריך-ISO עד היום (0 = אותו חודש). ריק ⇒ Infinity.
num _monthsAgoIso(String iso, String todayIso) {
  if (!_truthy(iso)) return double.infinity;
  final a = (iso.length >= 7 ? iso.substring(0, 7) : iso).split('-');
  final b = (todayIso.length >= 7 ? todayIso.substring(0, 7) : todayIso).split('-');
  final y = num.parse(a[0]);
  final m = num.parse(a[1]);
  final ty = num.parse(b[0]);
  final tm = num.parse(b[1]);
  return (ty - y) * 12 + (tm - m);
}

/// Returns whether the supporter's standing-order (hok) is effectively active.
/// Verbatim behaviour of the JS source `hokEffectivelyActive`.
///  - no hok / flag off ⇒ false
///  - manual hok (no kevaId) ⇒ trusts the flag ⇒ true
///  - clearing hok (kevaId): true unless the latest נדרים/סולה charge is > 2 months old.
bool hokEffectivelyActive(Map<String, Object?> sp, String todayIso) {
  final h = sp['hok'];
  if (h is! Map || !_truthy(h['active'])) return false;
  if (!_truthy(h['kevaId'])) return true; // הו"ק ידני — אין לאפ-אוטומטי
  var last = '';
  final hist = sp['hist'];
  final entries = hist is List ? hist : const <Object?>[];
  // 🐛 נחיל-סולה C7: גם חיובי-סולה נחשבים "חיות" של הו"ק-סליקה
  for (final e in entries) {
    if (e is! Map) continue;
    final clearer = e['clearer'];
    final ed = _truthy(e['d']) ? e['d'] as String : '';
    if ((clearer == 'נדרים' || clearer == 'סולה') && ed.compareTo(last) > 0) {
      last = ed;
    }
  }
  if (!_truthy(last)) return true; // עדיין אין היסטוריית-נדרים — סומכים על הדגל
  return _monthsAgoIso(last, todayIso) <= 2;
}
