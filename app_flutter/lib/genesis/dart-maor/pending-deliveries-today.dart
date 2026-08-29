// ⚛️ אטום-Dart (דרגת-חוזה) · pendingDeliveriesToday — מסירות פתוחות עד-היום שטרם נמסרו (מונה-הבית).
// מוצא: maor/src/components/shop7/lib.ts:73-85 · המקור: new/atoms/pending-deliveries-today.mjs:
//   const openDays = new Set(db.distributionDays.filter((d) => d.date <= todayIso && !d.closed).map((d) => d.id));
//   return db.deliveries.filter((d) => openDays.has(d.dayId) && d.status !== 'delivered');
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: אוסף המסירות שעדיין דורשות טיפול — כל מסירה השייכת ליום-חלוקה שכבר
//        הגיע/חלף (date <= todayIso) ושאינו סגור, וסטטוסה עדיין אינו 'delivered'.
// שקעים (חוק-1): אין — טהור, db + todayIso בלבד.
//
// הערות-המרה (מקור→Dart, DART-PORTING-RULES):
//  * המנוע פספס: `openDays.has(...)` ⇒ `Set.contains(...)`; `_falsy(d.closed)` הושלם ל-JS-falsy.
//  * truthiness (כלל 7): `!d.closed` של JS אמיתי כאשר closed הוא undefined/false/null/0/''/NaN
//    — שקע `_falsy` מחקה זאת (שדה חסר במפה ⇒ null ⇒ falsy ⇒ היום פתוח, כמו במקור).
//  * `d.date <= todayIso`: השוואת-מחרוזות-ISO לקסיקוגרפית ב-JS ⇒ String.compareTo <= 0 ב-Dart
//    (ISO YYYY-MM-DD מסודר-לקסיקוגרפית ⇒ זהה להשוואת-תאריך).
//  * `filter` שומר סדר-מקור ומחזיר את אותן רפרנסות-אובייקט ⇒ list-comprehension שומר-סדר,
//    האיברים הם אותם Map-ים בדיוק (לא עותק) — כמו filter של JS.

/// JS falsy: null · false · 0 · 0.0 · '' · NaN. מחקה את `!x` של JavaScript.
bool _falsy(Object? v) =>
    v == null ||
    v == false ||
    v == 0 ||
    v == 0.0 ||
    v == '' ||
    (v is double && v.isNaN);

/// Deliveries still needing action: those on a distribution-day that has already
/// arrived/passed (date <= todayIso) and is not closed, whose status is not yet
/// 'delivered'. Verbatim behaviour of the JS source `pendingDeliveriesToday`.
List<Map<String, dynamic>> pendingDeliveriesToday(
    Map<String, dynamic> db, String todayIso) {
  final openDays = <Object?>{};
  for (final raw in (db['distributionDays'] as List)) {
    final d = raw as Map;
    if ((d['date'] as String).compareTo(todayIso) <= 0 && _falsy(d['closed'])) {
      openDays.add(d['id']);
    }
  }
  return [
    for (final raw in (db['deliveries'] as List))
      if (openDays.contains((raw as Map)['dayId']) &&
          raw['status'] != 'delivered')
        raw as Map<String, dynamic>,
  ];
}
