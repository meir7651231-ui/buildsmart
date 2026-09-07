// חוט · support-msg-time — הומר מ-JS ‏(new/atoms/support-msg-time.mjs). חוזה: support-msg-time.contract.md
// שיקוף V8: פרסור-ISO בלבד (regex + אימות-טווחים + TimeClip); קלט לא-תקין ⇒ '' (כמו NaN-date ב-JS).
// פורמט he-IL ‏hour/minute '2-digit' = ‏HH:MM ‏(24 שעות, מרופד). חוק-1: אטום לא-מייבא — עוזרים _ מוזרקים inline.

const int _kMaxTime = 8640000000000000; // ±8.64e15ms = גבול-TimeClip של ES ‏(±275760/-271821).

// ימים-מאז-האפוך לתאריך-אזרחי (אלגוריתם Hinnant) — טווח-שנים חופשי (בלי מגבלת-DateTime).
int _daysFromCivil(int y, int m, int d) {
  final yy = y - (m <= 2 ? 1 : 0);
  final era = (yy >= 0 ? yy : yy - 399) ~/ 400;
  final yoe = yy - era * 400;
  final doy = (153 * (m + (m > 2 ? -3 : 9)) + 2) ~/ 5 + d - 1;
  final doe = yoe * 365 + yoe ~/ 4 - yoe ~/ 100 + doy;
  return era * 146097 + doe - 719468;
}

/// שעה-ודקה מקומיות למחרוזת-ISO בסגנון V8; ‏null = Invalid Date (כולל TimeClip).
List<int>? _jsLocalHourMinute(String s) {
  final re = RegExp(
      r'^(\d{4}|[+-]\d{6})-(\d{2})(?:-(\d{2}))?T(\d{2}):(\d{2})(?::(\d{2})(?:\.(\d+))?)?(Z|[+-]\d{2}:?\d{2})?$');
  final m = re.firstMatch(s);
  if (m == null) return null;
  final year = int.parse(m.group(1)!);
  final month = int.parse(m.group(2)!);
  final day = m.group(3) == null ? 1 : int.parse(m.group(3)!);
  final hour = int.parse(m.group(4)!);
  final minute = int.parse(m.group(5)!);
  final second = m.group(6) == null ? 0 : int.parse(m.group(6)!);
  // שבר-שנייה: כל-מספר-ספרות מותר; ES גוזם ל-3 (מילישניות). '.9' ⇒ 900, '.0009' ⇒ 000.
  final frac = m.group(7);
  final ms = frac == null ? 0 : int.parse((frac + '000').substring(0, 3));
  if (month < 1 || month > 12) return null; // חודש-13/00 ⇒ Invalid
  // חוקים 3+4 · V8 מגלגל יום-בטווח-[1,31] שחורג-מהחודש (Feb 29 בפשוטה ⇒ Mar 1),
  // ‏_daysFromCivil (Hinnant) מגלגל את הגלישה ליניארית ⇒ ה-TimeClip נכון; רק 00/≥32 = Invalid.
  if (day < 1 || day > 31) return null; // יום-00/≥32 ⇒ Invalid (גלישה-בתוך-31 מתגלגלת)
  if (hour > 24 || minute > 59 || second > 59) return null;
  if (hour == 24 && (minute != 0 || second != 0 || ms != 0)) return null; // T24:00:00.000 בלבד תקין

  final h0 = hour == 24 ? 0 : hour;
  final addDayMs = hour == 24 ? 86400000 : 0;

  final tz = m.group(8);
  var offMin = 0;
  if (tz != null && tz != 'Z') {
    final sign = tz[0] == '-' ? -1 : 1;
    final digits = tz.substring(1).replaceAll(':', '');
    offMin = sign *
        (int.parse(digits.substring(0, 2)) * 60 +
            int.parse(digits.substring(2, 4)));
  }

  // ערך-הזמן (ms מאז-אפוך). TimeClip לפני כל המרה — גם על שבר-השנייה-בגבול.
  final days = _daysFromCivil(year, month, day);
  final t = days * 86400000 +
      h0 * 3600000 +
      minute * 60000 +
      second * 1000 +
      ms +
      addDayMs -
      offMin * 60000;
  if (t < -_kMaxTime || t > _kMaxTime) return null; // TimeClip ⇒ Invalid Date

  if (tz == null) {
    // בלי אזור-זמן: ES מפרש כזמן-מקומי ⇒ הפלט המקומי הוא בדיוק השעה שנכתבה.
    return [h0, minute];
  }
  final local = DateTime.fromMillisecondsSinceEpoch(t, isUtc: true).toLocal();
  return [local.hour, local.minute];
}

/// חוט · supportMsgTime — "HH:MM" בפורמט he-IL, או '' לקלט לא-תקין.
dynamic supportMsgTime(dynamic at) {
  final String raw = at as String;
  final s = raw.contains('T') ? raw : raw + 'T12:00:00';
  final hm = _jsLocalHourMinute(s);
  if (hm == null) return '';
  final hh = hm[0].toString().padLeft(2, '0');
  final mm = hm[1].toString().padLeft(2, '0');
  return '$hh:$mm';
}
