// ⚛️ אטום-Dart (דרגת-חוזה) · attachChargesBulk — חיבור-אצווה של עסקאות-סליקה
// לכרטיסי-תומכים ממופים, בסיבוב-אחד: אינדקס-id, דדופ **גלובלי** שנבנה פעם מכל
// ה-hist הקיים **ומתעדכן תוך-כדי האצווה** (מגן C2 HIGH), ומגן C10 (amount=0 מדולג).
// מוצא: maor/src/lib/nedarimSync.ts:449-540 · המקור: new/atoms/attach-charges-bulk.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). חמשת השכנים הוזרקו כשקעים (חוק-1/3).
//
// שקעים (מוזרקים כפרמטרים — קריאות-השכנים):
//  • histDedupKey(h)          ⇒ מפתח-דדופ מרשומת-hist ('txn:…'/'ref:…'/'').
//  • chargeDedupKey(charge)   ⇒ המפתח המקביל מעסקה.
//  • chargeToHist(charge)     ⇒ רשומת-hist חדשה.
//  • fillCardFromCharge(sp,c) ⇒ מילוי-אם-ריק של שדות-קשר (שני ארגומנטים במקור!).
//  • withNedarimHok(sp,c)     ⇒ עדכון משבצת-הו"ק (שני ארגומנטים במקור!).
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • truthiness: `if (k)` על מפתח-דדופ = מחרוזת-ריקה false ⇒ `.isNotEmpty` (השקעים
//    מחזירים String לא-null). `if (!charge.amount)` = 0/null false ⇒ `_truthy`.
//  • `s.hist ?? []` / `next[idx].hist || []` — במקור `??` תופס null/undefined ו-`||`
//    תופס גם ריק, אך על **מערך** רק null/undefined נופלים ל-[] ⇒ `(x as List?) ?? const []`.
//  • טוהר-הקלט: `next = supporters.slice()` = עותק-רדוד; next[idx] מוקצה-מחדש לאובייקט
//    חדש (spread) ⇒ איברי-הקלט המקוריים לא מוטבלים. ב-Dart `supporters.toList()` זהה.
//  • byId.get(supId) ⇒ null אם לא-ממופה ⇒ continue (idx == null).
//  • מוטביליות: next/globalKeys/added מוטבלים (var/מבנה-מוטבל); byId final. אין locale/
//    פורמט/getMonth — כל הפורמט חי בשקעים המוזרקים.

/// חיקוי `!!v` של JS לתחום-האטום: null/מחרוזת-ריקה/0/NaN/false ⇒ false, אחרת true.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is String) return v.isNotEmpty;
  if (v is num) return v != 0 && !(v is double && v.isNaN);
  return true;
}

/// Attach a batch of charges to their mapped supporter cards in one pass, with a
/// **global** dedup set (built once from all existing hist, updated during the batch —
/// C2 HIGH) and the C10 guard (amount=0 skipped). Pure — a fresh list is returned.
/// Verbatim port of new/atoms/attach-charges-bulk.mjs (`attachChargesBulk`); the five
/// neighbour calls are injected as sockets (Law 1/3).
Map<String, dynamic> attachChargesBulk(
  List<Map<String, dynamic>> supporters,
  List<Map<String, dynamic>> items,
  String Function(Map<String, dynamic>) histDedupKey,
  String Function(Map<String, dynamic>) chargeDedupKey,
  Map<String, dynamic> Function(Map<String, dynamic>) chargeToHist,
  Map<String, dynamic> Function(Map<String, dynamic>, Map<String, dynamic>) fillCardFromCharge,
  Map<String, dynamic> Function(Map<String, dynamic>, Map<String, dynamic>) withNedarimHok,
) {
  final byId = <dynamic, int>{};
  for (var i = 0; i < supporters.length; i++) {
    byId[supporters[i]['id']] = i;
  }
  final next = supporters.toList();
  // 🐛 נחיל-סולה C2 (HIGH): דדופ **גלובלי** — מפתח שכבר יושב על כרטיס כלשהו
  // (או שנוסף במהלך האצווה) לא נרשם שוב בשום כרטיס אחר.
  final globalKeys = <String>{};
  for (final s in supporters) {
    for (final h in (s['hist'] as List?) ?? const []) {
      final k = histDedupKey(h as Map<String, dynamic>);
      if (k.isNotEmpty) globalKeys.add(k);
    }
  }
  var added = 0;
  for (final item in items) {
    final supId = item['supId'];
    final charge = item['charge'] as Map<String, dynamic>;
    final idx = byId[supId];
    if (idx == null) continue;
    if (!_truthy(charge['amount'])) continue; // 🐛 C10: ביטול (amount=0) אינו כסף
    final key = chargeDedupKey(charge);
    if (key.isNotEmpty && globalKeys.contains(key)) continue;
    if (key.isNotEmpty) globalKeys.add(key);
    final prev = next[idx];
    final merged = <String, dynamic>{
      ...prev,
      'hist': [...((prev['hist'] as List?) ?? const []), chargeToHist(charge)],
    };
    next[idx] = withNedarimHok(fillCardFromCharge(merged, charge), charge);
    added++;
  }
  return {'supporters': next, 'added': added};
}
