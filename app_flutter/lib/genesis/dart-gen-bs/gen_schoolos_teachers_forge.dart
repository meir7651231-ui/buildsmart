// 🎨 schoolos_teachers.dart בעור-forge (GENMAX·G12d) — מחולל דטרמיניסטי: skin-golden.mjs · הזהב לא נגע (טעינה-לצד, חוק-7) · עור: kpi=ForgeStatPlain · navTile=ForgeHubTile · stat=ForgeStatPlain · hero=ForgeStatPlain · button=ForgeSoftButton · statusChip=ForgeStatusChip · banner=ForgeSectionPill · emptyState=ForgeSearchEmptyState · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegmentedPillToggleSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeGlassCard · timeline=ForgeNotifRow · field=ForgeDsField · enumField=ForgeDsEnumField · numberField=ForgeDsNumberField · dateField=ForgeDsDateFieldInput · search=ForgeDsSearch · pageHeader=ForgeCenteredPageHeader · table=ForgeDataGrid · bars=ForgeBarChart
//   החלפות: stat×0 · hero×1 · chipRow×1 · chip×6 · statRow×17 · button×17 · statusChip×10 · banner×12 · emptyState×12 · mediaRow×6 · section×2 · segmented×6 · meter×2 · frame×4 · timeline×4 · search×1 · table×2 · bars×2 · BareStat ב-Row נשאר DS (רצועת-4) · צבעי-מצב-DS לא מועברים · חיפוש/טבלאות/פילטרים = DS (אטומי-forge של קלט הם ציור, לא שדה)
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
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/feedback/feedback.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/list/list.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
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
  static List<String> subjects(Map<String, dynamic> t) => [...(t['subjects'] as List).cast<String>(), ...extraSubjects[t['id']] ?? const []];
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
  static int get underN => active.where(underLoad).length;
  static int get contractsN => staff.where(contractEndsMonth).length;
  static int get certsN => active.where(certMissing).length;
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
    {'key': 'startDate', 'prefix': '🗓 מ-', 'suffix': ''},
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
    if (unc.isNotEmpty) out.add({'g': '🚨', 'tone': 2, 'm': '${unc.length} שיעורים ללא מורה היום: ${unc.map((s) => '${s['time']} ${courseById(s['courseId'] as String)?['cls']}').join(' · ')} — ${unc.where((s) => candidates(s).isNotEmpty).length} עם מחליף-מוצע'});
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
    {'label': '👩‍🏫 מורה', 'principal': 'p:t2', 'config': {'roles': {'teachers': {'p:t2': 't2'}}, 'features': {'team.absence': true, 'team.avail': true, 'team.cert': true}}},
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
    added.add({'id': 'n$_seq', 'name': 'מורה חדש/ה $_seq', 'role': 'subject', 'subjects': <String>[], 'homeroom': <String>[], 'contractHours': 20, 'contractType': 'זמני', 'startDate': today, 'status': 'active',
      'availability': <int, List<String>>{}, 'constraints': <String>[], 'extraRoles': <String>[], 'certs': <Map<String, dynamic>>[], 'attendance': <Map<String, dynamic>>[], 'absences': <Map<String, dynamic>>[], 'notes': ''});
    log(who, 'מורה-חדש (ממתין לפרטים)', 'n$_seq');
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
class TeachersScreen extends StatefulWidget {
  const TeachersScreen({super.key, this.initialMode = 0, this.initialPanel, this.initialTab = 0}); // שקעי-הזרקה לתצוגה-מקדימה/בדיקה: מבט · כרטיס-פתוח · טאב
  final int initialMode;
  final String? initialPanel; // מזהה-מורה שכרטיסו נפתח אחרי הפריים-הראשון
  final int initialTab;
  @override
  State<TeachersScreen> createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
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
    final visible = _TeamData.filter(_TeamData.search(ranked, _q), _locks);
    // טריאז' — פעולת-יסוד "הכרעה" מקבצת פר-דחיפות-מאוחדת (sev)
    final buckets = <int, List<Map<String, dynamic>>>{3: [], 2: [], 1: [], 0: [], -1: []};
    for (final t in visible) {
      buckets[_TeamData.sev(t)]!.add(t);
    }
    const secTitle = {3: '🔴 שיעור-ללא-מורה היום', 2: '🟠 דורש-טיפול', 1: '🟡 לתשומת-לב', 0: '🟢 תקין', -1: '⏸ לא-פעיל/חופשה'};
    const secTone = {3: 2, 2: 3, 1: 3, 0: 1, -1: 0};
    return DsScaffold(
      title: 'מורים וצוות',
      subtitle: '${_TeamData.staff.length} אנשי-צוות · ${_TeamData.byRole.map((r) => '${r[0]} ${r[1]}').join(' · ')}',
      icon: '👩‍🏫',
      children: [
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — roleOf⊕teacherIdOf⊕canGrantedAction מגדרים פעולות/עמודות/רשומות
        //   6 תפקידים ב-2 שורות של SegmentedSwitch (Row-מבוקר; 6 פריטים גולשים ברוחב-המסך — נתפס בבדיקת-widget)
        for (var r = 0; r < 2; r++) ...[
          Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final d in _TeamData.roleDefs.sublist(r * 3, r * 3 + 3)) d['label'] as String]) [s]], selected: {_role ~/ 3 == r ? _role % 3 : -1}, onSelect: (i) => setState(() => _role = r * 3 + i))),
          _gap(6),
        ],
        _gap(4),
        // KPI-10: hero=שיעורים-ללא-מורה-היום (המטרה) + 10 מדדי-מצב (BareStat נושאי-ערך-אמת)
        ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatPlain(fields: ['שיעורים ללא מורה היום', '$uncovered'])),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['👥 סך-צוות', '${_TeamData.staff.length}'])),
              Expanded(child: ForgeStatPlain(fields: ['✅ פעילים', '${all.length}'])),
              Expanded(child: ForgeStatPlain(fields: ['🤒 נעדרים היום', '${_TeamData.absentN}'])),
              Expanded(child: ForgeStatPlain(fields: ['🚨 ללא-מורה', '$uncovered'])),
              Expanded(child: ForgeStatPlain(fields: ['🔁 החלפות פתוחות', '${_TeamData.openSubs}'])),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['⚖️ עומס ממוצע ש׳/שב׳', _TeamData.avgHours.toStringAsFixed(1)])),
              Expanded(child: ForgeStatPlain(fields: ['🔥 עמוסים-מדי', '${_TeamData.overN}'])),
              Expanded(child: ForgeStatPlain(fields: ['🪫 בתת-עומס', '${_TeamData.underN}'])),
              Expanded(child: ForgeStatPlain(fields: ['📄 חוזים פגים החודש', '${_TeamData.contractsN}'])),
              Expanded(child: ForgeStatPlain(fields: ['🎓 הכשרות חסרות', '${_TeamData.certsN}'])),
            ]),
          ])),
        const SizedBox(height: 8),
        // מרכז-אוטומציות (23-ג · פרואקטיבי): המערכת מתריעה לפני שדבר נשמט — 9 אוטומציות-המפרט
        for (final a in _TeamData.alerts(_role)) ...[ForgeSectionPill(items: [[a['m'] as String]], variants: [const <int>[0, 0, 0, 0][(a['tone'] as int) % 4]]), _gap(6)],
        const SizedBox(height: 4),
        // פס-עליון: חיפוש-מבוקר (DsSearch) · מורה-חדש · לוח-החלפות-היום · ייצוא (רשימה-נראית)
        Row(children: [
          Expanded(child: ForgeDsSearch(control: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v), bare: true))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _refresh, child: ForgeSoftButton(fields: ['🔄']))),
          if (_TeamData.can(_role, 'team.add')) ...[const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _TeamData.addTeacher(_who)), child: ForgeSoftButton(fields: ['➕ מורה'])))],
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _mode = 2), child: ForgeSoftButton(fields: ['🔁 היום']))),
          if (_TeamData.can(_role, 'team.export') && exportAllowed(false)) ...[const SizedBox(width: 6), Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openExport('רשימת-צוות · ${visible.length}', _TeamData.rosterCsv(visible, _TeamData.hiddenKeys(_role))), child: ForgeSoftButton(fields: ['⬇ CSV'])))],
        ]),
        // פילטרים (המפרט: 11) — צ׳יפי-חריגה (finderMatches) + תפקיד/סטטוס (SegmentedSwitch) + מקצוע/כיתה (FilterChipPill)
        Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[((('🤒 נעדר-היום · ${_TeamData.absentN}')), _locks[(('absent'))] == ('1'), () => setState(() => _locks[(('absent'))] == ('1') ? _locks.remove((('absent'))) : _locks[(('absent'))] = ('1'))), ((('🔥 עומס>סף · ${_TeamData.overN}')), _locks[(('over'))] == ('1'), () => setState(() => _locks[(('over'))] == ('1') ? _locks.remove((('over'))) : _locks[(('over'))] = ('1'))), ((('🪫 עומס<סף · ${_TeamData.underN}')), _locks[(('under'))] == ('1'), () => setState(() => _locks[(('under'))] == ('1') ? _locks.remove((('under'))) : _locks[(('under'))] = ('1'))), ((('🎓 הכשרה-חסרה/פגה')), _locks[(('cert'))] == ('1'), () => setState(() => _locks[(('cert'))] == ('1') ? _locks.remove((('cert'))) : _locks[(('cert'))] = ('1'))), ((('📄 חוזה-פג')), _locks[(('contract'))] == ('1'), () => setState(() => _locks[(('contract'))] == ('1') ? _locks.remove((('contract'))) : _locks[(('contract'))] = ('1'))), ((('🟢 זמין ב-${_TeamData.openSlot}')), _locks[(('free'))] == ('1'), () => setState(() => _locks[(('free'))] == ('1') ? _locks.remove((('free'))) : _locks[(('free'))] = ('1')))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
        const SizedBox(height: 8),
        Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['כל תפקיד', 'מחנך', 'מקצועי', 'סייע', 'הנהלה']) [s]], selected: {_segIdx('role', const ['homeroom', 'subject', 'aide', 'mgmt'])}, onSelect: (i) => _segSet('role', const ['homeroom', 'subject', 'aide', 'mgmt'], i))),
        const SizedBox(height: 6),
        Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['כל סטטוס', 'פעיל', 'חופשה', 'חל״ת', 'עזב']) [s]], selected: {_segIdx('status', const ['active', 'leave', 'unpaid', 'left'])}, onSelect: (i) => _segSet('status', const ['active', 'leave', 'unpaid', 'left'], i))),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 6, children: [for (final sj in _TeamData.allSubjects) _vchip('subject', sj, '📚 $sj')]),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 6, children: [for (final c in _TeamData.allClasses.take(10)) _vchip('cls', c, '🏫 $c')]),
        const SizedBox(height: 10),
        // מיון (המפרט: עומס · חיסורים · כיתות) — SegmentedSwitch מבוקר
        Align(
          alignment: Alignment.centerRight,
          child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['⚖️ עומס', '🤒 חיסורים', '🏫 כיתות']) [s]], selected: {_sort}, onSelect: (i) => setState(() => _sort = i)),
        ),
        const SizedBox(height: 10),
        // בורר-מבט (SegmentedSwitch מבוקר): 🎯 חכם (טריאז'-החלטה) · 📋 טבלה (חוזה-עמודות) · 🔁 לוח-החלפות-היום
        Align(
          alignment: Alignment.centerRight,
          child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['🎯 חכם', '📋 טבלה', '🔁 החלפות היום']) [s]], selected: {_mode}, onSelect: (i) => setState(() => _mode = i)),
        ),
        const SizedBox(height: 10),
        // מצבי-מסך שמורים: טעינה · שגיאה · אין-צוות · ללא-תוצאות — ואז התוכן
        if (_loading)
          _loadingView()
        else if (_error != null)
          ForgeSectionPill(items: [[_error!]], variants: const <int>[0])
        else if (_TeamData.staff.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: ['אין צוות — הוסף מורה ראשון/ה', '']))
        else if (_mode == 2)
          _subsBoard()
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: ['אין אנשי-צוות תואמים לחיפוש/סינון', '']))
        else if (_mode == 1)
          _table(visible)
        else
          for (final st in const [3, 2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              ForgeTitledSection(fields: ['${secTitle[st]} · ${buckets[st]!.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
                for (final t in buckets[st]!) _row(t),
              ]])),
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
              child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  Row(children: [
                    PremiumAvatar(name: t['name'] as String, size: 56, status: _TeamData.absentToday(t) ? AvatarStatus.busy : _TeamData.presentToday(t) ? AvatarStatus.online : AvatarStatus.none),
                    const SizedBox(width: 10),
                    Expanded(child: ForgeContactTile(fields: ['${t['name']} · ${_TeamData.roleLabel[_TeamData.roleOf_(t)]}', '${_TeamData.subjects(t).join(' · ')} · ותק ${_TeamData.tenure(t) ?? '—'} ש׳ · ${_TeamData.statusLabel[_TeamData.statusOf(t)]}'])),
                  ]),
                  _gap(12),
                  ForgeLinearProgressStatus(fields: ['עומס מול חוזה', '${_TeamData.hoursWeek(t).round()} מתוך ${_TeamData.contractHours(t)} ש׳ · ${_TeamData.loadPct(t)}%'], values: [(_TeamData.loadPct(t) / 100).clamp(0.0, 1.0)]),
                  _gap(10),
                  Row(children: [
                    Expanded(child: ForgeStatPlain(fields: ['חוגים', '${_TeamData.coursesOf(t).length}'])),
                    Expanded(child: ForgeStatPlain(fields: ['שיעורים/שבוע', '${_TeamData.sessionsWeek(t)}'])),
                    Expanded(child: ForgeStatPlain(fields: ['היעדרויות החודש', '${_TeamData.absencesMonth(t)}'])),
                    Expanded(child: ForgeStatPlain(fields: ['החלפות ביצע/קיבל', '${_TeamData.subsDone(t)}/${_TeamData.subsReceived(t)}'])),
                  ]),
                  _gap(12),
                  // 9 טאבים ב-3 שורות של SegmentedSwitch (Row-מבוקר; 4+ פריטים גולשים ברוחב-הגיליון — נתפס בבדיקת-widget)
                  for (var r = 0; r < 3; r++) ...[
                    Align(alignment: Alignment.centerRight, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in _tabNames.sublist(r * 3, r * 3 + 3)) [s]], selected: {tab ~/ 3 == r ? tab % 3 : -1}, onSelect: (i) => act(() => _tab[t['id'] as String] = r * 3 + i))),
                    _gap(6),
                  ],
                  _gap(12),
                  _tabView(t, tab, act),
                  _gap(16),
                  const Text('פעולות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                  _gap(8),
                  _actions(t, act, ctx),
                ])),
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
          if (t[f['key']] != null) ForgeStatusChip(items: [['${f['prefix']}${f['key'] == 'preferredSub' ? _TeamData.nameOf(t[f['key']] as String) : f['key']!.contains('Date') || f['key'] == 'contractEnd' ? fmtDate('${t[f['key']]}') : t[f['key']]}${f['suffix']}']], variants: const <int>[0]),
        for (final r in (t['extraRoles'] as List)) ForgeStatusChip(items: [['🎖 $r']], variants: const <int>[1]),
        for (final c in (t['constraints'] as List)) ForgeStatusChip(items: [['⛔ $c']], variants: const <int>[2]),
      ]),
      _gap(10),
      Text('זמינות שבועית · ${days.length} ימים', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
      _gap(6),
      Wrap(spacing: 8, runSpacing: 6, children: [
        for (final d in days) DsChip(label: '${dayNames[d]} ${av[d]![0]}–${av[d]![1]}', tone: 0),
        if (days.isEmpty) const DsChip(label: 'אין חלונות-זמינות (חופשה/עזב)', tone: 2),
      ]),
      if ('${t['notes']}'.isNotEmpty && !_TeamData.hiddenKeys(_role).contains('notes')) ...[_gap(10), ForgeSectionPill(items: [['הערת-הנהלה (מוגן): ${t['notes']}']], variants: const <int>[0])],
      if (_TeamData.hiddenKeys(_role).contains('notes')) ...[_gap(10), ForgeSectionPill(items: [['הערות-הנהלה מוגנות — למנהל/ת בלבד']], variants: const <int>[0])],
      if (_TeamData.balanceFor(t) != null) ...[
        _gap(10),
        ForgeSectionPill(items: [['הצעת-איזון: להעביר ${_TeamData.balanceFor(t)!['course']['name']} מ-${_TeamData.balanceFor(t)!['from']['name']} (עמוס-מדי) לכאן']], variants: const <int>[0]),
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
    if (times.isEmpty) return ForgeSearchEmptyState(fields: ['אין שיעורים במערכת', '']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeDataGrid(bare: true, columns: ['שעה', for (final d in days) dayNames[d]], items: [for (final tm in times) [tm, for (final d in days) grid[tm]![d] ?? '—']]),
      _gap(6),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['רצועות-שעה', '${times.length}'])),
        Expanded(child: ForgeStatPlain(fields: ['שיעורים/שבוע', '${_TeamData.sessionsWeek(t)}'])),
        Expanded(child: ForgeStatPlain(fields: ['שיעור-ראשון', minToHM((timeToMin(times.first) as num).toInt(), (n) => n.toString().padLeft(2, '0'))])),
      ]),
    ]);
  }

  // כיתות: חוג ⇒ MediaRow (שם·כיתה·חדר·מפגשים) · הקצה-כיתה = איזון (balanceFor)
  Widget _classes(Map<String, dynamic> t, void Function(void Function()) act) {
    final cs = _TeamData.coursesOf(t);
    final bal = _TeamData.balanceFor(t);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (cs.isEmpty) ForgeSearchEmptyState(fields: ['לא הוקצו חוגים', '']),
      for (final c in cs)
        ForgeContactTile(fields: ['${c['name']} · חדר ${c['roomId']}', '${(sessionsOf(c) as List).length} מפגשים/שבוע · ${(sessionsOf(c) as List).map((s) => '${dayNames[s['day'] as int]} ${s['time']}').join(' · ')}']),
      if (bal != null && _TeamData.can(_role, 'team.assign')) ...[
        _gap(8),
        Wrap(children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.reassign(bal['course'] as Map<String, dynamic>, t, _who)), child: ForgeSoftButton(fields: ['🏫 הקצה-כיתה: ${bal['course']['name']} מ-${bal['from']['name']}']))]),
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
      ForgeBarChart(fields: ['', ''], values: (() { final _vs = [for (final v in monthly) v.toDouble()]; final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
      _gap(6),
      Wrap(spacing: 8, children: [
        ForgeStatusChip(items: [['מגמה: ${trend['dir'] == 'up' ? '↑ עולה' : trend['dir'] == 'down' ? '↓ יורדת' : '→ יציבה'} ${trend['pct']}%']], variants: [const <int>[0, 1, 3, 2][(trend['dir'] == 'up' ? 2 : 1) % 4]]),
        if (_TeamData.frequentAbsentee(t)) ForgeStatusChip(items: [['דפוס-היעדרות — לשיחת-תמיכה']], variants: const <int>[2]),
      ]),
      _gap(10),
      if (list.isEmpty) ForgeSearchEmptyState(fields: ['אין היעדרויות רשומות', '']),
      for (final a in list)
        ForgeNotifRow(items: [['🤒 ${_TeamData.reasonOf(a['reason'] as String)}', fmtDate(a['date'] as String)]]),
    ]);
  }

  // החלפות: ביצע/קיבל (TimelineItem)
  Widget _subsOf(Map<String, dynamic> t) {
    final mine = _TeamData.subs.where((s) => s['subId'] == t['id'] || s['absentId'] == t['id']).toList()..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
    if (mine.isEmpty) return ForgeSearchEmptyState(fields: ['אין החלפות', '']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final s in mine)
        ForgeNotifRow(items: [['${s['subId'] == t['id'] ? '🟢 ביצע/ה' : '🟠 קיבל/ה'} · ${_TeamData.courseById(s['courseId'] as String)?['name']}', '${fmtDate(s['date'] as String)}${s['time'] != null ? ' ${s['time']}' : ''}']]),
    ]);
  }

  // ביצועי-כיתות (מקום-שמור · §20-ג): מאיר רק כשמוזרם classPerf {labels, values, monthly} ממודולי נוכחות/תלמידים
  Widget _performance(Map<String, dynamic> t) {
    final perf = t['classPerf'] as Map<String, dynamic>?;
    if (perf == null) return ForgeSearchEmptyState(fields: ['מקום-שמור: נוכחות/ציוני-כיתותיו יאירו כשיוזרמו ממודולי נוכחות ותלמידים (לא מזייפים)', '']);
    final trend = trendFromScan({'monthly': perf['monthly']});
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      ForgeBarChart(fields: ['', ''], values: (() { final _vs = (perf['values'] as List).map((v) => (v as num).toDouble()).toList(); final _m = _vs.fold<double>(0.0, (a, b) => a > b ? a : b); return [for (final v in _vs) _m == 0 ? 0.0 : v / _m]; })()),
      _gap(6),
      ForgeStatusChip(items: [['מגמה ${trend['dir']} ${trend['pct']}%']], variants: [const <int>[0, 1, 3, 2][(trend['dir'] == 'down' ? 2 : 1) % 4]]),
    ]);
  }

  // הכשרות+תוקף: MediaRow ⊕ StatusChip(certExpiryStatus)
  Widget _certs(Map<String, dynamic> t) {
    final cs = _TeamData.certsOf(t);
    if (cs.isEmpty) return ForgeSearchEmptyState(fields: ['אין הכשרות רשומות — הכשרה-חסרה', '']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (final c in cs)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            Expanded(child: ForgeContactTile(fields: ['${c['name']}', '${c['issuer']} · תוקף ${fmtDate(c['expiry'] as String)}'])),
            () {
              final st = _TeamData.certStatus(c);
              return Flexible(child: ForgeStatusChip(items: [[st == CertExpiryStatus.expired ? 'פג' : st == CertExpiryStatus.expiringSoon ? 'פג בקרוב' : 'בתוקף']], variants: [const <int>[0, 1, 3, 2][(st == CertExpiryStatus.expired ? 2 : st == CertExpiryStatus.expiringSoon ? 3 : 1) % 4]]));
            }(),
          ]),
        ),
    ]);
  }

  // מסמכים (מקום-שמור): רשומות שנרשמו ב"צרף-מסמך"; אין ⇒ ריק-אמת
  Widget _docs(Map<String, dynamic> t) {
    final ds = _TeamData.docs[t['id']] ?? const [];
    if (ds.isEmpty) return ForgeSearchEmptyState(fields: ['אין מסמכים — צרף-מסמך ירשום כאן (אחסון-קבצים = מקום-שמור להצבה)', '']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final d in ds) ForgeNotifRow(items: [['📎 ${d['name']}', fmtDate(d['date'] as String)]])]);
  }

  // אודיט: כל פעולה שנרשמה בפנקס (מי·מה·מתי) — TimelineItem
  Widget _audit(Map<String, dynamic> t) {
    final rows = _TeamData.audit.where((a) => a['target'] == t['name'] || '${a['target']}'.contains('${t['name']}')).toList();
    if (rows.isEmpty) return ForgeSearchEmptyState(fields: ['אין רישומי-אודיט למורה זה', '']);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [for (final a in rows) ForgeNotifRow(items: [['${a['what']}', fmtDate(a['date'] as String)]])]);
  }

  // 14 פעולות (המפרט) — SoftButton; מגודרות-הרשאה בגל 5. חסר-נתון ⇒ מקום-שמור מפורש, לא זיוף.
  Widget _actions(Map<String, dynamic> t, void Function(void Function()) act, BuildContext sheetCtx) {
    final reasons = absenceReasonChips(term: (k) => kTerms[k] ?? k);
    final keys = kTerms.keys.toList();
    final r = _role;
    final acts = <Widget>[
      if (_TeamData.can(r, 'team.assign')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.cycleRole(t, _who)), child: ForgeSoftButton(fields: ['✏️ ערוך תפקיד'])),
      if (_TeamData.can(r, 'team.assign')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.addSubject(t, _who)), child: ForgeSoftButton(fields: ['📚 הקצה-מקצוע'])),
      if (_TeamData.can(r, 'team.sub')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () { Navigator.of(sheetCtx).pop(); setState(() => _mode = 2); }, child: ForgeSoftButton(fields: ['🔎 מצא-מחליף'])),
      if (_TeamData.can(r, 'team.avail')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.toggleFriday(t, _who)), child: ForgeSoftButton(fields: ['🗓 עדכן-זמינות (שישי)'])),
      if (_TeamData.can(r, 'team.cert') || _TeamData.can(r, 'team.docs')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.addCert(t, _who)), child: ForgeSoftButton(fields: ['🎓 הוסף-הכשרה'])),
      if (_TeamData.can(r, 'team.docs')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.addDoc(t, _who)), child: ForgeSoftButton(fields: ['📎 צרף-מסמך'])),
      GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openExport('מערכת אישית · ${t['name']}', _TeamData.timetableCsv(t)), child: ForgeSoftButton(fields: ['🖨 הדפס-מערכת'])),
      if (_TeamData.roleName(r) == 'admin') GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.cycleStatus(t, _who)), child: ForgeSoftButton(fields: ['⏸ ${_TeamData.statusOf(t) == 'active' ? 'סמן-חופשה' : 'שנה-סטטוס'}'])),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Wrap(spacing: 8, runSpacing: 8, children: acts),
      if (acts.length <= 1) ...[_gap(8), ForgeSectionPill(items: [['צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה']], variants: const <int>[0])],
      _gap(8),
      if (!_TeamData.can(r, 'team.contact'))
        ForgeSectionPill(items: [['שלח-הודעה: פרטי-קשר מוסתרים לתפקיד זה (הרשאה)']], variants: const <int>[0])
      else if (t['contact'] == null)
        ForgeSectionPill(items: [['שלח-הודעה: פרטי-קשר מוזרקים בהצבה (חוק-6) — מקום-שמור, מאיר כשיוזרק contact']], variants: const <int>[0])
      else
        Wrap(children: [GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.log(_who, 'שליחת-הודעה', t['name'] as String)), child: ForgeSoftButton(fields: ['💬 שלח-הודעה']))]),
      _gap(8),
      if (!_TeamData.can(r, 'team.absence'))
        const SizedBox.shrink()
      else if (!_TeamData.absentOn(t, _TeamData.today)) ...[
        const Text('🤒 סמן-היעדרות היום — סיבה:', style: TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700)),
        _gap(6),
        Wrap(spacing: 8, runSpacing: 6, children: [
          for (var i = 0; i < reasons.length; i++) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => act(() => _TeamData.markAbsent(t, keys[i], _who)), child: ForgeSoftButton(fields: [reasons[i]])),
        ]),
      ] else
        ForgeSectionPill(items: [['מסומן/ת נעדר/ת היום — שיעורי-היום נרשמו בלוח-ההחלפות']], variants: const <int>[0]),
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
          child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              ForgeContactTile(fields: [title, 'CSV · BOM + חסימת-הזרקה · PDF = מקום-שמור (מנוע-PDF בהצבה)']),
              _gap(8),
              if (!exportAllowed(false))
                ForgeSectionPill(items: [['ייצוא חסום (שער-יציאת-מידע)']], variants: const <int>[0])
              else
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                  child: SelectableText(csv, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
                ),
            ])),
        ),
      ),
    );
  }

  // 📋 מבט-טבלה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid (מזייף int rows).
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _TeamData.columnDefs) if (_TeamData.colShown(c, rows, _TeamData.hiddenKeys(_role))) c];
    return ForgeDataGrid(bare: true, columns: [for (final c in cols) c['label'] as String], items: [for (final t in rows) [for (final c in cols) _TeamData.cell(c, t)]]);
  }

  // 🔁 לוח-החלפות-היום (זיהוי-חריגה ⇒ הכרעה ⇒ ביצוע): DsBoard (תפר-דאטה: stages+records+onMove) ⊕ candidates
  //   (זמין ∧ מקצוע ∧ פנוי-בסלוט[scheduleClashText] ∧ עומס-נמוך ∧ מועדף) ⊕ taskOverdue (החלפה שעבר מועדה).
  Widget _subsBoard() {
    final today = _TeamData.todaySubs;
    final open = _TeamData.uncoveredToday;
    final overdue = _TeamData.subs.where((s) => _TeamData.subOverdue(s)).length;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (today.isEmpty)
        ForgeSearchEmptyState(fields: ['אין החלפות להיום — כל השיעורים מכוסים', ''])
      else ...[
        DsBoard(
          stages: const ['🔴 ללא-מחליף', '🟠 הוצע', '✅ אושר'],
          records: [for (final s in today) {'id': '${s['id']}', 'title': '${s['time'] ?? ''} ${_TeamData.courseById(s['courseId'] as String)?['name']} · במקום ${_TeamData.nameOf(s['absentId'] as String)}${s['subId'] != null ? ' ⇐ ${_TeamData.nameOf(s['subId'] as String)}' : ''}', 'stage': '${s['stage']}'}],
          stageOf: (r) => int.parse(r['stage']!),
          titleOf: (r) => r['title']!,
          onMove: (id, to) { if (_TeamData.can(_role, 'team.sub')) setState(() => _TeamData.moveSub(id, to, _who)); },
        ),
        if (overdue > 0) ...[_gap(8), ForgeSectionPill(items: [['$overdue החלפות פתוחות שעבר מועדן']], variants: const <int>[0])],
        _gap(10),
        // הצעת-מחליף אוטומטית פר-שיעור-פתוח: המועמד-הראשון = מועדף/עומס-נמוך; אין ⇒ אמת (לא מזייפים מחליף)
        ForgeTitledSection(fields: ['🧭 מחליף מוצע · ${open.length} שיעורים פתוחים', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
          if (open.isEmpty) ForgeSearchEmptyState(fields: ['כל שיעורי-היום מכוסים', ''])
          else for (final s in open) _subRow(s),
        ]])),
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
        ForgeContactTile(fields: ['${s['time'] ?? ''} · ${c['name']} · ${c['roomId']}', 'במקום ${_TeamData.nameOf(s['absentId'] as String)} · ${s['stage'] == 1 ? 'הוצע: ${chosen?['name']}' : 'ללא-מחליף'}']),
        _gap(6),
        if (cands.isEmpty)
          ForgeSectionPill(items: [['אין מחליף זמין (מקצוע+חלון-זמינות+פנוי-בסלוט) — נדרשת הכרעה ידנית']], variants: const <int>[0])
        else if (!_TeamData.can(_role, 'team.sub'))
          Wrap(spacing: 8, children: [for (final t in cands.take(3)) ForgeStatusChip(items: [['${t['name']} · ${_TeamData.loadPct(t)}%']], variants: const <int>[0])])
        else
          Wrap(spacing: 8, runSpacing: 6, children: [
            for (final t in cands.take(3))
              GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _TeamData.propose(s, t, _who)), child: ForgeSoftButton(fields: ['${t == cands.first ? '⭐ ' : ''}${t['name']} · ${_TeamData.loadPct(t)}%${(_TeamData.byId(s['absentId'] as String)?['preferredSub']) == t['id'] ? ' · מועדף' : ''}'])),
            if (s['stage'] == 1) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _TeamData.moveSub(s['id'] as String, 2, _who)), child: ForgeSoftButton(fields: ['✅ אשר-החלפה'])),
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
      child: ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            PremiumAvatar(name: t['name'] as String, size: 44, status: avatarStatus),
            const SizedBox(width: 10),
            // MediaRow בולע את הקליק (InkWell פנימי no-op) ⇒ כפתור-שברון נפרד כשקע-הפתיחה
            IconButton(onPressed: () => _openPanel(t), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'כרטיס-מורה ופעולות'),
            Expanded(
              child: ForgeContactTile(fields: ['${t['name']} · ${_TeamData.roleLabel[t['role']]}', '${_TeamData.subjects(t).join(' · ')}${(t['homeroom'] as List).isNotEmpty ? ' · מחנך/ת ${(t['homeroom'] as List).join(',')}' : ''} · ${_TeamData.coursesOf(t).length} חוגים']),
            ),
          ]),
          _gap(8),
          ForgeLinearProgressStatus(fields: ['עומס מול חוזה', '${hours % 1 == 0 ? hours.toStringAsFixed(0) : hours.toStringAsFixed(1)} מתוך $ch ש׳ · $pct%'], values: [(pct / 100).clamp(0.0, 1.0)]),
          if (sev >= 1 || st != 'active') ...[
            _gap(8),
            Wrap(spacing: 8, runSpacing: 6, children: [
              if (st != 'active') ForgeStatusChip(items: [[_TeamData.statusLabel[st] ?? st]], variants: const <int>[0]),
              if (_TeamData.why(t).isNotEmpty) ForgeStatusChip(items: [[_TeamData.why(t)]], variants: [const <int>[0, 1, 3, 2][(sev == 3 ? 2 : sev == 2 ? 3 : 0) % 4]]),
            ]),
          ],
        ])),
    );
  }
}
