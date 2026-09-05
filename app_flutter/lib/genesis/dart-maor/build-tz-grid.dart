// ⚛️ אטום-Dart (דרגת-חוזה) · buildTzGrid — גריד-חודשי ללוח-הצדקה (wrapper דק).
// מוצא: maor/src/components/tzedaka/lib.ts:302-307 · המקור: new/atoms/build-tz-grid.mjs —
//   `export function buildTzGrid(tzEvents, anchorIso, hebMode, buildMonthGrid) {
//        return buildMonthGrid(tzEvents, anchorIso, hebMode); }`
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: האצלה מלאה — קורא לשכן buildMonthGrid עם שלושת הארגומנטים כמו-שהם,
//        באותן רפרנסים בדיוק, ומחזיר את פלטו כמו-שהוא (אפס עטיפה, אפס העתקה).
//        ה-re-export של DAY_NAMES במקור = חיווט-קופסה, הושמט מהאטום.
// שקע (חוק-1): buildMonthGrid — השכן שהוזרק כפרמטר-פונקציה. חתימתו (tzEvents, anchorIso, hebMode).
// קלט: tzEvents · anchorIso · hebMode · השקע buildMonthGrid. פלט: הערך שמחזיר השקע, כמו-שהוא.
//
// הערת-המרה (מקור→Dart): ה-JS עיוור-לתוכן — לא קורא שדה, רק מעביר-ומחזיר. כדי
// לשמר זהות-רפרנס לכל טיפוס (Map/List/null/int-זקיף) הפרמטרים `Object?` והשקע
// הוא `dynamic Function(Object?, Object?, Object?)`. אין locale/פורמט/getMonth/
// truthiness/מוטביליות לתקן — האטום טהור-האצלה.

/// Delegates verbatim to the injected [buildMonthGrid] neighbour: passes the
/// three arguments through unchanged (same references) and returns its result
/// as-is. Verbatim behaviour of the JS source `buildTzGrid`.
Object? buildTzGrid(
  Object? tzEvents,
  Object? anchorIso,
  Object? hebMode,
  dynamic Function(Object? tzEvents, Object? anchorIso, Object? hebMode)
      buildMonthGrid,
) {
  return buildMonthGrid(tzEvents, anchorIso, hebMode);
}
