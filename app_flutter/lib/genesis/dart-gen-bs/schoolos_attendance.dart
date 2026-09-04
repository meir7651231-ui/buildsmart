// 🏫 SchoolOS · מודול נוכחות (ATTENDANCE) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד).
// מפרט (SSOT): knowledge/SPEC-ATTENDANCE-FULL-2026-09-04.md · הסטנדרט: schoolos.dart (מלאי).
// מטרה: "לדעת מי נוכח ומי לא — עכשיו, היום, החודש — ולפעול לפני שהיעדרות הופכת לנשירה."
// מודל הפוך: רושמים רק חיסורים (ברירת-מחדל נוכח) · אידמפוטנטי (מפתח date|lesson|student).
// פעולות-יסוד (צעד 2): איתור · רישום · הערכת-מצב · זיהוי-חריגה · הכרעה · ביצוע · אימות.
// כל חלקיק-תובנה = הרכבה של כמה אטומים (תצוגה⊕לוגיקה); עובדה (תווית+ערך) = אטום-יחיד.
// אין Date.now במנוע — today/now מוזרקים (חוק-6/VERIFY). זהות (מיילים/טלפונים) = בלוק-הצבה.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/bare_stat.dart'; // עובדה-KPI חשופה (ערך+תווית, פיגמנט מוזרק)
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // ההירו = המטרה (דורשי-פעולה)
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-כיתה מבוקר
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/dataviz/progress_ring.dart'; // יחס נוכחות-חודשי (0..1) — תובנת-יחס
import '../dart-maor/presents-in-month.dart'; // מנוע-מדף: ספירת-נוכחויות בחודש (presents ISO)
import '../dart-maor/sheet-summary.dart'; // מנוע-מדף: {present,total} לתאריך על roster
import '../dart-maor/sheet-roster.dart'; // מנוע-מדף: roster פר-חוג (active בלבד)
import '../dart-maor/pending-makeups.dart'; // מנוע-מדף: השלמות-ממתינות (לא-מתוזמנות קודם)
import '../dart-maor/enroll-summary.dart'; // מנוע-מדף: {presents,absences,noshow,...} פר-שיבוץ
import '../dart-maor/intel-day-diff.dart'; // מנוע-מדף: הפרש-ימים בין ISO (רצף/חלון-מורה)
import '../dart-maor/intel-trend-from-scan.dart'; // מנוע-מדף: מגמה מרשימה-חודשית {dir,pct}
import '../dart-maor/fmt-date.dart'; // מנוע-מדף: ISO ⇒ dd/mm/yyyy
import '../dart-maor/month-key.dart'; // מנוע-מדף: ISO ⇒ YYYY-MM
import '../dart-maor/week-day-names.dart'; // דאטה-מדף: שמות-ימים (ראשון..שבת)
import '../dart-maor/time-to-min.dart'; // מנוע-מדף: 'HH:MM' ⇒ דקות (איחור · שיעור-נוכחי)
import '../dart-maor/holiday-of.dart'; // מנוע-מדף: שם-חג לתאריך (לוח-עברי)
import '../dart-maor/holidays.dart'; // דאטה-מדף: HOLIDAYS מפת-חגים
import '../dart-maor/heb-parts.dart'; // מנוע-מדף: תאריך ⇒ {day,month(En),year} עברי
import '../dart-data-maor/holiday-of-terms.dart' as hol_t; // מונחי-חגים-נדחים (דאטה)
import '../dart-data-maor/absence-reason-chips-terms.dart' as reason_t; // סיבות-מובנות (דאטה)
import '../dart-maor/absence-reason-chips.dart'; // מנוע-מדף: רשימת-סיבות-מובנות דרך term

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (חוק-6: צבע=הצבה)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════ בלוק-הצבה (חוק-6): זהויות/קשרים מוזרקים — לא אטום, לא דאטה-דומיין ═══════════
class _Placement {
  static const today = '2026-09-04'; // תאריך-הזרקה דטרמיניסטי (VERIFY: אין Date.now במנוע)
  static const nowHm = '10:20'; // שעה-מוזרקת (שיעור-נוכחי · תזכורת · נעילה-אוטו)
  static const lateWindowMin = 10; // חלון-איחור (דקות) — מוגדר-מוסד
  static const minAttendancePct = 80; // סף-רגולטורי (זכאות/תעודה)
  static const streakAlert = 3; // התרעת-רצף: N חיסורים רצופים
  // קשרי-הורים (הצבה): studentId ⇒ {name, phone}. חסר ⇒ המקום-השמור שקט.
  static const parents = <String, Map<String, String>>{
    's1': {'name': 'דנה שמעוני', 'phone': '050-555-0101'},
    's2': {'name': 'יוסי אוחיון', 'phone': '052-555-0102'},
    's3': {'name': 'מיכל נחום', 'phone': '054-555-0103'},
    's4': {'name': 'אורית ביטון', 'phone': '050-555-0104'},
    's5': {'name': 'רות לוי', 'phone': '053-555-0105'},
    's6': {'name': 'עמית כהן', 'phone': '058-555-0106'},
    's8': {'name': 'שרון מזרחי', 'phone': '050-555-0108'},
  };
}

// ═══════════ המנוע הטהור: דאטה-אמת + נגזרות (אפס-DOM) ═══════════
// 🔴 סכמת-אמת (§20-ג): שיבוץ-מאור {id, memberId, courseId, status, presents:[ISO], absences:[{date, reason,
//   makeup, makeupDate, noshow}]} (pending-makeups.contract.md · enroll-summary.contract.md) — הבסיס.
//   הרחבת-חיסור (מקור: AttendanceDay/AttendanceEntry של בנייה-חכמה — timeIn/timeOut): lesson · status
//   (absent|late|released) · arrival 'HH:MM' · justified · parentOk · by · at.
//   ⛔ ללא-מקור ⇒ מקום-שמור בלבד: תמונה · אישור-רפואי-קובץ · נוכחות-מקוונת · הסעה · ביומטרי · GPS · ציון-חיצוני.
class _AttData {
  // כיתות (courseId) + מערכת-שיעורים פר-יום-בשבוע (0=ראשון) — מקור "איזה-שיעור-עכשיו" (מודול-חוגים)
  static const classes = <Map<String, dynamic>>[
    {'id': 'y1', 'name': 'י׳-1', 'teacher': 't1'},
    {'id': 'y2', 'name': 'י׳-2', 'teacher': 't2'},
    {'id': 'h2', 'name': 'ח׳-2', 'teacher': 't3'},
  ];
  // שיעור = {n, time, subject, teacher}. שבת=אין. שישי=4 שיעורים.
  static const lessonsByDow = <int, List<Map<String, dynamic>>>{
    0: [{'n': 1, 'time': '08:00', 'subject': 'מתמטיקה'}, {'n': 2, 'time': '08:50', 'subject': 'לשון'}, {'n': 3, 'time': '09:50', 'subject': 'אנגלית'}, {'n': 4, 'time': '10:40', 'subject': 'היסטוריה'}, {'n': 5, 'time': '11:40', 'subject': 'מדעים'}],
    1: [{'n': 1, 'time': '08:00', 'subject': 'לשון'}, {'n': 2, 'time': '08:50', 'subject': 'מתמטיקה'}, {'n': 3, 'time': '09:50', 'subject': 'ספורט'}, {'n': 4, 'time': '10:40', 'subject': 'אנגלית'}, {'n': 5, 'time': '11:40', 'subject': 'תנ״ך'}],
    2: [{'n': 1, 'time': '08:00', 'subject': 'מדעים'}, {'n': 2, 'time': '08:50', 'subject': 'מתמטיקה'}, {'n': 3, 'time': '09:50', 'subject': 'לשון'}, {'n': 4, 'time': '10:40', 'subject': 'אזרחות'}, {'n': 5, 'time': '11:40', 'subject': 'אנגלית'}],
    3: [{'n': 1, 'time': '08:00', 'subject': 'אנגלית'}, {'n': 2, 'time': '08:50', 'subject': 'היסטוריה'}, {'n': 3, 'time': '09:50', 'subject': 'מתמטיקה'}, {'n': 4, 'time': '10:40', 'subject': 'מדעים'}, {'n': 5, 'time': '11:40', 'subject': 'לשון'}],
    4: [{'n': 1, 'time': '08:00', 'subject': 'מתמטיקה'}, {'n': 2, 'time': '08:50', 'subject': 'תנ״ך'}, {'n': 3, 'time': '09:50', 'subject': 'אנגלית'}, {'n': 4, 'time': '10:40', 'subject': 'ספורט'}, {'n': 5, 'time': '11:40', 'subject': 'לשון'}],
    5: [{'n': 1, 'time': '08:00', 'subject': 'מתמטיקה'}, {'n': 2, 'time': '08:50', 'subject': 'לשון'}, {'n': 3, 'time': '09:50', 'subject': 'אנגלית'}, {'n': 4, 'time': '10:40', 'subject': 'חינוך'}],
    6: [],
  };
  // תלמידים (members): id · name · cls · num · active. תמונה (photo) = מקום-שמור.
  static const students = <Map<String, dynamic>>[
    {'id': 's1', 'name': 'רון שמעוני', 'cls': 'y1', 'num': 1},
    {'id': 's2', 'name': 'ליאור אוחיון', 'cls': 'y1', 'num': 2},
    {'id': 's3', 'name': 'הדר נחום', 'cls': 'y1', 'num': 3},
    {'id': 's4', 'name': 'מאיה ביטון', 'cls': 'y1', 'num': 4},
    {'id': 's5', 'name': 'נועה לוי', 'cls': 'y1', 'num': 5},
    {'id': 's6', 'name': 'עידו כהן', 'cls': 'y1', 'num': 6},
    {'id': 's7', 'name': 'שירה פרץ', 'cls': 'y1', 'num': 7, 'active': false}, // תלמיד-לא-פעיל (מצב-מיוחד)
    {'id': 's8', 'name': 'טל מזרחי', 'cls': 'y2', 'num': 1},
    {'id': 's9', 'name': 'יובל דהן', 'cls': 'y2', 'num': 2},
    {'id': 's10', 'name': 'אלה ברק', 'cls': 'y2', 'num': 3},
    {'id': 's11', 'name': 'נדב חדד', 'cls': 'h2', 'num': 1},
    {'id': 's12', 'name': 'רוני גל', 'cls': 'h2', 'num': 2},
  ];
  // ─── יומן-חיסורים בסיסי (const · מקור-האמת ההיסטורי · מודל-הפוך: רק מי-שלא-נכח) ───
  //   date · lesson · sid · status(absent|late|released) · reason · justified · makeup · makeupDate ·
  //   arrival('HH:MM' — מקור: AttendanceEntry.timeIn) · parentOk · by(מי-רשם) · at(מתי, אודיט)
  static const baseMarks = <Map<String, dynamic>>[
    // רון — דפוס: יום-קבוע (ראשון) + רצף אחרון ⇒ בסיכון
    {'date': '2026-08-16', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-08-16T08:07'},
    {'date': '2026-08-23', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-08-23T08:05'},
    {'date': '2026-08-30', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-08-30T08:06'},
    {'date': '2026-09-01', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-01T08:04'},
    {'date': '2026-09-02', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-02T08:09'},
    {'date': '2026-09-03', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-03T08:03'},
    // ליאור — מאחר כרוני (שיעור-קבוע 1) + חיסור מוצדק עם השלמה-מתוזמנת
    {'date': '2026-08-24', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:18', 'by': 't1', 'at': '2026-08-24T08:18'},
    {'date': '2026-08-26', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:22', 'by': 't1', 'at': '2026-08-26T08:22'},
    {'date': '2026-08-31', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:15', 'by': 't1', 'at': '2026-08-31T08:15'},
    {'date': '2026-09-02', 'lesson': 3, 'sid': 's2', 'status': 'absent', 'reason': 'חולה', 'justified': true, 'makeup': true, 'makeupDate': '2026-09-08', 'parentOk': true, 'by': 't1', 'at': '2026-09-02T09:55'},
    // הדר — טיול משפחתי מוצדק, השלמה לא-מתוזמנת
    {'date': '2026-08-27', 'lesson': 2, 'sid': 's3', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'makeup': true, 'parentOk': true, 'by': 't1', 'at': '2026-08-27T08:52'},
    {'date': '2026-08-27', 'lesson': 3, 'sid': 's3', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'parentOk': true, 'by': 't1', 'at': '2026-08-27T09:52'},
    // מאיה — שחרור-מאושר (יציאה-מוקדמת)
    {'date': '2026-09-01', 'lesson': 5, 'sid': 's4', 'status': 'released', 'reason': 'רפואי', 'justified': true, 'parentOk': true, 'by': 't1', 'at': '2026-09-01T11:30'},
    // עידו — חיסורים לא-מוצדקים ללא-אישור-הורה (החודש) ⇒ הודעה-אוטו
    {'date': '2026-09-01', 'lesson': 2, 'sid': 's6', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-01T08:55'},
    {'date': '2026-09-03', 'lesson': 4, 'sid': 's6', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-03T10:44'},
    // י׳-2 · טל — אבל (מוצדק), יובל — איחור-הסעה
    {'date': '2026-09-02', 'lesson': 1, 'sid': 's8', 'status': 'absent', 'reason': 'אבל', 'justified': true, 'parentOk': true, 'by': 't2', 'at': '2026-09-02T08:03'},
    {'date': '2026-09-03', 'lesson': 1, 'sid': 's9', 'status': 'late', 'arrival': '08:12', 'by': 't2', 'at': '2026-09-03T08:12'},
    // היום (מוזרק): י׳-1 שיעור 1 נרשם — רון חסר (רצף 4!), ליאור מאחר; י׳-2 וח׳-2 טרם נרשמו
    {'date': '2026-09-04', 'lesson': 1, 'sid': 's1', 'status': 'absent', 'reason': 'אחר', 'justified': false, 'by': 't1', 'at': '2026-09-04T08:06'},
    {'date': '2026-09-04', 'lesson': 1, 'sid': 's2', 'status': 'late', 'arrival': '08:14', 'by': 't1', 'at': '2026-09-04T08:14'},
  ];
  // כיתה-שיעור-יום שאושר "כולם-נוכחים" (מודל-הפוך: רישום-ריק חייב אישור מפורש כדי להיחשב "נרשם")
  static const baseRecorded = <String>{'2026-09-04|y1|1', '2026-09-03|y1|1', '2026-09-03|y1|2', '2026-09-03|y1|3', '2026-09-03|y1|4', '2026-09-03|y2|1'};

  // ─── פנקס-הפעולות (state): סימונים מעל הבסיס — אידמפוטנטי (מפתח date|lesson|sid) ───
  static final Map<String, Map<String, dynamic>> _overrides = {};
  static final Set<String> _recorded = {...baseRecorded};
  static String keyOf(String date, int lesson, String sid) => '$date|$lesson|$sid';
  static bool isRecorded(String date, String cls, int lesson) => _recorded.contains('$date|$cls|$lesson');
  static void record(String date, String cls, int lesson) => _recorded.add('$date|$cls|$lesson');

  // כל הסימונים האפקטיביים: בסיס + דריסות (דריסה עם status='present' = ביטול ⇒ נעלם מהמודל-ההפוך)
  static List<Map<String, dynamic>> get marks {
    final m = <String, Map<String, dynamic>>{};
    for (final b in baseMarks) {
      m[keyOf(b['date'] as String, b['lesson'] as int, b['sid'] as String)] = b;
    }
    for (final e in _overrides.entries) {
      m[e.key] = e.value;
    }
    return [for (final v in m.values) if (v['status'] != 'present') v];
  }
  static Map<String, dynamic>? markOf(String date, int lesson, String sid) {
    final k = keyOf(date, lesson, sid);
    final v = _overrides[k] ?? _baseIndex[k];
    return v == null || v['status'] == 'present' ? null : v;
  }
  static final Map<String, Map<String, dynamic>> _baseIndex = {
    for (final b in baseMarks) keyOf(b['date'] as String, b['lesson'] as int, b['sid'] as String): b,
  };

  // ─── תלמידים/כיתות (עובדות) ───
  static bool activeOf(Map<String, dynamic> s) => (s['active'] as bool?) ?? true;
  static List<Map<String, dynamic>> studentsOf(String cls) => students.where((s) => s['cls'] == cls && activeOf(s)).toList();
  static Map<String, dynamic> studentById(String sid) => students.firstWhere((s) => s['id'] == sid);
  static String className(String cls) => classes.firstWhere((c) => c['id'] == cls)['name'] as String;
  static int dow(String iso) => DateTime.parse('${iso}T12:00:00').weekday % 7; // 0=ראשון
  static List<Map<String, dynamic>> lessonsOf(String iso) => lessonsByDow[dow(iso)] ?? const [];
  static String iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String shift(String isoDate, int days) {
    final d = DateTime.parse('${isoDate}T12:00:00');
    return iso(DateTime(d.year, d.month, d.day + days));
  }

  // ─── לוח/חופשים (מודול-יומן): holidayOf ⊕ hebParts ⊕ HOLIDAYS — חג ⇒ לא-נספר אוטומטית ───
  //   scanHebYear (שקע): קבוצת-החודשים-בני-30 סביב התאריך — נגזר מ-hebParts (יום==30), לא מנוחש.
  static Map<String, dynamic> _scanHebYear(DateTime near) {
    final has30 = <String>{};
    for (var i = -70; i <= 70; i++) {
      final p = hebParts(DateTime(near.year, near.month, near.day + i));
      if (p['day'] == 30) has30.add(p['month'] as String);
    }
    return {'has30': has30};
  }
  static String? holidayName(String isoDate) {
    final d = DateTime.parse('${isoDate}T12:00:00');
    return holidayOf(d, (x) => hebParts(x), (_) => _scanHebYear(d), HOLIDAYS, term: (k) => hol_t.kTerms[k] ?? k);
  }
  // יום-לימודים = יש שיעורים בשבוע-הלימודים וגם אין-חג (נספר בנוכחות%; חג/שבת ⇒ לא-נספר)
  static bool isSchoolDay(String isoDate) => lessonsOf(isoDate).isNotEmpty && holidayName(isoDate) == null;
  static List<String> schoolDaysInMonth(String anyIso, {String? upTo}) {
    final mk = monthKey(anyIso);
    final first = DateTime.parse('$mk-01T12:00:00');
    final out = <String>[];
    for (var i = 0; i < 31; i++) {
      final d = DateTime(first.year, first.month, first.day + i);
      if (d.month != first.month) break;
      final s = iso(d);
      if (upTo != null && s.compareTo(upTo) > 0) break;
      if (isSchoolDay(s)) out.add(s);
    }
    return out;
  }
  // 30 ימי-לימודים אחרונים (עד today כולל) — חלון-הדפוס
  static List<String> lastSchoolDays(int n) {
    final out = <String>[];
    var d = _Placement.today;
    for (var i = 0; i < 90 && out.length < n; i++) {
      if (isSchoolDay(d)) out.add(d);
      d = shift(d, -1);
    }
    return out.reversed.toList();
  }

  // ─── סטטוס-יומי פר-תלמיד (הכרעה מאוחדת על כל שיעורי-היום): absent > late > released > present ───
  static List<Map<String, dynamic>> marksOn(String date, String sid) => marks.where((m) => m['date'] == date && m['sid'] == sid).toList();
  static String dayStatus(String date, String sid) {
    final ms = marksOn(date, sid);
    if (ms.any((m) => m['status'] == 'absent')) return 'absent';
    if (ms.any((m) => m['status'] == 'late')) return 'late';
    if (ms.any((m) => m['status'] == 'released')) return 'released';
    return 'present';
  }
  static bool absentDay(String date, String sid) => marksOn(date, sid).any((m) => m['status'] == 'absent');
  // שעת-הגעה (מקור: arrival) · דקות-איחור = arrival − תחילת-השיעור (timeToMin מהמדף) − חלון-מוסד
  static String? arrivalOf(String date, String sid) {
    for (final m in marksOn(date, sid)) {
      if (m['arrival'] != null) return m['arrival'] as String;
    }
    return null;
  }
  static int lateMinutes(Map<String, dynamic> m) {
    final arr = m['arrival'];
    if (arr == null) return 0;
    final lesson = lessonsOf(m['date'] as String).firstWhere((l) => l['n'] == m['lesson'], orElse: () => const {'time': '08:00'});
    final a = timeToMin(arr), s = timeToMin(lesson['time']);
    if (a is! num || s is! num || a.isNaN || s.isNaN) return 0;
    final d = (a - s).toInt();
    return d < 0 ? 0 : d;
  }
  static bool isLate(Map<String, dynamic> m) => m['status'] == 'late' && lateMinutes(m) > _Placement.lateWindowMin;
  static bool unjustified(Map<String, dynamic> m) => m['status'] == 'absent' && m['justified'] != true;

  // ─── מיפוי לצורת-מאור (enrollment) ⇒ מנועי-המדף עובדים על האמת-ההפוכה ───
  //   presents = ימי-לימודים בחודש שהתלמיד לא-חסר בהם (נגזרת מהמודל-ההפוך) · absences = הסימונים
  static Map<String, dynamic> enrollmentOf(Map<String, dynamic> s, {String? month}) {
    final sid = s['id'] as String;
    final days = schoolDaysInMonth(month ?? _Placement.today, upTo: _Placement.today);
    final presents = [for (final d in days) if (!absentDay(d, sid)) d];
    final absences = [
      for (final m in marks)
        if (m['sid'] == sid && m['status'] == 'absent')
          {'date': m['date'], 'reason': m['reason'], 'makeup': m['makeup'] == true, if (m['makeupDate'] != null) 'makeupDate': m['makeupDate'], 'noshow': m['justified'] != true, 'lesson': m['lesson']},
    ];
    return {'id': 'e-$sid', 'memberId': sid, 'courseId': s['cls'], 'status': activeOf(s) ? 'active' : 'ended', 'presents': presents, 'absences': absences};
  }
  static List<Map<String, dynamic>> get enrollments => [for (final s in students) enrollmentOf(s)];
  static List<Map<String, dynamic>> rosterOf(String cls) => sheetRoster(enrollments, cls).cast<Map<String, dynamic>>();

  // ─── הערכת-מצב (פעולה-3): מנועי-מדף ───
  static int presentsThisMonth(Map<String, dynamic> s) => presentsInMonth((enrollmentOf(s)['presents'] as List).cast<Object?>(), _Placement.today);
  static int absencesThisMonth(String sid) => marks.where((m) => m['sid'] == sid && m['status'] == 'absent' && monthKey(m['date'] as String) == monthKey(_Placement.today)).length;
  static int schoolDaysSoFar() => schoolDaysInMonth(_Placement.today, upTo: _Placement.today).length;
  static double attendancePct(Map<String, dynamic> s) {
    final n = schoolDaysSoFar();
    return n == 0 ? 1.0 : presentsThisMonth(s) / n;
  }
  static Map<String, dynamic> summaryOf(Map<String, dynamic> s) => enrollSummary(enrollmentOf(s), (_) => 0, (_) => 0, const {'k1': 'פעיל', 'k2': 'מושהה', 'k3': 'הסתיים', 'k4': 'רשימת-המתנה'});
  // רצף-חיסורים: ימי-לימודים רצופים (אחורה מהיום) שבהם חסר — dayDiff מהמדף מוודא רציפות-לוח
  static int streak(String sid) {
    final days = lastSchoolDays(30);
    var n = 0;
    for (var i = days.length - 1; i >= 0; i--) {
      if (!absentDay(days[i], sid)) break;
      if (i < days.length - 1 && dayDiff(days[i], days[i + 1]) > 4) break; // פער > 4 ימי-לוח (חופשה) שובר רצף
      n++;
    }
    return n;
  }
  // מגמה: חיסורים פר-חודש (3 חודשים) ⇒ trendFromScan {dir,pct}
  static Map<String, dynamic> trend(String sid) {
    final months = [monthKey(shift(_Placement.today, -60)), monthKey(shift(_Placement.today, -30)), monthKey(_Placement.today)];
    final counts = [for (final mk in months) marks.where((m) => m['sid'] == sid && m['status'] == 'absent' && monthKey(m['date'] as String) == mk).length];
    return trendFromScan({'monthly': counts});
  }
  static List<Map<String, Object?>> get pendingMakeupList => pendingMakeups(enrollments);
  static List<Map<String, Object?>> pendingMakeupsOf(String sid) => pendingMakeupList.where((p) => p['memberId'] == sid).toList();

  // ─── סיבות-מובנות: absenceReasonChips (מדף) ⊕ מונחי-דאטה + סיבות-מוסד (חולה/משפחתי/טיול/אבל/אחר) ───
  static List<String> get reasons => [...absenceReasonChips(term: (k) => reason_t.kTerms[k] ?? k), 'חולה', 'טיול', 'אבל', 'רפואי', 'אחר'];

  // ─── KPI-10 (פעולה-3 · כל אחד = ספירה/יחס על אמת) ───
  static List<Map<String, dynamic>> get activeStudents => students.where(activeOf).toList();
  static int countToday(String status) => activeStudents.where((s) => dayStatus(_Placement.today, s['id'] as String) == status).length;
  static int get presentToday => countToday('present');
  static int get absentToday => countToday('absent');
  static int get lateToday => countToday('late');
  static int get releasedToday => countToday('released');
  static double get monthPct {
    final n = schoolDaysSoFar() * activeStudents.length;
    if (n == 0) return 1.0;
    var p = 0;
    for (final s in activeStudents) {
      p += presentsThisMonth(s);
    }
    return p / n;
  }
  static int get unjustifiedMonth => marks.where((m) => unjustified(m) && monthKey(m['date'] as String) == monthKey(_Placement.today)).length;
  static int get noParentOk => marks.where((m) => unjustified(m) && m['parentOk'] != true).length;
  // כיתות-שטרם-נרשמו-היום: כיתה עם שיעור שכבר התחיל (nowHm) ואין לו רישום (סימון או אישור-כולם-נוכחים)
  static List<Map<String, dynamic>> lessonsStarted(String date) {
    final now = timeToMin(_Placement.nowHm);
    if (date != _Placement.today) return lessonsOf(date);
    return lessonsOf(date).where((l) => (timeToMin(l['time']) as num) <= (now as num)).toList();
  }
  static List<String> get classesNotRecordedToday => [
        for (final c in classes)
          if (lessonsStarted(_Placement.today).any((l) => !isRecorded(_Placement.today, c['id'] as String, l['n'] as int) && !marks.any((m) => m['date'] == _Placement.today && m['lesson'] == l['n'] && studentById(m['sid'] as String)['cls'] == c['id'])))
            c['id'] as String,
      ];
}

// ═══════════ המסך הציבורי ═══════════
class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _date = _Placement.today; // תאריך-נבחר (בורר-תאריך)
  int _cls = 0; // כיתה-נבחרת (SegmentedSwitch)

  @override
  Widget build(BuildContext context) {
    final cls = _AttData.classes[_cls]['id'] as String;
    final roster = _AttData.studentsOf(cls);
    final holiday = _AttData.holidayName(_date);
    final lessons = _AttData.lessonsOf(_date);
    final sum = sheetSummary(_AttData.rosterOf(cls), _date) as Map; // {present,total} מהמדף
    final monthPct = _AttData.monthPct;
    final notRec = _AttData.classesNotRecordedToday;
    return DsScaffold(
      title: 'נוכחות',
      subtitle: '${_AttData.activeStudents.length} תלמידים · ${_AttData.classes.length} כיתות · ${fmtDate(_Placement.today)}',
      icon: '🗓️',
      children: [
        // ── פס-עליון: בורר-תאריך (◀ היום ▶ · שם-יום · חג) + בורר-כיתה ──
        Row(children: [
          SoftButton(label: '◀', tone: 0, onTap: () => setState(() => _date = _AttData.shift(_date, -1))),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${dayNames[_AttData.dow(_date)]} · ${fmtDate(_date)}', style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
              Text(holiday != null ? '🕎 $holiday · לא-נספר' : lessons.isEmpty ? 'אין-שיעורים' : '${lessons.length} שיעורים', style: const TextStyle(color: _muted, fontSize: 12)),
            ]),
          ),
          const SizedBox(width: 6),
          SoftButton(label: '▶', tone: 0, onTap: () => setState(() => _date = _AttData.shift(_date, 1))),
          if (_date != _Placement.today) ...[
            const SizedBox(width: 6),
            SoftButton(label: 'היום', tone: 1, onTap: () => setState(() => _date = _Placement.today)),
          ],
        ]),
        _gap(10),
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(
            items: [for (final c in _AttData.classes) c['name'] as String],
            selected: _cls,
            onSelect: (i) => setState(() => _cls = i),
          ),
        ),
        _gap(12),
        // ── KPI-10 (המפרט): hero = דורשי-פעולה-היום (המטרה) + 10 עובדות-ספירה (BareStat) + יחס-חודשי (ProgressRing) ──
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: StatHero(value: '${_AttData.absentToday + notRec.length}', label: 'דורשי-פעולה היום (חסרים + כיתות-שטרם-נרשמו)')),
              ProgressRing(value: monthPct, label: 'נוכחות החודש', size: 96),
            ]),
            const SizedBox(height: 14),
            Row(children: [
              BareStat(value: '${_AttData.presentToday}', label: '✅ נוכחים-היום', inkColor: _ok, mutedColor: _muted),
              BareStat(value: '${_AttData.absentToday}', label: '⛔ חסרים-היום', inkColor: _AttData.absentToday > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_AttData.lateToday}', label: '⏰ מאחרים', inkColor: _AttData.lateToday > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${_AttData.releasedToday}', label: '🚪 שוחררו', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${(monthPct * 100).round()}%', label: '📈 נוכחות%-חודשי', inkColor: monthPct * 100 < _Placement.minAttendancePct ? _danger : _acc, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: '${_AttData.activeStudents.where((s) => _AttData.streak(s['id'] as String) >= _Placement.streakAlert).length}', label: '🚨 בסיכון-נשירה', inkColor: _danger, mutedColor: _muted),
              BareStat(value: '${_AttData.pendingMakeupList.length}', label: '🔁 השלמות-ממתינות', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_AttData.unjustifiedMonth}', label: '❔ לא-מוצדקים-החודש', inkColor: _AttData.unjustifiedMonth > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${_AttData.noParentOk}', label: '👪 ללא-אישור-הורה', inkColor: _AttData.noParentOk > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${notRec.length}', label: '📝 כיתות-שטרם-נרשמו', inkColor: notRec.isNotEmpty ? _danger : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        _gap(8),
        if (holiday != null)
          AlertBanner(glyph: '🕎', tone: 3, message: '$holiday — יום-חופש: היום לא נספר בנוכחות (סנכרון-לוח)')
        else if (lessons.isEmpty)
          const AlertBanner(glyph: '📭', tone: 0, message: 'אין-שיעורים ביום זה')
        else
          DsSection(
            title: '📋 ${_AttData.className(cls)} · ${fmtDate(_date)} · ${sum['present']}/${sum['total']} נוכחים',
            children: [
              for (final s in roster) _row(s),
            ],
          ),
      ],
    );
  }

  // שורת-תלמיד (גל 1: עובדות בלבד — זהות + סטטוס-יומי; טאפ-מחזורי ופאנל בגל 2-3)
  Widget _row(Map<String, dynamic> s) {
    final sid = s['id'] as String;
    final st = _AttData.dayStatus(_date, sid);
    final arr = _AttData.arrivalOf(_date, sid);
    const label = {'present': '✅ נוכח', 'absent': '⛔ חסר', 'late': '⏰ איחור', 'released': '🚪 שחרור'};
    const tone = {'present': 1, 'absent': 2, 'late': 3, 'released': 0};
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: MediaRow(glyph: '🎓', title: s['name'] as String, subtitle: '${_AttData.className(s['cls'] as String)} · מס׳ ${s['num']}${arr != null ? ' · הגעה $arr' : ''}')),
        const SizedBox(width: 8),
        if (_Placement.parents[sid] == null) const StatusChip(label: 'ללא קשר-הורה', tone: 3), // מקום-שמור מואר רק כשחסר (חוק-7)
        StatusChip(label: label[st]!, tone: tone[st]!),
      ]),
    );
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
}
