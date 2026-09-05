// 🎯 ShopAssignmentScreen — retarget של schoolos_teachers.dart לישות ShopAssignment (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module schoolos_teachers.dart --entity ShopAssignment
//   זרע-ראשי: roster (מועמדים: roster(22/23) courses(8/11) subsSeed(6/6)) · מיפוי שם 3 · ערוץ 0 · טיפוס-יחיד 2 · מקום-שמור 18 · חוזה-מנוע (לא משתנה) 0
//   id⇒id(name) · status⇒status(name) · notes⇒notes(name) · name⇒∅(reserved) · role⇒∅(reserved) · subjects⇒redemptions(unique) · homeroom⇒∅(reserved) · contractHours⇒∅(reserved) · contractType⇒∅(reserved) · startDate⇒since(unique) · availability⇒∅(reserved) · constraints⇒∅(reserved) · preferredSub⇒∅(reserved(4 מועמדים)) · extraRoles⇒∅(reserved) · certs⇒∅(reserved) · issuer⇒∅(reserved) · expiry⇒∅(reserved) · attendance⇒∅(reserved) · absences⇒∅(reserved) · reason⇒∅(reserved) · date⇒∅(reserved) · inTs⇒∅(reserved) · contractEnd⇒∅(reserved)
//   עור-forge (G12c): BareStat⇒ForgeMetricTile ×0 (ב-Wrap) · נשארו BareStat ב-Row ×17 · StatHero⇒ForgeStatBlock ×1 — fields לפי תפקידי-חריצים; צבעי-מצב-DS לא מועברים
//   תפר-עובדות (G9b): ShopAssignmentFacts · count=roster.length (static-const) · מדדים 6 · hero=absentN · שורות-מדד (G10a) openSubs/overN/underN/contractsN/certsN · תפר-כניסה initialPanel · תפר-סינון-מדד initialMetric · תפר-הזרקה ∅
//   שדות-ShopAssignment בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): productId, famId, memberId, criterionIds · תוויות: מונחי teacher (מורה/—) ⇒ ShopAssignment (שיוך/—) · 11 החלפות · הזרע = זרע-הצבה של המקור, לא ערך-אמת של ShopAssignment
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
import '../dart-ui-bs/premium/lists/timeline_item.dart';
import '../dart-ui-bs/premium/lists/expandable_tile.dart'; // פנקס-המקומות-השמורים (מתקפל) // ציר-זמן (היעדרויות · החלפות · אודיט) — לא timeline_flow המזייף
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
import 'gen_core_shopassignment.dart'; // G6c · הגרעין-מהסכמה של ShopAssignment (מצבים · מעבר · חוקים · ערוצים)
import '../dart-forge-bs/dataviz/dataviz.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

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

  // roster — זהות-תצוגה = שמות-דמו בדויים; בהצבה מוזרק roster אמיתי דרך ShopAssignmentScreen(roster:) (חוק-6).
  static const roster = <Map<String, dynamic>>[
    {'id': 't1', 'name': 'יעל ברק', 'role': 'homeroom', 'redemptions': ['מתמטיקה'], 'homeroom': ['י-1'], 'contractHours': 24, 'contractType': 'קבוע', 'since': '2014-09-01', 'status': 'active',
      'availability': {0: ['08:00', '15:00'], 1: ['08:00', '15:00'], 2: ['08:00', '15:00'], 3: ['08:00', '15:00'], 4: ['08:00', '13:00']}, 'constraints': ['לא-בשישי'], 'preferredSub': 't7', 'extraRoles': ['ריכוז-שכבה י׳'],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2030-06-30'}, {'name': 'עזרה-ראשונה', 'issuer': 'מד״א', 'expiry': '2026-09-20'}],
      'attendance': <Map<String, dynamic>>[], 'absences': [{'date': '2026-09-03', 'reason': 'mchlh'}, {'date': '2026-05-12', 'reason': 'ayrva-mshpchty'}], 'notes': 'מועמדת לריכוז-פדגוגי בתשפ״ז'},
    {'id': 't2', 'name': 'דוד כהן', 'role': 'subject', 'redemptions': ['מתמטיקה', 'פיזיקה'], 'homeroom': <String>[], 'contractHours': 20, 'contractType': 'קבוע', 'since': '2019-09-01', 'status': 'active',
      'availability': {0: ['08:00', '16:00'], 1: ['08:00', '16:00'], 2: ['08:00', '16:00'], 3: ['08:00', '16:00'], 4: ['08:00', '16:00']}, 'constraints': <String>[], 'preferredSub': 't7', 'extraRoles': <String>[],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2029-08-31'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:41'}], 'absences': [{'date': '2026-09-01', 'reason': 'mchlh'}, {'date': '2026-08-25', 'reason': 'mchlh'}, {'date': '2026-08-18', 'reason': 'nsyah'}, {'date': '2026-07-02', 'reason': 'mchlh'}, {'date': '2026-06-10', 'reason': 'shmchh'}], 'notes': ''},
    {'id': 't3', 'name': 'נועה לוי', 'role': 'subject', 'redemptions': ['אנגלית'], 'homeroom': <String>[], 'contractHours': 18, 'contractType': 'זמני', 'contractEnd': '2026-09-25', 'since': '2025-09-01', 'status': 'active',
      'availability': {0: ['08:00', '14:00'], 2: ['08:00', '14:00'], 4: ['08:00', '14:00']}, 'constraints': ['לא-בשני-ורביעי'], 'extraRoles': <String>[],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2031-06-30'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:55'}], 'absences': <Map<String, dynamic>>[], 'notes': ''},
    {'id': 't4', 'name': 'אמיר חדד', 'role': 'aide', 'redemptions': ['סיוע-לימודי'], 'homeroom': <String>[], 'contractHours': 30, 'contractType': 'קבוע', 'since': '2021-09-01', 'status': 'active',
      'availability': {0: ['08:00', '15:00'], 1: ['08:00', '15:00'], 2: ['08:00', '15:00'], 3: ['08:00', '15:00'], 4: ['08:00', '15:00']}, 'constraints': <String>[], 'extraRoles': <String>[],
      'certs': [{'name': 'סייע-פדגוגי', 'issuer': 'משרד החינוך', 'expiry': '2026-05-01'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:50'}], 'absences': [{'date': '2026-08-30', 'reason': 'mzg-avvyr'}], 'notes': ''},
    {'id': 't5', 'name': 'רות אזולאי', 'role': 'homeroom', 'redemptions': ['היסטוריה', 'אזרחות'], 'homeroom': ['ט-2'], 'contractHours': 22, 'contractType': 'קבוע', 'since': '2010-09-01', 'status': 'active',
      'availability': {0: ['08:00', '15:00'], 1: ['08:00', '15:00'], 2: ['08:00', '15:00'], 3: ['08:00', '15:00'], 4: ['08:00', '15:00']}, 'constraints': <String>[], 'preferredSub': 't1', 'extraRoles': ['יועצת'],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2028-06-30'}, {'name': 'ייעוץ-חינוכי', 'issuer': 'אונ׳ ת״א', 'expiry': '2027-12-31'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:38'}], 'absences': <Map<String, dynamic>>[], 'notes': ''},
    {'id': 't6', 'name': 'מיכל שרון', 'role': 'subject', 'redemptions': ['אנגלית'], 'homeroom': <String>[], 'contractHours': 20, 'contractType': 'קבוע', 'since': '2017-09-01', 'status': 'leave',
      'availability': <int, List<String>>{}, 'constraints': <String>[], 'extraRoles': <String>[],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2029-06-30'}],
      'attendance': <Map<String, dynamic>>[], 'absences': <Map<String, dynamic>>[], 'notes': 'חופשת-לידה עד 2027-01'},
    {'id': 't7', 'name': 'יוסי מזרחי', 'role': 'mgmt', 'redemptions': ['מתמטיקה'], 'homeroom': <String>[], 'contractHours': 8, 'contractType': 'קבוע', 'since': '2008-09-01', 'status': 'active',
      'availability': {0: ['07:30', '16:00'], 1: ['07:30', '16:00'], 2: ['07:30', '16:00'], 3: ['07:30', '16:00'], 4: ['07:30', '16:00']}, 'constraints': <String>[], 'extraRoles': ['סגן-מנהל'],
      'certs': [{'name': 'תעודת-הוראה', 'issuer': 'משרד החינוך', 'expiry': '2027-06-30'}, {'name': 'ניהול-חינוכי', 'issuer': 'אבני-ראשה', 'expiry': '2026-10-01'}],
      'attendance': [{'date': '2026-09-03', 'inTs': '07:20'}], 'absences': <Map<String, dynamic>>[], 'notes': ''},
    {'id': 't8', 'name': 'שרה פרץ', 'role': 'subject', 'redemptions': ['ביולוגיה'], 'homeroom': <String>[], 'contractHours': 16, 'contractType': 'שעתי', 'since': '2020-09-01', 'status': 'left',
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
  static final List<Map<String, dynamic>> added = []; // מורה-חדש (פנקס)
  static List<Map<String, dynamic>> get everyone => [...roster, ...added];
  static Map<String, dynamic>? byId(String id) {
    for (final t in everyone) {
      if (t['id'] == id) return t;
    }
    return null;
  }
  static String nameOf(String? id) => id == null ? '—' : (byId(id)?['name'] as String? ?? id);
  static const roleLabel = {'homeroom': 'מחנך/ת', 'subject': 'מקצועי/ת', 'aide': 'סייע/ת', 'mgmt': 'הנהלה'};
  static const statusLabel = {'active': 'פעיל', 'leave': 'חופשה', 'unpaid': 'חל״ת', 'left': 'עזב/ה'};
  static List<String> subjects(Map<String, dynamic> t) => [...(t['redemptions'] as List).cast<String>(), ...extraSubjects[t['id']] ?? const []];
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
  static int? tenure(Map<String, dynamic> t) => ageOf(t['since'] as String?, _now); // ותק בשנים (ageOf מהמדף)

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
    for (final t in everyone) {
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
  static List<Map<String, dynamic>> get rowsOf_openSubs => subs.where((s) => (s['stage'] as int) < 2).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד openSubs (מהצורה של ה-getter, לא מילון)
  static bool subOverdue(Map<String, dynamic> s) => taskOverdue({'due': s['date'], 'doneAt': (s['stage'] as int) == 2 ? s['date'] : null}, today); // מדף
  static int subsDone(Map<String, dynamic> t) => subs.where((s) => s['subId'] == t['id'] && s['stage'] == 2).length;
  static int subsReceived(Map<String, dynamic> t) => subs.where((s) => s['absentId'] == t['id'] && s['stage'] == 2).length;

  // הצעת-מחליף (23-ד: זמין ∧ מקצוע ∧ פנוי-בסלוט ∧ עומס-נמוך ∧ מועדף — מחוברים בדירוג):
  //   פנוי-בסלוט = scheduleClashText מהמדף (enrollments = שיבוצי-המורים לחוגיהם; null ⇒ אין התנגשות)
  static Map<String, dynamic> get _clashDb => {
        'enrollments': [for (final t in everyone) for (final c in coursesOf(t)) {'memberId': t['id'], 'courseId': c['id'], 'status': 'active'}],
        'courses': courses,
      };
  static const _clashT = <String, dynamic>{'k1': 'ended', 'k2': '', 'k3': ' · '};
  static String? clashOf(Map<String, dynamic> t, Map<String, dynamic> course) => scheduleClashText(_clashDb, t['id'], course, sessionsOf, dayNames, _clashT) as String?;
  static bool availableAt(Map<String, dynamic> t, int day, String time) { // חלון-זמינות (timeToMin מהמדף)
    final w = availabilityOf(t)[day];
    if (w == null) return false;
    final m = timeToMin(time), a = timeToMin(w[0]), b = timeToMin(w[1]);
    return m is num && a is num && b is num && m >= a && m < b;
  }
  static List<Map<String, dynamic>> candidates(Map<String, dynamic> sub) {
    final c = courseById(sub['courseId'] as String)!;
    final absent = byId(sub['absentId'] as String)!;
    final time = '${sub['time'] ?? slotOf(c, todayWd)}';
    // החלפה-ליום-אחד ⇒ ההתנגשות נבדקת מול הסלוט-של-היום בלבד (מבט-חוג מצומצם מוזרק למנוע); ההקצאה-הקבועה בודקת את כל השבוע.
    final slot = <String, dynamic>{...c, 'sessions': [{'day': todayWd, 'time': time}]};
    final list = everyone.where((t) => isActive(t) && t['id'] != absent['id'] && !absentToday(t) && subjects(t).contains(c['subject']) && availableAt(t, todayWd, time) && clashOf(t, slot) == null).toList();
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
  static List<Map<String, dynamic>> get active => everyone.where(isActive).toList();
  static List<Map<String, dynamic>> get staff => everyone.where((t) => !isGone(t)).toList();
  static int get absentN => active.where(absentToday).length + everyone.where((t) => statusOf(t) == 'leave' || statusOf(t) == 'unpaid').length;
  static double get avgHours => active.isEmpty ? 0 : grandTotal(active, (t) => hoursWeek(t as Map<String, dynamic>)) / active.length;
  static int get overN => active.where(overLoad).length;
  static List<Map<String, dynamic>> get rowsOf_overN => active.where(overLoad).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד overN (מהצורה של ה-getter, לא מילון)
  static int get underN => active.where(underLoad).length;
  static List<Map<String, dynamic>> get rowsOf_underN => active.where(underLoad).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד underN (מהצורה של ה-getter, לא מילון)
  static int get contractsN => staff.where(contractEndsMonth).length;
  static List<Map<String, dynamic>> get rowsOf_contractsN => staff.where(contractEndsMonth).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד contractsN (מהצורה של ה-getter, לא מילון)
  static int get certsN => active.where(certMissing).length;
  static List<Map<String, dynamic>> get rowsOf_certsN => active.where(certMissing).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד certsN (מהצורה של ה-getter, לא מילון)
  static List<List<Object>> get byRole => countBy(staff, (t) => roleLabel[roleOf_(t as Map<String, dynamic>)] ?? roleOf_(t)); // מדף

  // ═══ איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — לא `.contains` שטוח ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> t) => ['${t['name']}', ...subjects(t), ...(t['homeroom'] as List).cast<String>(), roleLabel[roleOf_(t)] ?? '', for (final c in coursesOf(t)) '${c['cls']}', for (final r in (t['extraRoles'] as List)) '$r'];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> items, String q) =>
      (smartFilter(q, items, (it) => _termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה (הכרעה 23-ג) = FilterChipPill ⊕ finderMatches (AND רב-צירי על נעילות) ═══
  //   צירים: absent · over · under · cert · contract · free(זמין-בסלוט-הפתוח-הקרוב) · role · status · subject · cls
  static String get openSlot => uncoveredToday.isEmpty ? '08:00' : '${uncoveredToday.first['time']}';
  static String _axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) {
    final t = f as Map<String, dynamic>;
    switch (axis) {
      case 'absent': return absentToday(t) ? '1' : '0';
      case 'over': return overLoad(t) ? '1' : '0';
      case 'under': return underLoad(t) ? '1' : '0';
      case 'cert': return certMissing(t) || certSoon(t) ? '1' : '0';
      case 'contract': return contractEndsMonth(t) || contractExpired(t) ? '1' : '0';
      case 'free': return isActive(t) && !absentToday(t) && availableAt(t, todayWd, openSlot) && clashOf(t, {'id': '__slot', 'sessions': [{'day': todayWd, 'time': openSlot}]}) == null ? '1' : '0';
      case 'role': return roleOf_(t);
      case 'status': return statusOf(t);
      case 'subject': return subjects(t).join('|');
      case 'cls': return [for (final c in coursesOf(t)) '${c['cls']}', ...(t['homeroom'] as List)].join('|');
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> items, Map<String, String> locks) {
    // ערכי-רשימה (subject/cls) נבדקים בהכלה: נועלים על 'X' ובודקים דרך ציר-נגזר
    final rows = items.where((t) => (locks['subject'] == null || subjects(t).contains(locks['subject'])) && (locks['cls'] == null || _axisValue({}, t, 'cls').split('|').contains(locks['cls']))).toList();
    final simple = {for (final e in locks.entries) if (e.key != 'subject' && e.key != 'cls') e.key: e.value};
    return finderMatches({'families': rows}, simple, _axisValue).cast<Map<String, dynamic>>();
  }
  static List<String> get allSubjects => [for (final r in countBy([for (final t in staff) for (final sj in subjects(t)) sj], (x) => '$x')) '${r[0]}'];
  static List<String> get allClasses => [for (final r in countBy([for (final t in staff) for (final c in coursesOf(t)) '${c['cls']}'], (x) => '$x')) '${r[0]}'];

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 16 עמודות-המפרט כשקעי-דאטה ═══
  //   נגזרת(get)=תמיד-מוצגת · שדה(key)=מוארת רק כשרשומה נושאת ערך, חסר ⇒ שקט. photo/contact/classAttendance/updatedAt
  //   אין להם מקור-אמת/מוזרקים-בהצבה (חוק-6) ⇒ מקום-שמור: הזרקת-שדה ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    // ═══ חוזה-העמודות של ShopAssignment (G5h · חוק-7): 3 שדות-סכמה בלי מקור בזרע — עמודות-מקום-שמור, לא מזויפות ולא מושמטות ═══
    {'key': 'productId', 'label': 'productId'}, // G5h · מקום-שמור: שדה-ShopAssignment מהסכמה (Id) — מאיר כשהנתון מוזרם
    {'key': 'famId', 'label': 'famId'}, // G5h · מקום-שמור: שדה-ShopAssignment מהסכמה (Id) — מאיר כשהנתון מוזרם
    {'key': 'memberId', 'label': 'memberId'}, // G5h · מקום-שמור: שדה-ShopAssignment מהסכמה (Id | '') — מאיר כשהנתון מוזרם
    {'key': 'photo', 'label': 'תמונה'},                                                                  // מקום-שמור (WorkerCert.photo)
    {'label': 'שם', 'get': (Map<String, dynamic> t) => '${t['name']}'},
    {'label': 'תפקיד', 'get': (Map<String, dynamic> t) => roleLabel[roleOf_(t)] ?? roleOf_(t)},
    {'label': 'מקצועות', 'get': (Map<String, dynamic> t) => subjects(t).join('·')},
    {'label': 'כיתות-מחנך', 'get': (Map<String, dynamic> t) => (t['homeroom'] as List).isEmpty ? '—' : (t['homeroom'] as List).join('·')},
    {'label': 'ש׳/שבוע', 'get': (Map<String, dynamic> t) => '${hoursWeek(t).round()}/${contractHours(t)}'},
    {'label': 'עומס%', 'get': (Map<String, dynamic> t) => '${loadPct(t)}%'},
    {'label': 'חוגים', 'get': (Map<String, dynamic> t) => '${coursesOf(t).length}'},
    {'label': 'נוכח-היום', 'get': (Map<String, dynamic> t) => absentToday(t) ? '✗ נעדר' : presentToday(t) ? '✓' : '—'},
    {'label': 'היעדרויות-החודש', 'get': (Map<String, dynamic> t) => '${absencesMonth(t)}'},
    {'label': 'החלפות-שביצע', 'get': (Map<String, dynamic> t) => '${subsDone(t)}'},
    {'key': 'classAttendance', 'label': 'דירוג-נוכחות-כיתותיו'},                                       // מקום-שמור (מודול-נוכחות)
    {'label': 'ותק', 'get': (Map<String, dynamic> t) => '${tenure(t) ?? '—'} ש׳'},
    {'label': 'סטטוס', 'get': (Map<String, dynamic> t) => statusLabel[statusOf(t)] ?? statusOf(t)},
    {'key': 'contact', 'label': 'קשר'},                                                                 // מקום-שמור · חוק-6 (מוזרק · מוסתר-פר-הרשאה)
    {'key': 'salary', 'label': 'שכר'},                                                                  // מקום-שמור · מוגן-כספים (payRate של מאור — לעולם לא בקובץ)
    {'key': 'updatedAt', 'label': 'עדכון'},                                                             // מקום-שמור
  ];
  // חוזה-עובדות (metaFields · חוק-7): שדה שהרשומה נושאת ⇒ שבב; חסר ⇒ שקט. שדה חדש בדאטה מופיע לבד.
  static const metaFields = <Map<String, String>>[
    {'key': 'contractType', 'prefix': '📄 חוזה ', 'suffix': ''},
    {'key': 'contractEnd', 'prefix': '⏳ סיום ', 'suffix': ''},
    {'key': 'since', 'prefix': '🗓 מ-', 'suffix': ''},
    {'key': 'preferredSub', 'prefix': '⭐ מחליף-מועדף: ', 'suffix': ''},
    {'key': 'photo', 'prefix': '🖼 ', 'suffix': ''},            // מקום-שמור
    {'key': 'contact', 'prefix': '📞 ', 'suffix': ''},          // מקום-שמור · חוק-6
    {'key': 'peerReview', 'prefix': '🤝 הערכת-עמיתים ', 'suffix': ''}, // מקום-שמור
    {'key': 'studentFeedback', 'prefix': '💬 משוב-תלמידים ', 'suffix': ''}, // מקום-שמור
    {'key': 'personnelFile', 'prefix': '🗂 תיק-אישי ', 'suffix': ''}, // מקום-שמור
  ];
  // ייצוא: מערכת-אישית ⇒ CSV (toCsv⊕csvEscape מהמדף) · רשימת-צוות ⇒ CSV מחוזה-העמודות
  static String timetableCsv(Map<String, dynamic> t) => toCsv([
        ['חוג', 'כיתה', 'חדר', 'יום', 'שעה'],
        for (final c in coursesOf(t)) for (final s in sessionsOf(c) as List) [c['name'], c['cls'], c['roomId'], dayNames[s['day'] as int], s['time']],
      ], csvEscape) as String;
  static String rosterCsv(List<Map<String, dynamic>> rows, [Set<String> hidden = const {}]) => toCsv([
        [for (final c in columnDefs) if (colShown(c, rows, hidden)) c['label']],
        for (final t in rows) [for (final c in columnDefs) if (colShown(c, rows, hidden)) cell(c, t)],
      ], csvEscape) as String;
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows, [Set<String> hidden = const {}]) =>
      !hidden.contains(c['key']) && (c['get'] != null || rows.any((t) => t[c['key']] != null && '${t[c['key']]}'.trim().isNotEmpty));
  static String cell(Map<String, Object?> c, Map<String, dynamic> t) =>
      c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(t) : '${t[c['key']] ?? '—'}';

  // ═══ אוטומציות-חכמות (המפרט · 9) — כל אחת = מנוע-מדף ⊕ AlertBanner; מחושבות מהדאטה, אפס-זיוף ═══
  //   1 שיעור-ללא-מורה ברגע-היעדרות (syncUncovered) · 2 הצעת-מחליף (candidates) · 3 עומס-יתר/תת-עומס (volunteerLoadHint/clampScale)
  //   4 תוקף-הכשרה פג-בקרוב (certExpiryStatus) · 5 חוזה-מסתיים (dayDiff/presentsInMonth) · 6 דפוס-היעדרות (trendFromScan)
  //   7 השוואת-ביצועי-כיתות (מקום-שמור classPerf — לא-פומבי, למנהל) · 8 איזון-עומס (balanceFor) · 9 תזכורת-מערכת-יומית (sessionsOf · יום-היום)
  static List<Map<String, dynamic>> alerts(int role) {
    final out = <Map<String, dynamic>>[];
    final unc = uncoveredToday;
    if (unc.isNotEmpty) out.add({'g': '🚨', 'tone': 2, 'm': '${unc.length} שיעורים ללא שיוך היום: ${unc.map((s) => '${s['time']} ${courseById(s['courseId'] as String)?['cls']}').join(' · ')} — ${unc.where((s) => candidates(s).isNotEmpty).length} עם מחליף-מוצע'});
    final over = active.where(overLoad).toList();
    if (over.isNotEmpty) out.add({'g': '🔥', 'tone': 3, 'm': 'עומס-יתר: ${over.map((t) => '${t['name']} ${loadPct(t)}%').join(' · ')}'});
    final under = active.where(underLoad).toList();
    if (under.isNotEmpty) out.add({'g': '🪫', 'tone': 3, 'm': 'תת-עומס: ${under.map((t) => '${t['name']} ${loadPct(t)}%').join(' · ')}'});
    for (final t in active) {
      final b = balanceFor(t);
      if (b != null) out.add({'g': '⚖️', 'tone': 0, 'm': 'הצעת-איזון: להעביר ${b['course']['name']} מ-${b['from']['name']} ל-${t['name']} (ללא התנגשות-שבועית)'});
    }
    final soon = active.where((t) => certSoon(t) || certExpired(t)).toList();
    if (soon.isNotEmpty) out.add({'g': '🎓', 'tone': 3, 'm': 'הכשרות: ${soon.map((t) => '${t['name']} (${certExpired(t) ? 'פגה' : 'פגה בקרוב'})').join(' · ')}'});
    final ending = staff.where((t) => contractEndsMonth(t) || contractExpired(t)).toList();
    if (ending.isNotEmpty && (role == 0 || can(role, 'team.contract') || can(role, 'team.assign'))) out.add({'g': '📄', 'tone': 3, 'm': 'חוזים מסתיימים: ${ending.map((t) => '${t['name']} בעוד ${contractDays(t)} י׳').join(' · ')}'});
    final freq = active.where(frequentAbsentee).toList();
    if (freq.isNotEmpty && roleName(role) != 'teacher') out.add({'g': '🤒', 'tone': 3, 'm': 'דפוס-היעדרויות (לשיחת-תמיכה, לא פומבי): ${freq.map((t) => '${t['name']} · מגמה ${absenceTrend(t)['dir']}').join(' · ')}'});
    if (roleName(role) == 'admin') {
      final perf = active.where((t) => t['classPerf'] != null).toList();
      out.add(perf.isEmpty
          ? {'g': '📊', 'tone': 0, 'm': 'השוואת-ביצועי-כיתות (מי-צריך-תמיכה): מקום-שמור — יאיר כשיוזרמו נוכחות/ציונים ממודולי נוכחות/תלמידים'}
          : {'g': '📊', 'tone': 3, 'm': 'ביצועי-כיתות: ${perf.map((t) => '${t['name']} ${trendFromScan({'monthly': t['classPerf']['monthly']})['dir']}').join(' · ')}'});
    }
    final own = ownId(role) == null ? null : byId(ownId(role)!);
    if (own != null) { // תזכורת-מערכת-יומית למורה-המחובר
      final todayLessons = [for (final c in coursesOf(own)) for (final x in sessionsOf(c) as List) if (x['day'] == todayWd) '${x['time']} ${c['cls']} (${c['roomId']})']..sort();
      out.add({'g': '🗓', 'tone': 1, 'm': todayLessons.isEmpty ? 'אין לך שיעורים היום' : 'המערכת שלך להיום (${dayNames[todayWd]}): ${todayLessons.join(' · ')}'});
    }
    return out;
  }

  // ═══ פנקס-המקומות-השמורים (חוק-7 · מבחן-הקונכייה) — כל שקע חסר-נתון, מאיר לבד כשהנתון מוזרק (אפס-שינוי-קוד) ═══
  //   שדות-רשומה: מפתח בדאטה ⇒ עמודה/שבב/טאב מאירים. יכולות-הצבה: מוזרקות בלוח-האם (חוק-6/7).
  static const reservedSlots = <Map<String, String>>[
    {'key': 'photo', 'what': 'תמונה (WorkerCert.photo)', 'lights': 'עמודת-תמונה · שבב'},
    {'key': 'contact', 'what': 'קשר — טלפון/מייל (חוק-6, מוזרק)', 'lights': 'עמודת-קשר · שלח-הודעה'},
    {'key': 'salary', 'what': 'שכר (payRate — מוגן-כספים)', 'lights': 'עמודת-שכר (כספים/מנהל)'},
    {'key': 'classAttendance', 'what': 'דירוג-נוכחות-כיתותיו (מודול-נוכחות)', 'lights': 'עמודה'},
    {'key': 'classPerf', 'what': 'ביצועי-כיתות {labels,values,monthly} (נוכחות/ציונים)', 'lights': 'טאב-ביצועים · השוואה-למנהל'},
    {'key': 'updatedAt', 'what': 'עדכון-אחרון', 'lights': 'עמודה'},
    {'key': 'peerReview', 'what': 'הערכות-עמיתים', 'lights': 'שבב-סקירה'},
    {'key': 'studentFeedback', 'what': 'משוב-תלמידים', 'lights': 'שבב-סקירה'},
    {'key': 'personnelFile', 'what': 'תיק-אישי', 'lights': 'שבב-סקירה'},
    {'key': '__docs', 'what': 'אחסון-קבצים למסמכים', 'lights': 'טאב-מסמכים (הרשומה נרשמת כבר)'},
    {'key': '__pdf', 'what': 'מנוע-PDF לייצוא/הדפסה', 'lights': 'ייצוא PDF (CSV חי)'},
    {'key': '__fetch', 'what': 'חיבור-אסינק (טעינה/שגיאה)', 'lights': 'מצבי טעינה/שגיאה (השלד חי)'},
  ];
  static bool slotLit(Map<String, String> r) => !r['key']!.startsWith('__') && everyone.any((t) => t[r['key']] != null);

  // ═══ הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ teacherIdOf ⊕ canGrantedAction ═══
  //   6 תפקידי-המפרט כעקרונות-דמו אטומים ('p:...' — לא מיילים, לא זהות-אמת; בהצבה מוזרקת זהות-ההתחברות).
  //   roleOf ⇒ admin/teacher/staff · teacherIdOf ⇒ המורה-המחובר (כרטיס-שלו בלבד) · features ⇒ פעולות-מגודרות.
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👑 מנהל/ת', 'principal': 'p:mgr', 'config': {'adminEmails': ['p:mgr']}},
    {'label': '🧭 רכז/ת', 'principal': 'p:coord', 'config': {'features': {'team.assign': true, 'team.sub': true, 'team.avail': true, 'team.absence': true, 'team.export': true}}},
    {'label': '🗂 מזכירות', 'principal': 'p:sec', 'config': {'features': {'team.add': true, 'team.docs': true, 'team.absence': true, 'team.export': true, 'team.contact': true}}},
    {'label': '👩‍🏫 שיוך', 'principal': 'p:t2', 'config': {'roles': {'teachers': {'p:t2': 't2'}}, 'features': {'team.absence': true, 'team.avail': true, 'team.cert': true}}},
    {'label': '💰 כספים', 'principal': 'p:fin', 'config': {'features': {'team.salary': true, 'team.contract': true, 'team.export': true}}},
    {'label': '👁 צפייה', 'principal': 'p:view', 'config': <String, dynamic>{}},
  ];
  static Map<String, dynamic> _cfg(int role) => (roleDefs[role]['config'] as Map).cast<String, dynamic>();
  static String _principal(int role) => roleDefs[role]['principal'] as String;
  static bool _isAdmin(Map<String, dynamic> config, String p) => roleOf(config, p) == 'admin';
  static String roleName(int role) => roleOf(_cfg(role), _principal(role)); // admin · teacher · staff
  static String? ownId(int role) => teacherIdOf(_cfg(role), _principal(role)) as String?; // מורה ⇒ הכרטיס-שלו
  static bool can(int role, String key) => canGrantedAction(_cfg(role), _principal(role), false, key, _isAdmin);
  // RLS-תצוגה: עמודות/שדות מוגנים — קשר (מזכירות/מנהל) · שכר (כספים/מנהל) · הערות-הנהלה (מנהל) · חוזה (כספים/רכז/מנהל)
  static Set<String> hiddenKeys(int role) => {
        if (!can(role, 'team.contact')) 'contact',
        if (!can(role, 'team.salary')) 'salary',
        if (roleName(role) != 'admin') 'notes',
        if (!can(role, 'team.contract') && !can(role, 'team.assign')) 'contractEnd',
      };
  static bool canSee(int role, Map<String, dynamic> t) => ownId(role) == null || ownId(role) == t['id']; // מורה: לא-של-אחרים

  // ─── פנקס-פעולות (מצב=חיווט · הבסיס const נשאר מקור-האמת) ───
  static final Map<String, String> statusOverride = {};
  static String statusOf(Map<String, dynamic> t) => statusOverride[t['id']] ?? (t['status'] as String);
  static final Map<String, List<Map<String, dynamic>>> extraAbsences = {};
  static final Map<String, List<Map<String, dynamic>>> extraCerts = {};
  static final Map<String, String> reassigned = {}; // courseId ⇒ teacherId (הקצה-כיתה)
  static final Map<String, List<String>> extraSubjects = {}; // הקצה-מקצוע
  static final Map<String, String> roleOverride = {}; // ערוך: תפקיד
  static final Map<String, Map<int, List<String>>> availOverride = {}; // עדכן-זמינות
  static final Map<String, List<Map<String, dynamic>>> docs = {}; // מקום-שמור: מסמכים (צרף-מסמך רושם רשומה)
  static String roleOf_(Map<String, dynamic> t) => roleOverride[t['id']] ?? (t['role'] as String);
  static Map<int, List<String>> availabilityOf(Map<String, dynamic> t) => availOverride[t['id']] ?? (t['availability'] as Map).cast<int, List<String>>();
  static const subjectPool = ['מתמטיקה', 'אנגלית', 'פיזיקה', 'היסטוריה', 'אזרחות', 'ביולוגיה', 'חינוך'];
  static void addSubject(Map<String, dynamic> t, String who) { // הקצה-מקצוע: המקצוע הבא מהמאגר שאינו-בידו
    final has = subjects(t);
    for (final sj in subjectPool) {
      if (!has.contains(sj)) {
        (extraSubjects[t['id'] as String] ??= []).add(sj);
        log(who, 'הקצאת-מקצוע ($sj)', t['name'] as String);
        return;
      }
    }
  }
  static void cycleRole(Map<String, dynamic> t, String who) { // ערוך: תפקיד (מחזור מבוקר)
    const order = ['homeroom', 'subject', 'aide', 'mgmt'];
    final next = order[(order.indexOf(roleOf_(t)) + 1) % order.length];
    roleOverride[t['id'] as String] = next;
    log(who, 'עריכה: תפקיד ⇒ ${roleLabel[next]}', t['name'] as String);
  }
  static void toggleFriday(Map<String, dynamic> t, String who) { // עדכן-זמינות: חלון-שישי
    final cur = Map<int, List<String>>.from(availabilityOf(t));
    if (cur.containsKey(5)) { cur.remove(5); } else { cur[5] = ['08:00', '12:00']; }
    availOverride[t['id'] as String] = cur;
    log(who, cur.containsKey(5) ? 'זמינות: נוסף חלון-שישי' : 'זמינות: הוסר חלון-שישי', t['name'] as String);
  }
  static void addCert(Map<String, dynamic> t, String who) {
    (extraCerts[t['id'] as String] ??= []).add({'name': 'רענון עזרה-ראשונה', 'issuer': 'מד״א', 'expiry': '2028-09-03'});
    log(who, 'הוספת-הכשרה (רענון עזרה-ראשונה)', t['name'] as String);
  }
  static void addDoc(Map<String, dynamic> t, String who) {
    (docs[t['id'] as String] ??= []).insert(0, {'name': 'מסמך ${(docs[t['id']]?.length ?? 0) + 1}', 'date': today});
    log(who, 'צירוף-מסמך', t['name'] as String);
  }
  static void cycleStatus(Map<String, dynamic> t, String who) { // סמן-עזב/חופשה: מחזור מבוקר
    const order = ['active', 'leave', 'unpaid', 'left'];
    final next = order[(order.indexOf(statusOf(t)) + 1) % order.length];
    statusOverride[t['id'] as String] = next;
    if (next != 'active') syncUncovered(); // חופשה/חל״ת ⇒ שיעורי-היום ללא-מורה
    log(who, 'סטטוס ⇒ ${statusLabel[next]}', t['name'] as String);
  }
  // איזון-עומס (הצעה · 23-ד): חוג של עמוס-מדי באותו-מקצוע שפנוי-לשבוע-שלם אצל תת-עומס (clashOf מלא + חלון-זמינות לכל מפגש)
  static Map<String, dynamic>? balanceFor(Map<String, dynamic> t) {
    if (!isActive(t) || overLoad(t)) return null;
    for (final o in active.where(overLoad)) {
      for (final c in coursesOf(o)) {
        final ss = sessionsOf(c) as List;
        // תנאי-קיבולת (נתפס ברנדר-מול-המטרה): המקבל לא הופך עמוס-מדי — שעותיו + מפגשי-החוג ≤ חוזה
        if (!subjects(t).contains(c['subject']) || clashOf(t, c) != null || hoursWeek(t) + ss.length > contractHours(t)) continue;
        if (ss.every((x) => availableAt(t, x['day'] as int, '${x['time']}'))) return {'course': c, 'from': o};
      }
    }
    return null;
  }
  static void reassign(Map<String, dynamic> c, Map<String, dynamic> to, String who) {
    reassigned[c['id'] as String] = to['id'] as String;
    log(who, 'הקצאת-כיתה (${c['name']})', to['name'] as String);
  }
  static final List<Map<String, dynamic>> audit = []; // אודיט (מי·מה·מתי) — TimelineItem
  static void log(String who, String what, String target) => audit.insert(0, {'who': who, 'what': what, 'target': target, 'date': today});
  static int _seq = 0;
  static void addTeacher(String who) { // מורה-חדש: רשומה בצורת-החוזה; זהות = מקום-שמור להזרקה (חוק-6)
    _seq++;
    added.add({'id': 'n$_seq', 'name': 'שיוך חדש/ה $_seq', 'role': 'subject', 'redemptions': <String>[], 'homeroom': <String>[], 'contractHours': 20, 'contractType': 'זמני', 'since': today, 'status': 'active',
      'availability': <int, List<String>>{}, 'constraints': <String>[], 'extraRoles': <String>[], 'certs': <Map<String, dynamic>>[], 'attendance': <Map<String, dynamic>>[], 'absences': <Map<String, dynamic>>[], 'notes': ''});
    log(who, 'שיוך-חדש (ממתין לפרטים)', 'n$_seq');
  }
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
class ShopAssignmentScreen extends StatefulWidget {
  const ShopAssignmentScreen({this.initialMetric, super.key, this.initialMode = 0, this.initialPanel, this.initialTab = 0}); // שקעי-הזרקה לתצוגה-מקדימה/בדיקה: מבט · כרטיס-פתוח · טאב
  final String? initialMetric; // G10b · תפר-סינון: מפתח-מדד (ShopAssignmentFacts.metricDefs) ⇒ הטבלה מסוננת לשורות-המדד; null ⇒ ביט-זהה
  final int initialMode;
  final String? initialPanel; // מזהה-מורה שכרטיסו נפתח אחרי הפריים-הראשון
  final int initialTab;
  @override
  State<ShopAssignmentScreen> createState() => _ShopAssignmentScreenState();
}

  String? _metric; // G10b · המדד הנעול (null = ללא סינון-מדד)
class _ShopAssignmentScreenState extends State<ShopAssignmentScreen> {
  final Map<String, String> _coreState = {}; // G6d · פנקס-מצבי-הגרעין לפי id — overlay על הזרע (הזרע const; אין כתיבה אליו)
  int _sort = 0; // 0=⚖️ עומס · 1=🤒 חיסורים · 2=🏫 כיתות
  final Map<String, int> _tab = {}; // טאב-נבחר פר-מורה (חיווט SegmentedSwitch→תצוגה)
  static const _tabNames = ['סקירה', 'מערכת', 'כיתות', 'היעדרויות', 'החלפות', 'ביצועים', 'הכשרות', 'מסמכים', 'אודיט'];
  String _q = ''; // חיפוש-איתור (DsSearch→smartFilter)
  final Map<String, String> _locks = {}; // נעילות-סינון (FilterChipPill→finderMatches)
  int _mode = 0; // 0=🎯 חכם (טריאז') · 1=📋 טבלה (DsTable כל-העמודות) · 2=🔁 לוח-החלפות-היום (DsBoard)
  int _role = 0; // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור פר-תפקיד
  String get _who => _TeamData.roleDefs[_role]['label'] as String; // זהות-הפועל לאודיט (מהתפקיד המוזרק)
  bool _loading = false; // מצב-מסך שמור: טעינה
  String? _error; // מצב-מסך שמור: שגיאה (מקום-שמור — מאיר כש-fetch נכשל)

  @override
  void initState() {
    super.initState();
    _metric = widget.initialMetric != null && ShopAssignmentFacts.heroRows(widget.initialMetric!).isNotEmpty ? widget.initialMetric : null; // G10b · מדד בלי שורות ⇒ אין סינון (לא טבלה-ריקה בשקט)
    _mode = widget.initialMode;
    _TeamData.syncUncovered();
    final p = widget.initialPanel == null ? null : _TeamData.byId(widget.initialPanel!);
    if (p != null) {
      _tab[p['id'] as String] = widget.initialTab;
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _openPanel(p); });
    } // אוטומציה: היעדרויות-של-היום ⇒ שיעורים-ללא-מורה
  }

  @override
  Widget build(BuildContext context) {
    final all = _TeamData.active;
    final uncovered = _TeamData.uncoveredToday.length; // hero = המטרה: אף שיעור בלי מורה
    final ranked = [..._TeamData.everyone.where((t) => !_TeamData.isGone(t) && _TeamData.canSee(_role, t))]; // מורה ⇒ הכרטיס-שלו בלבד
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
    // איתור⊕חריגה (23-ג): search=DsSearch⊕smartFilter⊕smartScore⊕normSearch · filter=finderMatches — פייפליין אחד לטריאז'/טבלה/ייצוא
    final visibleAll = _TeamData.filter(_TeamData.search(ranked, _q), _locks);
    final visible = _metric == null ? visibleAll : visibleAll.where((r) => ShopAssignmentFacts.heroRows(_metric!).any((h) => '${h[ShopAssignmentFacts.idKey] ?? h['id']}' == '${r[ShopAssignmentFacts.idKey] ?? r['id']}')).toList(); // G10b · סינון-לפי-מדד (זהות לפי מזהה — שורות-המדד וטבלת-המסך אותו סוג-רשומה, L66)
    // טריאז' — פעולת-יסוד "הכרעה" מקבצת פר-דחיפות-מאוחדת (sev)
    final buckets = <int, List<Map<String, dynamic>>>{3: [], 2: [], 1: [], 0: [], -1: []};
    for (final t in visible) {
      buckets[_TeamData.sev(t)]!.add(t);
    }
    const secTitle = {3: '🔴 שיעור-ללא-שיוך היום', 2: '🟠 דורש-טיפול', 1: '🟡 לתשומת-לב', 0: '🟢 תקין', -1: '⏸ לא-פעיל/חופשה'};
    const secTone = {3: 2, 2: 3, 1: 3, 0: 1, -1: 0};
    return DsScaffold(
      title: 'מורים וצוות',
      subtitle: '${_TeamData.staff.length} אנשי-צוות · ${_TeamData.byRole.map((r) => '${r[0]} ${r[1]}').join(' · ')}',
      icon: '👩‍🏫',
      children: [
        // ═══ סינון-לפי-מדד (G10b): הרכזת שלחה מדד ⇒ הטבלה מוגבלת לשורותיו; הבאנר = עובדת-הסינון, הכפתור מסיר ═══
        if (_metric != null) AlertBanner(glyph: '🎯', tone: 1, message: 'מסונן למדד: ${ShopAssignmentFacts.metricDefs.firstWhere((d) => d['key'] == _metric, orElse: () => const {'label': ''})['label']} · ${visible.length} מתוך ${visibleAll.length}'),
        if (_metric != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: SoftButton(label: '✖ בטל סינון-מדד', tone: 2, onTap: () => setState(() => _metric = null))),
        // ═══ הגרעין-מהסכמה (G6c): ShopAssignmentCore — מצבים חצובים ⊕ מעבר מאטום-המדף ⊕ חוקים/ערוצים — לא מומצא, לא מצויר-ביד ═══
        DsSection(title: '🧠 מחזור-חיים · ${ShopAssignmentCore.term} (גרעין)', children: [
          Wrap(spacing: 6, runSpacing: 6, children: [for (final s in ShopAssignmentCore.states) StatusChip(label: s, tone: s == ShopAssignmentCore.states.first ? 1 : 0)]),
          AlertBanner(message: 'הבא אחרי ${ShopAssignmentCore.states.first}: ${ShopAssignmentCore.next(ShopAssignmentCore.states.first) ?? 'סופי'} · ${ShopAssignmentCore.rules.length} חוקים · ${ShopAssignmentCore.channels.length} ערוצים · ${ShopAssignmentCore.relations.length} יחסים', tone: 0, glyph: '🧠'),
        ]),
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — roleOf⊕teacherIdOf⊕canGrantedAction מגדרים פעולות/עמודות/רשומות
        //   6 תפקידים ב-2 שורות של SegmentedSwitch (Row-מבוקר; 6 פריטים גולשים ברוחב-המסך — נתפס בבדיקת-widget)
        for (var r = 0; r < 2; r++) ...[
          Align(alignment: Alignment.centerRight, child: SegmentedSwitch(items: [for (final d in _TeamData.roleDefs.sublist(r * 3, r * 3 + 3)) d['label'] as String], selected: _role ~/ 3 == r ? _role % 3 : -1, onSelect: (i) => setState(() => _role = r * 3 + i))),
          _gap(6),
        ],
        _gap(4),
        // KPI-10: hero=שיעורים-ללא-מורה-היום (המטרה) + 10 מדדי-מצב (BareStat נושאי-ערך-אמת)
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatBlock(fields: ['שיעורים ללא שיוך היום', '$uncovered', ''])),
            const SizedBox(height: 14),
            Row(children: [
              BareStat(value: '${_TeamData.staff.length}', label: '👥 סך-צוות', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${all.length}', label: '✅ פעילים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_TeamData.absentN}', label: '🤒 נעדרים היום', inkColor: _TeamData.absentN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '$uncovered', label: '🚨 ללא-שיוך', inkColor: uncovered > 0 ? _danger : _ok, mutedColor: _muted),
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
        const SizedBox(height: 8),
        // מרכז-אוטומציות (23-ג · פרואקטיבי): המערכת מתריעה לפני שדבר נשמט — 9 אוטומציות-המפרט
        for (final a in _TeamData.alerts(_role)) ...[AlertBanner(glyph: a['g'] as String, tone: a['tone'] as int, message: a['m'] as String), _gap(6)],
        const SizedBox(height: 4),
        // פס-עליון: חיפוש-מבוקר (DsSearch) · מורה-חדש · לוח-החלפות-היום · ייצוא (רשימה-נראית)
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔄', tone: 0, onTap: _refresh)),
          if (_TeamData.can(_role, 'team.add')) ...[const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '➕ שיוך', tone: 0, onTap: () => setState(() => _TeamData.addTeacher(_who))))],
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔁 היום', tone: _TeamData.uncoveredToday.isEmpty ? 0 : 2, onTap: () => setState(() => _mode = 2))),
          if (_TeamData.can(_role, 'team.export') && exportAllowed(false)) ...[const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '⬇ CSV', tone: 0, onTap: () => _openExport('רשימת-צוות · ${visible.length}', _TeamData.rosterCsv(visible, _TeamData.hiddenKeys(_role)))))],
        ]),
        // פילטרים (המפרט: 11) — צ׳יפי-חריגה (finderMatches) + תפקיד/סטטוס (SegmentedSwitch) + מקצוע/כיתה (FilterChipPill)
        Wrap(spacing: 8, runSpacing: 6, children: [
          _fchip('absent', '🤒 נעדר-היום · ${_TeamData.absentN}'),
          _fchip('over', '🔥 עומס>סף · ${_TeamData.overN}'),
          _fchip('under', '🪫 עומס<סף · ${_TeamData.underN}'),
          _fchip('cert', '🎓 הכשרה-חסרה/פגה'),
          _fchip('contract', '📄 חוזה-פג'),
          _fchip('free', '🟢 זמין ב-${_TeamData.openSlot}'),
        ]),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: SegmentedSwitch(items: const ['כל תפקיד', 'מחנך', 'מקצועי', 'סייע', 'הנהלה'], selected: _segIdx('role', const ['homeroom', 'subject', 'aide', 'mgmt']), onSelect: (i) => _segSet('role', const ['homeroom', 'subject', 'aide', 'mgmt'], i))),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerRight, child: SegmentedSwitch(items: const ['כל סטטוס', 'פעיל', 'חופשה', 'חל״ת', 'עזב'], selected: _segIdx('status', const ['active', 'leave', 'unpaid', 'left']), onSelect: (i) => _segSet('status', const ['active', 'leave', 'unpaid', 'left'], i))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [for (final sj in _TeamData.allSubjects) _vchip('subject', sj, '📚 $sj')]),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 6, children: [for (final c in _TeamData.allClasses.take(10)) _vchip('cls', c, '🏫 $c')]),
        const SizedBox(height: 10),
        // מיון (המפרט: עומס · חיסורים · כיתות) — SegmentedSwitch מבוקר
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(items: const ['⚖️ עומס', '🤒 חיסורים', '🏫 כיתות'], selected: _sort, onSelect: (i) => setState(() => _sort = i)),
        ),
        const SizedBox(height: 10),
        // בורר-מבט (SegmentedSwitch מבוקר): 🎯 חכם (טריאז'-החלטה) · 📋 טבלה (חוזה-עמודות) · 🔁 לוח-החלפות-היום
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(items: const ['🎯 חכם', '📋 טבלה', '🔁 החלפות היום'], selected: _mode, onSelect: (i) => setState(() => _mode = i)),
        ),
        const SizedBox(height: 10),
        // מצבי-מסך שמורים: טעינה · שגיאה · אין-צוות · ללא-תוצאות — ואז התוכן
        if (_loading)
          _loadingView()
        else if (_error != null)
          AlertBanner(glyph: '⚠️', tone: 2, message: _error!)
        else if (_TeamData.staff.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '👥', message: 'אין צוות — הוסף שיוך ראשון/ה'))
        else if (_mode == 2)
          _subsBoard()
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '🔍', message: 'אין אנשי-צוות תואמים לחיפוש/סינון'))
        else if (_mode == 1)
          _table(visible)
        else
          for (final st in const [3, 2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              DsSection(title: '${secTitle[st]} · ${buckets[st]!.length}', tone: secTone[st]!, children: [
                for (final t in buckets[st]!) _row(t),
              ]),
        // פנקס-המקומות-השמורים (חוק-7): שקוף לגבי מה עוד לא מואר — ExpandableTile (מתקפל)
        _gap(6),
        ExpandableTile(
          title: '🔌 מקומות-שמורים · ${_TeamData.reservedSlots.where((r) => !_TeamData.slotLit(r)).length} ממתינים לנתון · ${_TeamData.reservedSlots.where(_TeamData.slotLit).length} מוארים',
          body: [for (final r in _TeamData.reservedSlots) '${_TeamData.slotLit(r) ? '💡' : '⚫'} ${r['what']} ⇒ ${r['lights']}'].join('\n'),
        ),
      ],
    );
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה; כשל ⇒ _error)
  void _refresh() {
    setState(() { _loading = true; _error = null; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _loading = false); });
  }
  // מצב-טעינה: מחוון-מסגרת סטנדרטי (אפס ShimmerSkeleton מזייף); Column ולא Center (גובה-לא-חסום ברשימה)
  Widget _loadingView() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc), const SizedBox(height: 14),
          const Text('טוען צוות…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  // צ׳יפ-סינון מבוקר: הזרקת-צבעים (חוק-6) + נעילת-ציר ב-_locks (finderMatches)
  Widget _fchip(String axis, String label) => _vchip(axis, '1', label);
  Widget _vchip(String axis, String value, String label) => FilterChipPill(
        label: label, selected: _locks[axis] == value,
        onTap: () => setState(() => _locks[axis] == value ? _locks.remove(axis) : _locks[axis] = value),
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15), inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );
  int _segIdx(String axis, List<String> vals) => _locks[axis] == null ? 0 : vals.indexOf(_locks[axis]!) + 1;
  void _segSet(String axis, List<String> vals, int i) => setState(() => i == 0 ? _locks.remove(axis) : _locks[axis] = vals[i - 1]);

  // ═══ כרטיס-מורה-נבחר (צד) · GlassCard(child) · 9 טאבים (SegmentedSwitch×2) · 14 פעולות (SoftButton) ═══
  void _openPanel(Map<String, dynamic> t) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) {
          void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
          final tab = _tab[t['id']] ?? 0;
          return DraggableScrollableSheet(
            initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
            builder: (ctx, scroll) => Padding(
              padding: const EdgeInsets.all(12),
              child: GlassCard(
                child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  // ═══ הגרעין על הרשומה (G6d): מצב-הרשומה ⊕ ShopAssignmentCore.next ⊕ פנקס-overlay — מצב שאינו במחזור-החיים החצוב מדווח כפער, לא מתוקן בשקט ═══
                  Builder(builder: (_) {
                    final cur = _coreState['${t['id']}'] ?? '${t['status'] ?? ShopAssignmentCore.states.first}';
                    if (!ShopAssignmentCore.states.contains(cur)) return AlertBanner(message: 'מצב הרשומה "$cur" אינו במחזור-החיים החצוב (${ShopAssignmentCore.states.join('→')}) — פער זרע/סכמה, מקום-שמור', tone: 3, glyph: '🧠');
                    final nx = ShopAssignmentCore.next(cur);
                    return DsSection(title: '🧠 מחזור-חיים · רשומה (גרעין)', children: [
                      Wrap(spacing: 6, runSpacing: 6, children: [for (final st in ShopAssignmentCore.states) StatusChip(label: st, tone: st == cur ? 1 : 0)]),
                      AlertBanner(message: nx == null ? 'מצב-סופי: $cur' : 'הבא אחרי $cur: $nx', tone: 0, glyph: '🧠'),
                      SoftButton(label: nx == null ? 'אין מעבר' : 'קדם מצב ⇒ $nx', onTap: nx == null ? null : () => act(() => _coreState['${t['id']}'] = nx)),
                    ]);
                  }),
                  Row(children: [
                    PremiumAvatar(name: t['name'] as String, size: 56, status: _TeamData.absentToday(t) ? AvatarStatus.busy : _TeamData.presentToday(t) ? AvatarStatus.online : AvatarStatus.none),
                    const SizedBox(width: 10),
                    Expanded(child: MediaRow(glyph: '🪪', title: '${t['name']} · ${_TeamData.roleLabel[_TeamData.roleOf_(t)]}', subtitle: '${_TeamData.subjects(t).join(' · ')} · ותק ${_TeamData.tenure(t) ?? '—'} ש׳ · ${_TeamData.statusLabel[_TeamData.statusOf(t)]}')),
                  ]),
                  _gap(12),
                  StatRow(label: 'עומס מול חוזה', value: '${_TeamData.hoursWeek(t).round()} מתוך ${_TeamData.contractHours(t)} ש׳ · ${_TeamData.loadPct(t)}%', fraction: (_TeamData.loadPct(t) / 100).clamp(0.0, 1.0)),
                  _gap(10),
                  Row(children: [
                    BareStat(value: '${_TeamData.coursesOf(t).length}', label: 'חוגים', inkColor: _ink, mutedColor: _muted),
                    BareStat(value: '${_TeamData.sessionsWeek(t)}', label: 'שיעורים/שבוע', inkColor: _ink, mutedColor: _muted),
                    BareStat(value: '${_TeamData.absencesMonth(t)}', label: 'היעדרויות החודש', inkColor: _TeamData.absencesMonth(t) > 0 ? _warning : _ok, mutedColor: _muted),
                    BareStat(value: '${_TeamData.subsDone(t)}/${_TeamData.subsReceived(t)}', label: 'החלפות ביצע/קיבל', inkColor: _acc, mutedColor: _muted),
                  ]),
                  _gap(12),
                  // 9 טאבים ב-3 שורות של SegmentedSwitch (Row-מבוקר; 4+ פריטים גולשים ברוחב-הגיליון — נתפס בבדיקת-widget)
                  for (var r = 0; r < 3; r++) ...[
                    Align(alignment: Alignment.centerRight, child: SegmentedSwitch(items: _tabNames.sublist(r * 3, r * 3 + 3), selected: tab ~/ 3 == r ? tab % 3 : -1, onSelect: (i) => act(() => _tab[t['id'] as String] = r * 3 + i))),
                    _gap(6),
                  ],
                  _gap(12),
                  _tabView(t, tab, act),
                  _gap(16),
                  const Text('פעולות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                  _gap(8),
                  _actions(t, act, ctx),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _tabView(Map<String, dynamic> t, int tab, void Function(void Function()) act) {
    switch (tab) {
      case 1: return _timetable(t);
      case 2: return _classes(t, act);
      case 3: return _absences(t);
      case 4: return _subsOf(t);
      case 5: return _performance(t);
      case 6: return _certs(t);
      case 7: return _docs(t);
      case 8: return _audit(t);
      default: return _overview(t);
    }
  }

  // סקירה: עובדות (metaFields גנרי) + זמינות + אילוצים + תפקידים-נוספים + הערות-הנהלה (מוגן — גל 5)
  Widget _overview(Map<String, dynamic> t) {
    final av = _TeamData.availabilityOf(t);
    final days = av.keys.toList()..sort();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 6, children: [
        for (final f in _TeamData.metaFields)
          if (t[f['key']] != null) StatusChip(label: '${f['prefix']}${f['key'] == 'preferredSub' ? _TeamData.nameOf(t[f['key']] as String) : f['key']!.contains('Date') || f['key'] == 'contractEnd' ? fmtDate('${t[f['key']]}') : t[f['key']]}${f['suffix']}', tone: 0),
        for (final r in (t['extraRoles'] as List)) StatusChip(label: '🎖 $r', tone: 1),
        for (final c in (t['constraints'] as List)) StatusChip(label: '⛔ $c', tone: 3),
      ]),
      _gap(10),
      Text('זמינות שבועית · ${days.length} ימים', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
      _gap(6),
      Wrap(spacing: 8, runSpacing: 6, children: [
        for (final d in days) DsChip(label: '${dayNames[d]} ${av[d]![0]}–${av[d]![1]}', tone: 0),
        if (days.isEmpty) const DsChip(label: 'אין חלונות-זמינות (חופשה/עזב)', tone: 2),
      ]),
      if ('${t['notes']}'.isNotEmpty && !_TeamData.hiddenKeys(_role).contains('notes')) ...[_gap(10), AlertBanner(glyph: '🔒', tone: 0, message: 'הערת-הנהלה (מוגן): ${t['notes']}')],
      if (_TeamData.hiddenKeys(_role).contains('notes')) ...[_gap(10), const AlertBanner(glyph: '🔒', tone: 0, message: 'הערות-הנהלה מוגנות — למנהל/ת בלבד')],
      if (_TeamData.balanceFor(t) != null) ...[
        _gap(10),
        AlertBanner(glyph: '⚖️', tone: 3, message: 'הצעת-איזון: להעביר ${_TeamData.balanceFor(t)!['course']['name']} מ-${_TeamData.balanceFor(t)!['from']['name']} (עמוס-מדי) לכאן'),
      ],
    ]);
  }

  // מערכת-שבועית אישית: DsTable ⊕ sessionsOf ⊕ timeToMin (מיון-שעות) — שורה=שעה · עמודה=יום · תא=כיתה·חדר
  Widget _timetable(Map<String, dynamic> t) {
    final cs = _TeamData.coursesOf(t);
    final grid = <String, Map<int, String>>{};
    for (final c in cs) {
      for (final s in sessionsOf(c) as List) {
        (grid['${s['time']}'] ??= {})[s['day'] as int] = '${c['cls']} · ${c['roomId']}';
      }
    }
    final times = grid.keys.toList()..sort((a, b) => (timeToMin(a) as num).compareTo(timeToMin(b) as num));
    const days = [0, 1, 2, 3, 4, 5];
    if (times.isEmpty) return const EmptyState(glyph: '🗓', message: 'אין שיעורים במערכת');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DsTable(labels: ['שעה', for (final d in days) dayNames[d]], rows: [for (final tm in times) [tm, for (final d in days) grid[tm]![d] ?? '—']]),
      _gap(6),
      Row(children: [
        BareStat(value: '${times.length}', label: 'רצועות-שעה', inkColor: _ink, mutedColor: _muted),
        BareStat(value: '${_TeamData.sessionsWeek(t)}', label: 'שיעורים/שבוע', inkColor: _ink, mutedColor: _muted),
        BareStat(value: minToHM((timeToMin(times.first) as num).toInt(), (n) => n.toString().padLeft(2, '0')), label: 'שיעור-ראשון', inkColor: _acc, mutedColor: _muted),
      ]),
    ]);
  }

  // כיתות: חוג ⇒ MediaRow (שם·כיתה·חדר·מפגשים) · הקצה-כיתה = איזון (balanceFor)
  Widget _classes(Map<String, dynamic> t, void Function(void Function()) act) {
    final cs = _TeamData.coursesOf(t);
    final bal = _TeamData.balanceFor(t);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (cs.isEmpty) const EmptyState(glyph: '🏫', message: 'לא הוקצו חוגים'),
      for (final c in cs)
        MediaRow(glyph: '📘', title: '${c['name']} · חדר ${c['roomId']}', subtitle: '${(sessionsOf(c) as List).length} מפגשים/שבוע · ${(sessionsOf(c) as List).map((s) => '${dayNames[s['day'] as int]} ${s['time']}').join(' · ')}'),
      if (bal != null && _TeamData.can(_role, 'team.assign')) ...[
        _gap(8),
        Wrap(children: [SoftButton(label: '🏫 הקצה-כיתה: ${bal['course']['name']} מ-${bal['from']['name']}', tone: 1, onTap: () => act(() => _TeamData.reassign(bal['course'] as Map<String, dynamic>, t, _who)))]),
      ],
    ]);
  }

  // היעדרויות: ציר (TimelineItem×list) ⊕ NeonBars(4 חודשים) ⊕ trendFromScan (דפוס)
  Widget _absences(Map<String, dynamic> t) {
    final list = _TeamData.absencesOf(t);
    final monthly = _TeamData.absenceMonthly(t);
    final trend = _TeamData.absenceTrend(t);
    final base = DateTime.parse('${_TeamData.today}T12:00:00');
    final labels = [for (var i = 3; i >= 0; i--) () { final m = DateTime(base.year, base.month - i); return '${m.month}/${m.year % 100}'; }()];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      NeonBars(labels: labels, values: [for (final v in monthly) v.toDouble()], tone: _TeamData.frequentAbsentee(t) ? 2 : 1),
      _gap(6),
      Wrap(spacing: 8, children: [
        StatusChip(label: 'מגמה: ${trend['dir'] == 'up' ? '↑ עולה' : trend['dir'] == 'down' ? '↓ יורדת' : '→ יציבה'} ${trend['pct']}%', tone: trend['dir'] == 'up' ? 2 : 1),
        if (_TeamData.frequentAbsentee(t)) const StatusChip(label: 'דפוס-היעדרות — לשיחת-תמיכה', tone: 3),
      ]),
      _gap(10),
      if (list.isEmpty) const EmptyState(glyph: '🌤', message: 'אין היעדרויות רשומות'),
      for (final a in list)
        TimelineItem(title: '🤒 ${_TeamData.reasonOf(a['reason'] as String)}', time: fmtDate(a['date'] as String), body: () {
          final covered = _TeamData.subs.where((s) => s['absentId'] == t['id'] && s['date'] == a['date']).toList();
          return covered.isEmpty ? 'ללא רישום-החלפה' : '${covered.where((s) => s['stage'] == 2).length}/${covered.length} שיעורים כוסו';
        }()),
    ]);
  }

  // החלפות: ביצע/קיבל (TimelineItem)
  Widget _subsOf(Map<String, dynamic> t) {
    final mine = _TeamData.subs.where((s) => s['subId'] == t['id'] || s['absentId'] == t['id']).toList()..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    if (mine.isEmpty) return const EmptyState(glyph: '🔁', message: 'אין החלפות');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final s in mine)
        TimelineItem(
          title: '${s['subId'] == t['id'] ? '🟢 ביצע/ה' : '🟠 קיבל/ה'} · ${_TeamData.courseById(s['courseId'] as String)?['name']}',
          time: '${fmtDate(s['date'] as String)}${s['time'] != null ? ' ${s['time']}' : ''}',
          body: '${s['stage'] == 2 ? '✅ אושר' : s['stage'] == 1 ? '🟠 הוצע' : '🔴 ללא-מחליף'} · ${s['subId'] == t['id'] ? 'במקום ${_TeamData.nameOf(s['absentId'] as String)}' : 'מחליף: ${_TeamData.nameOf(s['subId'] as String?)}'}',
        ),
    ]);
  }

  // ביצועי-כיתות (מקום-שמור · §20-ג): מאיר רק כשמוזרם classPerf {labels, values, monthly} ממודולי נוכחות/תלמידים
  Widget _performance(Map<String, dynamic> t) {
    final perf = t['classPerf'] as Map<String, dynamic>?;
    if (perf == null) return const EmptyState(glyph: '📊', message: 'מקום-שמור: נוכחות/ציוני-כיתותיו יאירו כשיוזרמו ממודולי נוכחות ותלמידים (לא מזייפים)');
    final trend = trendFromScan({'monthly': perf['monthly']});
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      NeonBars(labels: (perf['labels'] as List).cast<String>(), values: (perf['values'] as List).map((v) => (v as num).toDouble()).toList(), tone: trend['dir'] == 'down' ? 2 : 1),
      _gap(6),
      StatusChip(label: 'מגמה ${trend['dir']} ${trend['pct']}%', tone: trend['dir'] == 'down' ? 2 : 1),
    ]);
  }

  // הכשרות+תוקף: MediaRow ⊕ StatusChip(certExpiryStatus)
  Widget _certs(Map<String, dynamic> t) {
    final cs = _TeamData.certsOf(t);
    if (cs.isEmpty) return const EmptyState(glyph: '🎓', message: 'אין הכשרות רשומות — הכשרה-חסרה');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final c in cs)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: MediaRow(glyph: '🎓', title: '${c['name']}', subtitle: '${c['issuer']} · תוקף ${fmtDate(c['expiry'] as String)}')),
            () {
              final st = _TeamData.certStatus(c);
              return StatusChip(label: st == CertExpiryStatus.expired ? 'פג' : st == CertExpiryStatus.expiringSoon ? 'פג בקרוב' : 'בתוקף', tone: st == CertExpiryStatus.expired ? 2 : st == CertExpiryStatus.expiringSoon ? 3 : 1);
            }(),
          ]),
        ),
    ]);
  }

  // מסמכים (מקום-שמור): רשומות שנרשמו ב"צרף-מסמך"; אין ⇒ ריק-אמת
  Widget _docs(Map<String, dynamic> t) {
    final ds = _TeamData.docs[t['id']] ?? const [];
    if (ds.isEmpty) return const EmptyState(glyph: '📎', message: 'אין מסמכים — צרף-מסמך ירשום כאן (אחסון-קבצים = מקום-שמור להצבה)');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final d in ds) TimelineItem(title: '📎 ${d['name']}', time: fmtDate(d['date'] as String))]);
  }

  // אודיט: כל פעולה שנרשמה בפנקס (מי·מה·מתי) — TimelineItem
  Widget _audit(Map<String, dynamic> t) {
    final rows = _TeamData.audit.where((a) => a['target'] == t['name'] || '${a['target']}'.contains('${t['name']}')).toList();
    if (rows.isEmpty) return const EmptyState(glyph: '🧾', message: 'אין רישומי-אודיט לשיוך זה');
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final a in rows) TimelineItem(title: '${a['what']}', time: fmtDate(a['date'] as String), body: 'ע״י ${a['who']}')]);
  }

  // 14 פעולות (המפרט) — SoftButton; מגודרות-הרשאה בגל 5. חסר-נתון ⇒ מקום-שמור מפורש, לא זיוף.
  Widget _actions(Map<String, dynamic> t, void Function(void Function()) act, BuildContext sheetCtx) {
    final reasons = absenceReasonChips(term: (k) => kTerms[k] ?? k);
    final keys = kTerms.keys.toList();
    final r = _role;
    final acts = <Widget>[
      if (_TeamData.can(r, 'team.assign')) SoftButton(label: '✏️ ערוך תפקיד', tone: 0, onTap: () => act(() => _TeamData.cycleRole(t, _who))),
      if (_TeamData.can(r, 'team.assign')) SoftButton(label: '📚 הקצה-מקצוע', tone: 0, onTap: () => act(() => _TeamData.addSubject(t, _who))),
      if (_TeamData.can(r, 'team.sub')) SoftButton(label: '🔎 מצא-מחליף', tone: 1, onTap: () { Navigator.of(sheetCtx).pop(); setState(() => _mode = 2); }),
      if (_TeamData.can(r, 'team.avail')) SoftButton(label: '🗓 עדכן-זמינות (שישי)', tone: 0, onTap: () => act(() => _TeamData.toggleFriday(t, _who))),
      if (_TeamData.can(r, 'team.cert') || _TeamData.can(r, 'team.docs')) SoftButton(label: '🎓 הוסף-הכשרה', tone: 0, onTap: () => act(() => _TeamData.addCert(t, _who))),
      if (_TeamData.can(r, 'team.docs')) SoftButton(label: '📎 צרף-מסמך', tone: 0, onTap: () => act(() => _TeamData.addDoc(t, _who))),
      SoftButton(label: '🖨 הדפס-מערכת', tone: 0, onTap: () => _openExport('מערכת אישית · ${t['name']}', _TeamData.timetableCsv(t))),
      if (_TeamData.roleName(r) == 'admin') SoftButton(label: '⏸ ${_TeamData.statusOf(t) == 'active' ? 'סמן-חופשה' : 'שנה-סטטוס'}', tone: 2, onTap: () => act(() => _TeamData.cycleStatus(t, _who))),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, children: acts),
      if (acts.length <= 1) ...[_gap(8), const AlertBanner(message: 'צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה', glyph: '🔒', tone: 2)],
      _gap(8),
      if (!_TeamData.can(r, 'team.contact'))
        const AlertBanner(glyph: '🔒', tone: 0, message: 'שלח-הודעה: פרטי-קשר מוסתרים לתפקיד זה (הרשאה)')
      else if (t['contact'] == null)
        const AlertBanner(glyph: '💬', tone: 0, message: 'שלח-הודעה: פרטי-קשר מוזרקים בהצבה (חוק-6) — מקום-שמור, מאיר כשיוזרק contact')
      else
        Wrap(children: [SoftButton(label: '💬 שלח-הודעה', tone: 1, onTap: () => act(() => _TeamData.log(_who, 'שליחת-הודעה', t['name'] as String)))]),
      _gap(8),
      if (!_TeamData.can(r, 'team.absence'))
        const SizedBox.shrink()
      else if (!_TeamData.absentOn(t, _TeamData.today)) ...[
        const Text('🤒 סמן-היעדרות היום — סיבה:', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
        _gap(6),
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (var i = 0; i < reasons.length; i++) SoftButton(label: reasons[i], tone: 2, onTap: () => act(() => _TeamData.markAbsent(t, keys[i], _who))),
        ]),
      ] else
        const AlertBanner(glyph: '🤒', tone: 2, message: 'מסומן/ת נעדר/ת היום — שיעורי-היום נרשמו בלוח-ההחלפות'),
    ]);
  }

  // ייצוא/הדפסה: GlassCard-preview של CSV (toCsv⊕csvEscape⊕exportAllowed) — בסנדבוקס ההורדה חסומה ⇒ תצוגה+העתקה
  void _openExport(String title, String csv) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              MediaRow(glyph: '⬇', title: title, subtitle: 'CSV · BOM + חסימת-הזרקה · PDF = מקום-שמור (מנוע-PDF בהצבה)'),
              _gap(8),
              if (!exportAllowed(false))
                const AlertBanner(message: 'ייצוא חסום (שער-יציאת-מידע)', tone: 2)
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                  child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
                ),
            ]),
          ),
        ),
      ),
    );
  }

  // 📋 מבט-טבלה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid (מזייף int rows).
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _TeamData.columnDefs) if (_TeamData.colShown(c, rows, _TeamData.hiddenKeys(_role))) c];
    return DsTable(labels: [for (final c in cols) c['label'] as String], rows: [for (final t in rows) [for (final c in cols) _TeamData.cell(c, t)]]);
  }

  // 🔁 לוח-החלפות-היום (זיהוי-חריגה ⇒ הכרעה ⇒ ביצוע): DsBoard (תפר-דאטה: stages+records+onMove) ⊕ candidates
  //   (זמין ∧ מקצוע ∧ פנוי-בסלוט[scheduleClashText] ∧ עומס-נמוך ∧ מועדף) ⊕ taskOverdue (החלפה שעבר מועדה).
  Widget _subsBoard() {
    final today = _TeamData.todaySubs;
    final open = _TeamData.uncoveredToday;
    final overdue = _TeamData.subs.where((s) => _TeamData.subOverdue(s)).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (today.isEmpty)
        const EmptyState(glyph: '🎉', message: 'אין החלפות להיום — כל השיעורים מכוסים')
      else ...[
        DsBoard(
          stages: const ['🔴 ללא-מחליף', '🟠 הוצע', '✅ אושר'],
          records: [for (final s in today) {'id': '${s['id']}', 'title': '${s['time'] ?? ''} ${_TeamData.courseById(s['courseId'] as String)?['name']} · במקום ${_TeamData.nameOf(s['absentId'] as String)}${s['subId'] != null ? ' ⇐ ${_TeamData.nameOf(s['subId'] as String)}' : ''}', 'stage': '${s['stage']}'}],
          stageOf: (r) => int.parse(r['stage']!),
          titleOf: (r) => r['title']!,
          onMove: (id, to) { if (_TeamData.can(_role, 'team.sub')) setState(() => _TeamData.moveSub(id, to, _who)); },
        ),
        if (overdue > 0) ...[_gap(8), AlertBanner(glyph: '⏰', tone: 2, message: '$overdue החלפות פתוחות שעבר מועדן')],
        _gap(10),
        // הצעת-מחליף אוטומטית פר-שיעור-פתוח: המועמד-הראשון = מועדף/עומס-נמוך; אין ⇒ אמת (לא מזייפים מחליף)
        DsSection(title: '🧭 מחליף מוצע · ${open.length} שיעורים פתוחים', tone: open.isEmpty ? 1 : 2, children: [
          if (open.isEmpty) const EmptyState(glyph: '✅', message: 'כל שיעורי-היום מכוסים')
          else for (final s in open) _subRow(s),
        ]),
      ],
    ]);
  }

  Widget _subRow(Map<String, dynamic> s) {
    final c = _TeamData.courseById(s['courseId'] as String)!;
    final cands = _TeamData.candidates(s);
    final chosen = s['subId'] == null ? null : _TeamData.byId(s['subId'] as String);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        MediaRow(glyph: '🚨', title: '${s['time'] ?? ''} · ${c['name']} · ${c['roomId']}', subtitle: 'במקום ${_TeamData.nameOf(s['absentId'] as String)} · ${s['stage'] == 1 ? 'הוצע: ${chosen?['name']}' : 'ללא-מחליף'}'),
        _gap(6),
        if (cands.isEmpty)
          const AlertBanner(glyph: '⚠️', tone: 3, message: 'אין מחליף זמין (מקצוע+חלון-זמינות+פנוי-בסלוט) — נדרשת הכרעה ידנית')
        else if (!_TeamData.can(_role, 'team.sub'))
          Wrap(spacing: 8, children: [for (final t in cands.take(3)) StatusChip(label: '${t['name']} · ${_TeamData.loadPct(t)}%', tone: 0)])
        else
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final t in cands.take(3))
              SoftButton(
                label: '${t == cands.first ? '⭐ ' : ''}${t['name']} · ${_TeamData.loadPct(t)}%${(_TeamData.byId(s['absentId'] as String)?['preferredSub']) == t['id'] ? ' · מועדף' : ''}',
                tone: t == cands.first ? 1 : 0,
                onTap: () => setState(() => _TeamData.propose(s, t, _who)),
              ),
            if (s['stage'] == 1) SoftButton(label: '✅ אשר-החלפה', tone: 1, onTap: () => setState(() => _TeamData.moveSub(s['id'] as String, 2, _who))),
          ]),
      ]),
    );
  }

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
            // MediaRow בולע את הקליק (InkWell פנימי no-op) ⇒ כפתור-שברון נפרד כשקע-הפתיחה
            IconButton(onPressed: () => _openPanel(t), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'כרטיס-שיוך ופעולות'),
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

// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): ShopAssignmentFacts — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══
class ShopAssignmentFacts {
  static const String entity = 'ShopAssignment';
  static const String label = 'שיוך'; // מונח-הישות מ-entity-terms (דאטה)
  static int get count => _TeamData.roster.length; // רשומות הזרע-הראשי "roster" (static-const)
  static const List<Map<String, String>> metricDefs = <Map<String, String>>[{'key': 'absentN', 'label': '🤒 נעדרים היום', 'tone': 'danger'}, {'key': 'openSubs', 'label': '🔁 החלפות פתוחות', 'tone': 'plain'}, {'key': 'overN', 'label': '🔥 עמוסים-מדי', 'tone': 'danger'}, {'key': 'underN', 'label': '🪫 בתת-עומס', 'tone': 'plain'}, {'key': 'contractsN', 'label': '📄 חוזים פגים החודש', 'tone': 'plain'}, {'key': 'certsN', 'label': '🎓 הכשרות חסרות', 'tone': 'danger'}]; // 6 מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי)
  static Map<String, String> get metrics => <String, String>{'absentN': '${_TeamData.absentN}', 'openSubs': '${_TeamData.openSubs}', 'overN': '${_TeamData.overN}', 'underN': '${_TeamData.underN}', 'contractsN': '${_TeamData.contractsN}', 'certsN': '${_TeamData.certsN}'};
  static const String heroKey = 'absentN'; // המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
  static String get hero => metrics[heroKey] ?? '$count';
  static String get heroLabel => '🤒 נעדרים היום';
  static const String idKey = 'id'; // מפתח-המזהה בזרע (אחרי retarget)
  static List<Map<String, dynamic>> get rows => _TeamData.roster; // כל רשומות הזרע-הראשי (static-const)
  static Map<String, dynamic>? byId(String id) { for (final r in [for (final k in const <String>['openSubs', 'overN', 'underN', 'contractsN', 'certsN']) ...heroRows(k), ...rows]) { if ('${r[idKey] ?? r['id']}' == id) return r; } return null; } // שורות-המדד קודם (הן מסוג-הרשומה שהפאנל צורך — בזהב-התלמידים הפאנל פותח תלמיד, הזרע-הראשי-לפי-מפתחות הוא families), ואז הזרע-הראשי
  static List<Map<String, dynamic>> heroRows(String key) { switch (key) { case 'openSubs': return _TeamData.rowsOf_openSubs; case 'overN': return _TeamData.rowsOf_overN; case 'underN': return _TeamData.rowsOf_underN; case 'contractsN': return _TeamData.rowsOf_contractsN; case 'certsN': return _TeamData.rowsOf_certsN; default: return const []; } } // G10a · 5 מדדים עם שורות (צורת X.where(P).length)
  static String? get heroFirstId { final r = heroRows(heroKey); return r.isEmpty ? null : '${r.first[idKey]}'; } // הרשומה-הראשונה של ה-hero — יעד-הקפיצה מהרכזת
}
