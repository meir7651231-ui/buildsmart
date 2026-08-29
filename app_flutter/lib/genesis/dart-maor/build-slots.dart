// ⚛️ אטום-Dart (דרגת-חוזה) · buildSlots — משבצות-היום של חדר ביומן-החדרים.
// מוצא: maor/src/components/diary/lib.ts:139-227 · המקור: new/atoms/build-slots.mjs.
// טוהר: פונקציית top-level עצמאית, אפס import (רק שפה/סטנדרט: dart:core). חוק-4 —
//        התנהגות זהה-ביט למקור-ה-JS (המקור קדוש). חמשת השכנים הוזרקו כשקעים (חוק-1/חוק-3):
//        timeToMin · minToHM · sessionsOf · courseOnDate · termOf.
//
// תפקיד: בניית משבצות מ-room.from עד room.to בקפיצות room.slot. קדימות פר-משבצת:
//        ניקיון-יומי (15:00–16:00, מגודר cleaningOn) → מפגש-חוג → אירוע → חסום → פנוי;
//        מפגשי-היום מחוץ-לשעות מתווספים בסוף עם outOfHours:true.
//
// הערות-המרה (מקור→Dart — הנקודות שמנוע-ה-AST נטה לפספס):
//  • getDay() ב-JS: 0=ראשון … 6=שבת. Dart weekday: 1=שני … 7=ראשון. `weekday % 7`
//    ממפה בדיוק: שני=1 … שבת=6, ראשון=7%7=0 ≡ getDay של JS. `new Date(iso+'T12:00:00')`
//    → `DateTime.parse(iso + 'T12:00:00')` (צהריים מקומי — נמנע גלישת-יום).
//  • JS `||` (truthiness) על `ss[i].time || hh` / `ev.time || hh` / `sess.time || '—'`:
//    '' ו-null/undefined = כבוי ⇒ נופל ל-fallback. שוקע ל-`_or` (null/''/false/0/NaN).
//    ‏`else if (blocked)` / `ev.done` = _truthy זהה.
//  • `Number.isNaN(timeToMin(...))` → `.isNaN` על ה-num שהשקע מחזיר (double.nan ללא-תקין).
//  • הגישה לשדות = Map (`room['from']`/`c['id']`) — הנתונים Map, לא record.
//  • שרשור-מחרוזת מספרי (`c.id`, `i`) → `.toString()` (Dart אינו מצרף-אוטומטית).
//  • מוטביליות: `slots`/`covered` final (מוטבלים דרך add) · `occupied` var (מתהפך) ·
//    לולאת-ה-C `t`/`guard` num (מתקדמים); step/from/to num (שקע יכול להחזיר לא-שלם).
//  • `room.slot > 0 ? room.slot : 60`: לא-מספר/≤0 ⇒ 60 (שומר על undefined>0=false של JS).

bool _truthy(dynamic v) =>
    v != null && v != false && v != '' && v != 0 && !(v is num && v.isNaN);

/// JS `a || b` for the string/optional fields: null/''/false/0/NaN ⇒ fallback.
dynamic _or(dynamic v, dynamic fb) => _truthy(v) ? v : fb;

/// A room's day-slots for the rooms-diary. Verbatim port of
/// new/atoms/build-slots.mjs (`buildSlots`); the five neighbours timeToMin,
/// minToHM, sessionsOf, courseOnDate and termOf are injected as sockets (Law 1/3).
List<Map<String, dynamic>> buildSlots(
  Map<String, dynamic> db,
  Map<String, dynamic> room,
  String iso,
  dynamic blocked,
  Map<String, dynamic> config,
  num Function(dynamic t) timeToMin,
  String Function(dynamic min) minToHM,
  List<dynamic> Function(dynamic c) sessionsOf,
  bool Function(dynamic c, dynamic iso) courseOnDate,
  String Function(dynamic cfg, dynamic key, dynamic fb) termOf, [
  bool cleaningOn = true,
]) {
  final num from = timeToMin(room['from']).isNaN ? 8 * 60 : timeToMin(room['from']);
  final num to = timeToMin(room['to']).isNaN ? 20 * 60 : timeToMin(room['to']);
  final slotV = room['slot'];
  final num step = (slotV is num && slotV > 0) ? slotV : 60;
  final int wd = DateTime.parse(iso + 'T12:00:00').weekday % 7;
  final slots = <Map<String, dynamic>>[];
  final covered = <Map<String, dynamic>>[];
  final dayCourses = (db['courses'] as List)
      .where((c) => (c as Map)['roomId'] == room['id'] && courseOnDate(c, iso))
      .toList();
  for (num t = from, guard = 0; t < to && guard < 96; t += step, guard++) {
    final hh = minToHM(t);
    // ניקיון יומי 15:00–16:00 — קבוע בכל החדרים (כמו במקור); מגודר cleaningOn
    if (cleaningOn && t >= 900 && t < 960) {
      slots.add({
        'key': 'clean' + hh,
        'time': hh,
        'kind': 'cleaning',
        'label': 'ניקיון יומי (15:00–16:00)',
        'bg': '#eceae2',
        'c': '#4d463c',
      });
      continue;
    }
    var occupied = false;
    for (final c in dayCourses) {
      final ss = sessionsOf(c);
      for (var i = 0; i < ss.length; i++) {
        final sess = ss[i] as Map;
        final tm = timeToMin(_or(sess['time'], ''));
        if (sess['day'] == wd && !tm.isNaN && tm >= t && tm < t + step) {
          occupied = true;
          covered.add({'c': c, 'i': i});
          slots.add({
            'key': 'crs|' + hh + '|' + (c as Map)['id'].toString() + '|' + i.toString(),
            'time': _or(sess['time'], hh),
            'kind': 'course',
            'label': termOf(config, 'entity.course', 'חוג') + ': ' + (c)['name'].toString(),
            'bg': '#fdf1d4',
            'c': '#9a6414',
            'course': c,
            'session': sess,
            'sessionIndex': i,
          });
        }
      }
    }
    if (occupied) continue;
    Map? oe;
    for (final ev in (db['events'] as List)) {
      final evm = ev as Map;
      if (_truthy(evm['done']) || evm['roomId'] != room['id'] || evm['date'] != iso) {
        continue;
      }
      final tm = timeToMin(_or(evm['time'], ''));
      if (!tm.isNaN && tm >= t && tm < t + step) {
        oe = evm;
        break;
      }
    }
    if (oe != null) {
      slots.add({
        'key': 'ev|' + hh + '|' + oe['id'].toString(),
        'time': _or(oe['time'], hh),
        'kind': 'event',
        'label': 'אירוע: ' + oe['title'].toString(),
        'bg': '#e7edf5',
        'c': '#3a5a86',
        'event': oe,
      });
    } else if (_truthy(blocked)) {
      slots.add({
        'key': 'blk' + hh,
        'time': hh,
        'kind': 'blocked',
        'label': 'חסום — ' + blocked.toString(),
        'bg': '#fdeaea',
        'c': '#b91c1c',
      });
    } else {
      slots.add({
        'key': 'free' + hh,
        'time': hh,
        'kind': 'free',
        'label': 'פנוי',
        'bg': '#e4f5ea',
        'c': '#12803c',
      });
    }
  }
  // מפגשים של היום שנופלים מחוץ לשעות הפעילות של החדר — עדיין מוצגים לרישום נוכחות
  for (final c in dayCourses) {
    final ss = sessionsOf(c);
    for (var i = 0; i < ss.length; i++) {
      final sess = ss[i] as Map;
      if (sess['day'] != wd) continue;
      if (covered.any((x) => (x['c'] as Map)['id'] == (c as Map)['id'] && x['i'] == i)) {
        continue;
      }
      slots.add({
        'key': 'out|' + (c as Map)['id'].toString() + '|' + i.toString(),
        'time': _or(sess['time'], '—'),
        'kind': 'course',
        'label': termOf(config, 'entity.course', 'חוג') +
            ': ' +
            (c)['name'].toString() +
            ' · מחוץ לשעות הפעילות של החדר',
        'bg': '#fdf1d4',
        'c': '#9a6414',
        'course': c,
        'session': sess,
        'sessionIndex': i,
        'outOfHours': true,
      });
    }
  }
  return slots;
}
