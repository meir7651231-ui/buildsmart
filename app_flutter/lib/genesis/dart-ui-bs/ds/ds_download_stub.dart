// אטום-הצבה (placement) · ברירת-מחדל ללא-פלטפורמה — אין הורדה (מחזיר false).
// נבחר דרך conditional-import כשאין js_interop (בדיקות/native).
bool downloadText(String filename, String text, [String mime = 'application/json']) => false;
