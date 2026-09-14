// ⚛️ אטום-Dart (דרגת-חוזה) · screenLabelHe
// מוצא: buildsmart/app_flutter/lib/config/screen_labels_he.dart:183-189 (חצב-בינה · חוק-3/4).
// שקע: normalizeScreen ← השכן `normalizeScreen(screen)` — מכווץ כפילויות-מזהה למסך-לוגי.
//       humanize        ← השכן `_humanize(key)` — גיבוי-זנב-ארוך (מזהה→תווית קריאה).
//         (שם-השקע private→param בלי-קו-תחתי; קריאת-הגוף חוברה לשם-הפרמטר.)
// מוטבע verbatim (מפת-נתונים, חוק-1): kScreenLabelsHe (screen_labels_he.dart:32-179).
// תווית-תצוגה עברית למסך: נרמול → שליפה מהמפה → נפילה ל-humanize. תמיד לא-ריק.

String screenLabelHe(String screen,
    {required String Function(String) normalizeScreen,
    required String Function(String) humanize, required Map<String, dynamic> kScreenLabelsHe,}) {
  final key = normalizeScreen(screen);
  return kScreenLabelsHe[key] ?? humanize(key);
}

