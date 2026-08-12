// 🌉 מצב-מסונן · אחסון-מפתח-ערך — גרסת ברירת-מחדל (native / Dart-VM).
//
// מצב-מסונן הוא web-first (סנני-הכשרות פועלים על דפדפן). על native ובבדיקות
// אין localStorage ⇒ מפה-בזיכרון (לא-מתמיד). כך `dart.library.js_interop`
// שקר ⇒ הקומפיילר בוחר את הקובץ הזה, ו-`package:web` לא נגרר ל-VM.

import 'package:buildsmart/data/edge/filtered_session.dart';

class _MemoryKv implements EdgeKvStore {
  final Map<String, String> _m = {};
  @override
  String? read(String key) => _m[key];
  @override
  void write(String key, String value) => _m[key] = value;
  @override
  void remove(String key) => _m.remove(key);
}

/// יוצר אחסון פר-פלטפורמה. native/VM: מפה-בזיכרון (מצב-מסונן לא-נתמך שם).
EdgeKvStore makeEdgeKvStore() => _MemoryKv();
