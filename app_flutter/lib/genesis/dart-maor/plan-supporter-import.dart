// ⚛️ אטום-Dart (דרגת-חוזה) · planSupporterImport — תכנון ייבוא-תומכות
// (עדכון-או-הוספה לפי שם מנורמל).
// מוצא: new/atoms/plan-supporter-import.mjs (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//   חולץ כלשונו מ-maor/src/components/supporters/lib.ts:598-636.
// שקעים (חוק-3 — קריאות-שכן שוקעו לפרמטרים): normName, fillEmpty.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// תפקיד: בונה מפת שם-מנורמל→id מהתומכות הקיימות; עובר על השורות המיובאות ומחלק
//        לעדכונים (שם קיים) או הוספות (שם חדש), עם קיבוץ פר-id / פר-שם דרך fillEmpty
//        כדי שקובץ-עסקאות רב-שורות לאותו תורם לא יאבד היסטוריה.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • truthiness (כלל-7): `if (existId)` ו-`if (!nm)` של JS ≠ Dart. מומש שקע `_truthy`
//    מפורש (null/false/0/NaN/'' ⇒ false). id='' או שם-ריק ⇒ falsy כמו במקור.
//  • `ui != null` / `idx != null` (כלל-2): המקור בודק `!= null` על תוצאת Map.get
//    (index-number או undefined). ב-Dart lookup על מפתח-חסר מחזיר null, והערכים
//    השמורים תמיד int לא-שלילי ⇒ `!= null` שקול בדיוק ל-JS.
//  • סדר-הכנס: JS Map ו-Array שומרים סדר-הכנסה; Dart LinkedHashMap/List זהים ⇒
//    סדר updates/inserts משתמר.

/// Verbatim behaviour of the JS source new/atoms/plan-supporter-import.mjs.
/// [rows]/[existing] are lists of maps; [normName]/[fillEmpty] are injected sockets.
/// Returns {'updates': [...{id,row}], 'inserts': [...row]}.
Map<String, dynamic> planSupporterImport(
  List<dynamic> rows,
  List<dynamic> existing,
  dynamic Function(dynamic) normName,
  dynamic Function(dynamic, dynamic) fillEmpty,
) {
  final byName = <dynamic, dynamic>{};
  for (final sp in existing) {
    byName[normName(sp['name'])] = sp['id'];
  }
  final updates = <dynamic>[];
  // קיבוץ-עדכונים פר-id (9.8): קובץ-עסקאות מכיל שורות רבות לאותו תורם קיים —
  // בלעדיו רק השורה האחרונה שרדה (ה-Map בצד-הרכיב) וכל ההיסטוריה אבדה.
  final updateIdx = <dynamic, int>{};
  final inserts = <dynamic>[];
  final insertIdx = <dynamic, int>{};
  for (final r in rows) {
    final nm = (r['name'] as String).trim();
    if (!_truthy(nm)) {
      continue;
    }
    final key = normName(nm);
    final existId = byName[key];
    if (_truthy(existId)) {
      final ui = updateIdx[existId];
      if (ui != null) {
        updates[ui] = {
          'id': existId,
          'row': fillEmpty((updates[ui] as Map)['row'], r),
        };
      } else {
        updateIdx[existId] = updates.length;
        updates.add({'id': existId, 'row': r});
      }
      continue;
    }
    final idx = insertIdx[key];
    if (idx != null) {
      inserts[idx] = fillEmpty(inserts[idx], r);
      continue;
    }
    insertIdx[key] = inserts.length;
    inserts.add(r);
  }
  return {'updates': updates, 'inserts': inserts};
}

// JS truthiness: falsy = null/undefined, false, 0, NaN, ''.
bool _truthy(dynamic v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}
