// ⚛️ אטום-Dart (דרגת-חוזה) · attachChargeTo — חיבור-ידני של עסקה לכרטיס-תומך
//   (דדופ-גלובלי C2, מגן-ביטול C10).
// מוצא: maor/src/lib/nedarimSync.ts:322-343 · המקור: new/atoms/attach-charge-to.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// שקעים (חוק-1 — השכנים הוזרקו כפרמטרים, אפס import פנימי):
//   chargeDedupKey · histDedupKey · chargeToHist · fillCardFromCharge · withNedarimHok.
// קלט: supporters (רשימת-מפות עם id + hist?) · supId · charge (מפה עם amount + txnId?/d?)
//      + חמשת-השקעים. פלט: מפה {'supporters': ..., 'added': bool}.
//
// הערות-המרה (מקור→Dart):
//   • findIndex(s => s.id === supId)  ⇒  indexWhere((s) => s['id'] == supId)  (חסר ⇒ -1/‏idx<0).
//   • `!charge.amount`  ⇒  `!_truthy(charge['amount'])` — truthiness של JS: 0/‏null/NaN ⇒ falsy
//     ⇒ ביטול (amount=0) מדולג (מגן C10). לא השוואת-שוויון עיוורת.
//   • `key && ...`  ⇒  `key.isNotEmpty && ...` — מחרוזת-ריקה '' היא falsy ב-JS ⇒ בלי-מפתח אין דדופ.
//   • `s.hist ?? []`  ⇒  `(s['hist'] as List?) ?? const []`  (nullish-coalescing → ?? ; חסר/null בלבד).
//   • `sp.hist || []`  ⇒  `(sp['hist'] as List?) ?? const []` — מערך-ריק [] truthy ב-JS ⇒ נשמר;
//     רק null/undefined נופל ל-[]. (‏|| כאן שקול ל-?? כי היחיד ה-falsy האפשרי הוא null.)
//   • supporters.slice()  ⇒  List<Object?>.of(supporters) — עותק רדוד, growable, לא-מוקשח-טיפוס
//     (מערך-JS חסר-גנריקה מקבל כל ערך; List<Object?> משמר זאת — המקור לא-משתנה).
//   • {...sp, hist:[...hist, chargeToHist(charge)]}  ⇒  spread-map + spread-list — אי-מוטציה מלאה.
//   • אין locale/פורמט/getMonth. מוטביליות: final בלבד.

/// Truthiness matching JS `!!v`: null/0/NaN/''/false are falsy, all else truthy.
bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// Manually attaches a charge to a supporter card. Global cross-card dedup (C2)
/// and cancellation guard (C10, amount=0 skipped). Returns
/// `{'supporters': <list>, 'added': <bool>}`. On no-op the original list is
/// returned by reference (identical). Verbatim behaviour of the JS source.
Map<String, Object?> attachChargeTo(
  List supporters,
  Object? supId,
  Map charge,
  String Function(Map) chargeDedupKey,
  String Function(Map) histDedupKey,
  Map Function(Map) chargeToHist,
  Map Function(Map, Map) fillCardFromCharge,
  Map Function(Map, Map) withNedarimHok,
) {
  final idx = supporters.indexWhere((s) => (s as Map)['id'] == supId);
  if (idx < 0) return {'supporters': supporters, 'added': false};
  // 🐛 נחיל-סולה C10: ביטול (amount=0) אינו כסף — המנוע המלא מדלג, וגם המיזוג הידני.
  if (!_truthy(charge['amount'])) return {'supporters': supporters, 'added': false};
  final sp = supporters[idx] as Map;
  final key = chargeDedupKey(charge);
  // 🐛 נחיל-סולה C2 (HIGH): הדדופ פר-כרטיס נספר-פעמיים — עכשיו המפתח נבדק
  // מול hist של **כל** התומכים.
  if (key.isNotEmpty &&
      supporters.any((s) => (((s as Map)['hist'] as List?) ?? const [])
          .any((h) => histDedupKey(h as Map) == key))) {
    return {'supporters': supporters, 'added': false};
  }
  final hist = (sp['hist'] as List?) ?? const [];
  final next = List<Object?>.of(supporters);
  next[idx] = withNedarimHok(
    fillCardFromCharge({...sp, 'hist': [...hist, chargeToHist(charge)]}, charge),
    charge,
  );
  return {'supporters': next, 'added': true};
}
