// ⚛️ אטום-Dart (דרגת-חוזה) · weeklyRoomSessions — ניצולת שבועית של חדר:
//    סכום המפגשים-השבועיים של החוגים המשויכים לחדר שלא הסתיימו נכון ל-iso.
// מוצא: maor/src/components/diary/lib.ts:237-243 · המקור: new/atoms/weekly-room-sessions.mjs
// חוזה: new/atoms/weekly-room-sessions.contract.md
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
// שקע (חוק-1): sessionsOf(course) ⇒ מערך-המפגשים-בפועל של החוג (השכן sessions-of
//    מ-courses/lib הוזרק כפרמטר — אפס import פנימי).
//
// הערות-המרה (DART-PORTING-RULES):
//  • truthiness (כלל 7): `!c.end` של JS ⇒ שקע `_falsy` מפורש (end חסר / null / '' ⇒ בלי-סיום).
//  • השוואת-מחרוזת `iso <= c.end` — לקסיקוגרפית ב-JS; `iso.compareTo(end) <= 0` ב-Dart
//    (פורמט ISO אחיד ⇒ סדר-מחרוזת ≡ סדר-כרונולוגי; יום-הסיום עצמו עדיין נספר).
//  • filter+reduce ⇒ לולאה מצטברת (אותו סדר, אותה סמנטיקה; ההתחלה 0 כמו ב-reduce).
//  • הגישה לשדות = Map (`c['roomId']`/`c['end']`) — הנתונים Map, לא record.

bool _falsy(dynamic v) =>
    v == null || v == false || v == 0 || v == '' || (v is num && v.isNaN);

/// Weekly room utilisation: sum of sessionsOf(c).length over the courses whose
/// roomId matches and which have not ended as of [iso] (end day itself counts).
/// Verbatim behaviour of the JS source `weeklyRoomSessions`.
num weeklyRoomSessions(
  Map<String, dynamic> db,
  dynamic roomId,
  String iso,
  List<dynamic> Function(dynamic c) sessionsOf,
) {
  num total = 0;
  for (final c in (db['courses'] as List)) {
    final cm = c as Map;
    final end = cm['end'];
    if (cm['roomId'] == roomId &&
        (_falsy(end) || iso.compareTo(end as String) <= 0)) {
      total += sessionsOf(c).length;
    }
  }
  return total;
}
