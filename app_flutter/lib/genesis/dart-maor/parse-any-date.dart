// חוט · parse-any-date — קלט-חופשי ⇒ ISO "YYYY-MM-DD" (או '' אם אינו תאריך). חוזה: parse-any-date.contract.md
// המרה מ-JS (new/atoms/parse-any-date.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4, המקור קדוש).
// מוצא: maor/src/lib/csvx.ts:121-160 · תורגם TS→JS מכונה · קודם במנוע-האוטומטי.
// אפס-import (רק dart-core).
//
// תיקוני-פורט מול המקור (הטיוטה dart-from-maor/*.draft חסרה בריפו — נבנה מהמקור, כמו excel-serial-to-iso):
//   • String(v || '').trim(): truthiness של JS — רק falsy⇒''. מומש ב-_coerce/_falsy (מחרוזת-ריקה=falsy).
//     ‏(כלל-פורט 7 — truthiness של JS ≠ Dart, שקע-falsy מפורש.)
//   • Date.UTC(y, mon-1, day) עם year 0–99 ⇒ JS ממפה ל-1900+year! ‏"0050-06-15" ⇒ probe.year=1950≠50 ⇒ ''.
//     ‏Dart DateTime.utc(50,…) נותן year=50 ⇒ סטייה. שיקוף מפורש ב-_ctorYear (כלל-פורט 3/4 — סמנטיקת-Date).
//     ‏(ענף-ISO בלבד; ענף-D/M/Y תמיד מסובב ל-≥1900 לפני ה-probe, וספרות-3 הן ≥100 — המיפוי לא נוגע בו.)
//   • DateTime.utc מגלגל יום-גולש (Feb 30 ⇒ מרץ) כמו new Date של JS ⇒ round-trip תופס, לא זורק (כלל-פורט 4).
//   • ציר-דו-ספרתי דינמי משתמש ב-DateTime.now().year (זהה ל-new Date().getFullYear() — תלוי-זמן במקור, נשמר).
//   • +s / +iso[k]: הקלטים כאן הם ספרות-בלבד מ-regex ⇒ int.parse בטוח (אין קלט-רע כמו gem-year).
//
// קלט:  v — ערך-חופשי (מחרוזת/מספר/null).
// פלט:  "YYYY-MM-DD" · '' אם אינו תאריך תקין.

String parseAnyDate(Object? v) {
  final s = _coerce(v).trim();
  if (s.isEmpty) return '';

  // ISO: אותה אימות-קיום כמו ענף ה-D/M/Y — אחרת '2015-06-31'/'2019-02-30' היו נשמרים כתאריך בלתי-אפשרי.
  final iso = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  if (iso != null) {
    final y = int.parse(iso.group(1)!);
    final mon = int.parse(iso.group(2)!);
    final day = int.parse(iso.group(3)!);
    if (mon < 1 || mon > 12 || day < 1 || day > 31) return '';
    final probe = DateTime.utc(_ctorYear(y), mon, day);
    if (probe.year != y || probe.month != mon || probe.day != day) return '';
    return s;
  }

  final m = RegExp(r'^(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})$').firstMatch(s);
  if (m != null) {
    final day = int.parse(m.group(1)!);
    final mon = int.parse(m.group(2)!);
    var y = int.parse(m.group(3)!);
    // ציר דו-ספרתי דינמי: עד ~10 שנים קדימה = 20xx, אחרת 19xx. מתעדכן עם הזמן.
    if (y < 100) {
      final cut = (DateTime.now().year % 100) + 10;
      y += y <= cut ? 2000 : 1900;
    }
    // אימות טווח + קיום התאריך בפועל (31/02, חודש 13 וכו' → ריק, לא זבל)
    if (mon < 1 || mon > 12 || day < 1 || day > 31) return '';
    final probe = DateTime.utc(_ctorYear(y), mon, day);
    if (probe.year != y || probe.month != mon || probe.day != day) return '';
    return '$y-${mon.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }

  if (RegExp(r'^\d{5}$').hasMatch(s)) {
    final b = DateTime.utc(1899, 12, 30).add(Duration(days: int.parse(s)));
    final yy = b.year.toString().padLeft(4, '0');
    final mm = b.month.toString().padLeft(2, '0');
    final dd = b.day.toString().padLeft(2, '0');
    return '$yy-$mm-$dd'; // toISOString().slice(0,10)
  }

  return '';
}

/// מיפוי-שנת-הבנאי של Date.UTC: year בטווח 0–99 ⇒ 1900+year (כמו new Date(Date.UTC(...))).
int _ctorYear(int y) => (y >= 0 && y <= 99) ? 1900 + y : y;

/// String(v || '') של JS — v falsy ⇒ '', אחרת המרת-מחרוזת.
String _coerce(Object? v) {
  if (_falsy(v)) return '';
  if (v is String) return v;
  return v.toString();
}

/// falsy של JS: null · false · 0/NaN · מחרוזת-ריקה.
bool _falsy(Object? v) {
  if (v == null) return true;
  if (v is bool) return !v;
  if (v is num) return v == 0 || v.isNaN;
  if (v is String) return v.isEmpty;
  return false;
}
