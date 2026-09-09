// ⚛️ אטום-Dart (דרגת-חוזה) · addDaysIso — הוספת ימים לתאריך (ISO yyyy-mm-dd) ⇒ תאריך; חודש ושנה מתגלגלים; שלילי = אחורה
// מוצא: בלגן G33 · app-shell _shift/_iso · הכרעת-בעלים 9.9 (G34): התנהגות של בלגן = אטום-מדף נבחר-לפי-ייעוד, לא קוד-ידני במחולל.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). דטרמיניסטי; קלט לא-תקין ⇒ ערך-ריק/כמות-שהוא, אפס-זריקה.
// תפר: קלט = מחרוזות-ISO / רשומות Map<String,String> / רשימות — אפס טיפוסי-UI ואפס store; הפלט = נתון (המחולל מלביש מונחים מהכרום).

String addDaysIso(String iso, int n) { final d = _pIso(iso); if (d == null) return iso; return _fIso(DateTime.utc(d.year, d.month, d.day + n)); }
DateTime? _pIso(String s) { final t = s.trim(); if (t.length < 10) return null; final y = int.tryParse(t.substring(0, 4)), m = int.tryParse(t.substring(5, 7)), d = int.tryParse(t.substring(8, 10)); if (y == null || m == null || d == null) return null; return DateTime.utc(y, m, d); }
String _fIso(DateTime d) => d.year.toString().padLeft(4, '0') + '-' + d.month.toString().padLeft(2, '0') + '-' + d.day.toString().padLeft(2, '0');

