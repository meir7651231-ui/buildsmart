// חוט · freshen-demo-db — ריענון תאריכי-תזמון של הדמו בדלתא מהעוגן.
// חוזה: new/atoms/freshen-demo-db.contract.md · המרה מ-JS (new/atoms/freshen-demo-db.mjs)
// — התנהגות זהה-לחלוטין למקור (חוק-4). חולץ כלשונו מ-maor/src/lib/demoFresh.ts:32-51
// (כולל העוזרים הפרטיים daysBetween/shift). DEMO_ANCHOR ו-isoLocal הוזרקו כשקעים (חוק-1).
// אפס-import (dart-core בלבד). db = Map; פריטי-אוסף = Map.
//
// 🔧 תיקון-הסגר (חודש-13, משפחת גלישת-תאריך, כלל-4): הפורט השבור השתמש ב-
// DateTime.tryParse, ש**מנרמל** month/day מחוץ-לטווח ש-V8 דוחה כ-Invalid Date:
//   • '2026-13-45' (חודש 13): JS ⇒ Invalid ⇒ shift מחזיר iso כמות-שהוא;
//     Dart.tryParse ⇒ 2027-02-14 ⇒ מזיז תאריך-פסול. גם חודש-00 ויום-32.
// המקור (new Date(iso+'T12:00:00')) דוחה חודש∉[1,12] ויום∉[1,31] אך *מגלגל*
// גלישת-יום (Feb 30 ⇒ Mar 2). התיקון: שקע _parseV8Local (מהספרייה המאומתת
// machtzev/emit/js-compat-reference.dart, מוזרק INLINE עם קידומת _ — חוק-1)
// שמאמת טווח נאמן-V8 ומחזיר null (≡ Invalid/NaN) על חוץ-לטווח.

/// חוקים 3+4 · parseV8Local — מחקה `new Date("YYYY-MM-DDThh:mm:ss")` של V8 (מקומי,
/// בלי אזור-זמן). מחזיר DateTime (מקומי) או null (≡ Invalid Date/NaN). אומת מול Node:
///  • יום-גולש מתגלגל (Feb 30 ⇒ Mar 2), אך רק אם day∈[1,31] month∈[1,12] (אחרת NaN).
///  • T24:00:00 ⇒ מחרת 00:00. שנה-מורחבת ±YYYYYY. שבר-שניות מתקבל (נחתך).
DateTime? _parseV8Local(String iso) {
  final m = RegExp(r'^([+-]?\d{4,6})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?)?$')
      .firstMatch(iso);
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final mon = int.parse(m.group(2)!);
  final day = int.parse(m.group(3)!);
  final hour = m.group(4) != null ? int.parse(m.group(4)!) : 0;
  final min = m.group(5) != null ? int.parse(m.group(5)!) : 0;
  final sec = m.group(6) != null ? int.parse(m.group(6)!) : 0;
  // אימות-טווח נאמן-V8: חודש 1–12 · יום 1–31 · שעה 0–24 · דקה/שנייה 0–59.
  if (mon < 1 || mon > 12) return null;
  if (day < 1 || day > 31) return null;
  if (hour > 24 || min > 59 || sec > 59) return null;
  if (hour == 24 && (min != 0 || sec != 0)) return null;
  // בנייה: DateTime של Dart מגלגל גלישת-יום כמו JS (Feb 30 ⇒ Mar 2), ושעה-24 ⇒ מחרת.
  return DateTime(year, mon, day, hour, min, sec);
}

int _daysBetween(String fromIso, String toIso) {
  final a = _parseV8Local(fromIso + 'T12:00:00');
  final b = _parseV8Local(toIso + 'T12:00:00');
  if (a == null || b == null) return 0;
  return ((b.millisecondsSinceEpoch - a.millisecondsSinceEpoch) / 86400000)
      .round();
}

/// מזיז תאריך ISO ב-days; קלט ריק/לא-תקין מוחזר כמות-שהוא.
dynamic _shift(dynamic iso, int days, String Function(DateTime d) isoLocal) {
  if (iso == null ||
      iso is! String ||
      iso.isEmpty ||
      !RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(iso)) {
    return iso;
  }
  // ‏new Date(iso.slice(0,10)+'T12:00:00') — V8 דוחה חודש/יום חוץ-לטווח (Invalid ⇒ iso).
  final base = _parseV8Local(iso.substring(0, 10) + 'T12:00:00');
  if (base == null) return iso;
  // מקביל ל-setDate(getDate()+days): הקונסטרוקטור מנרמל גלישת-יום/חודש/שנה.
  final d = DateTime(base.year, base.month, base.day + days, 12);
  return isoLocal(d);
}

Map<String, dynamic> freshenDemoDb(
  Map<String, dynamic> db,
  String todayIso,
  String anchorIso,
  String Function(DateTime d) isoLocal,
) {
  final delta = _daysBetween(anchorIso, todayIso);
  if (delta == 0) return db;
  final out = Map<String, dynamic>.from(db);
  out['courses'] = (db['courses'] as List).map((c) {
    final m = Map<String, dynamic>.from(c as Map);
    m['start'] = _shift(m['start'], delta, isoLocal);
    m['end'] = _shift(m['end'], delta, isoLocal);
    return m;
  }).toList();
  out['events'] = (db['events'] as List).map((e) {
    final m = Map<String, dynamic>.from(e as Map);
    m['date'] = _shift(m['date'], delta, isoLocal);
    return m;
  }).toList();
  out['distributionDays'] = (db['distributionDays'] as List).map((d) {
    final m = Map<String, dynamic>.from(d as Map);
    m['date'] = _shift(m['date'], delta, isoLocal);
    m['createdAt'] = _shift(m['createdAt'], delta, isoLocal);
    return m;
  }).toList();
  out['enrollments'] = (db['enrollments'] as List).map((en) {
    final m = Map<String, dynamic>.from(en as Map);
    m['dueDate'] = _shift(m['dueDate'], delta, isoLocal);
    m['enrolledAt'] = _shift(m['enrolledAt'], delta, isoLocal);
    return m;
  }).toList();
  return out;
}
