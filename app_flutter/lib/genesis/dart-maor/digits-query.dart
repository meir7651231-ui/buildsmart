// ⚛️ אטום-Dart (דרגת-חוזה) · digitsQuery — שאילתת-חיפוש שהיא ספרות (עם פסיקים/נקודות/מקפים/רווחים) ⇒ הספרות דרך שקע-נרמול-הטלפון (≥2); טקסט ⇒ ריק
// מוצא: בלגן G34 · הכרעת-בעלים 9.9 — חלקיק-יסוד: נבדק מול 850 מנועי-הלוגיקה באינדקס (חתימה+ייעוד) ואין לו מקבילה (normPhone/phoneKey מנקים ספרות אך אינם מכריעים אם השאילתה מספרית).
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). דטרמיניסטי; קלט לא-תקין ⇒ ערך-ריק, אפס-זריקה.

String digitsQuery(String q, String Function(String?) normPhone) { final t = q.trim(); if (t.isEmpty) return ''; for (var i = 0; i < t.length; i++) { final c = t.codeUnitAt(i); if (!((c >= 48 && c <= 57) || c == 44 || c == 46 || c == 45 || c == 32)) return ''; } if (t.codeUnitAt(0) < 48 || t.codeUnitAt(0) > 57) return ''; final d = normPhone(t); return d.length >= 2 ? d : ''; }
