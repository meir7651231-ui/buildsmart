// 🌉 מצב-מסונן · אחסון-מפתח-ערך — גרסת web (localStorage).
//
// נבחר ע"י `edge_kv.dart` כש-`dart.library.js_interop` אמת (build web). עוטף
// את `window.localStorage` (פר-מקור — בדיוק כמו סשן ה-Firebase-SDK עצמו).

import 'package:buildsmart/data/edge/filtered_session.dart';
import 'package:web/web.dart' as web;

class _LocalStorageKv implements EdgeKvStore {
  @override
  String? read(String key) => web.window.localStorage.getItem(key);
  @override
  void write(String key, String value) =>
      web.window.localStorage.setItem(key, value);
  @override
  void remove(String key) => web.window.localStorage.removeItem(key);
}

/// יוצר אחסון פר-פלטפורמה. web: ‏localStorage אמיתי (מתמיד בין ריצות).
EdgeKvStore makeEdgeKvStore() => _LocalStorageKv();

/// קורא את פרמטר `filtered` מה-URL (web): `?filtered=1` / `#filtered`.
/// מחזיר את הערך הגולמי (למשל '1'/'off'), או null אם לא-צוין.
String? readFilteredUrlParam() {
  final loc = web.window.location;
  final search = loc.search;
  final query = search.startsWith('?') ? search.substring(1) : search;
  final v = Uri.splitQueryString(query)['filtered'];
  if (v != null && v.isNotEmpty) return v.toLowerCase();
  // גם `#filtered` בלבד (בלי query) מדליק — נוח לקישור-hash.
  if (loc.hash.toLowerCase().contains('filtered')) return 'on';
  return null;
}
