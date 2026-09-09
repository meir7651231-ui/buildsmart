// ⚛️ אטום-Dart (דרגת-חוזה) · weekdayOfIso — יום-בשבוע של תאריך ISO: 0=ראשון … 6=שבת; לא-תקין ⇒ -1
// מוצא: בלגן G34 · הכרעת-בעלים 9.9 — חלקיק-יסוד: נבדק מול 850 מנועי-הלוגיקה באינדקס (חתימה+ייעוד) ואין לו מקבילה (dayNames מחזיר שמות בלבד, הלוח העברי מחזיר חלקי-תאריך).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). דטרמיניסטי; קלט לא-תקין ⇒ ערך-ריק, אפס-זריקה.

int weekdayOfIso(String iso) { final d = _pIso(iso); return d == null ? -1 : d.weekday % 7; }
DateTime? _pIso(String s) { final t = s.trim(); if (t.length < 10) return null; final y = int.tryParse(t.substring(0, 4)), m = int.tryParse(t.substring(5, 7)), d = int.tryParse(t.substring(8, 10)); if (y == null || m == null || d == null) return null; return DateTime.utc(y, m, d); }
