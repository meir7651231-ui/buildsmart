// אטום-הצבה (placement) · התמדת-דפדפן דרך localStorage. חוצה package:web — גבול-פלטפורמה
// מבוקר (חוק-6: הצבה, לא אטום-טהור). נכשל-רך אם האחסון חסום (חלון-פרטי/הרשאות).
import 'package:web/web.dart' as web;

void persistSave(String key, String value) {
  try {
    web.window.localStorage.setItem(key, value);
  } catch (_) {}
}

String? persistLoad(String key) {
  try {
    return web.window.localStorage.getItem(key);
  } catch (_) {
    return null;
  }
}
