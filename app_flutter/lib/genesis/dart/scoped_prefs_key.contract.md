# חוזה · scopedPrefsKey

- **מוצא:** `buildsmart/app_flutter/lib/features/card_keyboard/scoped_prefs_key.dart:10-12`.
- **חתימה:** `String scopedPrefsKey(String base, String? uid)`
- **התנהגות (חוק-4, verbatim):** `(uid == null || uid.isEmpty) ? base : '$base::$uid'` — uid null/ריק ⇒ המפתח הגלובלי כמות-שהוא; זהות אמיתית ⇒ `base::uid`.
- **טוהר:** אפס import; מניפולציית-מחרוזת בלבד. הזהות מוזרקת כפרמטר (חוק-6).
- **אימות:** `dart analyze` נקי + `dart run --enable-asserts scoped_prefs_key_test.dart` עובר.
