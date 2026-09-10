// אטום-הצבה (placement) · התמדת-דפדפן דרך localStorage. חוצה package:web — גבול-פלטפורמה
// מבוקר (חוק-6: הצבה, לא אטום-טהור). נכשל-רך אם האחסון חסום (חלון-פרטי/הרשאות).
import 'package:web/web.dart' as web;

/// G51 · מחזיר האם נשמר בפועל. מכסה-מלאה/אחסון-חסום ⇒ false (הקורא חייב להראות זאת; אסור לבלוע).
bool persistSave(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
    return true;
  } catch (_) {
    return false;
  }
}

String? persistLoad(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}
