// ⚛️ אטום-Dart (דרגת-חוזה) · buildCourseDailyRows — דו"ח נוכחות יומי מפורט לחוג.
// מוצא: maor/src/lib/courseDaily.ts:23-92 · המקור: new/atoms/build-course-daily-rows.mjs
// טוהר: פונקציית top-level עצמאית, אפס import (רק dart-core). חוק-4 — התנהגות זהה-ביט למקור-ה-JS.
//
// תפקיד: סורק יום-יום בין start ל-end; יום נספר רק כשיש בו מפגש (sessions לפי
//        day===getDay). לכל מפגש: שורה לכל תלמידה-פעילה (או 'אין רשומות').
//        תקרת-בטיחות MAX_DAYS=500 ⇒ קטיעה + שורת-אזהרה. start/end חסר ⇒ days:0.
// שקעים (חוק-1): termOf(config,key,fb)⇒String (נקרא רק כש-config קיים) ·
//        hebDateFull(iso)⇒String. העוזרים DAY_NAMES/isoOf/fmtD נשארו פנימיים.
// קלט: c (חוג) · db{families,enrollments} · config? · שני השקעים.
// פלט: {'rows': List<List<String>>, 'days': int}.
//
// הערות-המרה (מקור→Dart) — מה שהמנוע פספס:
//  · אובייקטי-JS ⇒ Map<String,Object?>; גישת-שדה .x ⇒ ['x'].
//  · getMonth()+1 (0-אינדקס) ⇒ month (1-אינדקס של Dart); getDay() ⇒ weekday % 7.
//  · new Date(iso+'T12:00:00') ⇒ DateTime.parse; איטרציה חסינת-DST דרך
//    DateTime(y,m,d+1,12) במקום setDate המוטבילי; `d <= end` ⇒ `!d.isAfter(end)`.
//  · truthiness של JS (`!c.start` / `abs` / `ss.label` / `x || ''`) ⇒ null-או-'' מפורש.
//  · padStart(2,'0') ⇒ padLeft(2,'0'); String.split; compareTo להשוואת-iso לקסיקוגרפית.

const List<String> _dayNames = ['ראשון', 'שני', 'שלישי', 'רביעי', 'חמישי', 'שישי', 'שבת'];

String _isoOf(DateTime d) {
  String p2(int n) => n.toString().padLeft(2, '0');
  return '${d.year}-${p2(d.month)}-${p2(d.day)}';
}

String _fmtD(String iso) {
  final parts = iso.split('-');
  final y = parts[0];
  final m = parts[1];
  final d = parts[2];
  return '$d/$m/$y';
}

/// Builds the detailed daily attendance report for a course. Verbatim behaviour
/// of the JS source `buildCourseDailyRows`. `termOf`/`hebDateFull` are injected
/// sockets. Returns {'rows': List<List<String>>, 'days': int}.
Map<String, Object?> buildCourseDailyRows(
  Map<String, Object?> c,
  Map<String, Object?> db,
  Map<String, Object?>? config,
  String Function(Map<String, Object?> config, String key, String fb) termOf,
  String Function(String iso) hebDateFull,
) {
  String T(String k, String fb) => config != null ? termOf(config, k, fb) : fb;
  final rows = <List<String>>[
    ['תאריך עברי', 'תאריך לועזי', 'יום', 'קבוצה/שעה', 'סטטוס יום', 'תלמידה פעילה', T('entity.family', 'משפחה'), 'סטטוס נוכחות'],
  ];
  final cStart = c['start'];
  final cEnd = c['end'];
  if (cStart == null || cStart == '' || cEnd == null || cEnd == '') {
    return {'rows': rows, 'days': 0};
  }
  // אינדקס בן-משפחה → שם פרטי + שם משפחה
  final memberFam = <String, Map<String, String>>{};
  for (final f in (db['families'] as List)) {
    final fam = f as Map<String, Object?>;
    for (final m in (fam['members'] as List)) {
      final mem = m as Map<String, Object?>;
      memberFam[mem['id'] as String] = {
        'first': (mem['first'] ?? '') as String,
        'famName': (fam['name'] ?? '') as String,
      };
    }
  }
  final enrolls = (db['enrollments'] as List)
      .cast<Map<String, Object?>>()
      .where((e) => e['courseId'] == c['id'])
      .toList();
  final rawSessions = c['sessions'];
  final sessions = (rawSessions is List && rawSessions.isNotEmpty)
      ? rawSessions.cast<Map<String, Object?>>()
      : <Map<String, Object?>>[
          {'day': c['weekday'], 'time': c['time'], 'label': ''}
        ];
  final start = DateTime.parse('$cStart' 'T12:00:00');
  final end = DateTime.parse('$cEnd' 'T12:00:00');
  // תקרת בטיחות: קורס לגיטימי הוא שנתי/דו-שנתי (עד ~100 ימי מפגש). טווח ענק
  // (טעות הקלדה בשנת הסיום) היה מייצר עשרות אלפי שורות — עוצרים ומסמנים קטיעה.
  const MAX_DAYS = 500;
  var days = 0;
  var truncated = false;
  for (var d = start; !d.isAfter(end); d = DateTime(d.year, d.month, d.day + 1, 12, 0, 0)) {
    final iso = _isoOf(d);
    final dow = d.weekday % 7;
    final sess = sessions.where((ss) => ss['day'] == dow).toList();
    if (sess.isEmpty) continue;
    if (days >= MAX_DAYS) {
      truncated = true;
      break;
    }
    days++;
    for (final ss in sess) {
      final ssLabel = ss['label'];
      final ssTime = ss['time'];
      final slot = ((ssLabel == null || ssLabel == '') ? 'קבוצה' : ssLabel as String) + ' · ' + ((ssTime ?? '') as String);
      // תלמידה "פעילה" במפגש — שובצה עד היום ושייכת לקבוצת המפגש. שיבוץ שהסתיים
      // (#8) עדיין כלול במפגשים שקדמו לתאריך-הסיום שלו; בלי endedAt נשאר מוחרג.
      final active = enrolls.where((e) {
        final status = e['status'];
        if (status == 'wait') return false; // רשימת-המתנה לא בדוח-הנוכחות
        final ea = e['enrolledAt'];
        final enrolledOk = ea == null || ea == '' || (ea as String).compareTo(iso) <= 0;
        if (!enrolledOk) return false;
        final grp = e['group'];
        final groupOk = (ssLabel == null || ssLabel == '') || (grp == null || grp == '') || grp == ssLabel;
        if (!groupOk) return false;
        if (status == 'ended') {
          final endedAt = e['endedAt'];
          final endedOk = (endedAt != null && endedAt != '') && iso.compareTo(endedAt as String) < 0;
          if (!endedOk) return false;
        }
        return true;
      }).toList();
      if (active.isEmpty) {
        rows.add([hebDateFull(iso), _fmtD(iso), _dayNames[dow], slot, 'אין רשומות', '', '', '']);
        continue;
      }
      for (final e in active) {
        final mf = memberFam[e['memberId']];
        final absences = (e['absences'] as List).cast<Map<String, Object?>>();
        Map<String, Object?>? abs;
        for (final a in absences) {
          if (a['date'] == iso) {
            abs = a;
            break;
          }
        }
        final status = e['status'];
        final dayStatus = status == 'paused' ? 'מוקפא' : 'מתקיים';
        String attend;
        if (status == 'paused') {
          attend = 'מוקפא';
        } else if (abs != null) {
          final noshow = abs['noshow'];
          if (noshow == true) {
            attend = 'לא הופיעה';
          } else {
            final reason = abs['reason'];
            attend = 'חיסור' + ((reason != null && reason != '') ? ' · ' + (reason as String) : '');
          }
        } else {
          attend = 'פעיל';
        }
        rows.add([
          hebDateFull(iso),
          _fmtD(iso),
          _dayNames[dow],
          slot,
          dayStatus,
          (mf?['first'] ?? '') as String,
          (mf?['famName'] ?? '') as String,
          attend,
        ]);
      }
    }
  }
  if (truncated) {
    rows.add(['—', '—', '—', '—', 'הדוח נקטע ב-$MAX_DAYS ימי מפגש — בדקו את תאריך הסיום של ה${T('entity.course', 'חוג')}', '', '', '']);
  }
  return {'rows': rows, 'days': days};
}
