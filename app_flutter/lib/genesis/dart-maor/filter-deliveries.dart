// ⚛️ אטום-Dart (דרגת-חוזה) · filterDeliveries — סינון לוח-המסירות (SHOP7).
// מוצא: maor/src/components/shop7/lib.ts:155-162 · המקור: new/atoms/filter-deliveries.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש).
//
// תפקיד: q ריק (אחרי trim) ⇒ מחזיר rows כמות-שהם (השקע לא נקרא). אחרת ⇒ smartFilter(q, rows,
//        getTerms) עם getTerms = [familyName, volunteerName, statusLabel(status)].
//        statusLabel הוטמע (חוק-1): pickup⇒'איסוף' · enroute⇒'בדרך' · else⇒'נמסר'.
//        smartFilter הוזרק כשקע (חוק-3) — הקופסה מחווטת את אטום-smartFilter האמיתי.
//
// הערות-המרה (מקור→Dart — DART-PORTING-RULES):
//  • truthiness (כלל-7): `if (!q.trim())` של JS = מחרוזת-ריקה-אחרי-trim ⇒ `.trim().isEmpty`.
//  • rows דינמי: ה-Golden מזרים rows כמחרוזת (q ריק ⇒ מוחזר כמות-שהוא), במסלול-החי rows=List;
//    ⇒ חתימה `dynamic rows`/`dynamic` פלט, ביט-זהה למקור שאינו מטפס על טיפוס.
//  • שדות-שורה: `r.familyName` (JS property) ⇒ `(r as Map)['familyName']` — ערך כמות-שהוא (חוק-4).

/// Filter SHOP7 deliveries — verbatim port of new/atoms/filter-deliveries.mjs
/// (`filterDeliveries`). `smartFilter` is injected as a socket (Law 1/3);
/// `statusLabel` is inlined (Law 1).
dynamic filterDeliveries(
  dynamic rows,
  String q,
  dynamic Function(String, dynamic, List<dynamic> Function(dynamic)) smartFilter,
 {required String Function(String) term}) {
  if (q.trim().isEmpty) return rows;
  String statusLabel(dynamic status) => status == 'pickup'
      ? term('aysvf')
      : status == 'enroute'
          ? term('bdrk')
          : term('nmsr');
  return smartFilter(q, rows, (r) {
    final m = r as Map;
    return [m['familyName'], m['volunteerName'], statusLabel(m['status'])];
  });
}
