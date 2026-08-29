// ⚛️ אטום-Dart (דרגת-חוזה) · ageOf
// מוצא: maor · new/atoms/age-of.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). השעון מוזרק כשקע `now`.
//
// 🔧 תיקון-הסגר (FIXES · "age-of — פסילת-תאריך-שבור"):
//   הבאג — ‏`DateTime.tryParse` של Dart מקבל/מגלגל חודש-מחוץ-לטווח ('2000-13-01'→תקין),
//   בעוד ‏JS `new Date` מחזיר NaN. סיכון-נתונים: גיל-שגוי ב-CRM.
//   התיקון — פרסור נאמן-V8 (‏_parseV8Local, מוזרק INLINE מ-js-compat, חוק-1):
//     • דקדוק-ISO קפדני (regex) ⇒ מחרוזת-שבורה/חלקית ⇒ null (≡ NaN).
//     • אימות-טווח נאמן-V8: חודש 1–12 · יום 1–31 (אחרת null ≡ NaN).
//     • גלישת-יום חוקית (‏02-31 ⇒ 03-02) מתגלגלת דרך בנאי-DateTime — בדיוק כמו V8.
//   אומת מול Node: ‏13/00-חודש · 00/32-יום ⇒ NaN; ‏Feb-31 ⇒ Mar-02.
//
// קלט:  birth — תאריך-לידה ISO (String?, נלקחים 10 התווים הראשונים) · now — שעון-מוזרק.
// פלט:  גיל בשנים מלאות (int), או null לריק/שבור.

/// גיל בשנים מלאות מתאריך-לידה ISO, בכלל-הצהריים (חסין אזורי-זמן).
int? ageOf(String? birth, DateTime now) {
  if (birth == null || birth.isEmpty) return null;
  final head = birth.length <= 10 ? birth : birth.substring(0, 10);
  final d = _parseV8Local('${head}T12:00:00');
  if (d == null) return null;
  final n = now;
  var a = n.year - d.year;
  final md = n.month - d.month;
  if (md < 0 || (md == 0 && n.day < d.day)) a--;
  return a;
}

// —— עוזר מוזרק INLINE מ-js-compat (חוק-1: אטום לא-מייבא) ——
// מחקה `new Date("YYYY-MM-DDThh:mm:ss")` של V8 (מקומי, בלי אזור-זמן).
// מחזיר DateTime מקומי או null (≡ Invalid Date/NaN). יום-גולש מתגלגל (Feb 30 ⇒ Mar 2),
// אך רק אם day∈[1,31] month∈[1,12] (אחרת NaN). בנאי-DateTime של Dart מגלגל כמו JS.
DateTime? _parseV8Local(String iso) {
  final m = RegExp(
          r'^([+-]?\d{4,6})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?)?$')
      .firstMatch(iso);
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final mon = int.parse(m.group(2)!);
  final day = int.parse(m.group(3)!);
  final hour = m.group(4) != null ? int.parse(m.group(4)!) : 0;
  final min = m.group(5) != null ? int.parse(m.group(5)!) : 0;
  final sec = m.group(6) != null ? int.parse(m.group(6)!) : 0;
  if (mon < 1 || mon > 12) return null;
  if (day < 1 || day > 31) return null;
  if (hour > 24 || min > 59 || sec > 59) return null;
  if (hour == 24 && (min != 0 || sec != 0)) return null;
  return DateTime(year, mon, day, hour, min, sec);
}
