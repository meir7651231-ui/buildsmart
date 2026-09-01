// ⚛️ אטום-Dart (דרגת-חוזה) · upcomingMeetings — פגישות-קרובות פתוחות בטווח ימים.
// מוצא: maor/src/components/shop/lib.ts:406-426 · המקור: new/atoms/upcoming-meetings.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: אירועי kind='meeting' פתוחים (done כוזב) בטווח [todayIso, todayIso+days-1],
//        ממוינים תאריך+שעה עולה — בלי-שעה ממוין לסוף-היום (מפתח '99:99').
//        לכל פגישה: {'ev','who','roomName'}. who: שיבוץ נמצא ⇒ שקע-beneficiaryLabel,
//        אחרת ev.title. roomName: roomId אמת ⇒ שם-החדר (חדר-לא-קיים ⇒ ''), אחרת ''.
// שקעים (חוק-1): isoOf(DateTime)⇒'YYYY-MM-DD' מקומי · beneficiaryLabel(db,a,config)⇒שם-המוטב.
//
// הערות-המרה (מקור→Dart):
//  · new Date(iso+'T12:00:00') + setDate(getDate()+days-1) המוטבילי ⇒ בנאי
//    DateTime(y,m,day+…,12) — יום-גולש מגלגל חודש/שנה בדיוק כמו V8 (חוק-3);
//    days-1 עובר truncate-לכיוון-אפס (ToInteger של setDate).
//  · truthiness של JS (חוק-7): !e.done · (time || '99:99') · ev.roomId ? … ⇒ _falsy
//    מפורש (null/false/0/-0/NaN/'' כוזבים).
//  · x.id === ev.assignmentId (===) ⇒ _keyEq מודע-מפתח-חסר (חוק-2): undefined===undefined
//    אמת, undefined===null שקר — containsKey, לא ==null.
//  · Array.find ⇒ לולאה שמחזירה null בהיעדר (firstWhere של Dart זורק — לא שקול).
//  · sort של V8 יציב ⇒ decorate-sort-undecorate עם אינדקס שובר-שוויון (חוק-1);
//    localeCompare על מפתחות ASCII-ספרתיים ('YYYY-MM-DD·HH:MM') ≡ compareTo.
//  · e.date >= todayIso (השוואת-מחרוזות רלציונית) ⇒ compareTo; date שאינו String
//    (undefined) ⇒ false ב-JS (NaN-השוואה) ⇒ מגודר is String.
//  · ?.name ?? '' ⇒ null-מפורש; חוזר Object? כי ev.title שרירותי.

/// כוזב-JS (חוק-7): null/false/0/-0/NaN/'' — כל השאר אמת ('0'/[]/{} אמת).
bool _falsy(Object? v) =>
    v == null || v == false || v == 0 || v == '' || (v is double && v.isNaN);

/// ‏a[ka] === b[kb] של JS, מודע-מפתח-חסר (חוק-2): חסר≡undefined; ‏undefined===undefined
/// אמת, ‏undefined מול כל-ערך (כולל null) שקר; שניהם-קיימים ⇒ == (בלי קוארציה, כמו ===).
bool _keyEq(Map a, String ka, Map b, String kb) {
  final hasA = a.containsKey(ka);
  final hasB = b.containsKey(kb);
  if (hasA != hasB) return false;
  if (!hasA) return true;
  return a[ka] == b[kb];
}

/// Upcoming open meetings in [todayIso, todayIso+days-1], sorted by date+time
/// (no time ⇒ end of day, key '99:99'). Verbatim behaviour of the JS source
/// `upcomingMeetings`; `isoOf`/`beneficiaryLabel` are injected sockets (rule 1).
/// Returns a List of {'ev': event, 'who': Object?, 'roomName': String}.
List<Map<String, Object?>> upcomingMeetings(
  Map<String, Object?> db,
  String todayIso, [
  num days = 2,
  Map<String, Object?>? config,
  String Function(DateTime d)? isoOf,
  Object? Function(Map<String, Object?> db, Map<String, Object?> a,
          Map<String, Object?>? config)?
      beneficiaryLabel,
]) {
  final start = DateTime.parse(todayIso + 'T12:00:00');
  // setDate(getDate() + days - 1) — גלגול-יום דרך הבנאי (חוק-3); truncate כ-ToInteger.
  final end =
      DateTime(start.year, start.month, (start.day + days - 1).toInt(), 12);
  final endIso = isoOf!(end);
  final events = (db['shopEvents'] as List).cast<Map<String, Object?>>();
  final picked = events.where((e) {
    final d = e['date'];
    return e['kind'] == 'meeting' &&
        _falsy(e['done']) &&
        d is String &&
        d.compareTo(todayIso) >= 0 &&
        d.compareTo(endIso) <= 0;
  }).toList();
  // decorate-sort-undecorate (חוק-1) — sort של Dart אינו מובטח-יציב.
  final dec = <List<Object?>>[];
  for (var i = 0; i < picked.length; i++) {
    final e = picked[i];
    final t = _falsy(e['time']) ? '99:99' : e['time'];
    dec.add(['${e['date']}·$t', i, e]);
  }
  dec.sort((x, y) {
    final c = (x[0] as String).compareTo(y[0] as String);
    return c != 0 ? c : (x[1] as int) - (y[1] as int);
  });
  return dec.map((row) {
    final ev = row[2] as Map<String, Object?>;
    // Array.find — null בהיעדר; === מודע-מפתח-חסר.
    Map<String, Object?>? a;
    for (final x in (db['shopAssignments'] as List)) {
      final xm = x as Map<String, Object?>;
      if (_keyEq(xm, 'id', ev, 'assignmentId')) {
        a = xm;
        break;
      }
    }
    String roomName = '';
    if (!_falsy(ev['roomId'])) {
      final rid = ev['roomId'];
      Map<String, Object?>? room;
      for (final r in (db['rooms'] as List)) {
        final rm = r as Map<String, Object?>;
        if (rm['id'] == rid) {
          // rid אמת (לא-undefined) ⇒ == שקול ל-===
          room = rm;
          break;
        }
      }
      roomName = (room == null ? '' : (room['name'] ?? '')) as String;
    }
    return <String, Object?>{
      'ev': ev,
      'who': a != null ? beneficiaryLabel!(db, a, config) : ev['title'],
      'roomName': roomName,
    };
  }).toList();
}
