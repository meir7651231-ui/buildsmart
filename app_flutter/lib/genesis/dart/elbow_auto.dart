// ⚛️ אטום-Dart (דרגת-חוזה) · elbowAuto
// מוצא: buildsmart/app_flutter/lib/features/fittings/engine/fitting_dims.dart:170-172 (חצב-בינה · חוק-3/4).
// שקע: miteredElbow ← השכן `miteredElbow(d)` — ברך מחותכת גדולה (מפת-מידות).
// שקע: elbow ← השכן `elbow(od, {angle})` — ברך חד-קוטרית (מפת-מידות).
// בורר-דיאגרמה: d≥160 ⇒ מחותכת, אחרת ברך רגילה בזווית.

Map<String, double> elbowAuto(
  int d, {
  int angle = 90,
  required Map<String, double> Function(int) miteredElbow,
  required Map<String, double> Function(int, {int angle}) elbow,
}) =>
    d >= 160 ? miteredElbow(d) : elbow(d, angle: angle);
