// סטאב · פלטפורמה בלי התראת-דפדפן (בדיקות · native). G55 · «אין ערוץ» מוחזר ככשל-כן,
// והקורא נופל למסלול המקומי (flutter_local_notifications) — לא מדווח הצלחה מדומה.
bool notifyGranted() => false;
bool notifyCanAsk() => false;
Future<bool> notifyAsk() async => false;
Future<bool> notifyShow(String title, String body, String tag) async => false;
