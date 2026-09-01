// ⚛️ אטום-Dart (דרגת-חוזה) · lastCollectionIso — תאריך-הריקון האחרון של קופת-צדקה ('' כשאין).
// מוצא: maor/src/components/tzedaka/lib.ts:26-32 · המקור: new/atoms/last-collection-iso.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 — התנהגות
//        זהה-ביט למקור-ה-JS (המקור קדוש). אפס שקעים — נגזרת טהורה של box.collections (חוק-1).
//
// תפקיד: סורק את box.collections ומחזיר את מחרוזת-ה-ISO המקסימלית לקסיקוגרפית ('' כשריק).
// קלט:  box (מפה עם 'collections' = List<Map> ובכל אחת 'date' = מחרוזת-ISO).
// פלט:  מחרוזת — התאריך המאוחר-ביותר, או '' כשאין ריקונים.
//
// הערות-המרה (מקור→Dart · תיקוני-מנוע):
//  • המנוע פלט `if (c.date > last)` — שגוי: ל-String של Dart אין operator `>` (שגיאת-קומפילציה),
//    בעוד JS משווה מחרוזות לקסיקוגרפית. תוקן ל-`c['date'].compareTo(last) > 0` (סדר-code-unit
//    זהה להשוואת-JS על מחרוזות-ISO). זהו כלל-ההמרה של השוואת-מחרוזות (compareTo, לא `>`).
//  • גישת-`.collections`/`.date` על אובייקט (המנוע פלט dynamic) → `box['collections']`/`c['date']`
//    כ-Map-lookup, בהתאם לקונבנציית-האטומים (Map<String,dynamic>).
//  • מוטביליות: `last` הוא var (מוקצה-מחדש בלולאה כמו let במקור); היתר final.

/// Last charity-box collection date ('' when none) — verbatim port of
/// new/atoms/last-collection-iso.mjs (`lastCollectionIso`). Pure derivation of
/// box.collections, no sockets (Law 1). String comparison via compareTo to
/// mirror JS lexicographic `>` on ISO strings.
String lastCollectionIso(Map<String, dynamic> box) {
  var last = '';
  for (final c in (box['collections'] as List)) {
    final date = (c as Map)['date'] as String;
    if (date.compareTo(last) > 0) last = date;
  }
  return last;
}
