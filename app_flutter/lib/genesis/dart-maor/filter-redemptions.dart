// ⚛️ אטום-Dart (דרגת-חוזה) · filterRedemptions — סינון מימושי-שיוך.
// מוצא: maor/src/components/shop/lib.ts:565-575 · המקור: new/atoms/filter-redemptions.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן dateInRange הוזרק כשקע (חוק-1/3).
//
// תפקיד: a.redemptions מסונן ⇒ dateInRange(r.date, from, to) כוללני-משני-הקצוות
//        (קצה ריק=פתוח, ההכרעה בשקע) ‏&& (includeVoided || !r.voidedAt) —
//        includeVoided=true ⇒ גם מבוטלים; אחרת רק מי ש-voidedAt שלו "falsy".
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • truthiness (כלל-7): `!r.voidedAt` של JS = falsy-check (undefined/null/'' ⇒ true).
//    ב-Dart מפתח-חסר ⇒ null; מומש דרך `_falsy` מפורש במקום `!` (שאינו חוקי על dynamic).
//  • null מול undefined (כלל-2): voidedAt חסר ⇒ null; `_falsy(null)` = true, זהה ל-`!undefined`.
//  • השכן dateInRange מוזרק by-reference; אין נגיעה בלוגיקת-הטווח (חיה בשקע).

/// `!x` של JS על ערך dynamic: null/false/''/0 ⇒ true (falsy); אחרת false.
bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || (v is String && v.isEmpty);

/// Filter shop-assignment redemptions — verbatim port of
/// new/atoms/filter-redemptions.mjs (`filterRedemptions`).
/// The neighbour dateInRange is injected as a socket (Law 1/3).
List<dynamic> filterRedemptions(
  Map<String, dynamic> a,
  String fromIso,
  String toIso,
  bool includeVoided,
  bool Function(dynamic, String, String) dateInRange,
) {
  final redemptions = a['redemptions'] as List<dynamic>;
  return redemptions
      .where((r) =>
          dateInRange((r as Map)['date'], fromIso, toIso) &&
          (includeVoided || _falsy(r['voidedAt'])))
      .toList();
}
