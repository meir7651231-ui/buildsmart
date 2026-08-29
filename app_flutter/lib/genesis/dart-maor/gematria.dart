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
String gem(num n) {
  // Math.floor(+n) + Number.isFinite guard: NaN/Infinity ⇒ '' (ולא זורק .floor()).
  if (n.isNaN || n.isInfinite) return '';
  final int nn = n.floor();
  if (nn <= 0) return '';

  const List<String> u = ['', 'א', 'ב', 'ג', 'ד', 'ה', 'ו', 'ז', 'ח', 'ט'];
  const List<String> t = ['', 'י', 'כ', 'ל', 'מ', 'נ', 'ס', 'ע', 'פ', 'צ'];
  const List<String> h = ['', 'ק', 'ר', 'ש', 'ת', 'תק', 'תר', 'תש', 'תת', 'תתק'];

  final int hi = nn ~/ 100;
  var s = hi < h.length ? h[hi] : ''; // H[..] || '' — כולל חריגת-גבול וגם H[0]==''
  final int r = nn % 100;
  if (r == 15) {
    s += 'טו';
  } else if (r == 16) {
    s += 'טז';
  } else {
    s += t[r ~/ 10] + u[r % 10];
  }

  if (s.length == 1) return '$s׳';
  // JS: s.slice(0,-1) + '״' + s.slice(-1). על s ריק ⇒ '' + '״' + '' = '״'.
  final head = s.length >= 2 ? s.substring(0, s.length - 1) : '';
  final last = s.isEmpty ? '' : s.substring(s.length - 1);
  return '$head״$last';
}
