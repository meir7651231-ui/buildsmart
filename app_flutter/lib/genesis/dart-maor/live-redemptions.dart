// ⚛️ אטום-Dart (דרגת-חוזה) · liveRedemptions — המימושים החיים של שיוך (בלי מבוטלים).
// מוצא: maor/src/components/shop/lib.ts:25-27 · המקור: new/atoms/live-redemptions.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). אפס שקעים.
//
// תפקיד: a.redemptions מסונן ל-!r.voidedAt — המבוטלים מושמטים, הסדר נשמר,
//        והרפרנסות זהות (filter לא מעתיק). הרשומה המבוטלת נשארת בדאטה, רק לא נספרת.
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • truthiness (כלל-7): `!r.voidedAt` של JS = falsy-check (undefined/null/'' ⇒ true).
//    ב-Dart מפתח-חסר ⇒ null; מומש דרך `_falsy` מפורש במקום `!` (שאינו חוקי על dynamic).
//  • null מול undefined (כלל-2): voidedAt חסר ⇒ null; `_falsy(null)` = true, זהה ל-`!undefined`.
//  • .where().toList() משמר רפרנסות (כמו Array.filter) ⇒ דוגמה 4 (זהות-אברים) נשמרת.

/// `!x` של JS על ערך dynamic: null/false/''/0 ⇒ true (falsy); אחרת false.
bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || (v is String && v.isEmpty);

/// Live shop-assignment redemptions — verbatim port of
/// new/atoms/live-redemptions.mjs (`liveRedemptions`). Voided ones are excluded
/// (`!r.voidedAt`); original order and element references are preserved.
List<dynamic> liveRedemptions(Map<String, dynamic> a) {
  final redemptions = a['redemptions'] as List<dynamic>;
  return redemptions.where((r) => _falsy((r as Map)['voidedAt'])).toList();
}
