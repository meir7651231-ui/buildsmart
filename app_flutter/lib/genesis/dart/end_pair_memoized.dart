// ⚛️ אטום-Dart (דרגת-חוזה) · endPairMemoized
// מוצא: buildsmart/app_flutter/lib/domain/connection_resolver.dart:223-227
//        (‏ConnectionResolver._endPairMemoized; תיעוד-המֶמו :178-183; חוק-4 — verbatim).
//        ⚠️ חולץ מענף claude/align-main (הקובץ אינו בעץ-העבודה הנוכחי של buildsmart).
// טוהר: פונקציית top-level גנרית, אפס import, אפס סטייט — המטמון מוזרק.
//
// שקעים שהוזרקו (קריאה-לשכן/סטייט ⇒ פרמטר-שקע · חוק-1/3, דיבר-3):
//   • `_endPair(endA, endB)` (‏:226) ⇒ שקע `endPair` — מעריך-הזוג של הקופסה.
//   • `_memo` — סטייט-המחלקה (‏:183, Map<String, ConnectResult>) ⇒ שקע `memo` —
//     הסטייט חי אצל הקופסה (חוק-5: אפס ידע-הקשר באטום).
//   • `end.connectorTypeId` / `end.sizeValue` ⇒ שקעי-ריאדר גנריים
//     (התקדים: estimate_price.dart · categoryHe) — E/R גנריים, אפס טיפוס-מוטבע.
//
// קלט:  endA, endB · connectorTypeId · sizeValue · memo · endPair.
// פלט:  R — תוצאת endPair, ממוטמנת פר-מפתח `'$aType|$aSize|$bType|$bSize'`.
//
// ⚠️ המפתח נבנה מערכי-הגודל ה-RAW (לא-מנורמלים) — במקור במפורש (‏:179-181):
// הנרמול קורה בתוך ההערכה; `'1/2'` ו-`'1/2"'` הם מפתחות שונים. כיווניות נשמרת:
// ‏(A,B) ו-(B,A) — מפתחות שונים.

/// ‏connection_resolver.dart:223-227 verbatim: מפתח-צירוף `|` + putIfAbsent —
/// מפתח חסר ⇒ חישוב-יחיד ושמירה; מפתח קיים ⇒ endPair לא נקרא, מוחזר השמור.
R endPairMemoized<E, R>(
  E endA,
  E endB, {
  required String Function(E) connectorTypeId,
  required String Function(E) sizeValue,
  required Map<String, R> memo,
  required R Function(E endA, E endB) endPair,
}) {
  final key = '${connectorTypeId(endA)}|${sizeValue(endA)}'
      '|${connectorTypeId(endB)}|${sizeValue(endB)}';
  return memo.putIfAbsent(key, () => endPair(endA, endB));
}
