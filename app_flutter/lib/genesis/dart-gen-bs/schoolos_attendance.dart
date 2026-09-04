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
import '../dart-ui-bs/ds/ds_search.dart'; // חיפוש-מבוקר (value+onChanged) — פעולת-יסוד "איתור"
import '../dart-ui-bs/ds/ds_calendar.dart'; // לוח-חודש עם תפר-דאטה אמיתי (ספירת-חיסורים פר-יום) — טאב "חודש"
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר (חריגה)
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
import '../dart-maor/date-in-range.dart'; // מנוע-מדף: ISO בטווח כוללני (היסטוריה/דוח)
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND (מדף)
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM (מדף)
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא (חוסם CSV-injection) (מדף)
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע (מדף)
import '../dart-maor/guard-export.dart'; // ייצוא: שומר-סף עם notify (מדף)
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל admin/teacher/staff (מדף)
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה פר-מפתח (מדף)
import '../dart-maor/intel-trend-from-scan.dart'; // מנוע-מדף: מגמה מרשימה-חודשית {dir,pct}
import '../dart-maor/fmt-date.dart'; // מנוע-מדף: ISO ⇒ dd/mm/yyyy
import '../dart-maor/month-key.dart'; // מנוע-מדף: ISO ⇒ YYYY-MM
import '../dart-maor/week-day-names.dart'; // דאטה-מדף: שמות-ימים (ראשון..שבת)
import '../dart-maor/time-to-min.dart'; // מנוע-מדף: 'HH:MM' ⇒ דקות (איחור · שיעור-נוכחי)
import '../dart-maor/holiday-of.dart'; // מנוע-מדף: שם-חג לתאריך (לוח-עברי)
import '../dart-maor/upcoming-holidays.dart'; // מנוע-מדף: חגים-קרובים בחלון-ימים (סנכרון-לוח מקדים)
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
  static const lockHm = '16:00'; // נעילה-אוטומטית סוף-יום
  static const remindHm = '10:00'; // תזכורת "לא-נרשם-היום" למורה בשעה-X
  static const responseWindowDays = 2; // חלון-תגובה להורה אחרי הודעה-אוטו (ימים)
  static const groupAbsenceMin = 2; // חיסור-קבוצתי: לפחות N חסרים וגם ≥ חצי-כיתה ⇒ אירוע?
  static const thresholdWarnPct = 5; // התרעה-מקדימה: עד N% מעל הסף-הרגולטורי
  // 6 זהויות-דמו מוזרקות (חוק-6 · לא אטום): תפקיד ⇐ roleOf(config,email) · פעולה ⇐ canGrantedAction(features)
  //   scope: classes (null=הכל) · window (ימים סביב היום שמותר לערוך; 0=היום בלבד) · child (הורה)
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👩‍🏫 מורה', 'id': 't1', 'email': 'teacher1@school', 'classes': ['y1'], 'window': 1, 'config': {'roles': {'teachers': {'teacher1@school': true}}, 'features': {'att.mark': true, 'att.notify': true, 'att.makeup': true, 'att.export': true}}},
    {'label': '🔄 מחליף', 'id': 'sub1', 'email': 'sub@school', 'classes': ['y2'], 'window': 0, 'config': {'features': {'att.mark': true}}},
    {'label': '🧭 רכז/ת', 'id': 'coord', 'email': 'coord@school', 'classes': null, 'window': 365, 'config': {'features': {'att.mark': true, 'att.back': true, 'att.justify': true, 'att.unlock': true, 'att.lock': true, 'att.makeup': true, 'att.notify': true, 'att.export': true, 'att.audit': true}}},
    {'label': '👑 הנהלה', 'id': 'mgmt', 'email': 'mgr@school', 'classes': null, 'window': 365, 'config': {'adminEmails': ['mgr@school']}}, // admin ⇒ הכל
    {'label': '👪 הורה', 'id': 'parent-s1', 'email': 'parent1@home', 'child': 's1', 'window': 0, 'config': {'features': {'att.parentOk': true}}},
    {'label': '👁 צפייה', 'id': 'viewer', 'email': 'view@school', 'classes': null, 'window': 0, 'config': <String, dynamic>{}},
  ];
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
    // ח׳-2 · 25/8 — כל הכיתה חסרה (2/2) ⇒ זיהוי-חיסור-קבוצתי (אירוע: טיול)
    {'date': '2026-08-25', 'lesson': 1, 'sid': 's11', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'parentOk': true, 'by': 't3', 'at': '2026-08-25T08:05'},
    {'date': '2026-08-25', 'lesson': 1, 'sid': 's12', 'status': 'absent', 'reason': 'טיול', 'justified': true, 'parentOk': true, 'by': 't3', 'at': '2026-08-25T08:05'},
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
    audit.insert(0, {'at': '${_Placement.today}T${_Placement.nowHm}', 'seq': _seq, 'by': _AttData.recorder, 'action': action, 'key': key});
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
    if (!canMarkOn(date)) return false; // יום-נעול / מחוץ-לחלון / אין-הרשאה ⇒ חסום (המסך מדווח why)
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
        'by': _AttData.recorder, 'at': '${_Placement.today}T${_Placement.nowHm}',
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
    _overrides[keyOf(date, lesson, sid)] = {...cur, ...fields, 'by': _AttData.recorder, 'at': '${_Placement.today}T${_Placement.nowHm}'};
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

  // ═══ הרשאות-פר-תפקיד (חוק-6 · הכרעה 23-ג) = roleOf ⊕ canGrantedAction — 6 תפקידים ═══
  static int role = 0; // אינדקס-תפקיד נבחר (בורר מדגים גידור)
  static String recorder = 't1'; // זהות-הרושם (אודיט "מי-רשם") — נגזרת מהתפקיד הנבחר
  static Map<String, dynamic> get roleDef => _Placement.roleDefs[role];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(String key) => canGrantedAction((roleDef['config'] as Map).cast<String, dynamic>(), roleDef['email'] as String, false, key, _isAdmin);
  static String get roleName => roleOf((roleDef['config'] as Map).cast<String, dynamic>(), roleDef['email'] as String);
  static void setRole(int i) {
    role = i;
    recorder = roleDef['id'] as String;
  }
  // כיתות-בהיקף: מורה=כיתותיו · מחליף=כיתה-מוקצית · הורה=כיתת-ילדו · רכז/הנהלה/צפייה=הכל
  static List<Map<String, dynamic>> get visibleClasses {
    final child = roleDef['child'] as String?;
    if (child != null) return classes.where((c) => c['id'] == studentById(child)['cls']).toList();
    final cs = roleDef['classes'] as List?;
    return cs == null ? classes : classes.where((c) => cs.contains(c['id'])).toList();
  }
  // תלמידים-בהיקף: הורה רואה רק את ילדו
  static List<Map<String, dynamic>> visibleStudents(String cls) {
    final child = roleDef['child'] as String?;
    return child == null ? studentsOf(cls) : studentsOf(cls).where((s) => s['id'] == child).toList();
  }
  // חלון-עריכה: |date−today| ≤ window (dayDiff מהמדף) — מורה היום±1, מחליף היום, רכז אחורה
  static bool inWindow(String date) => dayDiff(date, _Placement.today).abs() <= (roleDef['window'] as int? ?? 0);
  static bool canMarkOn(String date) => can('att.mark') && inWindow(date) && !isLocked(date);
  static String? whyCannot(String date) => !can('att.mark') ? 'אין הרשאת-רישום לתפקיד $roleName' : isLocked(date) ? 'יום-נעול — רק רכז/ת פותח/ת' : !inWindow(date) ? 'מחוץ לחלון-העריכה (היום±${roleDef['window']}) — אין עריכה-לאחור' : null;

  // ═══ נעילת-יום (מצב-מיוחד): ידנית (רכז/הנהלה) · אוטומטית סוף-יום (nowHm ≥ lockHm) ═══
  static final Set<String> _locked = {};
  static final Set<String> _unlocked = {}; // פתיחה-מפורשת של רכז גוברת על נעילה-אוטו
  static bool autoLocked(String date) => date.compareTo(_Placement.today) < 0 || (date == _Placement.today && (timeToMin(_Placement.nowHm) as num) >= (timeToMin(_Placement.lockHm) as num));
  static bool isLocked(String date) => !_unlocked.contains(date) && (_locked.contains(date) || (autoLocked(date) && date != _Placement.today && !can('att.back')));
  static void lockDay(String date) { _locked.add(date); _unlocked.remove(date); _log('lock', date); }
  static void unlockDay(String date) { _unlocked.add(date); _locked.remove(date); _log('unlock', date); }

  // ═══ איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — לא .contains שטוח ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> s) => ['${s['name']}', '${s['num']}', className(s['cls'] as String), '${_Placement.parents[s['id']]?['name'] ?? ''}'];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> items, String q) =>
      (smartFilter(q, items, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה (הכרעה 23-ג) = FilterChipPill ⊕ finderMatches — 10 צירי-נעילה (המפרט: סטטוס·מוצדק·בסיכון·רצף·אישור·השלמה·הגעה) ═══
  static const filterDefs = <Map<String, String>>[
    {'axis': '', 'label': 'הכל'},
    {'axis': 'absent', 'label': '⛔ חסרים'},
    {'axis': 'late', 'label': '⏰ מאחרים'},
    {'axis': 'released', 'label': '🚪 שוחררו'},
    {'axis': 'unjust', 'label': '❔ לא-מוצדק'},
    {'axis': 'just', 'label': '✔ מוצדק'},
    {'axis': 'risk', 'label': '🚨 בסיכון'},
    {'axis': 'streak', 'label': '🔗 רצף≥${_Placement.streakAlert}'},
    {'axis': 'noParent', 'label': '👪 ללא-אישור'},
    {'axis': 'makeup', 'label': '🔁 השלמה-ממתינה'},
    {'axis': 'lateArr', 'label': '🕒 הגעה>${_Placement.lateWindowMin}׳'},
  ];
  static String _axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) {
    final s = f as Map<String, dynamic>;
    final sid = s['id'] as String, date = db['date'] as String;
    final ms = marksOn(date, sid);
    switch (axis) {
      case 'absent': case 'late': case 'released': return dayStatus(date, sid) == axis ? '1' : '0';
      case 'unjust': return ms.any(unjustified) ? '1' : '0';
      case 'just': return ms.any((m) => m['status'] == 'absent' && m['justified'] == true) ? '1' : '0';
      case 'risk': return riskBand(sid) > 0 ? '1' : '0';
      case 'streak': return streak(sid) >= _Placement.streakAlert ? '1' : '0';
      case 'noParent': return ms.any((m) => unjustified(m) && m['parentOk'] != true) ? '1' : '0';
      case 'makeup': return pendingMakeupsOf(sid).isNotEmpty ? '1' : '0';
      case 'lateArr': return ms.any(isLate) ? '1' : '0';
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> items, String date, int chip) {
    final axis = filterDefs[chip]['axis']!;
    final locks = axis.isEmpty ? <dynamic, dynamic>{} : <dynamic, dynamic>{axis: '1'};
    return finderMatches({'families': items, 'date': date}, locks, _axisValue).cast<Map<String, dynamic>>();
  }

  // ═══ ייצוא (23-ג) = toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport — שורות מהחוזה-עמודות ═══
  static List<List<Object?>> csvRows(List<Map<String, dynamic>> rows, String date) {
    final cols = [for (final c in columnDefs(date)) if (colShown(c, rows)) c];
    return [
      [for (final c in cols) c['label']],
      for (final s in rows) [for (final c in cols) c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(s) : '${s[c['key']] ?? ''}'],
    ];
  }
  static String csvOf(List<Map<String, dynamic>> rows, String date) => toCsv(csvRows(rows, date), csvEscape) as String;
  static bool get exportOk => exportAllowed(false) && guardExport(!can('att.export'), null);

  // ═══ תקשורת-הורים: תור-הודעות אוטו (חיסור לא-מוצדק ללא-אישור ⇒ הודעה) + שליחות ידניות; שקע-שליחה = מקום-שמור ═══
  static final Set<String> sent = {}; // מפתחות-סימון שנשלחה עליהם הודעה (חלון-תגובה נפתח)
  static final List<Map<String, dynamic>> manualQueue = []; // הודעות-כיתה/ידניות
  static List<Map<String, dynamic>> get notificationQueue => [
        for (final m in marks)
          if (unjustified(m) && m['parentOk'] != true && _Placement.parents[m['sid']] != null)
            {'key': keyOf(m['date'] as String, m['lesson'] as int, m['sid'] as String), 'sid': m['sid'], 'date': m['date'], 'lesson': m['lesson'], 'to': _Placement.parents[m['sid']]!['name'], 'phone': _Placement.parents[m['sid']]!['phone'], 'text': 'חיסור לא-מוצדק בשיעור ${m['lesson']} ב-${fmtDate(m['date'] as String)} — נא לאשר/לנמק', 'auto': true},
        ...manualQueue,
      ];
  static void send(String key) { sent.add(key); _log('notify', key); }
  static void notifyClass(String cls, String text) {
    for (final s in studentsOf(cls)) {
      final p = _Placement.parents[s['id']];
      if (p != null) manualQueue.insert(0, {'key': 'cls|$cls|${s['id']}|${manualQueue.length}', 'sid': s['id'], 'date': _Placement.today, 'lesson': 0, 'to': p['name'], 'phone': p['phone'], 'text': text, 'auto': false});
    }
    _log('notify-class', cls);
  }
  // חיסורים-בטווח (dateInRange מהמדף) — היסטוריה/דוח
  static List<Map<String, dynamic>> marksInRange(String from, String to, {String? cls}) =>
      (marks.where((m) => dateInRange(m['date'] as String, from, to) && (cls == null || studentById(m['sid'] as String)['cls'] == cls)).toList()
        ..sort((a, b) => '${b['date']}${b['lesson']}'.compareTo('${a['date']}${a['lesson']}')));

  // ═══ אוטומציות-חכמות (פעולה-4 "חריגה" + פעולה-5 "הכרעה" · פרואקטיבי — המערכת מתריעה לפני שדבר נשמט) ═══
  // 1) התרעת-רצף: N חיסורים רצופים (streak ⊕ dayDiff)
  static List<Map<String, dynamic>> get streakAlerts => [for (final s in activeStudents) if (streak(s['id'] as String) >= _Placement.streakAlert) s];
  // 2) ניבוי-נשירה: band≥1 עם דפוס (יום/שיעור-קבוע · אחרי-חופשה) — riskParts⊕patterns (countBy)
  static List<Map<String, dynamic>> get dropoutPredictions => [for (final s in activeStudents) if (riskBand(s['id'] as String) > 0) s];
  // 3) חלון-תגובה להורה: הודעה נשלחה ואין אישור אחרי responseWindowDays (dayDiff) ⇒ הסלמה
  static List<Map<String, dynamic>> get expiredResponses => [
        for (final m in marks)
          if (unjustified(m) && m['parentOk'] != true && sent.contains(keyOf(m['date'] as String, m['lesson'] as int, m['sid'] as String)) && dayDiff(m['date'] as String, _Placement.today) > _Placement.responseWindowDays) m,
      ];
  // 4) הצעת-השלמה: חיסור-מוצדק זכאי (makeupEligibility) שטרם תוזמן
  static List<Map<String, dynamic>> get makeupSuggestions => [
        for (final m in marks)
          if (m['status'] == 'absent' && m['justified'] == true && m['makeupDate'] == null && m['makeupDone'] != true && eligibility(m)['eligible'] == true) m,
      ];
  // 6) דוח-שבועי-להנהלה: סימוני 7 הימים האחרונים (dateInRange) בשורות-CSV
  static List<List<Object?>> weeklyRows() => [
        ['תאריך', 'תלמיד', 'כיתה', 'שיעור', 'סטטוס', 'סיבה', 'מוצדק', 'אישור-הורה', 'הגעה', 'רשם/ה'],
        for (final m in marksInRange(shift(_Placement.today, -7), _Placement.today))
          [m['date'], studentById(m['sid'] as String)['name'], className(studentById(m['sid'] as String)['cls'] as String), m['lesson'], statusLabel[m['status']], m['reason'] ?? '', m['justified'] == true ? 'כן' : 'לא', m['parentOk'] == true ? 'כן' : 'לא', m['arrival'] ?? '', m['by']],
      ];
  static String get weeklyCsv => toCsv(weeklyRows(), csvEscape) as String;
  // 7) סף-רגולטורי: מתחת לסף (זכאות/תעודה) · התרעה-מקדימה (עד thresholdWarnPct מעל הסף)
  static List<Map<String, dynamic>> get belowThreshold => [for (final s in activeStudents) if (attendancePct(s) * 100 < _Placement.minAttendancePct) s];
  static List<Map<String, dynamic>> get nearThreshold => [for (final s in activeStudents) if (attendancePct(s) * 100 >= _Placement.minAttendancePct && attendancePct(s) * 100 < _Placement.minAttendancePct + _Placement.thresholdWarnPct) s];
  // 9) זיהוי-חיסור-קבוצתי: ביום-לימודים, כיתה עם ≥ חצי-הרוסטר חסרים (ומינימום N) ⇒ אירוע? (30 ימי-לימודים אחרונים)
  static List<Map<String, dynamic>> get groupAbsences => [
        for (final d in lastSchoolDays(30))
          for (final c in classes)
            if (() {
              final r = studentsOf(c['id'] as String);
              final n = r.where((s) => absentDay(d, s['id'] as String)).length;
              return r.isNotEmpty && n >= _Placement.groupAbsenceMin && n * 2 >= r.length;
            }())
              {'date': d, 'cls': c['id'], 'absent': studentsOf(c['id'] as String).where((s) => absentDay(d, s['id'] as String)).length, 'total': studentsOf(c['id'] as String).length},
      ];
  // 10) סנכרון-לוח מקדים: חגים-קרובים (upcomingHolidays מהמדף על holidayOf) ⇒ ימים שלא ייספרו
  static List<Map<String, dynamic>> get upcoming => upcomingHolidays(_Placement.today, (d) => holidayName(iso(d)), iso, 30);
  // 8) נעילה-אוטומטית: autoLocked (nowHm ≥ lockHm) — מוצג כמצב

  // ═══ שקעי-הצבה · מקום-שמור (חוק-7 · מבחן-הקונכייה): כל יכולת חסרת-נתון = שקע מוצהר, מאיר כשמחובר ═══
  static const reservedSockets = <Map<String, String>>[
    {'key': 'photo', 'label': 'תמונת-תלמיד', 'where': 'students[].photo ⇒ עמודה "תמונה"'},
    {'key': 'medicalDoc', 'label': 'אישור-רפואי (קובץ)', 'where': 'mark.medicalDoc ⇒ עמודה + כפתור "צרף-אישור"'},
    {'key': 'online', 'label': 'נוכחות-מקוונת (היברידי)', 'where': 'mark.online ⇒ עמודה "מקוון"'},
    {'key': 'transportLate', 'label': 'הסעה-איחור', 'where': 'mark.transportLate ⇒ עמודה "איחור-הסעה"'},
    {'key': 'cardIn', 'label': 'ביומטרי/כרטיס-כניסה', 'where': 'mark.cardIn ⇒ עמודה + arrival אוטומטי'},
    {'key': 'gpsIn', 'label': 'GPS-הגעה', 'where': 'mark.gpsIn (מקור: AttendanceDay.inLat/inLng)'},
    {'key': 'riskExternal', 'label': 'ציון-סיכון חיצוני (מודול-תלמידים)', 'where': 'students[].riskExternal ⇒ max(פנימי,חיצוני)'},
    {'key': 'noticeHrs', 'label': 'שעות-הודעה-מראש (ביטול-מוקדם)', 'where': 'mark.noticeHrs ⇒ makeupEligibility rawHrs'},
    {'key': 'notifySink', 'label': 'שקע-שליחה SMS/וואטסאפ (מודול-הורים)', 'where': 'send(key) ⇒ תור בלבד עד חיבור'},
    {'key': 'auditSink', 'label': 'אחסון-אודיט (pushAuditRing/pullAuditRing)', 'where': 'audit[] בזיכרון עד חיבור fs'},
    {'key': 'pdfPrint', 'label': 'PDF/הדפסה', 'where': 'CSV זמין; PDF/מדפסת = שקע'},
    {'key': 'substituteTeacher', 'label': 'מורה-מחליף מוקצה (מודול-מורים)', 'where': 'roleDefs[מחליף].classes מוזרק בהצבה'},
    {'key': 'dashboardCounters', 'label': 'מוני-לוח-הנהלה', 'where': 'KPI getters — המנהל מחווט למסך-הבית'},
    {'key': 'loader', 'label': 'חיבור-אסינק (fetch/Firestore)', 'where': 'AttendanceScreen(loader:) ⇒ טעינה/שגיאה אמיתיות; null ⇒ הדגמה'},
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
  const AttendanceScreen({super.key, this.loader});
  /// שקע-טעינה (חוק-7 · מקום-שמור): חיבור-אסינק אמיתי (fetch/Firestore) מוזרק בהצבה; null ⇒ הדגמת-700ms.
  /// זריקה ⇒ מצב-השגיאה השמור מאיר (AlertBanner); הצלחה ⇒ מתנקה. הבדיקה מזריקה loader-נכשל (§6).
  final Future<void> Function()? loader;
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String _date = _Placement.today; // תאריך-נבחר (בורר-תאריך)
  int _cls = 0; // כיתה-נבחרת (SegmentedSwitch, בהיקף-התפקיד)
  int? _lesson; // שיעור-נבחר (null ⇒ השיעור-הנוכחי)
  int _mode = 0; // 0=📋 גיליון (טאפ-מחזורי) · 1=🗂 טבלה (DsTable כל-העמודות)
  int _tab = 0; // 8 טאבים: היום · חודש · היסטוריה · השלמות · סיבות · הורים · בסיכון · אודיט
  String _q = ''; // חיפוש-איתור (DsSearch→smartFilter)
  int _filter = 0; // צ׳יפ-חריגה (FilterChipPill→finderMatches)
  int _range = 1; // טווח-היסטוריה: 0=7 · 1=30 · 2=90 ימים (dateInRange)
  String? _notice; // הודעת-מערכת אחרונה (רישום-כפול · כולם-נוכחים · שקעים)
  bool _loading = false; // מצב-מסך שמור: טעינה (רענון מדגים; חיבור-אסינק מאיר זהה)
  String? _error; // מצב-מסך שמור: שגיאה (מאיר כש-fetch נכשל; null בזרימה-התקינה)

  int get _lessonN => _lesson ?? _AttData.currentLesson(_date);
  static const _tabs = ['📋 היום', '🗓 חודש', '📜 היסטוריה', '🔁 השלמות', '📊 סיבות', '👪 הורים', '🚨 בסיכון', '🧾 אודיט'];
  static const _rangeDays = [7, 30, 90];

  Widget _fchip(int i) => FilterChipPill(
        label: _AttData.filterDefs[i]['label']!, selected: _filter == i, onTap: () => setState(() => _filter = i),
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15),
        inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );

  @override
  Widget build(BuildContext context) {
    final vClasses = _AttData.visibleClasses;
    if (_cls >= vClasses.length) _cls = 0;
    final cls = vClasses[_cls]['id'] as String;
    final roster = _AttData.visibleStudents(cls);
    final holiday = _AttData.holidayName(_date);
    final lessons = _AttData.lessonsOf(_date);
    final sum = sheetSummary(_AttData.rosterOf(cls), _date) as Map; // {present,total} מהמדף
    final monthPct = _AttData.monthPct;
    final notRec = _AttData.classesNotRecordedToday;
    final lessonIdx = lessons.indexWhere((l) => l['n'] == _lessonN);
    final recorded = lessons.isNotEmpty && _AttData.isRecorded(_date, cls, _lessonN);
    // איתור⊕חריגה (23-ג): search=smartFilter⊕smartScore⊕normSearch · filter=finderMatches — פייפליין אחד לכל הטאבים
    final visible = _AttData.filter(_AttData.search(roster, _q), _date, _filter);
    final locked = _AttData.isLocked(_date);
    final why = _AttData.whyCannot(_date);
    return DsScaffold(
      title: 'נוכחות',
      subtitle: '${_AttData.activeStudents.length} תלמידים · ${_AttData.classes.length} כיתות · ${fmtDate(_Placement.today)} ${_Placement.nowHm}',
      icon: '🗓️',
      children: [
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות פר-תפקיד (roleOf⊕canGrantedAction)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal, reverse: true,
          child: SegmentedSwitch(items: [for (final r in _Placement.roleDefs) r['label'] as String], selected: _AttData.role, onSelect: (i) => setState(() => _AttData.setRole(i))),
        ),
        _gap(10),
        // ── פס-עליון: בורר-תאריך (◀ היום ▶ · שם-יום · חג) + בורר-כיתה (בהיקף) + חיפוש + נעילה ──
        Row(children: [
          SoftButton(label: '◀', tone: 0, onTap: () => setState(() => _date = _AttData.shift(_date, -1))),
          const SizedBox(width: 6),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Text('${dayNames[_AttData.dow(_date)]} · ${fmtDate(_date)}${locked ? ' · 🔒' : ''}', style: const TextStyle(color: _ink, fontSize: 15, fontWeight: FontWeight.w800)),
              Text(holiday != null ? '🕎 $holiday · לא-נספר' : lessons.isEmpty ? 'אין-שיעורים' : '${lessons.length} שיעורים · תפקיד: ${_AttData.roleName}', style: const TextStyle(color: _muted, fontSize: 12)),
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
        Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
          SegmentedSwitch(items: [for (final c in vClasses) c['name'] as String], selected: _cls, onSelect: (i) => setState(() => _cls = i)),
          SoftButton(label: '🔄', tone: 0, onTap: _refresh),
          if (_AttData.can('att.lock') && !locked) SoftButton(label: '🔒 נעל-יום', tone: 3, onTap: () => setState(() => _AttData.lockDay(_date))),
          if (_AttData.can('att.unlock') && locked) SoftButton(label: '🔓 פתח יום-נעול', tone: 1, onTap: () => setState(() => _AttData.unlockDay(_date))),
          if (_AttData.exportOk) SoftButton(label: '⬇ CSV', tone: 0, onTap: () => _openExport(visible)),
          if (_AttData.exportOk) SoftButton(label: '📄 PDF', tone: 0, onTap: () => setState(() => _notice = 'ייצוא-PDF: שקע-מדפסת/PDF לא מחובר בהצבה — מקום-שמור (CSV זמין)')),
          if (_AttData.exportOk) SoftButton(label: '🖨 הדפס-גיליון', tone: 0, onTap: () => setState(() => _notice = 'הדפסה: שקע-מדפסת לא מחובר בהצבה — מקום-שמור')),
          if (_AttData.exportOk && (_AttData.can('att.audit') || _AttData.roleName == 'admin')) SoftButton(label: '📈 דוח-שבועי', tone: 0, onTap: () => _openCsv('דוח-שבועי להנהלה', _AttData.weeklyRows(), _AttData.weeklyCsv)),
        ]),
        _gap(8),
        DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
        Wrap(spacing: 8, runSpacing: 6, children: [for (var i = 0; i < _AttData.filterDefs.length; i++) _fchip(i)]),
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
        // ── מצבי-מסך: הודעה · נעילה · לא-נרשם-היום (התרעה-למורה) ──
        if (_notice != null) ...[AlertBanner(glyph: 'ℹ️', tone: 0, message: _notice!), _gap(8)],
        if (locked) ...[AlertBanner(glyph: '🔒', tone: 3, message: 'יום-נעול (${_AttData._locked.contains(_date) ? 'נעילה-ידנית' : 'נעילה-אוטומטית סוף-יום/עבר'}) — רישום חסום; רכז/ת פותח/ת'), _gap(8)],
        if (why != null && !locked && _tab == 0) ...[AlertBanner(glyph: '🔐', tone: 2, message: 'צפייה-בלבד: $why'), _gap(8)],
        if (_date == _Placement.today && notRec.isNotEmpty && (timeToMin(_Placement.nowHm) as num) >= (timeToMin(_Placement.remindHm) as num)) ...[
          AlertBanner(glyph: '📝', tone: 2, message: 'לא-נרשם-היום (תזכורת ${_Placement.remindHm}): ${notRec.map(_AttData.className).join(' · ')} — שיעור שהתחיל ללא רישום'),
          _gap(8),
        ],
        // ── מרכז-אוטומציות (פרואקטיבי · 23-ג): רק התרעות פעילות — כל אחת = מנוע-מדף ⊕ AlertBanner/StatusChip ──
        ..._automations(cls),
        // ── 8 טאבים (SegmentedSwitch מבוקר, גלילה-אופקית) ──
        SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: SegmentedSwitch(items: _tabs, selected: _tab, onSelect: (i) => setState(() => _tab = i))),
        _gap(10),
        if (_loading)
          _loadingView()
        else if (_error != null)
          AlertBanner(glyph: '⚠️', tone: 2, message: _error!)
        else if (_tab == 1)
          _monthTab(cls)
        else if (_tab == 2)
          _historyTab(cls)
        else if (_tab == 3)
          _makeupsTab(cls)
        else if (_tab == 4)
          _reasonsTab(cls)
        else if (_tab == 5)
          _parentsTab(cls)
        else if (_tab == 6)
          _riskTab(visible)
        else if (_tab == 7)
          _auditTab()
        else if (holiday != null)
          AlertBanner(glyph: '🕎', tone: 3, message: '$holiday — יום-חופש: היום לא נספר בנוכחות (סנכרון-לוח)')
        else if (lessons.isEmpty)
          const EmptyState(glyph: '📭', message: 'אין-שיעורים ביום זה (שבת)')
        else ...[
          // ── בורר-שיעור (פר-שיעור, לא פר-יום) + מבט + רישום-מרוכז ──
          // בורר-שיעור בגלילה-אופקית (תוקן ברנדר-בדיקה: 5 שיעורים גלשו ב-800px בפונט-רחב ⇒ במובייל ודאי)
          SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: SegmentedSwitch(items: [for (final l in lessons) '${l['n']} · ${l['time']}'], selected: lessonIdx < 0 ? 0 : lessonIdx, onSelect: (i) => setState(() => _lesson = lessons[i]['n'] as int))),
          _gap(8),
          Align(alignment: Alignment.centerRight, child: SegmentedSwitch(items: const ['📋 גיליון', '🗂 טבלה'], selected: _mode, onSelect: (i) => setState(() => _mode = i))),
          _gap(8),
          Wrap(spacing: 8, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
            StatusChip(label: '${lessons[lessonIdx < 0 ? 0 : lessonIdx]['subject']} · ${recorded ? 'נרשם' : 'טרם-נרשם'}', tone: recorded ? 1 : 3),
            if (_AttData.canMarkOn(_date))
              SoftButton(label: '✅ כולם-נוכחים', tone: 1, onTap: () => setState(() {
                final n = _AttData.allPresent(_date, cls, _lessonN);
                _notice = 'שיעור $_lessonN · ${_AttData.className(cls)}: נרשם "כולם נוכחים" ($n סימונים אופסו)';
              })),
            if (_AttData.can('att.notify')) SoftButton(label: '📣 הודעה-לכיתה', tone: 0, onTap: () => setState(() { _AttData.notifyClass(cls, 'הודעה מהמחנך/ת ל-${_AttData.className(cls)} · ${fmtDate(_date)}'); _notice = 'הודעה-לכיתה נרשמה בתור ל-${_AttData.studentsOf(cls).where((s) => _Placement.parents[s['id']] != null).length} הורים (שקע-שליחה: מקום-שמור)'; })),
          ]),
          _gap(8),
          if (roster.isEmpty)
            const EmptyState(glyph: '🏫', message: 'כיתה ריקה — אין תלמידים פעילים')
          else if (visible.isEmpty)
            const EmptyState(glyph: '🔍', message: 'אין תלמידים תואמים לחיפוש/סינון')
          else if (_mode == 1)
            DsSection(title: '🗂 טבלה · ${_AttData.className(cls)} · ${fmtDate(_date)} · ${visible.length}', children: [_table(visible)])
          else
            DsSection(
              title: '📋 ${_AttData.className(cls)} · שיעור $_lessonN · ${sum['present']}/${sum['total']} נוכחים-היום',
              children: [for (final s in visible) _row(s)],
            ),
          // מצב-מיוחד: תלמידים לא-פעילים (StatusChip תג, אפס-פעולות) — מחוץ לתפעול/KPI
          if (_AttData.students.any((s) => s['cls'] == cls && !_AttData.activeOf(s)) && _AttData.roleDef['child'] == null) ...[
            _gap(6),
            DsSection(title: '🚫 לא-פעילים', tone: 0, children: [
              for (final s in _AttData.students.where((s) => s['cls'] == cls && !_AttData.activeOf(s)))
                Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
                  Expanded(child: MediaRow(glyph: '🚫', title: s['name'] as String, subtitle: 'מס׳ ${s['num']} · עזב/ה — לא נספר בנוכחות')),
                  const SizedBox(width: 8),
                  const StatusChip(label: 'לא-פעיל', tone: 0),
                ])),
            ]),
          ],
        ],
      ],
    );
  }

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה)
  void _refresh() {
    setState(() { _loading = true; _error = null; });
    final load = widget.loader ?? () => Future<void>.delayed(const Duration(milliseconds: 700));
    load().then((_) { if (mounted) setState(() => _loading = false); }, onError: (Object e) {
      if (mounted) setState(() { _loading = false; _error = 'שגיאת-טעינה: $e — הנתונים המוצגים הם האחרונים שנטענו; נסה/י רענון'; });
    });
  }
  Widget _loadingView() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc),
          SizedBox(height: 14),
          Text('טוען נוכחות…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  // שורת-תלמיד (גיליון): זהות (MediaRow) ⊕ מצב-בשיעור (StatusChip/SoftButton-cycle) ⊕ פאנל (שברון)
  //   הטאפ-המחזורי: נוכח→חסר→איחור→שחרור→נוכח (מודל-הפוך: "נוכח" = מחיקת-הסימון). אידמפוטנטי. מגודר-הרשאה.
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
        if (_AttData.canMarkOn(_date))
          SoftButton(label: _AttData.statusLabel[st]!, tone: _AttData.statusTone[st]!, onTap: () => setState(() => _AttData.cycle(_date, _lessonN, sid)))
        else
          StatusChip(label: _AttData.statusLabel[st]!, tone: _AttData.statusTone[st]!),
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
        [for (final c in cols) if (c['get'] != null) (c['get'] as String Function(Map<String, dynamic>))(s) else '${s[c['key']] ?? '—'}'],
    ];
    return DsTable(labels: labels, rows: data);
  }

  // 🗓 חודש (לוח-חום): DsCalendar עם תפר-דאטה אמיתי — רשומה=חיסור, התא סופר חיסורים-פר-יום · חגים כרשומות-לוח
  Widget _monthTab(String cls) {
    final recs = <Map<String, String>>[
      for (final m in _AttData.marks)
        if (_AttData.studentById(m['sid'] as String)['cls'] == cls && m['status'] == 'absent') {'date': m['date'] as String, 'title': _AttData.studentById(m['sid'] as String)['name'] as String},
    ];
    final days = _AttData.schoolDaysInMonth(_date);
    final hols = [for (var i = 1; i <= 31; i++) if (DateTime.parse('${monthKey(_date)}-01T12:00:00').add(Duration(days: i - 1)).month == int.parse(_date.substring(5, 7))) _AttData.shift('${monthKey(_date)}-01', i - 1)].where((d) => _AttData.holidayName(d) != null).toList();
    return DsSection(title: '🗓 ${_AttData.className(cls)} · ${recs.length} חיסורים החודש · ${days.length} ימי-לימודים', children: [
      DsCalendar(records: recs, dateOf: (r) => r['date']!, titleOf: (r) => r['title']!),
      _gap(8),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final d in hols) StatusChip(label: '🕎 ${fmtDate(d)} ${_AttData.holidayName(d)} · לא-נספר', tone: 3),
        if (hols.isEmpty) const StatusChip(label: 'אין חגים החודש', tone: 1),
      ]),
    ]);
  }

  // 📜 היסטוריה: סימונים-בטווח (dateInRange) · TimelineItem פר-סימון (מי-רשם+מתי = אודיט-שדה)
  Widget _historyTab(String cls) {
    final from = _AttData.shift(_Placement.today, -_rangeDays[_range]);
    final rows = _AttData.marksInRange(from, _Placement.today, cls: cls);
    return DsSection(
      title: '📜 היסטוריה · ${_AttData.className(cls)} · ${rows.length} סימונים',
      trailing: SegmentedSwitch(items: const ['7 י׳', '30 י׳', '90 י׳'], selected: _range, onSelect: (i) => setState(() => _range = i)),
      children: [
        if (rows.isEmpty) const EmptyState(glyph: '📜', message: 'אין סימונים בטווח') else
          for (final m in rows)
            TimelineItem(
              title: '${_AttData.statusLabel[m['status']]} · ${_AttData.studentById(m['sid'] as String)['name']} · שיעור ${m['lesson']}',
              time: '${fmtDate(m['date'] as String)}${m['arrival'] != null ? ' ${m['arrival']}' : ''}',
              body: '${m['reason'] ?? ''}${m['justified'] == true ? ' · מוצדק' : ''}${m['parentOk'] == true ? ' · אישור-הורה' : ''} · רשם/ה ${m['by']} ב-${(m['at'] as String).replaceFirst('T', ' ')}',
            ),
      ],
    );
  }

  // 🔁 השלמות: pendingMakeups (לא-מתוזמנות קודם) ⊕ makeupEligibility · תזמון/בוצע מגודר-הרשאה
  Widget _makeupsTab(String cls) {
    final pend = _AttData.pendingMakeupList.where((p) => p['courseId'] == cls).toList();
    return DsSection(title: '🔁 השלמות · ${_AttData.className(cls)} · ${pend.length} ממתינות', children: [
      if (pend.isEmpty) const EmptyState(glyph: '🔁', message: 'אין השלמות ממתינות') else
        for (final p in pend)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: TimelineItem(title: '${_AttData.studentById(p['memberId'] as String)['name']} · ${p['makeupDate'] == null ? 'ממתין לתזמון' : 'מתוזמן ${fmtDate(p['makeupDate'] as String)}'}', time: fmtDate(p['date'] as String), body: '${p['reason'] ?? ''}')),
            if (_AttData.can('att.makeup') && p['makeupDate'] == null)
              SoftButton(label: '📅 תזמן', tone: 1, onTap: () => setState(() => _patchAbsence(p, {'makeupDate': _AttData.nextSchoolDay(_Placement.today)}))),
            if (_AttData.can('att.makeup') && p['makeupDate'] != null)
              SoftButton(label: '✅ בוצע', tone: 1, onTap: () => setState(() => _patchAbsence(p, {'makeup': false, 'makeupDone': true}))),
          ])),
    ]);
  }
  void _patchAbsence(Map<String, Object?> p, Map<String, dynamic> fields) {
    final date = p['date'] as String, sid = p['memberId'] as String;
    for (final m in _AttData.marksOn(date, sid)) {
      if (m['status'] == 'absent' && m['makeup'] == true) {
        final saved = _AttData.role; _AttData.setRole(2); // רכז: השלמה מותרת גם לאחור (חלון-365)
        _AttData.patch(date, m['lesson'] as int, sid, fields);
        _AttData.setRole(saved);
        break;
      }
    }
  }

  // 📊 סיבות (פילוח): countBy על חיסורי-הכיתה החודש ⇒ NeonBars · מוצדק/לא ⇒ BareStat×2
  Widget _reasonsTab(String cls) {
    final abs = _AttData.marks.where((m) => m['status'] == 'absent' && _AttData.studentById(m['sid'] as String)['cls'] == cls && monthKey(m['date'] as String) == monthKey(_date)).toList();
    final by = countBy(abs, (m) => '${(m as Map)['reason'] ?? 'אחר'}');
    final just = abs.where((m) => m['justified'] == true).length;
    return DsSection(title: '📊 סיבות · ${_AttData.className(cls)} · ${abs.length} חיסורים החודש', children: [
      Row(children: [
        BareStat(value: '$just', label: '✔ מוצדקים', inkColor: _ok, mutedColor: _muted),
        BareStat(value: '${abs.length - just}', label: '❔ לא-מוצדקים', inkColor: abs.length - just > 0 ? _danger : _ok, mutedColor: _muted),
        BareStat(value: '${by.length}', label: '🗂 סיבות-שונות', inkColor: _ink, mutedColor: _muted),
      ]),
      _gap(10),
      if (by.isEmpty) const EmptyState(glyph: '📊', message: 'אין חיסורים החודש') else NeonBars(labels: [for (final e in by) '${e[0]}'], values: [for (final e in by) (e[1] as int).toDouble()], tone: 3),
    ]);
  }

  // 👪 תקשורת-הורים: תור-אוטו (חיסור לא-מוצדק ללא-אישור) + ידני · שליחה מגודרת · הורה מאשר-חיסור
  Widget _parentsTab(String cls) {
    final q = _AttData.notificationQueue.where((n) => _AttData.studentById(n['sid'] as String)['cls'] == cls && (_AttData.roleDef['child'] == null || n['sid'] == _AttData.roleDef['child'])).toList();
    return DsSection(title: '👪 תקשורת-הורים · ${q.length} הודעות · ${q.where((n) => _AttData.sent.contains(n['key'])).length} נשלחו', children: [
      const AlertBanner(glyph: '📨', tone: 0, message: 'שקע-שליחה (מודול-הורים · SMS/וואטסאפ) לא מחובר בהצבה — ההודעות מנוהלות בתור (מקום-שמור)'),
      _gap(8),
      if (q.isEmpty) const EmptyState(glyph: '👪', message: 'אין הודעות ממתינות') else
        for (final n in q)
          Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
            Expanded(child: TimelineItem(title: '${n['auto'] == true ? '🤖 אוטו' : '✍️ ידני'} · ${n['to']} (${n['phone']})', time: fmtDate(n['date'] as String), body: '${n['text']}')),
            if (_AttData.sent.contains(n['key'])) const StatusChip(label: 'נשלח · חלון-תגובה', tone: 1)
            else if (_AttData.can('att.notify')) SoftButton(label: '📨 שלח', tone: 0, onTap: () => setState(() => _AttData.send(n['key'] as String))),
            if (_AttData.can('att.parentOk') && n['lesson'] != 0) SoftButton(label: '✔ אשר-חיסור', tone: 1, onTap: () => setState(() { final saved = _AttData.role; _AttData.setRole(2); _AttData.patch(n['date'] as String, n['lesson'] as int, n['sid'] as String, {'parentOk': true}); _AttData.setRole(saved); })),
          ])),
    ]);
  }

  // 🚨 בסיכון (טריאז'): קיבוץ-פר-band (DsSection tone) · StatRow ציון · StatusChip אות+התערבות (חיבור-מודלים)
  Widget _riskTab(List<Map<String, dynamic>> rows) {
    final ranked = [...rows]..sort((a, b) => _AttData.risk(b['id'] as String).compareTo(_AttData.risk(a['id'] as String)));
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: []};
    for (final s in ranked) {
      buckets[_AttData.riskBand(s['id'] as String)]!.add(s);
    }
    const title = {2: '🔴 בסיכון-נשירה', 1: '🟠 מעקב', 0: '🟢 תקין'};
    const tone = {2: 2, 1: 3, 0: 1};
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final b in const [2, 1, 0])
        if (buckets[b]!.isNotEmpty)
          DsSection(title: '${title[b]} · ${buckets[b]!.length}', tone: tone[b]!, children: [
            for (final s in buckets[b]!)
              Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                StatRow(label: '${s['name']} · ${_AttData.className(s['cls'] as String)}', value: 'סיכון ${_AttData.risk(s['id'] as String)}', fraction: _AttData.risk(s['id'] as String) / 100),
                if (b > 0)
                  Padding(padding: const EdgeInsets.only(top: 6, right: 4), child: Wrap(spacing: 8, runSpacing: 6, children: [
                    StatusChip(label: _AttData.riskWhy(s['id'] as String), tone: tone[b]!),
                    StatusChip(label: _AttData.riskAction(s['id'] as String), tone: tone[b]!),
                    for (final p in _AttData.patterns(s['id'] as String).entries) StatusChip(label: '${p.key} (${p.value})', tone: 3),
                    if ((s['riskExternal'] as int?) != null) StatusChip(label: 'ציון-חיצוני ${s['riskExternal']}', tone: 0), // מקום-שמור (מודול-תלמידים)
                  ])),
              ])),
          ]),
    ]);
  }

  // 🧾 אודיט-רישום: פעולות-הסשן (audit) + סימוני-הבסיס (by/at) — TimelineItem · מגודר att.audit
  Widget _auditTab() {
    if (!_AttData.can('att.audit')) return const AlertBanner(glyph: '🔒', tone: 2, message: 'אודיט — רכז/ת והנהלה בלבד');
    final base = [..._AttData.baseMarks]..sort((a, b) => '${b['at']}'.compareTo('${a['at']}'));
    return DsSection(title: '🧾 אודיט-רישום · ${_AttData.audit.length} פעולות-סשן · ${base.length} סימוני-בסיס', children: [
      const AlertBanner(glyph: '🗄', tone: 0, message: 'שקע-אחסון (pushAuditRing/pullAuditRing · Firestore) לא מחובר בהצבה — הטבעת בזיכרון (מקום-שמור)'),
      _gap(8),
      for (final a in _AttData.audit) TimelineItem(title: '${a['action']} · ${a['key']}', time: '${(a['at'] as String).replaceFirst('T', ' ')} #${a['seq']}', body: 'רשם/ה ${a['by']}'),
      for (final m in base.take(12)) TimelineItem(title: '${m['status']} · ${_AttData.studentById(m['sid'] as String)['name']} · שיעור ${m['lesson']}', time: '${(m['at'] as String).replaceFirst('T', ' ')}', body: 'רשם/ה ${m['by']}'),
      _gap(12),
      // 🔌 שקעי-הצבה (מקום-שמור · חוק-7): מוצהרים, לא מזויפים — מאירים כשמחובר נתון
      Text('🔌 שקעי-הצבה · ${_AttData.reservedSockets.length} מקומות-שמורים (לא-מחוברים)', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
      _gap(6),
      for (final r in _AttData.reservedSockets) TimelineItem(title: '${r['label']}', time: r['key']!, body: r['where']),
    ]);
  }

  // ═══ מרכז-אוטומציות: 10 אוטומציות-המפרט — כל אחת מנוע-מדף ⊕ AlertBanner (מוצג רק כשפעיל) ═══
  List<Widget> _automations(String cls) {
    // היקף-פרטיות (תוקן ברנדר-הורה): הורה רואה רק את ילדו — גם בהתרעות (אפס שמות של ילדים אחרים)
    final child = _AttData.roleDef['child'] as String?;
    bool inScope(Map<String, dynamic> x) => child == null || (x['id'] ?? x['sid']) == child;
    final streaks = _AttData.streakAlerts.where(inScope).toList(), preds = _AttData.dropoutPredictions.where(inScope).toList(), exp = _AttData.expiredResponses.where(inScope).toList();
    final mk = _AttData.makeupSuggestions.where(inScope).toList(), below = _AttData.belowThreshold.where(inScope).toList(), near = _AttData.nearThreshold.where(inScope).toList();
    final groups = _AttData.groupAbsences.where((g) => child == null || g['cls'] == _AttData.studentById(child)['cls']).toList(), up = _AttData.upcoming;
    final autoLock = _AttData.autoLocked(_Placement.today);
    final out = <Widget>[
      if (streaks.isNotEmpty) AlertBanner(glyph: '🔗', tone: 2, message: 'התרעת-רצף (≥${_Placement.streakAlert}): ${streaks.map((s) => '${s['name']} (${_AttData.streak(s['id'] as String)})').join(' · ')}'),
      if (preds.isNotEmpty) AlertBanner(glyph: '🔮', tone: 2, message: 'ניבוי-נשירה: ${preds.map((s) => '${s['name']} ${_AttData.risk(s['id'] as String)} · ${_AttData.riskWhy(s['id'] as String)}${_AttData.patterns(s['id'] as String).isEmpty ? '' : ' · ${_AttData.patterns(s['id'] as String).keys.join(', ')}'}').join(' | ')}'),
      if (exp.isNotEmpty) AlertBanner(glyph: '⏳', tone: 3, message: 'חלון-תגובה (${_Placement.responseWindowDays} י׳) פג ללא אישור-הורה: ${exp.map((m) => '${_AttData.studentById(m['sid'] as String)['name']} ${fmtDate(m['date'] as String)}').join(' · ')} — הסלמה לרכז/ת'),
      if (mk.isNotEmpty) AlertBanner(glyph: '🔁', tone: 0, message: 'הצעת-השלמה (חיסור-מוצדק זכאי): ${mk.map((m) => '${_AttData.studentById(m['sid'] as String)['name']} ${fmtDate(m['date'] as String)} ש${m['lesson']}').join(' · ')}'),
      if (below.isNotEmpty) AlertBanner(glyph: '⚖️', tone: 2, message: 'מתחת לסף-הרגולטורי ${_Placement.minAttendancePct}%: ${below.map((s) => '${s['name']} ${(_AttData.attendancePct(s) * 100).round()}%').join(' · ')}'),
      if (near.isNotEmpty) AlertBanner(glyph: '⚖️', tone: 3, message: 'התרעה-מקדימה (עד ${_Placement.thresholdWarnPct}% מעל הסף): ${near.map((s) => '${s['name']} ${(_AttData.attendancePct(s) * 100).round()}%').join(' · ')}'),
      if (groups.isNotEmpty) AlertBanner(glyph: '👥', tone: 3, message: 'חיסור-קבוצתי (≥חצי-כיתה): ${groups.map((g) => '${_AttData.className(g['cls'] as String)} ${fmtDate(g['date'] as String)} ${g['absent']}/${g['total']}').join(' · ')} — אירוע? לסמן כלא-נספר'),
      if (up.isNotEmpty) AlertBanner(glyph: '🕎', tone: 0, message: 'סנכרון-לוח (30 י׳): ${up.map((h) => '${fmtDate(h['iso'] as String)} ${h['name']}').join(' · ')} — לא ייספרו'),
      AlertBanner(glyph: autoLock ? '🔒' : '⏰', tone: autoLock ? 3 : 0, message: autoLock ? 'נעילה-אוטומטית סוף-יום פעילה (${_Placement.nowHm} ≥ ${_Placement.lockHm})' : 'נעילה-אוטומטית סוף-יום ב-${_Placement.lockHm} (עכשיו ${_Placement.nowHm})'),
    ];
    return [for (final w in out) ...[w, _gap(8)]];
  }

  // ═══ ייצוא (23-ג) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ guardExport ⊕ GlassCard-preview ═══
  void _openExport(List<Map<String, dynamic>> rows) => _openCsv('ייצוא CSV · נוכחות · ${fmtDate(_date)}', _AttData.csvRows(rows, _date), _AttData.csvOf(rows, _date));
  void _openCsv(String title, List<List<Object?>> rows, String csv) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(padding: const EdgeInsets.all(12), child: GlassCard(
          child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
            MediaRow(glyph: '⬇', title: title, subtitle: '${rows.length - 1} שורות · ${rows.first.length} עמודות'),
            _gap(10),
            const Text('תצוגה מקדימה (BOM + חסימת-הזרקה):', style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
            _gap(8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
              child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6))),
          ]),
        )),
      ),
    );
  }

  // ═══ פאנל תלמיד-נבחר (GlassCard) · פעולת-יסוד "ביצוע"+"הערכה": זהות · סטטוס-היום · פר-שיעור · ציר-30-יום ·
  //   סיבות (NeonBars⊕countBy) · מגמה+סיכון (TrendStat⊕StatRow⊕StatusChip) · השלמות · קשר-הורה · הערות · פעולות (מגודרות) ═══
  void _openPanel(Map<String, dynamic> s) {
    final sid = s['id'] as String;
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
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
          final canMark = _AttData.canMarkOn(_date);
          return DraggableScrollableSheet(
            initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
            builder: (ctx, scroll) => Padding(padding: const EdgeInsets.all(12), child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                AvatarTile(initials: _AttData.initials(s['name'] as String), title: s['name'] as String, subtitle: '${_AttData.className(s['cls'] as String)} · מס׳ ${s['num']} · ${_AttData.summaryOf(s)['statusLabel']}'),
                _gap(10),
                Wrap(spacing: 8, runSpacing: 6, children: [
                  StatusChip(label: 'היום: ${_AttData.statusLabel[_AttData.dayStatus(_date, sid)]}', tone: _AttData.statusTone[_AttData.dayStatus(_date, sid)]!),
                  StatusChip(label: 'שיעור $_lessonN: ${_AttData.statusLabel[st]}', tone: _AttData.statusTone[st]!),
                  if (m?['arrival'] != null) StatusChip(label: 'הגעה ${m!['arrival']} · +${_AttData.lateMinutes(m)}׳', tone: _AttData.isLate(m) ? 3 : 1),
                ]),
                _gap(8),
                // שיעורים-מרובים-ביום (פר-שיעור, לא פר-יום): כפתור פר-שיעור — טאפ מחזורי על אותו שיעור (מגודר)
                Wrap(spacing: 6, runSpacing: 6, children: [
                  for (final l in _AttData.lessonsOf(_date))
                    if (canMark)
                      SoftButton(label: 'ש${l['n']} ${_AttData.statusLabel[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']}', tone: _AttData.statusTone[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']!, onTap: () => act(() => _AttData.cycle(_date, l['n'] as int, sid)))
                    else
                      StatusChip(label: 'ש${l['n']} ${_AttData.statusLabel[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']}', tone: _AttData.statusTone[_AttData.markOf(_date, l['n'] as int, sid)?['status'] as String? ?? 'present']!),
                ]),
                _gap(12),
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
                if (pct * 100 < _Placement.minAttendancePct) ...[_gap(6), AlertBanner(glyph: '⚖️', tone: pct * 100 < _Placement.minAttendancePct - 5 ? 2 : 3, message: 'מתחת לסף-הרגולטורי ${_Placement.minAttendancePct}% (זכאות/תעודה) — התרעה-מקדימה')],
                _gap(8),
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
                if (pend.isEmpty) const Align(alignment: Alignment.centerRight, child: StatusChip(label: 'אין השלמות ממתינות', tone: 1)) else
                  for (final p in pend)
                    TimelineItem(title: p['makeupDate'] == null ? '🔁 ממתין לתזמון' : '📅 מתוזמן ל-${fmtDate(p['makeupDate'] as String)}', time: fmtDate(p['date'] as String), body: '${p['reason'] ?? ''}'),
                _gap(12),
                const Text('קשר-הורה', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                _gap(6),
                if (parent == null)
                  const AlertBanner(glyph: '👪', tone: 3, message: 'אין קשר-הורה מוזרק (בלוק-הצבה) — הודעות לא יישלחו')
                else
                  Wrap(spacing: 8, runSpacing: 6, children: [
                    for (final f in _AttData.metaFields) if (parent[f['key']] != null) StatusChip(label: '${f['prefix']}${parent[f['key']]}${f['suffix']}', tone: 0),
                    if (m != null) StatusChip(label: m['parentOk'] == true ? 'אישור-הורה ✓' : 'ללא אישור-הורה', tone: m['parentOk'] == true ? 1 : 3),
                  ]),
                _gap(12),
                Text('הערות · ${(_AttData.notes[sid] ?? const []).length}', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
                _gap(6),
                for (final n in _AttData.notes[sid] ?? const <String>[]) TimelineItem(title: n, time: '${fmtDate(_Placement.today)} ${_Placement.nowHm}'),
                _gap(12),
                const Text('פעולות-מהירות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                _gap(8),
                Builder(builder: (_) {
                  final acts = <Widget>[
                    if (canMark) SoftButton(label: '⛔ סמן-חיסור', tone: 2, onTap: () => act(() => _mark(sid, 'absent'))),
                    if (canMark) SoftButton(label: '⏰ סמן-איחור', tone: 3, onTap: () => act(() => _mark(sid, 'late'))),
                    if (canMark) SoftButton(label: '🚪 סמן-שחרור', tone: 0, onTap: () => act(() => _mark(sid, 'released'))),
                    if (canMark && m != null) SoftButton(label: '↩ בטל', tone: 0, onTap: () => act(() => _mark(sid, 'present'))),
                    if (_AttData.can('att.justify') && m != null && m['justified'] != true) SoftButton(label: '✔ סמן-מוצדק', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'justified': true}))),
                    if (canMark && m != null) SoftButton(label: '📎 צרף-אישור', tone: 0, onTap: () => act(() => _notice = 'צרף-אישור: שקע-קובץ (medicalDoc) לא מחובר בהצבה — מקום-שמור')),
                    if (_AttData.can('att.makeup') && m != null && m['status'] == 'absent' && elig!['eligible'] == true && m['makeupDate'] == null)
                      SoftButton(label: '📅 תזמן-השלמה', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'makeup': true, 'makeupDate': _AttData.nextSchoolDay(_Placement.today)}))),
                    if (_AttData.can('att.makeup') && m != null && m['makeupDate'] != null) SoftButton(label: '✅ השלמה-בוצעה', tone: 1, onTap: () => act(() => _AttData.patch(_date, _lessonN, sid, {'makeup': false, 'makeupDone': true}))),
                    if (_AttData.can('att.notify') && m != null && m['parentOk'] != true && parent != null) SoftButton(label: '📨 הודעה-להורה', tone: 0, onTap: () => act(() { _AttData.send(_AttData.keyOf(_date, _lessonN, sid)); _notice = 'הודעה ל-${parent['name']} (${parent['phone']}) נרשמה בתור — שקע-שליחה (מודול-הורים) מקום-שמור'; })),
                    if (_AttData.can('att.parentOk') && m != null && m['parentOk'] != true) SoftButton(label: '✔ אשר-חיסור (הורה)', tone: 1, onTap: () => act(() { final saved = _AttData.role; _AttData.setRole(2); _AttData.patch(_date, _lessonN, sid, {'parentOk': true}); _AttData.setRole(saved); })),
                    if (_AttData.can('att.mark') || _AttData.can('att.justify')) SoftButton(label: '📝 הוסף-הערה', tone: 0, onTap: () => act(() => (_AttData.notes[sid] ??= []).insert(0, 'הערה ${(_AttData.notes[sid]?.length ?? 0) + 1} · ${_AttData.riskWhy(sid)}'))),
                  ];
                  return acts.isEmpty ? AlertBanner(message: 'צפייה-בלבד — ${_AttData.whyCannot(_date) ?? 'אין הרשאת-פעולה'}', glyph: '🔒', tone: 2) : Wrap(spacing: 8, runSpacing: 8, children: acts);
                }),
                if (m != null && m['status'] == 'absent') ...[
                  _gap(10),
                  if (elig!['eligible'] != true) const AlertBanner(glyph: '🔁', tone: 3, message: 'לא-זכאי להשלמה (חיסור לא-מוצדק = no-show · makeupEligibility)'),
                  if (canMark) DsEnumField(label: 'סיבה (מובנית)', options: _AttData.reasons, value: '${m['reason'] ?? ''}', onChanged: (v) => act(() => _AttData.patch(_date, _lessonN, sid, {'reason': v}))),
                ],
              ]),
            )),
          );
        },
      ),
    );
  }

  void _mark(String sid, String status) {
    final ok = _AttData.mark(_date, _lessonN, sid, status);
    _notice = ok ? null : (_AttData.whyCannot(_date) ?? 'רישום-כפול חסום (אידמפוטנטי): ${_AttData.studentById(sid)['name']} כבר ${_AttData.statusLabel[status]} בשיעור $_lessonN');
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
}
