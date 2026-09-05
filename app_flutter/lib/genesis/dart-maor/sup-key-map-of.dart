// ⚛️ אטום-Dart (דרגת-חוזה) · supKeyMapOf — מפת spId→skey מרשימת-התומכים
// (אכיפת-הרשאה בשכבת-הנתונים, פאזה-1).
// מוצא: maor/src/lib/supporterPartition.ts:52-60 · המקור: new/atoms/sup-key-map-of.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core). חוק-4 — התנהגות זהה-ביט
//        למקור-ה-JS. השכן supKeyOf הוזרק כשקע (חוק-1/חוק-3) — האטום עיוור לחוקיו.
//
// תפקיד: new Map(supporters.map(sp => [sp.id, supKeyOf(sp)])) — ממפה כל תומכת
//        דרך השקע; ותו-לא.
// קלט:  supporters — List של Map ‏{id, …} · supKeyOf — שקע ‏(sp)⇒skey.
// פלט:  Map ‏id⇒skey.
//
// הערות-המרה (מקור→Dart — הנקודות שהמנוע נוטה לפספס):
//  • סמנטיקת-Map של JS (סדר-הכנסה, כפל-מפתח ⇒ האחרון גובר) ≡ LinkedHashMap
//    של Dart (ה-{} הרגיל) — put חוזר דורס את הערך ומשאיר את מקום-ההכנסה המקורי,
//    בדיוק כמו Map.set של JS. דוגמת-חוזה 4 (כפל-id) נשענת על זה.
//  • sp.id — גישת-שדה על אובייקט-נתונים ⇒ sp['id'] על Map; מפתח-חסר ב-JS ⇒
//    undefined כמפתח-Map, ב-Dart ⇒ null כמפתח — שקילות-הייצוג המוסכמת (חוק-2:
//    ההבחנה containsKey נחוצה רק כשקוראים ערך, לא כשכותבים מפתח).
//  • אין כאן trim/toLowerCase/מספרים/לוח — כל החיטוי חי בשקע המוזרק (טוהר חוק-5,
//    דוגמת-חוזה 5: עיוורון-לשקע). חוקים 12/13/15/16 אינם באים לידי ביטוי באטום עצמו.

/// spId→skey map from the supporters list — each supporter mapped through the
/// injected supKeyOf socket. Verbatim port of new/atoms/sup-key-map-of.mjs
/// (`supKeyMapOf`); the neighbour call `supKeyOf` is injected as a socket (Law 1).
Map<dynamic, dynamic> supKeyMapOf(
  dynamic supporters,
  dynamic Function(dynamic) supKeyOf,
) {
  final m = <dynamic, dynamic>{};
  for (final sp in (supporters as List)) {
    m[(sp as Map)['id']] = supKeyOf(sp);
  }
  return m;
}
