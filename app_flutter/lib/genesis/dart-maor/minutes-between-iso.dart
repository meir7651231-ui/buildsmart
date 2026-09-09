// ⚛️ אטום-Dart (דרגת-חוזה) · minutesBetweenIso — דקות בין שני זמנים ISO (yyyy-mm-ddThh:mm[:ss]); חיובי קדימה; לא-תקין ⇒ 0
// מוצא: בלגן G34 · הכרעת-בעלים 9.9 — חלקיק-יסוד: נבדק מול 850 מנועי-הלוגיקה באינדקס (חתימה+ייעוד) ואין לו מקבילה (timeToMin עובד על HH:MM בתוך יום; cockpitDaysSince מחזיר ימים).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). דטרמיניסטי; קלט לא-תקין ⇒ ערך-ריק, אפס-זריקה.

int minutesBetweenIso(String fromIso, String toIso) { final a = _pDt(fromIso), b = _pDt(toIso); if (a == null || b == null) return 0; return b.difference(a).inMinutes; }
DateTime? _pDt(String s) { final t = s.trim(); final d = _pIso(t); if (d == null) return null; if (t.length < 16) return d; final hh = int.tryParse(t.substring(11, 13)) ?? 0, mm = int.tryParse(t.substring(14, 16)) ?? 0, ss = t.length >= 19 ? (int.tryParse(t.substring(17, 19)) ?? 0) : 0; return DateTime.utc(d.year, d.month, d.day, hh, mm, ss); }
DateTime? _pIso(String s) { final t = s.trim(); if (t.length < 10) return null; final y = int.tryParse(t.substring(0, 4)), m = int.tryParse(t.substring(5, 7)), d = int.tryParse(t.substring(8, 10)); if (y == null || m == null || d == null) return null; return DateTime.utc(y, m, d); }
