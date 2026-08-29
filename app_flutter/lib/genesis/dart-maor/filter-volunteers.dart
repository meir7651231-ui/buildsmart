// ⚛️ אטום-Dart (דרגת-חוזה) · filterVolunteers — סינון מתנדבי-החלוקה (SHOP7).
// מוצא: maor/src/components/shop7/lib.ts:149-154 · המקור: new/atoms/filter-volunteers.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: q ריק (אחרי trim) ⇒ מחזיר vols כמות-שהם (השקע לא נקרא). אחרת ⇒ smartFilter(q, vols,
//        getTerms) עם getTerms = [name, phone, area ?? ''].
//        smartFilter הוזרק כשקע (חוק-3) — הקופסה מחווטת את אטום-smartFilter האמיתי.
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • truthiness (כלל-7): `if (!q.trim())` של JS = מחרוזת-ריקה-אחרי-trim ⇒ `.trim().isEmpty`.
//  • vols דינמי: ה-Golden מזרים vols כמחרוזת (q ריק ⇒ מוחזר כמות-שהוא), במסלול-החי vols=List;
//    ⇒ חתימה `dynamic vols`/`dynamic` פלט, ביט-זהה למקור שאינו מטפס על טיפוס.
//  • שדות-שורה: `v.name`/`v.phone`/`v.area` (JS property) ⇒ `(v as Map)['...']` — כמות-שהוא.
//  • `v.area ?? ''` (כלל-2, null≠undefined): area חסר/null ⇒ '' (Dart `?? ''` על Map מכסה שניהם).

/// Filter SHOP7 volunteers — verbatim port of new/atoms/filter-volunteers.mjs
/// (`filterVolunteers`). `smartFilter` is injected as a socket (Law 1/3).
dynamic filterVolunteers(
  dynamic vols,
  String q,
  dynamic Function(String, dynamic, List<dynamic> Function(dynamic)) smartFilter,
) {
  if (q.trim().isEmpty) return vols;
  return smartFilter(q, vols, (v) {
    final m = v as Map;
    return [m['name'], m['phone'], m['area'] ?? ''];
  });
}
