// ⚛️ אטום-Dart (דרגת-חוזה) · dayMonthOfIso — תאריך ISO כ«יום.חודש» בלי אפסים מובילים (8.9), ועם שנה כשמבקשים (3.10.2027); לא-תקין ⇒ כמות-שהוא
// מוצא: בלגן G34 · הכרעת-בעלים 9.9 — חלקיק-יסוד: נבדק מול 850 מנועי-הלוגיקה באינדקס (חתימה+ייעוד) ואין לו מקבילה (fmtDate מחזיר dd/mm/yyyy עם אפסים — צורה אחרת).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). דטרמיניסטי; קלט לא-תקין ⇒ ערך-ריק, אפס-זריקה.

String dayMonthOfIso(String iso, bool withYear) { final d = _pIso(iso); if (d == null) return iso; return d.day.toString() + '.' + d.month.toString() + (withYear ? '.' + d.year.toString() : ''); }
DateTime? _pIso(String s) { final t = s.trim(); if (t.length < 10) return null; final y = int.tryParse(t.substring(0, 4)), m = int.tryParse(t.substring(5, 7)), d = int.tryParse(t.substring(8, 10)); if (y == null || m == null || d == null) return null; return DateTime.utc(y, m, d); }
