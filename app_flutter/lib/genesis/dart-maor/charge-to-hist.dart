// ⚛️ אטום-Dart (דרגת-חוזה) · chargeToHist — בניית רשומת-hist מעסקת-סליקה.
// מוצא: maor/src/lib/nedarimSync.ts:124-145 · המקור: new/atoms/charge-to-hist.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: בונה h עם d/a/c/clearer תמיד, ומוסיף ref/txn/receipt/last4/kevaId רק כשלא-ריקים (אחרי גזימה).
// שקעים (חוק-1): curOf(charge)⇒מטבע · providerClearer(provider)⇒שם-סולק — הוזרקו כפרמטרים
//        (במקור שכנים ב-nedarimSync; כאן שקעים, אפס import פנימי).
// קלט: charge (Map) + שני השקעים. פלט: Map<String,dynamic> — רשומת-hist.
//
// הערות-המרה (מקור→Dart), מה שהמנוע פספס בזנב:
//  · JS `||` = טוהר (empty-string נופל) ⇒ NOT `??` (null בלבד). d ריק חייב ליפול ל-at.
//    ממומש דרך `_orEmpty` (JS-truthy על מחרוזות/null) ולא `??`.
//  · JS `.slice(0,10)` על מחרוזת קצרה מ-10 = כל המחרוזת (בלי חריגה) ⇒ substring עם קיטום.
//  · JS `if (ref)` = truthy ⇒ `ref.isNotEmpty` ב-Dart (לא `if (ref)` — Dart מצריך bool).
//  · charge.d / charge['d'] — גישת-שדה של Map ב-Dart.
//  · אין locale/פורמט/getMonth — אין המרות-אינדקס.

/// בונה רשומת-hist מעסקת-סליקה. d/a/c/clearer תמיד; ref/txn/receipt/last4/kevaId
/// רק כשלא-ריקים (אחרי גזימה). התנהגות זהה-ביט למקור-ה-JS `chargeToHist`.
Map<String, dynamic> chargeToHist(
  Map<String, dynamic> charge,
  String Function(Map<String, dynamic>) curOf,
  String Function(dynamic) providerClearer,
) {
  // JS: (charge.d || (charge.at || '').slice(0,10) || '').trim()
  final at = _orEmpty(charge['at']);
  final atSlice = at.length <= 10 ? at : at.substring(0, 10);
  final d0 = _orEmpty(charge['d']);
  final String dPick = d0.isNotEmpty ? d0 : (atSlice.isNotEmpty ? atSlice : '');

  final h = <String, dynamic>{
    'd': dPick.trim(),
    'a': charge['amount'],
    'c': curOf(charge),
    'clearer': providerClearer(charge['provider']),
  };

  final ref = _orEmpty(charge['reference']).trim();
  final txn = _orEmpty(charge['txnId']).trim();
  final rec = _orEmpty(charge['receipt']).trim();
  final l4 = _orEmpty(charge['last4']).trim();
  final keva = _orEmpty(charge['kevaId']).trim();

  if (ref.isNotEmpty) h['ref'] = ref;
  if (txn.isNotEmpty) h['txn'] = txn;
  if (rec.isNotEmpty) h['receipt'] = rec;
  if (l4.isNotEmpty) h['last4'] = l4;
  if (keva.isNotEmpty) h['kevaId'] = keva; // חיוב חוזר — נשמר ל-hist לזיהוי-הו"ק מדויק

  return h;
}

// (v || '') של JS על ערך-מחרוזת/null: null או '' ⇒ '' (טוהר); אחרת המחרוזת.
String _orEmpty(dynamic v) => (v == null) ? '' : v as String;
