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
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל-התלמיד (child שרירותי)
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // ההירו = המטרה (דורשי-פעולה)
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-כיתה/שיעור/מבט מבוקר
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/status_dot.dart'; // נקודת-יום צבעונית (ציר-30-יום)
import '../dart-ui-bs/premium/feedback/empty_state.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/lists/avatar_tile.dart'; // זהות-תלמיד בפאנל (ראשי-תיבות+שם+תת)
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס (ציון-סיכון · נוכחות%) — בר-מילוי
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // פריט-ציר-זמן (השלמות · היסטוריה · אודיט)
import '../dart-ui-bs/premium/dataviz/progress_ring.dart'; // יחס נוכחות-חודשי (0..1) — תובנת-יחס
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // השוואת-סיבות (countBy) — עמודות-מנורמלות
import '../dart-ui-bs/premium/dataviz/trend_stat.dart'; // מגמה (ערך+דלתא%) — trendFromScan
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows, מיון) — לא DataGrid המזייף
import '../dart-ui-bs/ds/ds_enum_field.dart'; // בורר-סיבה מרשימה-סגורה (absenceReasonChips)
import '../dart-maor/presents-in-month.dart'; // מנוע-מדף: ספירת-נוכחויות בחודש (presents ISO)
import '../dart-maor/sheet-summary.dart'; // מנוע-מדף: {present,total} לתאריך על roster
import '../dart-maor/sheet-roster.dart'; // מנוע-מדף: roster פר-חוג (active בלבד)
import '../dart-maor/pending-makeups.dart'; // מנוע-מדף: השלמות-ממתינות (לא-מתוזמנות קודם)
import '../dart-maor/makeup-eligibility.dart'; // מנוע-מדף: זכאות-השלמה (noshow לעולם לא · מוצדק כן)
import '../dart-maor/enroll-summary.dart'; // מנוע-מדף: {presents,absences,noshow,...} פר-שיבוץ
import '../dart-maor/count-by.dart'; // מנוע-מדף: קיבוץ+ספירה (סיבות · ימים · שיעורים)
import '../dart-maor/grand-total.dart'; // מנוע-מדף: Σ-לפי-מפתח (דקות-איחור)
import '../dart-maor/clamp-scale.dart'; // מנוע-מדף: הצמדה לגבולות (יחסים 0..1)
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
  static const riskRed = 60, riskOrange = 35; // ספי-סיכון (ציון 0..100)
  static const recorder = 't1'; // זהות-הרושם המוזרקת (מי-רשם באודיט) — בורר-תפקיד בגל 5
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
  // שיעור = {n, time, subject}. שבת=אין. שישי=4 שיעורים.
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
  static final List<Map<String, dynamic>> audit = []; // אודיט-רישום {at, by, action, key} (חדש-ראשון)
  static final Map<String, List<String>> notes = {}; // הערות פר-תלמיד
  static int _seq = 0; // מונה-אירועים (סדר-אודיט דטרמיניסטי; השעון מוזרק)
  static String keyOf(String date, int lesson, String sid) => '$date|$lesson|$sid';
  static bool isRecorded(String date, String cls, int lesson) => _recorded.contains('$date|$cls|$lesson');
  static void _log(String action, String key) {
    _seq++;
    audit.insert(0, {'at': '${_Placement.today}T${_Placement.nowHm}', 'seq': _seq, 'by': _Placement.recorder, 'action': action, 'key': key});
  }

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
  static final Map<String, Map<String, dynamic>> _baseIndex = {
    for (final b in baseMarks) keyOf(b['date'] as String, b['lesson'] as int, b['sid'] as String): b,
  };
  static Map<String, dynamic>? markOf(String date, int lesson, String sid) {
    final k = keyOf(date, lesson, sid);
    final v = _overrides[k] ?? _baseIndex[k];
    return v == null || v['status'] == 'present' ? null : v;
  }

  // ═══ רישום (פעולה-2): אידמפוטנטי — אותו מפתח+אותו מצב ⇒ false (רישום-כפול חסום, לא מוכפל) ═══
  static bool mark(String date, int lesson, String sid, String status, {String? reason, String? arrival}) {
    final cur = markOf(date, lesson, sid);
    if ((cur?['status'] ?? 'present') == status) return false; // כפול ⇒ חסום
    final k = keyOf(date, lesson, sid);
    if (status == 'present') {
      _overrides[k] = {...?cur, 'date': date, 'lesson': lesson, 'sid': sid, 'status': 'present'};
    } else {
      _overrides[k] = {
        ...?cur, 'date': date, 'lesson': lesson, 'sid': sid, 'status': status,
        'reason': reason ?? cur?['reason'] ?? (status == 'absent' ? 'אחר' : null),
        'justified': cur?['justified'] ?? (status == 'released'),
        if (status == 'late') 'arrival': arrival ?? cur?['arrival'] ?? _Placement.nowHm,
        'by': _Placement.recorder, 'at': '${_Placement.today}T${_Placement.nowHm}',
      };
    }
    _recorded.add('$date|${studentById(sid)['cls']}|$lesson');
    _log(status, k);
    return true;
  }
  static const cycleOrder = ['present', 'absent', 'late', 'released']; // טאפ-מחזורי
  static String cycle(String date, int lesson, String sid) {
    final cur = markOf(date, lesson, sid)?['status'] as String? ?? 'present';
    final next = cycleOrder[(cycleOrder.indexOf(cur) + 1) % cycleOrder.length];
    mark(date, lesson, sid, next);
    return next;
  }
  static void patch(String date, int lesson, String sid, Map<String, dynamic> fields) {
    final cur = markOf(date, lesson, sid);
    if (cur == null) return;
    _overrides[keyOf(date, lesson, sid)] = {...cur, ...fields, 'by': _Placement.recorder, 'at': '${_Placement.today}T${_Placement.nowHm}'};
    _log(fields.keys.join('+'), keyOf(date, lesson, sid));
  }
  // כולם-נוכחים (טאפ-אחד): מאפס סימוני-השיעור לנוכח + מסמן "נרשם"
  static int allPresent(String date, String cls, int lesson) {
    var n = 0;
    for (final s in studentsOf(cls)) {
      if (mark(date, lesson, s['id'] as String, 'present')) n++;
    }
    _recorded.add('$date|$cls|$lesson');
    _log('all-present', '$date|$cls|$lesson');
    return n;
  }
  // תזמון-השלמה: ליום-הלימודים הבא אחרי today (לא חג/שבת) — עם זכאות makeupEligibility (מדף)
  static Map<String, bool> eligibility(Map<String, dynamic> m) =>
      makeupEligibility(m['justified'] == true ? 'cancel' : 'noshow', m['justified'] == true, m['noticeHrs'] as num?); // noticeHrs = מקום-שמור
  static String nextSchoolDay(String from) {
    var d = shift(from, 1);
    for (var i = 0; i < 30 && !isSchoolDay(d); i++) {
      d = shift(d, 1);
    }
    return d;
  }

  // ─── תלמידים/כיתות (עובדות) ───
  static bool activeOf(Map<String, dynamic> s) => (s['active'] as bool?) ?? true;
  static List<Map<String, dynamic>> studentsOf(String cls) => students.where((s) => s['cls'] == cls && activeOf(s)).toList();
  static Map<String, dynamic> studentById(String sid) => students.firstWhere((s) => s['id'] == sid);
  static String className(String cls) => classes.firstWhere((c) => c['id'] == cls)['name'] as String;
  static String initials(String name) => name.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join();
  static int dow(String iso) => DateTime.parse('${iso}T12:00:00').weekday % 7; // 0=ראשון
  static List<Map<String, dynamic>> lessonsOf(String iso) => lessonsByDow[dow(iso)] ?? const [];
  static String iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String shift(String isoDate, int days) {
    final d = DateTime.parse('${isoDate}T12:00:00');
    return iso(DateTime(d.year, d.month, d.day + days));
  }
  // השיעור-הנוכחי (מודול-חוגים): האחרון שהתחיל לפי nowHm (היום) · 1 ביום אחר
  static int currentLesson(String date) {
    final ls = lessonsStarted(date);
    return ls.isEmpty ? (lessonsOf(date).isEmpty ? 1 : lessonsOf(date).first['n'] as int) : ls.last['n'] as int;
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
  static final Map<String, String?> _holCache = {};
  static String? holidayName(String isoDate) => _holCache.putIfAbsent(isoDate, () {
        final d = DateTime.parse('${isoDate}T12:00:00');
        return holidayOf(d, (x) => hebParts(x), (_) => _scanHebYear(d), HOLIDAYS, term: (k) => hol_t.kTerms[k] ?? k);
      });
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
  // N ימי-לימודים אחרונים (עד today כולל) — חלון-הדפוס
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
  static int lateMinutesOn(String date, String sid) => grandTotal(marksOn(date, sid).where((m) => m['status'] == 'late').toList(), (m) => lateMinutes(m as Map<String, dynamic>)).toInt();
  static bool isLate(Map<String, dynamic> m) => m['status'] == 'late' && lateMinutes(m) > _Placement.lateWindowMin;
  static bool unjustified(Map<String, dynamic> m) => m['status'] == 'absent' && m['justified'] != true;
  static Map<String, dynamic>? firstMarkOn(String date, String sid) => marksOn(date, sid).isEmpty ? null : marksOn(date, sid).first;

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
  static String trendLabel(String sid) {
    final t = trend(sid);
    return t['dir'] == 'up' ? '↑ ${t['pct']}%' : t['dir'] == 'down' ? '↓ ${t['pct']}%' : '→';
  }
  static List<Map<String, Object?>> get pendingMakeupList => pendingMakeups(enrollments);
  static List<Map<String, Object?>> pendingMakeupsOf(String sid) => pendingMakeupList.where((p) => p['memberId'] == sid).toList();
  static String? scheduledMakeup(String sid) {
    for (final p in pendingMakeupsOf(sid)) {
      if (p['makeupDate'] != null) return p['makeupDate'] as String;
    }
    return null;
  }
  // חיסורים-לפי-סיבה (countBy מהמדף) — 30 ימי-לימודים אחרונים
  static List<Map<String, dynamic>> absencesOf(String sid) => marks.where((m) => m['sid'] == sid && m['status'] == 'absent').toList();
  static List<List<Object>> reasonsOf(String sid) => countBy(absencesOf(sid), (m) => '${(m as Map)['reason'] ?? 'אחר'}');

  // ═══ ניבוי-נשירה (הכרעה 23-ד · חיבור-מודלים): דפוס-היעדרות ⇒ ציון-סיכון 0..100 ═══
  //   4 אותות מנורמלים: שיעור-חיסורים-לא-מוצדקים(40) · רצף(30) · מגמה(20) · דפוס-קבוע(10).
  //   פוקטור-חיצוני (מודול-תלמידים): riskExternal = מקום-שמור — כשיוזרק, מחברים max(פנימי,חיצוני).
  static Map<String, int> patterns(String sid) {
    final abs = absencesOf(sid);
    if (abs.length < 3) return const {};
    final byDow = countBy(abs, (m) => '${dow((m as Map)['date'] as String)}');
    final byLesson = countBy(abs, (m) => '${(m as Map)['lesson']}');
    final afterHoliday = abs.where((m) => holidayName(shift(m['date'] as String, -1)) != null || dow(m['date'] as String) == 0).length;
    final out = <String, int>{};
    if ((byDow.first[1] as int) * 2 >= abs.length) out['יום-קבוע: ${dayNames[int.parse(byDow.first[0] as String)]}'] = byDow.first[1] as int;
    if ((byLesson.first[1] as int) * 2 >= abs.length) out['שיעור-קבוע: ${byLesson.first[0]}'] = byLesson.first[1] as int;
    if (afterHoliday * 2 >= abs.length) out['אחרי-חופשה/סופ״ש'] = afterHoliday;
    return out;
  }
  static Map<String, num> riskParts(String sid) {
    final days = lastSchoolDays(30);
    final unj = days.where((d) => marksOn(d, sid).any(unjustified)).length;
    final rate = clampScale(unj / 6, 0, 1); // 6 חיסורים לא-מוצדקים ב-30 ימי-לימודים = מקסימום
    final st = clampScale(streak(sid) / 4, 0, 1);
    final t = trend(sid);
    final tr = t['dir'] == 'up' ? 1 : t['dir'] == 'flat' && unj > 0 ? 0.4 : 0;
    final pat = patterns(sid).isEmpty ? 0 : 1;
    return {'rate': rate * 40, 'streak': st * 30, 'trend': tr * 20, 'pattern': pat * 10};
  }
  static int risk(String sid) {
    final internal = riskParts(sid).values.fold<num>(0, (a, b) => a + b).round();
    final ext = studentById(sid)['riskExternal'] as int?; // מקום-שמור (מודול-תלמידים)
    return ext == null ? internal : (ext > internal ? ext : internal);
  }
  static String riskWhy(String sid) {
    final p = riskParts(sid);
    final top = p.entries.reduce((a, b) => a.value >= b.value ? a : b);
    const why = {'rate': 'חיסורים לא-מוצדקים', 'streak': 'רצף-חיסורים', 'trend': 'מגמה עולה', 'pattern': 'דפוס-קבוע'};
    return top.value == 0 ? 'אין-אות' : why[top.key]!;
  }
  static int riskBand(String sid) => risk(sid) >= _Placement.riskRed ? 2 : risk(sid) >= _Placement.riskOrange ? 1 : 0;
  static String riskAction(String sid) => riskBand(sid) == 2 ? 'ועדת-שילוב + ביקור-בית' : riskBand(sid) == 1 ? 'שיחת-מחנך + יידוע-הורים' : 'מעקב';

  // ─── סיבות-מובנות: absenceReasonChips (מדף) ⊕ מונחי-דאטה + סיבות-מוסד (חולה/משפחתי/טיול/אבל/אחר) ───
  static List<String> get reasons => [...absenceReasonChips(term: (k) => reason_t.kTerms[k] ?? k), 'חולה', 'טיול', 'אבל', 'רפואי', 'אחר'];

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 16 עמודות-המפרט + 5 שקעים כחוזה-דאטה ═══
  //   נגזרת(get)=תמיד-מוצגת · שדה(key)=מוארת רק כשתלמיד/סימון נושא ערך, חסר ⇒ שקט. הזרקת photo/medicalDoc/
  //   online/transportLate/cardIn/gpsIn לדאטה ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static List<Map<String, Object?>> columnDefs(String date) => <Map<String, Object?>>[
        {'key': 'photo', 'label': 'תמונה'}, // מקום-שמור
        {'label': 'שם', 'get': (Map<String, dynamic> s) => '${s['name']}'},
        {'label': 'כיתה', 'get': (Map<String, dynamic> s) => className(s['cls'] as String)},
        {'label': 'מס׳', 'get': (Map<String, dynamic> s) => '${s['num']}'},
        {'label': 'סטטוס-היום', 'get': (Map<String, dynamic> s) => statusLabel[dayStatus(date, s['id'] as String)]!},
        {'label': 'שעת-הגעה', 'get': (Map<String, dynamic> s) => arrivalOf(date, s['id'] as String) ?? '—'},
        {'label': 'דקות-איחור', 'get': (Map<String, dynamic> s) => '${lateMinutesOn(date, s['id'] as String)}'},
        {'label': 'סיבה', 'get': (Map<String, dynamic> s) => '${firstMarkOn(date, s['id'] as String)?['reason'] ?? '—'}'},
        {'label': 'מוצדק?', 'get': (Map<String, dynamic> s) => firstMarkOn(date, s['id'] as String) == null ? '—' : firstMarkOn(date, s['id'] as String)!['justified'] == true ? 'כן' : 'לא'},
        {'label': 'אישור-הורה', 'get': (Map<String, dynamic> s) => firstMarkOn(date, s['id'] as String) == null ? '—' : firstMarkOn(date, s['id'] as String)!['parentOk'] == true ? '✓' : '✗'},
        {'label': 'חיסורים-החודש', 'get': (Map<String, dynamic> s) => '${absencesThisMonth(s['id'] as String)}'},
        {'label': 'רצף-חיסורים', 'get': (Map<String, dynamic> s) => '${streak(s['id'] as String)}'},
        {'label': 'נוכחות%', 'get': (Map<String, dynamic> s) => '${(attendancePct(s) * 100).round()}'},
        {'label': 'מגמה', 'get': (Map<String, dynamic> s) => trendLabel(s['id'] as String)},
        {'label': 'ציון-סיכון', 'get': (Map<String, dynamic> s) => '${risk(s['id'] as String)}'},
        {'label': 'השלמה-מתוזמנת', 'get': (Map<String, dynamic> s) => scheduledMakeup(s['id'] as String) ?? (pendingMakeupsOf(s['id'] as String).isEmpty ? '—' : 'ממתין')},
        {'key': 'medicalDoc', 'label': 'אישור-רפואי'}, // מקום-שמור (קובץ)
        {'key': 'online', 'label': 'מקוון'}, // מקום-שמור (היברידי)
        {'key': 'transportLate', 'label': 'איחור-הסעה'}, // מקום-שמור
        {'key': 'cardIn', 'label': 'כרטיס/ביומטרי'}, // מקום-שמור
        {'key': 'gpsIn', 'label': 'GPS-הגעה'}, // מקום-שמור
      ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || rows.any((s) => s[c['key']] != null && '${s[c['key']]}'.trim().isNotEmpty);
  static const statusLabel = {'present': '✅ נוכח', 'absent': '⛔ חסר', 'late': '⏰ איחור', 'released': '🚪 שחרור'};
  static const statusTone = {'present': 1, 'absent': 2, 'late': 3, 'released': 0};
  // חוזה-עובדות-הפאנל (מקום-שמור כמו metaFields): שדה מוצג רק כשקיים ערך
  static const metaFields = <Map<String, String>>[
    {'key': 'phone', 'prefix': '📞 ', 'suffix': ''},
    {'key': 'name', 'prefix': '👪 ', 'suffix': ''},
    {'key': 'email', 'prefix': '✉️ ', 'suffix': ''}, // מקום-שמור
    {'key': 'lang', 'prefix': '🗣 ', 'suffix': ''}, // מקום-שמור (שפת-הודעה)
  ];

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
  static int get atRiskCount => activeStudents.where((s) => riskBand(s['id'] as String) > 0).length;
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
          if (lessonsStarted(_Placement.today).any((l) => !isRecorded(_Placement.today, c['id'] as String, l['n'] as int)))
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
  int? _lesson; // שיעור-נבחר (null ⇒ השיעור-הנוכחי)
  int _mode = 0; // 0=📋 גיליון (טאפ-מחזורי) · 1=🗂 טבלה (DsTable כל-העמודות)
  String? _notice; // הודעת-מערכת אחרונה (רישום-כפול · כולם-נוכחים)

  int get _lessonN => _lesson ?? _AttData.currentLesson(_date);

  @override
  Widget build(BuildContext context) {
    final cls = _AttData.classes[_cls]['id'] as String;
    final roster = _AttData.studentsOf(cls);
    final holiday = _AttData.holidayName(_date);
    final lessons = _AttData.lessonsOf(_date);
    final sum = sheetSummary(_AttData.rosterOf(cls), _date) as Map; // {present,total} מהמדף
    final monthPct = _AttData.monthPct;
    final notRec = _AttData.classesNotRecordedToday;
    final lessonIdx = lessons.indexWhere((l) => l['n'] == _lessonN);
    final recorded = lessons.isNotEmpty && _AttData.isRecorded(_date, cls, _lessonN);
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
              BareStat(value: '${_AttData.atRiskCount}', label: '🚨 בסיכון-נשירה', inkColor: _AttData.atRiskCount > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_AttData.pendingMakeupList.length}', label: '🔁 השלמות-ממתינות', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_AttData.unjustifiedMonth}', label: '❔ לא-מוצדקים-החודש', inkColor: _AttData.unjustifiedMonth > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${_AttData.noParentOk}', label: '👪 ללא-אישור-הורה', inkColor: _AttData.noParentOk > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${notRec.length}', label: '📝 כיתות-שטרם-נרשמו', inkColor: notRec.isNotEmpty ? _danger : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        _gap(8),
        if (_notice != null) ...[AlertBanner(glyph: 'ℹ️', tone: 0, message: _notice!), _gap(8)],
        if (holiday != null)
          AlertBanner(glyph: '🕎', tone: 3, message: '$holiday — יום-חופש: היום לא נספר בנוכחות (סנכרון-לוח)')
        else if (lessons.isEmpty)
          const AlertBanner(glyph: '📭', tone: 0, message: 'אין-שיעורים ביום זה')
        else ...[
          // ── בורר-שיעור (פר-שיעור, לא פר-יום) + מבט + רישום-מרוכז ──
          Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
            SegmentedSwitch(
              items: [for (final l in lessons) '${l['n']} · ${l['time']}'],
              selected: lessonIdx < 0 ? 0 : lessonIdx,
              onSelect: (i) => setState(() => _lesson = lessons[i]['n'] as int),
            ),
            SegmentedSwitch(items: const ['📋 גיליון', '🗂 טבלה'], selected: _mode, onSelect: (i) => setState(() => _mode = i)),
          ]),
          _gap(8),
          Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            StatusChip(label: '${lessons[lessonIdx < 0 ? 0 : lessonIdx]['subject']} · ${recorded ? 'נרשם' : 'טרם-נרשם'}', tone: recorded ? 1 : 3),
            SoftButton(label: '✅ כולם-נוכחים', tone: 1, onTap: () => setState(() {
              final n = _AttData.allPresent(_date, cls, _lessonN);
              _notice = 'שיעור $_lessonN · ${_AttData.className(cls)}: נרשם "כולם נוכחים" ($n סימונים אופסו)';
            })),
          ]),
          _gap(8),
          if (roster.isEmpty)
            const EmptyState(glyph: '🏫', message: 'כיתה ריקה — אין תלמידים פעילים')
          else if (_mode == 1)
            DsSection(title: '🗂 טבלה · ${_AttData.className(cls)} · ${fmtDate(_date)}', children: [_table(roster)])
          else
            DsSection(
              title: '📋 ${_AttData.className(cls)} · שיעור $_lessonN · ${sum['present']}/${sum['total']} נוכחים-היום',
              children: [for (final s in roster) _row(s)],
            ),
        ],
      ],
    );
  }

  // שורת-תלמיד (גיליון): זהות (MediaRow) ⊕ מצב-בשיעור (StatusChip) ⊕ טאפ-מחזורי (SoftButton) ⊕ פאנל (שברון)
  //   הטאפ-המחזורי: נוכח→חסר→איחור→שחרור→נוכח (מודל-הפוך: "נוכח" = מחיקת-הסימון). אידמפוטנטי.
  Widget _row(Map<String, dynamic> s) {
    final sid = s['id'] as String;
    final m = _AttData.markOf(_date, _lessonN, sid);
    final st = m?['status'] as String? ?? 'present';
    final dayst = _AttData.dayStatus(_date, sid);
    final arr = m?['arrival'] as String?;
    final rb = _AttData.riskBand(sid);
    final sub = [
      '${_AttData.className(s['cls'] as String)} · מס׳ ${s['num']}',
      if (arr != null) 'הגעה $arr (+${_AttData.lateMinutes(m!)}׳)',
      if (m?['reason'] != null) '${m!['reason']}${m['justified'] == true ? ' · מוצדק' : ''}',
      if (dayst != st) 'היום: ${_AttData.statusLabel[dayst]}',
      if (_AttData.streak(sid) >= _Placement.streakAlert) '🚨 רצף ${_AttData.streak(sid)}',
    ].join(' · ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: MediaRow(glyph: rb == 2 ? '🚨' : rb == 1 ? '⚠️' : '🎓', title: s['name'] as String, subtitle: sub)),
        const SizedBox(width: 6),
        SoftButton(label: _AttData.statusLabel[st]!, tone: _AttData.statusTone[st]!, onTap: () => setState(() => _AttData.cycle(_date, _lessonN, sid))),
        IconButton(onPressed: () => _openPanel(s), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פרטים ופעולות'),
      ]),
    );
  }

  // 🗂 מבט-טבלה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid.
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _AttData.columnDefs(_date)) if (_AttData.colShown(c, rows)) c];
    final labels = [for (final c in cols) c['label'] as String];
    final data = <List<String>>[
      for (final s in rows)
        [
          for (final c in cols)
            if (c['get'] != null) (c['get'] as String Function(Map<String, dynamic>))(s) else '${s[c['key']] ?? '—'}',
        ],
    ];
    return DsTable(labels: labels, rows: data);
  }

  // ═══ פאנל תלמיד-נבחר (GlassCard) · פעולת-יסוד "ביצוע"+"הערכה": זהות · סטטוס-היום · ציר-30-יום ·
  //   סיבות (NeonBars⊕countBy) · מגמה+סיכון (TrendStat⊕StatRow⊕StatusChip) · השלמות · קשר-הורה · הערות · פעולות ═══
  void _openPanel(Map<String, dynamic> s) {
    final sid = s['id'] as String;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void act(void Function() f) {
            f();
            setSheet(() {});
            setState(() {});
          }
          final m = _AttData.markOf(_date, _lessonN, sid);
          final st = m?['status'] as String? ?? 'present';
          final days = _AttData.lastSchoolDays(30);
          final reasons = _AttData.reasonsOf(sid);
          final pend = _AttData.pendingMakeupsOf(sid);
          final r = _AttData.risk(sid), rb = _AttData.riskBand(sid);
          final t = _AttData.trend(sid);
          final pct = _AttData.attendancePct(s);
          final parent = _Placement.parents[sid];
          final elig = m == null || m['status'] != 'absent' ? null : _AttData.eligibility(m);
          return DraggableScrollableSheet(
            initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: GlassCard(
                child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  AvatarTile(initials: _AttData.initials(s['name'] as String), title: s['name'] as String, subtitle: '${_AttData.className(s['cls'] as String)} · מס׳ ${s['num']} · ${_AttData.summaryOf(s)['statusLabel']}'),
                  _gap(10),
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    StatusChip(label: 'היום: ${_AttData.statusLabel[_AttData.dayStatus(_date, sid)]}', tone: _AttData.statusTone[_AttData.dayStatus(_date, sid)]!),
                    StatusChip(label: 'שיעור $_lessonN: ${_AttData.statusLabel[st]}', tone: _AttData.statusTone[st]!),
                    if (m?['arrival'] != null) StatusChip(label: 'הגעה ${m!['arrival']} · +${_AttData.lateMinutes(m)}׳', tone: _AttData.isLate(m) ? 3 : 1),
                  ]),
                  _gap(8),
                  // שיעורים-מרובים-ביום (פר-שיעור, לא פר-יום): כפתור פר-שיעור — טאפ מחזורי על אותו שיעור
                  Wrap(spacing: 6, runSpacing: 6, children: [
                    for (final l in _AttData.lessonsOf(_date))
                      SoftButton(
                        label: 'ש${l['n']} ${_AttData.statusLabel[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']}',
                        tone: _AttData.statusTone[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']!,
                        onTap: () => act(() => _AttData.cycle(_date, l['n'] as int, sid)),
                      ),
                  ]),
                  _gap(12),
                  // ציר-30-יום: StatusDot פר-יום-לימודים (ירוק/אדום/כתום/ציאן) + יום-בחודש (עובדה)
                  Text('ציר 30 ימי-לימודים · ${_AttData.presentsThisMonth(s)}/${_AttData.schoolDaysSoFar()} נוכח החודש', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  _gap(6),
                  Wrap(spacing: 2, runSpacing: 4, children: [
                    for (final d in days)
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        StatusDot(tone: _AttData.statusTone[_AttData.dayStatus(d, sid)]!, size: 9),
                        Text(d.substring(8), style: TextStyle(color: d == _date ? _ink : _muted, fontSize: 9)),
                      ]),
                  ]),
                  _gap(12),
                  StatRow(label: 'נוכחות% החודש (סף ${_Placement.minAttendancePct}%)', value: '${(pct * 100).round()}%', fraction: pct),
                  _gap(8),
                  // מגמה+ציון-סיכון (חיבור-מודלים): TrendStat (דלתא-חיסורים, הפוך) ⊕ StatRow (ציון) ⊕ StatusChip (אות-מוביל+התערבות)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: TrendStat(value: '${_AttData.absencesThisMonth(sid)}', delta: -((t['pct'] as num).toDouble()), label: 'חיסורים החודש · מגמת-נוכחות (↓=מחמיר)')),
                    const SizedBox(width: 8),
                    Expanded(child: Column(children: [
                      StatRow(label: 'ציון-סיכון-נשירה', value: '$r', fraction: r / 100),
                      _gap(6),
                      Wrap(spacing: 6, runSpacing: 4, children: [
                        StatusChip(label: _AttData.riskWhy(sid), tone: rb == 2 ? 2 : rb == 1 ? 3 : 1),
                        StatusChip(label: _AttData.riskAction(sid), tone: rb == 2 ? 2 : rb == 1 ? 3 : 1),
                        for (final p in _AttData.patterns(sid).entries) StatusChip(label: '${p.key} (${p.value})', tone: 3),
                      ]),
                    ])),
                  ]),
                  if (reasons.isNotEmpty) ...[
                    _gap(12),
                    const Text('חיסורים לפי סיבה', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                    _gap(6),
                    NeonBars(labels: [for (final e in reasons) '${e[0]}'], values: [for (final e in reasons) (e[1] as int).toDouble()], tone: 3),
                  ],
                  _gap(12),
                  Text('השלמות · ${pend.length}', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  _gap(6),
                  if (pend.isEmpty)
                    const Align(alignment: Alignment.centerRight, child: StatusChip(label: 'אין השלמות ממתינות', tone: 1))
                  else
                    for (final p in pend)
                      TimelineItem(title: p['makeupDate'] == null ? '🔁 ממתין לתזמון' : '📅 מתוזמן ל-${fmtDate(p['makeupDate'] as String)}', time: fmtDate(p['date'] as String), body: '${p['reason'] ?? ''}'),
                  _gap(12),
                  // קשר-הורה: לולאה גנרית על metaFields (מקום-שמור) — שדה מואר רק כשקיים
                  const Text('קשר-הורה', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  _gap(6),
                  if (parent == null)
                    const AlertBanner(glyph: '👪', tone: 3, message: 'אין קשר-הורה מוזרק (בלוק-הצבה) — הודעות לא יישלחו')
                  else
                    Wrap(spacing: 8, runSpacing: 6, children: [
                      for (final f in _AttData.metaFields)
                        if (parent[f['key']] != null) StatusChip(label: '${f['prefix']}${parent[f['key']]}${f['suffix']}', tone: 0),
                      if (m != null) StatusChip(label: m['parentOk'] == true ? 'אישור-הורה ✓' : 'ללא אישור-הורה', tone: m['parentOk'] == true ? 1 : 3),
                    ]),
                  _gap(12),
                  Text('הערות · ${(_AttData.notes[sid] ?? const []).length}', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                  _gap(6),
                  for (final n in _AttData.notes[sid] ?? const <String>[]) TimelineItem(title: n, time: '${fmtDate(_Placement.today)} ${_Placement.nowHm}'),
                  _gap(12),
                  const Text('פעולות-מהירות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                  _gap(8),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    SoftButton(label: '⛔ סמן-חיסור', tone: 2, onTap: () => act(() => _mark(sid, 'absent'))),
                    SoftButton(label: '⏰ סמן-איחור', tone: 3, onTap: () => act(() => _mark(sid, 'late'))),
                    SoftButton(label: '🚪 סמן-שחרור', tone: 0, onTap: () => act(() => _mark(sid, 'released'))),
                    if (m != null) SoftButton(label: '↩ בטל', tone: 0, onTap: () => act(() => _mark(sid, 'present'))),
                    if (m != null && m['justified'] != true) SoftButton(label: '✔ סמן-מוצדק', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'justified': true}))),
                    if (m != null) SoftButton(label: '📎 צרף-אישור', tone: 0, onTap: () => act(() => _notice = 'צרף-אישור: שקע-קובץ (medicalDoc) לא מחובר בהצבה — מקום-שמור')),
                    if (m != null && m['status'] == 'absent' && elig!['eligible'] == true && m['makeupDate'] == null)
                      SoftButton(label: '📅 תזמן-השלמה', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'makeup': true, 'makeupDate': _AttData.nextSchoolDay(_Placement.today)}))),
                    if (m != null && m['makeupDate'] != null) SoftButton(label: '✅ השלמה-בוצעה', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'makeup': false, 'makeupDone': true}))),
                    if (m != null && m['parentOk'] != true && parent != null) SoftButton(label: '📨 הודעה-להורה', tone: 0, onTap: () => act(() => _notice = 'הודעה ל-${parent['name']} (${parent['phone']}) נרשמה בתור — שקע-שליחה (מודול-הורים) מקום-שמור')),
                    SoftButton(label: '📝 הוסף-הערה', tone: 0, onTap: () => act(() => (_AttData.notes[sid] ??= []).insert(0, 'הערה ${(_AttData.notes[sid]?.length ?? 0) + 1} · ${_AttData.riskWhy(sid)}'))),
                  ]),
                  if (m != null && m['status'] == 'absent') ...[
                    _gap(10),
                    if (elig!['eligible'] != true) const AlertBanner(glyph: '🔁', tone: 3, message: 'לא-זכאי להשלמה (חיסור לא-מוצדק = no-show · makeupEligibility)'),
                    DsEnumField(label: 'סיבה (מובנית)', options: _AttData.reasons, value: '${m['reason'] ?? ''}', onChanged: (v) => act(() => _AttData.patch(_date, _lessonN, sid, {'reason': v}))),
                  ],
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  void _mark(String sid, String status) {
    final ok = _AttData.mark(_date, _lessonN, sid, status);
    _notice = ok ? null : 'רישום-כפול חסום (אידמפוטנטי): ${_AttData.studentById(sid)['name']} כבר ${_AttData.statusLabel[status]} בשיעור $_lessonN';
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
}
