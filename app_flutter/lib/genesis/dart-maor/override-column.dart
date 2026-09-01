// ⚛️ אטום-Dart (דרגת-חוזה) · overrideColumn — דריסת-עמודה בשורות-ייצוא.
// מוצא: maor/src/lib/customExport.ts:127-136 · המקור: new/atoms/override-column.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט ל-JS.
//
// תפקיד: דורס עמודה יחידה (colIdx) בכל שורת-נתונים לפי מפת-דריסות (overrides),
//        עם כותרת חסינה (שורה 0 לעולם לא נדרסת), אי-מוטציה של הקלט, ושמירת
//        אותה רפרנס לשורות שלא נדרסו (colIdx שלילי ⇒ הקלט עצמו).
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • כלל-2 (null≠undefined): ה-JS מדלג רק על `overrides[i] === undefined` —
//    מפתח-חסר, לא ערך-null. ⇒ `!overrides.containsKey(i)` (לא `== null`),
//    כדי שדריסה לערך-ריק '' (או null מפורש) עדיין תתפוס. (דוגמה 6 בחוזה.)
//  • זהות-רפרנס: `===` של JS על שורות שלא-נדרסו ⇒ מוחזרות כמו-שהן (identical).
//    colIdx<0 ⇒ מוחזר `rows` עצמו (אותה רפרנס). ‏.map של JS ⇒ לולאה מפורשת ב-Dart
//    כדי לשמר את הרפרנסים במדויק ולא לגעת בטיפוסים.
//  • אי-מוטציה: `[...r]` ⇒ עותק-רדוד לפני הדריסה; הקלט לא משתנה.

/// Overrides a single column (colIdx) in each data row per the overrides map,
/// with an immune header (row 0 is never overridden), no input mutation, and
/// reference-identity preserved for untouched rows. colIdx<0 returns rows itself.
/// Verbatim behaviour of the JS source `overrideColumn`.
List<dynamic> overrideColumn(List<dynamic> rows, int colIdx, Map overrides) {
  if (colIdx < 0) return rows;
  final out = <dynamic>[];
  for (var i = 0; i < rows.length; i++) {
    final r = rows[i];
    if (i == 0 || !overrides.containsKey(i)) {
      out.add(r);
      continue;
    }
    final c = [...(r as Iterable)];
    c[colIdx] = overrides[i];
    out.add(c);
  }
  return out;
}
