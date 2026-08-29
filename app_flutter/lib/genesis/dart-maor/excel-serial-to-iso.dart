// חוט · excel-serial-to-iso — מספר-סידורי-של-Excel ⇒ ISO "YYYY-MM-DD". חוזה: excel-serial-to-iso.contract.md
// המרה מ-JS (new/atoms/excel-serial-to-iso.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4, המקור קדוש).
// מוצא: maor/src/components/supporters/lib.ts:509-516 · תורגם TS→JS מכונה.
// אפס-import (רק dart-core).
//
// תיקוני-פורט מול טיוטת-המנוע (הטיוטה dart-from-maor/*.draft חסרה בריפו — נבנה מהמקור):
//   • קלט dynamic + כפיית-ToNumber של JS. במקור-ה-TS החתימה `serial: number`, אך רתמת-הזהב
//     מזינה **מחרוזות** ו-JS מכפיף כל שימוש (isFinite / `< 1` / חיסור) ל-Number(serial).
//     מומש בשקע-מקומי _jsToNumber: מחרוזת-ריקה⇒0 (כמו Number('')===0), לא-מספרית⇒NaN.
//     דוגמה קריטית: "0501234567" עובר את שני השערים (Number=501234567, סופי, >1) אך גולש
//     מטווח-ה-Date ⇒ '' — לא נחסם בשער אלא בבדיקת-הטווח, בדיוק כמו ב-JS.
//   • Math.round של JS = floor(x+0.5) (חצי כלפי +∞), שונה מ-.round() של Dart (חצי-מאפס) — כלל-פורט.
//   • טווח-Date של JS: |ms| > 8.64e15 ⇒ Invalid Date ⇒ getTime()=NaN ⇒ ''. שיקוף מפורש **לפני**
//     בניית DateTime, כי Dart זורק מחוץ-לטווח (כלל-פורט 3/4 — לשקף סמנטיקת-Date, לא לתת ל-guard לזרוק).
//   • getUTCMonth()+1 (0-אינדקס +1) ≡ DateTime.month (1-אינדקס) — אין תיקון-כפול.
//
// קלט:  serial — מספר/מחרוזת (מספר-סידורי-Excel; 25569 = היסט 1970-01-01).
// פלט:  "YYYY-MM-DD" (UTC) · '' לקלט לא-סופי / <1 / מחוץ-לטווח-Date.

String excelSerialToIso(Object? serial) {
  final n = _jsToNumber(serial);
  if (!n.isFinite || n < 1) return '';
  final ms = ((n - 25569) * 86400000 + 0.5).floor(); // JS Math.round = floor(x+0.5)
  if (ms.abs() > 8640000000000000) return ''; // מחוץ-לטווח-Date ⇒ Invalid Date ⇒ ''
  final dt = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  final mo = dt.month.toString().padLeft(2, '0'); // getUTCMonth()+1
  final da = dt.day.toString().padLeft(2, '0'); // getUTCDate()
  return '${dt.year}-$mo-$da';
}

/// שקע-כפייה מקומי המחקה את Number() של JS על קלט-הרתמה (מספר/מחרוזת).
/// מחרוזת-ריקה/רווחים ⇒ 0 · מחרוזת-לא-מספרית ⇒ NaN · null ⇒ NaN.
double _jsToNumber(Object? v) {
  if (v is num) return v.toDouble();
  if (v is String) {
    final t = v.trim();
    if (t.isEmpty) return 0.0; // Number('') === 0
    return double.tryParse(t) ?? double.nan;
  }
  return double.nan;
}
