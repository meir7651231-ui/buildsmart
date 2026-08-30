// ⚛️ אטום-Dart (דרגת-חוזה) · inactiveRoomCourses — חוגים חיים המשויכים לחדר
//    לא-פעיל / לא-קיים (אזהרות-יומן).
// מוצא: maor/src/components/diary/lib.ts:244-258 · המקור: new/atoms/inactive-room-courses.mjs
// חוזה: new/atoms/inactive-room-courses.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
// שקע (חוק-1): termOf(config, key, fallback) — מונח פר-ארגון; האטום קורא לו רק עם
//    המפתח 'entity.room' וה-fallback 'חדר'. השכן הוזרק כפרמטר (אפס import פנימי).
//
// הערות-המרה (DART-PORTING-RULES):
//  • truthiness (כלל 7): `if (!c.roomId)` / `if (!room.active)` של JS ⇒ שקע `_falsy` מפורש.
//    `c.end &&` (מחרוזת) ⇒ `_truthy(end)` (מדלג על end חסר / '').
//  • השוואת-מחרוזת `iso > c.end` — לקסיקוגרפית ב-JS; `iso.compareTo(end) > 0` ב-Dart
//    (פורמט ISO אחיד ⇒ סדר-מחרוזת ≡ סדר-כרונולוגי).
//  • `db.rooms.find(...)` ⇒ לולאה עם break; לא-נמצא ⇒ null (מקביל ל-undefined של JS).
//  • ה-Map-ים dynamic (course/room מגיעים כמו-שהם); course בפלט = אותה רפרנס למקור.

bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || v == '' || (v is num && v.isNaN);
bool _truthy(dynamic v) => !_falsy(v);

/// Live courses assigned to an inactive / non-existent room (diary warnings).
/// Verbatim behaviour of the JS source `inactiveRoomCourses`. Output order = db.courses order.
List<Map<String, dynamic>> inactiveRoomCourses(Map<String, dynamic> db,
  String iso,
  dynamic config,
  String Function(dynamic config, String key, String fallback) termOf, Map<String, String> T) {
  final out = <Map<String, dynamic>>[];
  final courses = (db['courses'] as List?) ?? const [];
  final rooms = (db['rooms'] as List?) ?? const [];
  for (final c in courses) {
    final cm = c as Map;
    final end = cm['end'];
    if (_truthy(end) && iso.compareTo(end as String) > 0) continue;
    if (_falsy(cm['roomId'])) continue;
    final roomId = cm['roomId'];
    Map? room;
    for (final r in rooms) {
      if ((r as Map)['id'] == roomId) {
        room = r;
        break;
      }
    }
    if (room == null) {
      out.add({
        'course': c,
        'roomName': termOf(config, 'entity.room', T['k2']!) + T['k3']!,
      });
    } else if (_falsy(room['active'])) {
      out.add({'course': c, 'roomName': room['name']});
    }
  }
  return out;
}
