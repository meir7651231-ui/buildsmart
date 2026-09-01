// אטום-הצבה (placement) · ברירת-מחדל ללא-פלטפורמה — אין התמדה (נשאר in-memory).
// נבחר דרך conditional-import כשאין js_interop (למשל בבדיקות/native ללא-אחסון).
void persistSave(String key, String value) {}
String? persistLoad(String key) => null;
