// ⚛️ אטום-Dart (דרגת-חוזה) · isoToHebParts
// מוצא: maor · new/atoms/iso-to-heb-parts.mjs (חוק-4 — התנהגות זהה-לחלוטין למקור-ה-JS, לא-משופרת).
//        המקור: maor/src/lib/hebdate.ts:106-115 (לועזי→עברי). השכנים hebParts (חלקי-עברי
//        דרך Intl) ו-monthHeOf (תווית עברית) מוזרקים כשקעים (חוק-1/3 — אפס import פנימי;
//        כלל-פורט 11: לוח-עברי = שקע, לא מימוש-מחדש).
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core).
//
// תיקוני-פורט מול טיוטת-המנוע (התנהגות משומרת ביט-אחר-ביט):
//   • ולידציית-Date — המנוע פלט `(d.millisecondsSinceEpoch).isNaN` (לעולם לא NaN ב-Dart).
//                 המקור: `new Date(iso+'T12:00:00'); if (isNaN(d.getTime())) return null`.
//                 JS-ISO מאמת חודש 01-12 ויום 01-31 (אחרת Invalid Date), ואז מגלגל יום-עודף
//                 (2026-02-30 ⇒ 2 במרץ, תקין). Dart `DateTime.parse` מגלגל **הכול** —
//                 חודש 99/13/00 שורדים (כלל-פורט 3/4). ⇒ אימות-טווח מפורש חודש∈[1,12]
//                 ויום∈[1,31] לפני הפרסור; try/catch משקף isNaN.
//   • גישת-שדות — `p.month`/`p.day`/`p.year` על dynamic ⇒ ב-Dart גישת-מפתח על Map:
//                 `p['month']`/`p['day']`/`p['year']`.
//   • truthiness — המנוע פלט `_falsy(...)`. JS `!monthHe || !p.day || !p.year`:
//                 monthHe falsy = '' ; day/year falsy = null או 0 ⇒ תנאי-מפורש (כלל-פורט 7).
//   • המרת-פלט — אובייקט-JS ⇒ Map<String, dynamic>; null נשמר.
//
// קלט:  iso (String "YYYY-MM-DD") · hebParts — שקע: DateTime ⇒ {day, month(אנגלית), year} ·
//        monthHeOf — שקע: month(אנגלית) ⇒ תווית-עברית או ''.
// פלט:  {day, monthHe, year} או null (regex/תאריך-לא-חוקי/חודש-לא-מוכר/חלק-חסר).

/// לועזי→עברי: ISO ⇒ {day, monthHe, year}, או null.
Map<String, dynamic>? isoToHebParts(
  String iso,
  Map<String, dynamic> Function(DateTime d) hebParts,
  String Function(String en) monthHeOf,
) {
  if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(iso)) return null;
  // JS `new Date(iso+'T12:00:00')` = Invalid Date אם חודש∉[1,12] או יום∉[1,31]
  // (ואז מגלגל יום-עודף). ל-Dart מגלגל הכול ⇒ אימות-טווח מפורש לשיקוף isNaN.
  final mo = int.parse(iso.substring(5, 7));
  final dy = int.parse(iso.substring(8, 10));
  if (mo < 1 || mo > 12 || dy < 1 || dy > 31) return null;
  final DateTime d;
  try {
    d = DateTime.parse('${iso}T12:00:00');
  } catch (_) {
    return null;
  }
  final p = hebParts(d);
  final monthHe = monthHeOf((p['month'] ?? '') as String);
  if (monthHe.isEmpty || (p['day'] ?? 0) == 0 || (p['year'] ?? 0) == 0) {
    return null;
  }
  return {'day': p['day'], 'monthHe': monthHe, 'year': p['year']};
}
