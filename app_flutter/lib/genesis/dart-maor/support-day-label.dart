// חוט · support-day-label — תווית-יום לצ'אט-תמיכה (היום/אתמול/dd/mm/yyyy). חוזה: support-day-label.contract.md
// המרה מ-JS (new/atoms/support-day-label.mjs) — התנהגות זהה-לחלוטין למקור (חוק-4).
// אפס-import (dart-core בלבד). dynamic מותר.

/// חוק-7 · truthiness של JS: ''/0/-0/NaN/null/false כוזבים; השאר אמת.
/// (הוזרק inline מ-js-compat-reference.dart::jsTruthy — חוק-1: אטום לא-מייבא.)
bool _truthy(dynamic v) {
  if (v == null || v == false) return false;
  if (v == true) return true;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// slice(0,10) בטוח (חוק-5): מחרוזת קצרה מ-10 חוזרת כמות-שהיא.
String _slice10(String s) => s.length <= 10 ? s : s.substring(0, 10);

/// חוקים 3+4 · parseV8Local — מחקה `new Date("YYYY-MM-DDThh:mm:ss")` של V8 (מקומי, בלי אזור-זמן).
/// מחזיר DateTime (מקומי) או null (≡ Invalid Date/NaN).
/// (הוזרק inline מ-js-compat-reference.dart::parseV8Local — חוק-1: אטום לא-מייבא.)
/// ⚠️ התיקון (FIXES: "פרסור-V8: שנה-מורחבת +002026 מתקבלת ⇒ להרחיב regex"):
///    ה-regex תומך בשנה-מורחבת ±YYYYYY (‏[+-]?\d{4,6}) במקום \d{4} הצר של-ההסגר.
DateTime? _parseV8Local(String iso, Map<String, dynamic> T) {
  final m = RegExp(r'^([+-]?\d{4,6})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.\d+)?)?)?$')
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

dynamic supportDayLabel(dynamic at, dynamic todayIso, Map<String, dynamic> T) {
  final day = _slice10(at as String);
  if (day == todayIso) return T['k1']!;
  // אתמול = יום-אחד לפני todayIso (חישוב על ה-ISO, צהריים מקומי).
  // המקור: new Date(todayIso + 'T12:00:00') — מפרסמים את המחרוזת המשורשרת בדיוק.
  final t = _parseV8Local((todayIso as String) + 'T12:00:00', T);
  String y, m, dd;
  if (t == null) {
    // Invalid Date ב-JS: getFullYear/getMonth/getDate = NaN ⇒ String(NaN)='NaN'.
    y = 'NaN';
    m = 'NaN';
    dd = 'NaN';
  } else {
    final yst = DateTime(t.year, t.month, t.day - 1, 12); // setDate(getDate()-1) — מגלגל חודש/שנה
    y = yst.year.toString();
    m = yst.month.toString().padLeft(2, '0');
    dd = yst.day.toString().padLeft(2, '0');
  }
  if (day == '$y-$m-$dd') return T['k2']!;
  // const [yy, mm, d2] = day.split('-') — פירוק JS: איבר-חסר = undefined (null).
  final parts = day.split('-');
  final yy = parts.isNotEmpty ? parts[0] : null;
  final mm = parts.length > 1 ? parts[1] : null;
  final d2 = parts.length > 2 ? parts[2] : null;
  return (_truthy(d2) && _truthy(mm) && _truthy(yy)) ? '$d2/$mm/$yy' : day;
}
