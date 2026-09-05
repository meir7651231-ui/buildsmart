// ⚛️ אטום-Dart (דרגת-חוזה) · donAllowedKeys — ערכי-in מותרים לשאילתת-תרומות מפוצלת.
// מוצא: maor/src/lib/donationPartition.ts:34-37 · המקור: new/atoms/don-allowed-keys.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). השכן SHARED_PURPOSE_KEY הוזרק
//        כשקע sharedPurposeKey (חוק-1/חוק-6 — קבוע-זהות אינו אטום).
//
// תפקיד: מרשימת-מפתחות מותרים ⇒ ניקוי (trim), סינון-ריקים, דדופ, קיטום ל-29,
//        והוספת מפתח-הייעוד-המשותף בסוף. פלט: List<String> באורך ≤ 30.
//
// הערות-המרה (מקור→Dart), לפי DART-PORTING-RULES:
//  • `allowed.map(s=>s.trim()).filter(Boolean)` — filter(Boolean) מסלק מחרוזת-ריקה
//    (falsy). ב-Dart: `t.isNotEmpty` מפורש (כלל-7 truthiness — לא מסתמכים על `if(t)`).
//    '\t'.trim()==='' ⇒ מסונן, זהה למקור.
//  • `new Set(...)` — דדופ. Dart `<String>{}` (LinkedHashSet) שומר סדר-הכנסה כמו JS Set
//    ⇒ הפלט הממוין-לפי-הופעה זהה-ביט.
//  • ⚠️ `.slice(0, 29)` של JS **סלחן** (פחות-מ-29 ⇒ מחזיר הכול); Dart `.sublist(0, 29)`
//    זורק RangeError כשהאורך<29 (המלכודת בטיוטת-המנוע). ⇒ `.take(29)` שהוא סלחן-כמו-slice.
//  • מוטביליות: הרשימה נבנית מקומית; אין var מוקצה-מחדש. אין locale/פורמט/getMonth.

/// Allowed `in`-values for a partitioned donations query.
/// Verbatim port of new/atoms/don-allowed-keys.mjs (`donAllowedKeys`).
/// The neighbour constant SHARED_PURPOSE_KEY is injected as the socket
/// `sharedPurposeKey` (Law 1/6 — an identity constant is never an atom).
List<String> donAllowedKeys(List<String> allowed, String sharedPurposeKey) {
  final seen = <String>{};
  for (final s in allowed) {
    final t = s.trim();
    if (t.isNotEmpty) seen.add(t);
  }
  final out = seen.take(29).toList();
  out.add(sharedPurposeKey);
  return out;
}
