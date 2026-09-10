// אטום-הצבה (placement) · ברירת-מחדל ללא-פלטפורמה — אין התמדה (נשאר in-memory).
// נבחר דרך conditional-import כשאין js_interop (למשל בבדיקות/native ללא-אחסון).
/// G51 · אין-התמדה = החלטה, לא כשל ⇒ true (אחרת בדיקות/native-בלי-אחסון היו מציגות אזהרת-אובדן שקרית).
bool persistSave(String key, String value) => true;
String? persistLoad(String key) => null;
