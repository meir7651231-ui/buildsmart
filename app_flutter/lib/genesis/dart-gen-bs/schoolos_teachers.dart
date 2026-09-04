// 👩‍🏫 SchoolOS · מורים וצוות (TEACHERS) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד). מפרט: knowledge/SPEC-TEACHERS-FULL-2026-09-04.md
// מטרה: "שכל מורה יהיה במקום הנכון עם עומס נכון — ושהמנהל/ת יראה מי-עמוס-מדי, מי-חסר ומי-צריך-תמיכה לפני שזה פוגע בתלמידים."
// פעולות-יסוד (לא אזורי-מפרט): איתור · הערכת-עומס · זיהוי-חריגה · הכרעה (מחליף-מוצע · דחיפות-מאוחדת) · ביצוע · אימות.
// כל חלקיק-תובנה = כמה אטומים (תצוגה⊕לוגיקה); עובדה (תווית+ערך) = אטום-יחיד. אפס-ציור-ביד · אפס-זיוף (§20-ג) · מקום-שמור (חוק-7).
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart'; // DsScaffold · DsSection · DsTokens · DsChip
import '../dart-ui-bs/ds/ds_search.dart'; // חיפוש-מבוקר (value+onChanged) — פעולת-יסוד "איתור"
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows) — לא DataGrid המזייף
import '../dart-ui-bs/ds/ds_board.dart'; // לוח-שלבים עם תפר-דאטה (stages+records+onMove) — לוח-ההחלפות
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל (child) — כרטיס-מורה-נבחר
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // hero = המטרה (שיעורים-ללא-מורה)
import '../dart-ui-bs/bare_stat.dart'; // עובדה מספרית (פיגמנט מוזרק — חוק-6)
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס (עומס מול חוזה) = בר-מילוי
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // ציר-זמן (היעדרויות · החלפות · אודיט) — לא timeline_flow המזייף
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // השוואת-גדלים (שעות מול חוזה · ביצועי-כיתות)
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/alert_banner.dart';
import '../dart-ui-bs/premium/feedback/empty_state.dart';
import '../dart-ui-bs/premium/actions/soft_button.dart';
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-מבוקר (תפקיד · מיון · טאבים)
import '../dart-ui-bs/premium/showcase/premium_avatar.dart'; // ראשי-תיבות מהשם + נקודת-מצב (נוכח/נעדר/חופשה)
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר
// ── אטומי-לוגיקה (§21 שכבת-הלוגיקה · מאור + בנייה-חכמה) — מחווטים מהמדף, לא inline ──
import '../dart-maor/courses-of-teacher.dart'; // חוגים-של-מורה (Course.teacherId)
import '../dart-maor/sessions-of.dart'; // מפגשים {day,time} של חוג (sessions | weekday+time)
import '../dart-maor/time-to-min.dart'; // "HH:MM"⇒דקות (מיון-מערכת · חלון-זמינות)
import '../dart-maor/min-to-hm.dart'; // דקות⇒"HH:MM"
import '../dart-maor/grand-total.dart'; // Σ-לפי-מפתח (שעות/שבוע)
import '../dart-maor/volunteer-load-hint.dart'; // {count, over} — עומס מול מקסימום (מנוע-העומס)
import '../dart-maor/clamp-scale.dart'; // הצמדה לגבולות (יחס-עומס)
import '../dart-maor/schedule-clash-text.dart'; // התנגשות-לו"ז: מורה פנוי בסלוט? (null=פנוי)
import '../dart-maor/week-day-names.dart'; // dayNames (7)
import '../dart/cert_expiry_status.dart'; // רמזור-תוקף (בנייה-חכמה WorkerCert.statusAt): expired/expiringSoon/valid
import '../dart-maor/intel-day-diff.dart'; // dayDiff(iso, today) — ימים (חוזה-מסתיים · ימים-מאז)
import '../dart-maor/presents-in-month.dart'; // ספירת-תאריכים בחודש-של-today (היעדרויות-החודש · חוזים-פגים-החודש)
import '../dart-maor/age-of.dart'; // שנים-מאז-תאריך (ותק)
import '../dart-maor/fmt-date.dart'; // ISO⇒d/m/y
import '../dart-maor/intel-trend-from-scan.dart'; // trendFromScan({monthly}) ⇒ {dir,pct} — דפוס-היעדרות · מגמת-כיתות
import '../dart-maor/task-overdue.dart'; // החלפה-פתוחה שעבר מועדה
import '../dart-maor/count-by.dart'; // ספירה-לפי-מפתח (תפקיד · מקצוע)
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-עיקרון admin/teacher/staff (זהות מוזרקת — חוק-6)
import '../dart-maor/teacher-id-of.dart'; // הרשאות: מורה ⇒ הכרטיס-שלו בלבד
import '../dart-maor/can-granted-action.dart'; // גידור-פעולה פר-מפתח
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע
import '../dart-maor/absence-reason-chips.dart'; // סיבות-היעדרות (term-מוזרק)
import '../dart-data-maor/absence-reason-chips-terms.dart'; // kTerms — שמות-הסיבות (אטום-דאטה)

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (BareStat/FilterChipPill דורשים הזרקת-צבע — חוק-6: צבע=הצבה, לא ציור)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════ דאטה-אמת + מנוע-טהור (אפס-DOM · today מוזרק · אפס Date.now) ═══════════
// 🔴 סכמת-מורה = רק שדות עם מקור-אמת באימפריה (§20-ג אפס-זיוף):
//   id·name·specialty(⇒subjects)·startDate·notes → maor Teacher (schema-fields.dart:813-921)
//   phone·phone2·email·idNum·address·payRate·payMethod·bank* → maor Teacher — **חוק-6: זהות/קשר/שכר לעולם לא בקובץ**;
//     מקום-שמור בחוזה-העמודות (contact·salary) שמאיר רק כשמוזרק בהצבה.
//   courses: id·name·teacherId·roomId·start·end·weekday·time·sessions → maor Course (schema-fields.dart:360-470)
//   certs {name·issuer·expiry} → בנייה-חכמה WorkerCert (state/worker_certs.dart:25-72) · photo → מקום-שמור
//   attendance {date·inTs·outTs} → בנייה-חכמה AttendanceDay (state/worker_attendance.dart:30) — נוכחות-עצמית
//   קלט-תכנון בית-ספרי (לא נגזרת-מזויפת): role·homeroom·contractHours·contractType·contractEnd·availability·
//     constraints·preferredSub·extraRoles·status·absences{date,reason}·subject(חוג)·cls(חוג)·minutes(חוג).
//   ⛔ ללא-מקור-אמת ⇒ מקום-שמור בלבד (לא מזייפים): הערכות-עמיתים · משוב-תלמידים · תיק-אישי · מסמכים ·
//     ביצועי-כיתות (נוכחות/ציונים — יוזרם ממודולי נוכחות/תלמידים) · תמונה.
class _TeamData {
  static const today = '2026-09-03'; // תאריך-הזרקה דטרמיניסטי (יום-חמישי · weekday 4)
  static const underPct = 70; // סף תת-עומס: שעות < 70% מהחוזה
  static const frequentAbsences = 3; // דפוס: ≥3 היעדרויות ב-4 חודשים או מגמה עולה

  // roster — זהות-תצוגה = שמות-דמו בדויים; בהצבה מוזרק roster אמיתי דרך TeachersScreen(roster:) (חוק-6).
  static const roster = <Map<String, dynamic>>[
    {'id': 't1', 'name': 'יעל ברק', 'role': 'homeroom', 'subjects': ['מתמטיקה'], 'homeroom': ['י-1'], 'contractHours': 24, 'contractType': 'קבוע', 'startDate': '2014-09-01', 'status': 'active',
      'availability': {0: ['08:00', '15:00'], 1: ['08:00', '15:00'], 2: ['08:00', '15:00'], 3: ['08:00', '15:00'], 4: ['08:00', '13:00']}, 'constraints': ['לא-בשישי'], 'preferredSub': 't7', 'extraRoles': ['ריכוז-שכבה י׳'],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2030-06-30'}, {'name': 'עזרה-ראשונה', 'issuer': 'מד״א', 'expiry': '2026-09-20'}],
      'attendance': <Map<String, dynamic>>[], 'absences': [{'date': '2026-09-03', 'reason': 'mchlh'}, {'date': '2026-05-12', 'reason': 'ayrva-mshpchty'}], 'notes': 'מועמדת לריכוז-פדגוגי בתשפ״ז'},
    {'id': 't2', 'name': 'דוד כהן', 'role': 'subject', 'subjects': ['מתמטיקה', 'פיזיקה'], 'homeroom': <String>[], 'contractHours': 20, 'contractType': 'קבוע', 'startDate': '2019-09-01', 'status': 'active',
      'availability': {0: ['08:00', '16:00'], 1: ['08:00', '16:00'], 2: ['08:00', '16:00'], 3: ['08:00', '16:00'], 4: ['08:00', '16:00']}, 'constraints': <String>[], 'preferredSub': 't7', 'extraRoles': <String>[],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2029-08-31'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:41'}], 'absences': [{'date': '2026-09-01', 'reason': 'mchlh'}, {'date': '2026-08-25', 'reason': 'mchlh'}, {'date': '2026-08-18', 'reason': 'nsyah'}, {'date': '2026-07-02', 'reason': 'mchlh'}, {'date': '2026-06-10', 'reason': 'shmchh'}], 'notes': ''},
    {'id': 't3', 'name': 'נועה לוי', 'role': 'subject', 'subjects': ['אנגלית'], 'homeroom': <String>[], 'contractHours': 18, 'contractType': 'זמני', 'contractEnd': '2026-09-25', 'startDate': '2025-09-01', 'status': 'active',
      'availability': {0: ['08:00', '14:00'], 2: ['08:00', '14:00'], 4: ['08:00', '14:00']}, 'constraints': ['לא-בשני-ורביעי'], 'extraRoles': <String>[],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2031-06-30'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:55'}], 'absences': <Map<String, dynamic>>[], 'notes': ''},
    {'id': 't4', 'name': 'אמיר חדד', 'role': 'aide', 'subjects': ['סיוע-לימודי'], 'homeroom': <String>[], 'contractHours': 30, 'contractType': 'קבוע', 'startDate': '2021-09-01', 'status': 'active',
      'availability': {0: ['08:00', '15:00'], 1: ['08:00', '15:00'], 2: ['08:00', '15:00'], 3: ['08:00', '15:00'], 4: ['08:00', '15:00']}, 'constraints': <String>[], 'extraRoles': <String>[],
      'certs': [{'name': 'סייע-פדגוגי', 'issuer': 'משרד החינוך', 'expiry': '2026-05-01'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:50'}], 'absences': [{'date': '2026-08-30', 'reason': 'mzg-avvyr'}], 'notes': ''},
    {'id': 't5', 'name': 'רות אזולאי', 'role': 'homeroom', 'subjects': ['היסטוריה', 'אזרחות'], 'homeroom': ['ט-2'], 'contractHours': 22, 'contractType': 'קבוע', 'startDate': '2010-09-01', 'status': 'active',
      'availability': {0: ['08:00', '15:00'], 1: ['08:00', '15:00'], 2: ['08:00', '15:00'], 3: ['08:00', '15:00'], 4: ['08:00', '15:00']}, 'constraints': <String>[], 'preferredSub': 't1', 'extraRoles': ['יועצת'],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2028-06-30'}, {'name': 'ייעוץ-חינוכי', 'issuer': 'אונ׳ ת״א', 'expiry': '2027-12-31'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:38'}], 'absences': <Map<String, dynamic>>[], 'notes': ''},
    {'id': 't6', 'name': 'מיכל שרון', 'role': 'subject', 'subjects': ['אנגלית'], 'homeroom': <String>[], 'contractHours': 20, 'contractType': 'קבוע', 'startDate': '2017-09-01', 'status': 'leave',
      'availability': <int, List<String>>{}, 'constraints': <String>[], 'extraRoles': <String>[],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2029-06-30'}],
      'attendance': <Map<String, dynamic>>[], 'absences': <Map<String, dynamic>>[], 'notes': 'חופשת-לידה עד 2027-01'},
    {'id': 't7', 'name': 'יוסי מזרחי', 'role': 'mgmt', 'subjects': ['מתמטיקה'], 'homeroom': <String>[], 'contractHours': 8, 'contractType': 'קבוע', 'startDate': '2008-09-01', 'status': 'active',
      'availability': {0: ['07:30', '16:00'], 1: ['07:30', '16:00'], 2: ['07:30', '16:00'], 3: ['07:30', '16:00'], 4: ['07:30', '16:00']}, 'constraints': <String>[], 'extraRoles': ['סגן-מנהל'],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2027-06-30'}, {'name': 'ניהול-חינוכי', 'issuer': 'אבני-ראשה', 'expiry': '2026-10-01'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:20'}], 'absences': <Map<String, dynamic>>[], 'notes': ''},
    {'id': 't8', 'name': 'שרה פרץ', 'role': 'subject', 'subjects': ['ביולוגיה'], 'homeroom': <String>[], 'contractHours': 16, 'contractType': 'שעתי', 'startDate': '2020-09-01', 'status': 'left',
      'availability': <int, List<String>>{}, 'constraints': <String>[], 'extraRoles': <String>[],
      'certs': <Map<String, dynamic>>[], 'attendance': <Map<String, dynamic>>[], 'absences': <Map<String, dynamic>>[], 'notes': 'סיימה 2026-06-30'},
  ];
  // חוגים/שיעורים בצורת-Course של מאור (id·name·teacherId·roomId·sessions) + קלט-תכנון (subject·cls·minutes)
  static const courses = <Map<String, dynamic>>[
    {'id': 'c1', 'name': 'מתמטיקה י-1', 'subject': 'מתמטיקה', 'cls': 'י-1', 'teacherId': 't1', 'roomId': 'ח-12', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '08:00'}, {'day': 2, 'time': '10:00'}, {'day': 4, 'time': '08:00'}, {'day': 1, 'time': '12:00'}]},
    {'id': 'c3', 'name': 'מתמטיקה ט-1', 'subject': 'מתמטיקה', 'cls': 'ט-1', 'teacherId': 't1', 'roomId': 'ח-7', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 1, 'time': '09:00'}, {'day': 3, 'time': '11:00'}, {'day': 4, 'time': '11:00'}]},
    {'id': 'c9', 'name': 'שעת-מחנך י-1', 'subject': 'חינוך', 'cls': 'י-1', 'teacherId': 't1', 'roomId': 'ח-12', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 2, 'time': '08:00'}]},
    {'id': 'c2', 'name': 'מתמטיקה י-2', 'subject': 'מתמטיקה', 'cls': 'י-2', 'teacherId': 't2', 'roomId': 'ח-11', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '09:00'}, {'day': 1, 'time': '08:00'}, {'day': 2, 'time': '11:00'}, {'day': 4, 'time': '08:00'}]},
    {'id': 'c4', 'name': 'פיזיקה יא-1', 'subject': 'פיזיקה', 'cls': 'יא-1', 'teacherId': 't2', 'roomId': 'מעבדה-2', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '11:00'}, {'day': 1, 'time': '10:00'}, {'day': 3, 'time': '08:00'}, {'day': 3, 'time': '12:00'}, {'day': 4, 'time': '09:00'}]},
    {'id': 'c5', 'name': 'פיזיקה יב-1', 'subject': 'פיזיקה', 'cls': 'יב-1', 'teacherId': 't2', 'roomId': 'מעבדה-2', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '13:00'}, {'day': 2, 'time': '09:00'}, {'day': 3, 'time': '10:00'}, {'day': 4, 'time': '12:00'}]},
    {'id': 'c11', 'name': 'מתמטיקה יב-2', 'subject': 'מתמטיקה', 'cls': 'יב-2', 'teacherId': 't2', 'roomId': 'ח-11', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '10:00'}, {'day': 1, 'time': '12:00'}, {'day': 2, 'time': '13:00'}, {'day': 3, 'time': '09:00'}, {'day': 4, 'time': '13:00'}]},
    {'id': 'c12', 'name': 'פיזיקה י-3', 'subject': 'פיזיקה', 'cls': 'י-3', 'teacherId': 't2', 'roomId': 'מעבדה-1', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '12:00'}, {'day': 1, 'time': '09:00'}, {'day': 2, 'time': '08:00'}, {'day': 3, 'time': '13:00'}, {'day': 4, 'time': '10:00'}]},
    {'id': 'c13', 'name': 'הכנה-לבגרות 5 יח׳', 'subject': 'מתמטיקה', 'cls': 'יב', 'teacherId': 't2', 'roomId': 'ח-11', 'start': '2026-09-01', 'end': '2027-03-30', 'sessions': [{'day': 1, 'time': '13:00'}, {'day': 3, 'time': '11:00'}, {'day': 0, 'time': '08:00'}, {'day': 2, 'time': '12:00'}]},
    {'id': 'c6', 'name': 'אנגלית ט-2', 'subject': 'אנגלית', 'cls': 'ט-2', 'teacherId': 't3', 'roomId': 'ח-4', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '10:00'}, {'day': 2, 'time': '09:00'}, {'day': 4, 'time': '09:00'}]},
    {'id': 'c14', 'name': 'אנגלית י-1', 'subject': 'אנגלית', 'cls': 'י-1', 'teacherId': 't3', 'roomId': 'ח-4', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '12:00'}, {'day': 2, 'time': '11:00'}]},
    {'id': 'c7', 'name': 'סיוע-לימודי ז׳-ח׳', 'subject': 'סיוע-לימודי', 'cls': 'ז-ח', 'teacherId': 't4', 'roomId': 'ח-2', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '08:00'}, {'day': 0, 'time': '09:00'}, {'day': 0, 'time': '10:00'}, {'day': 1, 'time': '08:00'}, {'day': 1, 'time': '09:00'}, {'day': 1, 'time': '10:00'}, {'day': 2, 'time': '08:00'}, {'day': 2, 'time': '09:00'}, {'day': 2, 'time': '10:00'}, {'day': 3, 'time': '08:00'}, {'day': 3, 'time': '09:00'}, {'day': 3, 'time': '10:00'}, {'day': 4, 'time': '08:00'}, {'day': 4, 'time': '09:00'}, {'day': 4, 'time': '10:00'}, {'day': 0, 'time': '11:00'}, {'day': 1, 'time': '11:00'}, {'day': 2, 'time': '11:00'}, {'day': 3, 'time': '11:00'}, {'day': 4, 'time': '11:00'}, {'day': 0, 'time': '12:00'}, {'day': 1, 'time': '12:00'}, {'day': 2, 'time': '12:00'}, {'day': 3, 'time': '12:00'}, {'day': 4, 'time': '12:00'}]},
    {'id': 'c8', 'name': 'היסטוריה ט-2', 'subject': 'היסטוריה', 'cls': 'ט-2', 'teacherId': 't5', 'roomId': 'ח-9', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '09:00'}, {'day': 1, 'time': '11:00'}, {'day': 3, 'time': '09:00'}, {'day': 4, 'time': '10:00'}]},
    {'id': 'c15', 'name': 'אזרחות יא-2', 'subject': 'אזרחות', 'cls': 'יא-2', 'teacherId': 't5', 'roomId': 'ח-9', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '11:00'}, {'day': 2, 'time': '10:00'}, {'day': 3, 'time': '12:00'}, {'day': 4, 'time': '08:00'}]},
    {'id': 'c16', 'name': 'היסטוריה יא-1', 'subject': 'היסטוריה', 'cls': 'יא-1', 'teacherId': 't5', 'roomId': 'ח-9', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 1, 'time': '08:00'}, {'day': 2, 'time': '12:00'}, {'day': 3, 'time': '10:00'}]},
    {'id': 'c17', 'name': 'שעת-מחנך ט-2', 'subject': 'חינוך', 'cls': 'ט-2', 'teacherId': 't5', 'roomId': 'ח-9', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 2, 'time': '08:00'}]},
    {'id': 'c18', 'name': 'אנגלית יא-1', 'subject': 'אנגלית', 'cls': 'יא-1', 'teacherId': 't6', 'roomId': 'ח-5', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '08:00'}, {'day': 2, 'time': '09:00'}, {'day': 4, 'time': '11:00'}]},
    {'id': 'c19', 'name': 'מתמטיקה ח-2', 'subject': 'מתמטיקה', 'cls': 'ח-2', 'teacherId': 't1', 'roomId': 'ח-6', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '09:00'}, {'day': 1, 'time': '08:00'}, {'day': 2, 'time': '11:00'}, {'day': 3, 'time': '08:00'}, {'day': 4, 'time': '09:00'}]},
    {'id': 'c20', 'name': 'מתמטיקה ט-3', 'subject': 'מתמטיקה', 'cls': 'ט-3', 'teacherId': 't1', 'roomId': 'ח-7', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '10:00'}, {'day': 1, 'time': '10:00'}, {'day': 2, 'time': '09:00'}, {'day': 3, 'time': '09:00'}, {'day': 4, 'time': '10:00'}]},
    {'id': 'c21', 'name': 'היסטוריה ח-1', 'subject': 'היסטוריה', 'cls': 'ח-1', 'teacherId': 't5', 'roomId': 'ח-3', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '08:00'}, {'day': 1, 'time': '09:00'}, {'day': 3, 'time': '08:00'}, {'day': 4, 'time': '09:00'}]},
    {'id': 'c22', 'name': 'אזרחות י-2', 'subject': 'אזרחות', 'cls': 'י-2', 'teacherId': 't5', 'roomId': 'ח-11', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '10:00'}, {'day': 1, 'time': '10:00'}, {'day': 2, 'time': '09:00'}, {'day': 4, 'time': '11:00'}]},
    {'id': 'c23', 'name': 'מתמטיקה ז-1', 'subject': 'מתמטיקה', 'cls': 'ז-1', 'teacherId': 't7', 'roomId': 'ח-1', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '08:00'}, {'day': 1, 'time': '08:00'}, {'day': 3, 'time': '10:00'}, {'day': 4, 'time': '12:00'}]},
    {'id': 'c10', 'name': 'מתמטיקה ח-1', 'subject': 'מתמטיקה', 'cls': 'ח-1', 'teacherId': 't7', 'roomId': 'ח-3', 'start': '2026-09-01', 'end': '2027-06-20', 'sessions': [{'day': 0, 'time': '09:00'}, {'day': 2, 'time': '09:00'}, {'day': 4, 'time': '09:00'}]},
  ];
  // החלפות (seed בצורת-רשומה: id·date·courseId·absentId·subId·stage 0=ללא-מחליף·1=הוצע·2=אושר)
  static const subsSeed = <Map<String, dynamic>>[
    {'id': 's1', 'date': '2026-09-01', 'courseId': 'c2', 'absentId': 't2', 'subId': 't7', 'stage': 2},
    {'id': 's2', 'date': '2026-08-25', 'courseId': 'c4', 'absentId': 't2', 'subId': 't1', 'stage': 2},
    {'id': 's3', 'date': '2026-08-30', 'courseId': 'c7', 'absentId': 't4', 'subId': 't5', 'stage': 2},
  ];

  // ─── עובדות-נגזרות פר-מורה ───
  static Map<String, dynamic>? byId(String id) {
    for (final t in roster) {
      if (t['id'] == id) return t;
    }
    return null;
  }
  static String nameOf(String? id) => id == null ? '—' : (byId(id)?['name'] as String? ?? id);
  static const roleLabel = {'homeroom': 'מחנך/ת', 'subject': 'מקצועי/ת', 'aide': 'סייע/ת', 'mgmt': 'הנהלה'};
  static const statusLabel = {'active': 'פעיל', 'leave': 'חופשה', 'unpaid': 'חל״ת', 'left': 'עזב/ה'};
  static List<String> subjects(Map<String, dynamic> t) => (t['subjects'] as List).cast<String>();
  static bool isActive(Map<String, dynamic> t) => statusOf(t) == 'active';
  static bool isGone(Map<String, dynamic> t) => statusOf(t) == 'left';
  static int weekdayOf(String iso) => DateTime.parse('${iso}T12:00:00').weekday % 7; // JS getDay: 0=ראשון
  static int get todayWd => weekdayOf(today);

  // חוגים-של-מורה (מנוע-מדף coursesOfTeacher על Course.teacherId)
  static List<Map<String, dynamic>> coursesOf(Map<String, dynamic> t) =>
      (coursesOfTeacher(courses, t['id']) as List).cast<Map<String, dynamic>>().where((c) => !reassigned.containsKey(c['id']) || reassigned[c['id']] == t['id']).toList()
        ..addAll(courses.where((c) => reassigned[c['id']] == t['id'] && c['teacherId'] != t['id']));
  // מפגשים-בשבוע (sessionsOf מהמדף · Σ דרך grandTotal)
  static int sessionsWeek(Map<String, dynamic> t) => grandTotal(coursesOf(t), (c) => (sessionsOf(c) as List).length).toInt();
  static double hoursWeek(Map<String, dynamic> t) => sessionsWeek(t).toDouble(); // ש״ש = מספר-השיעורים בשבוע
  static int contractHours(Map<String, dynamic> t) => t['contractHours'] as int;
  static int contractSessions(Map<String, dynamic> t) => contractHours(t); // מפגשי-חוזה = שעות-חוזיות
  // יחס-עומס (clampScale מהמדף · 0..2) ⇒ אחוז
  static int loadPct(Map<String, dynamic> t) => (clampScale(hoursWeek(t) / contractHours(t), 0.0, 2.0) * 100).round();
  // עומס-יתר = מנוע-העומס של המדף (volunteerLoadHint: count ≥ max ⇒ over). max = מפגשי-חוזה+1 ⇒ over כש-מפגשים > חוזה.
  static List<dynamic> _sessionsAsDeliveries(dynamic db, dynamic id, dynamic week) =>
      [for (final c in coursesOf(byId(id as String)!)) ...(sessionsOf(c) as List)];
  static bool overLoad(Map<String, dynamic> t) =>
      isActive(t) && volunteerLoadHint(const {}, {'id': t['id'], 'maxDeliveries': contractSessions(t) + 1}, 'week', _sessionsAsDeliveries)['over'] == true;
  static bool underLoad(Map<String, dynamic> t) => isActive(t) && loadPct(t) < underPct;

  // נוכחות-עצמית היום (AttendanceDay: יש inTs לתאריך-היום)
  static bool presentToday(Map<String, dynamic> t) => (t['attendance'] as List).any((a) => a['date'] == today && a['inTs'] != null);
  static List<Map<String, dynamic>> absencesOf(Map<String, dynamic> t) => [...extraAbsences[t['id']] ?? const [], ...(t['absences'] as List).cast<Map<String, dynamic>>()];
  static bool absentOn(Map<String, dynamic> t, String iso) => absencesOf(t).any((a) => a['date'] == iso);
  static bool absentToday(Map<String, dynamic> t) => absentOn(t, today) || statusOf(t) == 'leave' || statusOf(t) == 'unpaid';
  static int absencesMonth(Map<String, dynamic> t) => presentsInMonth([for (final a in absencesOf(t)) a['date']], today); // ספירה-בחודש (מדף)
  static String reasonOf(String key) => kTerms[key] ?? key;
  // דפוס-היעדרות (23-ד · שני מודלים מחוברים): ספירה-ב-4-חודשים ∨ מגמה-עולה (trendFromScan על חודשים)
  static List<num> absenceMonthly(Map<String, dynamic> t) {
    final base = DateTime.parse('${today}T12:00:00');
    return [for (var i = 3; i >= 0; i--) () {
      final m = DateTime(base.year, base.month - i);
      final ym = '${m.year}-${m.month.toString().padLeft(2, '0')}';
      return absencesOf(t).where((a) => (a['date'] as String).startsWith(ym)).length;
    }()];
  }
  static Map<String, dynamic> absenceTrend(Map<String, dynamic> t) => trendFromScan({'monthly': absenceMonthly(t)});
  static bool frequentAbsentee(Map<String, dynamic> t) {
    final n = absenceMonthly(t).fold<num>(0, (a, b) => a + b);
    return isActive(t) && (n >= frequentAbsences || (n >= 2 && absenceTrend(t)['dir'] == 'up'));
  }

  // הכשרות+תוקף (certExpiryStatus מבנייה-חכמה · now מוזרק)
  static DateTime get _now => DateTime.parse('${today}T12:00:00');
  static List<Map<String, dynamic>> certsOf(Map<String, dynamic> t) => [...(t['certs'] as List).cast<Map<String, dynamic>>(), ...extraCerts[t['id']] ?? const []];
  static CertExpiryStatus certStatus(Map<String, dynamic> c) => certExpiryStatus(DateTime.parse(c['expiry'] as String), now: _now);
  static bool certExpired(Map<String, dynamic> t) => certsOf(t).any((c) => certStatus(c) == CertExpiryStatus.expired);
  static bool certSoon(Map<String, dynamic> t) => certsOf(t).any((c) => certStatus(c) == CertExpiryStatus.expiringSoon);
  static bool certMissing(Map<String, dynamic> t) => isActive(t) && (certsOf(t).isEmpty || certExpired(t)); // הכשרה-חסרה = אין/פגה
  // חוזה: ימים-עד-סיום (dayDiff: today−end ⇒ שלילי=עתיד) · פג-החודש (presentsInMonth על תאריך-הסיום)
  static num? contractDays(Map<String, dynamic> t) => t['contractEnd'] == null ? null : -dayDiff(t['contractEnd'] as String, today);
  static bool contractEndsMonth(Map<String, dynamic> t) => t['contractEnd'] != null && presentsInMonth([t['contractEnd']], today) > 0;
  static bool contractExpired(Map<String, dynamic> t) => (contractDays(t) ?? 1) < 0;
  static int? tenure(Map<String, dynamic> t) => ageOf(t['startDate'] as String?, _now); // ותק בשנים (ageOf מהמדף)

  // ─── שיעורים-ללא-מורה היום + לוח-החלפות (זיהוי-חריגה ⇒ הכרעה ⇒ ביצוע) ───
  static final List<Map<String, dynamic>> subs = [...subsSeed.map((s) => Map<String, dynamic>.from(s))];
  static Map<String, dynamic>? courseById(String id) {
    for (final c in courses) {
      if (c['id'] == id) return c;
    }
    return null;
  }
  static String slotOf(Map<String, dynamic> c, int day) {
    for (final s in sessionsOf(c) as List) {
      if (s['day'] == day) return '${s['time']}';
    }
    return '';
  }
  // אוטומציה: ברגע-היעדרות כל מפגש-של-היום ⇒ רשומת-החלפה stage 0 (אם אין כבר)
  static void syncUncovered() {
    for (final t in roster) {
      if (!absentToday(t) || isGone(t)) continue;
      for (final c in coursesOf(t)) {
        for (final s in sessionsOf(c) as List) {
          if (s['day'] != todayWd) continue;
          final id = 'u-${c['id']}-${s['time']}';
          if (!subs.any((x) => x['id'] == id)) {
            subs.add({'id': id, 'date': today, 'courseId': c['id'], 'time': s['time'], 'absentId': t['id'], 'subId': null, 'stage': 0});
          }
        }
      }
    }
  }
  static List<Map<String, dynamic>> get todaySubs => subs.where((s) => s['date'] == today).toList()..sort((a, b) => '${a['time'] ?? ''}'.compareTo('${b['time'] ?? ''}'));
  static List<Map<String, dynamic>> get uncoveredToday => todaySubs.where((s) => (s['stage'] as int) < 2).toList();
  static int get openSubs => subs.where((s) => (s['stage'] as int) < 2).length;
  static bool subOverdue(Map<String, dynamic> s) => taskOverdue({'due': s['date'], 'doneAt': (s['stage'] as int) == 2 ? s['date'] : null}, today); // מדף
  static int subsDone(Map<String, dynamic> t) => subs.where((s) => s['subId'] == t['id'] && s['stage'] == 2).length;
  static int subsReceived(Map<String, dynamic> t) => subs.where((s) => s['absentId'] == t['id'] && s['stage'] == 2).length;

  // הצעת-מחליף (23-ד: זמין ∧ מקצוע ∧ פנוי-בסלוט ∧ עומס-נמוך ∧ מועדף — מחוברים בדירוג):
  //   פנוי-בסלוט = scheduleClashText מהמדף (enrollments = שיבוצי-המורים לחוגיהם; null ⇒ אין התנגשות)
  static Map<String, dynamic> get _clashDb => {
        'enrollments': [for (final t in roster) for (final c in coursesOf(t)) {'memberId': t['id'], 'courseId': c['id'], 'status': 'active'}],
        'courses': courses,
      };
  static const _clashT = <String, dynamic>{'k1': 'ended', 'k2': '', 'k3': ' · '};
  static String? clashOf(Map<String, dynamic> t, Map<String, dynamic> course) => scheduleClashText(_clashDb, t['id'], course, sessionsOf, dayNames, _clashT) as String?;
  static bool availableAt(Map<String, dynamic> t, int day, String time) { // חלון-זמינות (timeToMin מהמדף)
    final w = (t['availability'] as Map)[day] as List?;
    if (w == null) return false;
    final m = timeToMin(time), a = timeToMin(w[0]), b = timeToMin(w[1]);
    return m is num && a is num && b is num && m >= a && m < b;
  }
  static List<Map<String, dynamic>> candidates(Map<String, dynamic> sub) {
    final c = courseById(sub['courseId'] as String)!;
    final absent = byId(sub['absentId'] as String)!;
    final time = '${sub['time'] ?? slotOf(c, todayWd)}';
    final list = roster.where((t) => isActive(t) && t['id'] != absent['id'] && !absentToday(t) && subjects(t).contains(c['subject']) && availableAt(t, todayWd, time) && clashOf(t, c) == null).toList();
    list.sort((a, b) { // מועדף ראשון, אחר-כך עומס עולה
      final pa = absent['preferredSub'] == a['id'] ? 0 : 1, pb = absent['preferredSub'] == b['id'] ? 0 : 1;
      return pa != pb ? pa - pb : loadPct(a).compareTo(loadPct(b));
    });
    return list;
  }

  // ─── דחיפות מאוחדת פר-מורה (מקסום-מטרה 23-ד: כל האותות ⇒ החלטה-אחת שמניעה טריאז'+KPI+התראה) ───
  //   3=🔴 נעדר-היום עם שיעור-ללא-מורה · 2=🟠 עומס-יתר ∨ חוזה-מסתיים ∨ הכשרה-פגה · 1=🟡 תת-עומס ∨ הכשרה-פגה-בקרוב ∨ דפוס-היעדרות · 0=🟢
  static int sev(Map<String, dynamic> t) {
    if (!isActive(t)) return -1;
    if (absentToday(t) && uncoveredToday.any((s) => s['absentId'] == t['id'])) return 3;
    if (overLoad(t) || contractEndsMonth(t) || certExpired(t)) return 2;
    if (underLoad(t) || certSoon(t) || frequentAbsentee(t)) return 1;
    return 0;
  }
  static String why(Map<String, dynamic> t) => [
        if (absentToday(t)) 'נעדר/ת היום',
        if (overLoad(t)) 'עומס-יתר ${loadPct(t)}%',
        if (underLoad(t)) 'תת-עומס ${loadPct(t)}%',
        if (contractEndsMonth(t)) 'חוזה מסתיים בעוד ${contractDays(t)} י׳',
        if (certExpired(t)) 'הכשרה פגה',
        if (certSoon(t)) 'הכשרה פגה בקרוב',
        if (frequentAbsentee(t)) 'דפוס-היעדרויות (${absenceMonthly(t).fold<num>(0, (a, b) => a + b)} ב-4 חודשים)',
      ].join(' · ');

  // ─── KPI-10 (המפרט) — ספירות/סכומים על מנועי-מדף ושדות-אמת (אפס StatBlock) ───
  static List<Map<String, dynamic>> get active => roster.where(isActive).toList();
  static List<Map<String, dynamic>> get staff => roster.where((t) => !isGone(t)).toList();
  static int get absentN => active.where(absentToday).length + roster.where((t) => statusOf(t) == 'leave' || statusOf(t) == 'unpaid').length;
  static double get avgHours => active.isEmpty ? 0 : grandTotal(active, (t) => hoursWeek(t as Map<String, dynamic>)) / active.length;
  static int get overN => active.where(overLoad).length;
  static int get underN => active.where(underLoad).length;
  static int get contractsN => staff.where(contractEndsMonth).length;
  static int get certsN => active.where(certMissing).length;
  static List<List<Object>> get byRole => countBy(staff, (t) => roleLabel[(t as Map)['role']] ?? '${t['role']}'); // מדף

  // ─── פנקס-פעולות (מצב=חיווט · הבסיס const נשאר מקור-האמת) ───
  static final Map<String, String> statusOverride = {};
  static String statusOf(Map<String, dynamic> t) => statusOverride[t['id']] ?? (t['status'] as String);
  static final Map<String, List<Map<String, dynamic>>> extraAbsences = {};
  static final Map<String, List<Map<String, dynamic>>> extraCerts = {};
  static final Map<String, String> reassigned = {}; // courseId ⇒ teacherId (הקצה-כיתה)
  static final List<Map<String, dynamic>> audit = []; // אודיט (מי·מה·מתי) — TimelineItem
  static void log(String who, String what, String target) => audit.insert(0, {'who': who, 'what': what, 'target': target, 'date': today});
  static void markAbsent(Map<String, dynamic> t, String reason, String who) {
    if (absentOn(t, today)) return;
    (extraAbsences[t['id'] as String] ??= []).insert(0, {'date': today, 'reason': reason});
    syncUncovered(); // אוטומציה: זיהוי שיעור-ללא-מורה ברגע-ההיעדרות
    log(who, 'סימון-היעדרות (${reasonOf(reason)})', t['name'] as String);
  }
  static void propose(Map<String, dynamic> s, Map<String, dynamic> t, String who) {
    s['subId'] = t['id'];
    s['stage'] = 1;
    log(who, 'הצעת-מחליף', '${nameOf(t['id'] as String)} ⇐ ${courseById(s['courseId'] as String)?['name']}');
  }
  static void moveSub(String id, int toStage, String who) {
    final s = subs.firstWhere((x) => x['id'] == id);
    if (toStage >= 1 && s['subId'] == null) {
      final c = candidates(s);
      if (c.isEmpty) return; // אין מחליף-זמין ⇒ לא מקדמים (אמת)
      s['subId'] = c.first['id'];
    }
    s['stage'] = toStage.clamp(0, 2);
    if (toStage <= 0) s['subId'] = null;
    log(who, toStage == 2 ? 'אישור-החלפה' : toStage == 1 ? 'הצעת-מחליף' : 'ביטול-החלפה', '${courseById(s['courseId'] as String)?['name']}');
  }
}

// ═══════════ המסך · מחלקה ציבורית יחידה (const · ללא main) ═══════════
class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key});
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  int _sort = 0; // 0=⚖️ עומס · 1=🤒 חיסורים · 2=🏫 כיתות

  @override
  void initState() {
    super.initState();
    _TeamData.syncUncovered(); // אוטומציה: היעדרויות-של-היום ⇒ שיעורים-ללא-מורה
  }

  @override
  Widget build(BuildContext context) {
    final all = _TeamData.active;
    final uncovered = _TeamData.uncoveredToday.length; // hero = המטרה: אף שיעור בלי מורה
    final ranked = [..._TeamData.roster.where((t) => !_TeamData.isGone(t))];
    ranked.sort((a, b) {
      switch (_sort) {
        case 1:
          return _TeamData.absencesMonth(b).compareTo(_TeamData.absencesMonth(a));
        case 2:
          return _TeamData.coursesOf(b).length.compareTo(_TeamData.coursesOf(a).length);
        default:
          return _TeamData.loadPct(b).compareTo(_TeamData.loadPct(a));
      }
    });
    // טריאז' — פעולת-יסוד "הכרעה" מקבצת פר-דחיפות-מאוחדת (sev)
    final buckets = <int, List<Map<String, dynamic>>>{3: [], 2: [], 1: [], 0: [], -1: []};
    for (final t in ranked) {
      buckets[_TeamData.sev(t)]!.add(t);
    }
    const secTitle = {3: '🔴 שיעור-ללא-מורה היום', 2: '🟠 דורש-טיפול', 1: '🟡 לתשומת-לב', 0: '🟢 תקין', -1: '⏸ לא-פעיל/חופשה'};
    const secTone = {3: 2, 2: 3, 1: 3, 0: 1, -1: 0};
    return DsScaffold(
      title: 'מורים וצוות',
      subtitle: '${_TeamData.staff.length} אנשי-צוות · ${_TeamData.byRole.map((r) => '${r[0]} ${r[1]}').join(' · ')}',
      icon: '👩‍🏫',
      children: [
        // KPI-10: hero=שיעורים-ללא-מורה-היום (המטרה) + 10 מדדי-מצב (BareStat נושאי-ערך-אמת)
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatHero(value: '$uncovered', label: 'שיעורים ללא מורה היום'),
            const SizedBox(height: 14),
            Row(children: [
              BareStat(value: '${_TeamData.staff.length}', label: '👥 סך-צוות', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${all.length}', label: '✅ פעילים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_TeamData.absentN}', label: '🤒 נעדרים היום', inkColor: _TeamData.absentN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '$uncovered', label: '🚨 ללא-מורה', inkColor: uncovered > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_TeamData.openSubs}', label: '🔁 החלפות פתוחות', inkColor: _TeamData.openSubs > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: _TeamData.avgHours.toStringAsFixed(1), label: '⚖️ עומס ממוצע ש׳/שב׳', inkColor: _acc, mutedColor: _muted),
              BareStat(value: '${_TeamData.overN}', label: '🔥 עמוסים-מדי', inkColor: _TeamData.overN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_TeamData.underN}', label: '🪫 בתת-עומס', inkColor: _TeamData.underN > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${_TeamData.contractsN}', label: '📄 חוזים פגים החודש', inkColor: _TeamData.contractsN > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${_TeamData.certsN}', label: '🎓 הכשרות חסרות', inkColor: _TeamData.certsN > 0 ? _danger : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        const SizedBox(height: 10),
        // מיון (המפרט: עומס · חיסורים · כיתות) — SegmentedSwitch מבוקר
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(items: const ['⚖️ עומס', '🤒 חיסורים', '🏫 כיתות'], selected: _sort, onSelect: (i) => setState(() => _sort = i)),
        ),
        const SizedBox(height: 10),
        for (final st in const [3, 2, 1, 0, -1])
          if (buckets[st]!.isNotEmpty)
            DsSection(title: '${secTitle[st]} · ${buckets[st]!.length}', tone: secTone[st]!, children: [
              for (final t in buckets[st]!) _row(t),
            ]),
      ],
    );
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);

  // שורת-מורה: זהות (PremiumAvatar ראשי-תיבות + נקודת-מצב) · תפקיד+כיתות · עומס מול חוזה (StatRow יחס) · סיבת-הדחיפות
  Widget _row(Map<String, dynamic> t) {
    final st = _TeamData.statusOf(t);
    final avatarStatus = st != 'active' ? AvatarStatus.away : _TeamData.absentToday(t) ? AvatarStatus.busy : _TeamData.presentToday(t) ? AvatarStatus.online : AvatarStatus.none;
    final hours = _TeamData.hoursWeek(t), ch = _TeamData.contractHours(t);
    final pct = _TeamData.loadPct(t);
    final sev = _TeamData.sev(t);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            PremiumAvatar(name: t['name'] as String, size: 44, status: avatarStatus),
            const SizedBox(width: 10),
            Expanded(
              child: MediaRow(
                glyph: t['role'] == 'homeroom' ? '🏫' : t['role'] == 'aide' ? '🤝' : t['role'] == 'mgmt' ? '🧭' : '📚',
                title: '${t['name']} · ${_TeamData.roleLabel[t['role']]}',
                subtitle: '${_TeamData.subjects(t).join(' · ')}${(t['homeroom'] as List).isNotEmpty ? ' · מחנך/ת ${(t['homeroom'] as List).join(',')}' : ''} · ${_TeamData.coursesOf(t).length} חוגים',
              ),
            ),
          ]),
          _gap(8),
          StatRow(label: 'עומס מול חוזה', value: '${hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1)} מתוך $ch ש׳ · $pct%', fraction: (pct / 100).clamp(0.0, 1.0)),
          if (sev >= 1 || st != 'active') ...[
            _gap(8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              if (st != 'active') StatusChip(label: _TeamData.statusLabel[st] ?? st, tone: 0),
              if (_TeamData.why(t).isNotEmpty) StatusChip(label: _TeamData.why(t), tone: sev == 3 ? 2 : sev == 2 ? 3 : 0),
            ]),
          ],
        ]),
      ),
    );
  }
}
