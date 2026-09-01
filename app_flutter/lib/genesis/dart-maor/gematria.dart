// ⚛️ אטום-Dart (דרגת-חוזה) · gem — גימטריה (מספר⇒אותיות עבריות)
// מוצא: maor/src/lib/hebrew.ts (חוק-4 — התנהגות זהה למקור-ה-JS, לא-משופרת).
//        המקור: new/atoms/gematria.mjs · חוזה: new/atoms/gematria.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart:core; אין צורך ב-dart:math).
//
// תפקיד: המרת מספר חיובי לייצוג-אותיות עברי (גימטריה) עם גרש/גרשיים, כולל
//        טו/טז (הימנעות מצירופי-שם), עד 999.
// קלט:  n — num (שלם/עשרוני/NaN/Infinity). מעל 999 (מאות≥10) המאות נבלעות ל-''.
// פלט:  String — הגימטריה; קלט לא-חוקי (לא-סופי / ≤0 אחרי רצפה) ⇒ ''.
//
// ⚠️ תיקון-הסגר: ‏n≥1000 כפולת-100 ⇒ s ריק. ‏JS `s.slice(0,-1)` ו-`s.slice(-1)`
//    על מחרוזת-ריקה מחזירים '' בשלווה (⇒ הפלט '״'); ‏Dart `s.substring(0, -1)`
//    זורק RangeError. התיקון: לוגיקת-slice בטוחה שמחקה את JS (בדיקת-אורך לפני חיתוך).

/// Hebrew gematria of a positive number (verbatim behaviour of the JS source
/// new/atoms/gematria.mjs). Non-finite or non-positive input yields `''`.
String gem(num n, List<String> U, List<String> T, List<String> H, Map<String, dynamic> T2) {
  // Math.floor(+n) + Number.isFinite guard: NaN/Infinity ⇒ '' (ולא זורק .floor()).
  if (n.isNaN || n.isInfinite) return '';
  final int nn = n.floor();
  if (nn <= 0) return '';

  final List<String> u = ['', U[1], U[2], U[3], U[4], U[5], U[6], U[7], U[8], U[9]];
  final List<String> t = ['', T[1], T[2], T[3], T[4], T[5], T[6], T[7], T[8], T[9]];
  final List<String> h = ['', H[1], H[2], H[3], H[4], H[5], H[6], H[7], H[8], H[9]];

  final int hi = nn ~/ 100;
  var s = hi < h.length ? h[hi] : ''; // H[..] || '' — כולל חריגת-גבול וגם H[0]==''
  final int r = nn % 100;
  if (r == 15) {
    s += (T2['k1'] as String);
  } else if (r == 16) {
    s += (T2['k2'] as String);
  } else {
    s += t[r ~/ 10] + u[r % 10];
  }

  if (s.length == 1) return '$s${(T2['k3'] as String)}';
  // JS: s.slice(0,-1) + '״' + s.slice(-1). על s ריק ⇒ '' + '״' + '' = '״'.
  final head = s.length >= 2 ? s.substring(0, s.length - 1) : '';
  final last = s.isEmpty ? '' : s.substring(s.length - 1);
  return '$head${(T2['k4'] as String)}$last';
}
