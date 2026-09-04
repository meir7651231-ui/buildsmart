// 📊 SchoolOS · לוח-הנהלה (DASHBOARD) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) לפי SPEC-DASHBOARD-FULL-2026-09-04.
// 🎯 המטרה: שהמנהל/ת יפתח את הבוקר ותוך 30 שניות יידע: מה דורש-החלטה היום · מה בסיכון · מה מגמתי · מה הפעולה-הראשונה.
// 🔒 גבול-חרוט: הלוח = נגזרת-טהורה של כל המודולים. אפס נתון-חדש, אפס-כתיבה. המודולים מוזרקים כשקעי-קלט
//    (חוזה-דאטה `DashInput` למטה) — הלוח לא מייבא מסכים אחרים (הם נבנים במקביל; חוק-3: חוט לא מייבא חוט).
// 🔺 פעולות-היסוד (צעד-2, לא אזורי-המפרט):
//    1 איסוף  — תורי-המודולים ⇒ תור-מאוחד (דפוס cockpitQueue: קבוצות + רשימה-מאוחדת + מונה)
//    2 הערכה — בריאות-המוסד: 12 מונים/יחסים ממוני-המודולים (BareStat×12 · אפס StatBlock מזייף)
//    3 דירוג  — דחיפות-מאוחדת בהחלטה (23-ד): band(השפעה×ותק) ∨ SLA-פרוץ(taskOverdue) ∨ חומרת-המודול
//    4 איתור  — DsSearch⊕smartFilter⊕smartScore⊕normSearch · FilterChipPill⊕finderMatches · dateInRange(טווח)
//    5 הכרעה+ביצוע — פאנל-משימה (GlassCard) · פעולה-בלחיצה = שקע-drill-down למודול (לא מעתיק לוגיקה) · cockpitProgress
//    6 מגמה+תחזית — trendFromScan(סדרה-חודשית⇒dir/pct) · יעד-מול-מדד (StatRow) · השוואת-שכבות (NeonBars+חריגה-סטטיסטית)
//    7 אימות+תדרוך — cockpitWorkListText(תדרוך-בוקר) · cockpitCsvRows⊕toCsv⊕csvEscape⊕exportAllowed · holidayOf⊕hebParts(יום-חופש)
// ⛔ אין Date.now במנוע — today מוזרק (DashInput.today). מקום-שמור (חוק-7) לכל KPI/עמודה/מצב חסר-מקור — לא מספר-מומצא.
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart'; // DsScaffold · DsSection · DsTokens · DsNavTile
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows) — לא DataGrid המזייף
import '../dart-ui-bs/bare_stat.dart'; // עובדה-אטומית: ערך+תווית (KPI-12 · פירוקים)
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // המספר-האחד של הבוקר (דורש-החלטה)
import '../dart-ui-bs/premium/surfaces/gradient_card.dart'; // כרטיס-KPI
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל (child שרירותי)
import '../dart-ui-bs/premium/lists/media_row.dart'; // כותרת-משימה (glyph+title+subtitle)
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס מול-יעד (fraction)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // היסטוריה/אודיט — לא timeline_flow המזייף
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // השוואה בין ערכי-אמת (מגמות/שכבות)
import '../dart-ui-bs/premium/dataviz/trend_stat.dart'; // ערך + דלתא-אחוזית (מגמה = אחוז, ייעוד-נכון)
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-מבוקר (טווח · מבט · טאבים)
import '../dart-ui-bs/premium/actions/soft_button.dart'; // פעולה
import '../dart-ui-bs/premium/feedback/alert_banner.dart'; // התרעה/אזעקה/שגיאת-מודול
import '../dart-ui-bs/premium/feedback/status_chip.dart'; // עובדה-שבב (סטטוס · SLA · מקום-שמור)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-משימות 🎉 · תקופה-ללא-דאטה
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר
// ── שכבת-הלוגיקה (§21) — מנועי-מדף, מחווטים דרך שקעים (חוק-1), לא inline ──
import '../dart-maor/cockpit-queue.dart'; // איסוף: קבוצות⇒רשימה-מאוחדת+מונה (שקעי-קבוצות)
import '../dart-maor/cockpit-progress.dart'; // אימות: {done,total} מול קבוצת-מזהים-שטופלה
import '../dart-maor/cockpit-work-list-text.dart'; // תדרוך-בוקר: שורה-למשימה (kind-icon · שם · סיבה)
import '../dart-maor/cockpit-csv-rows.dart'; // ייצוא: כותרת+שורה-למשימה
import '../dart-maor/intel-day-diff.dart'; // ותק: ימים בין ISO להיום (dayDiff)
import '../dart-maor/task-overdue.dart'; // SLA: פתוחה + due < today
import '../dart-maor/intel-trend-from-scan.dart'; // מגמה: מחצית-חדשה מול ישנה ⇒ {dir,pct}
import '../dart-maor/date-in-range.dart'; // טווח: iso בתוך [from,to]
import '../dart-maor/range-label.dart'; // תווית-טווח
import '../dart-maor/fmt-date.dart'; // dd/mm/yyyy
import '../dart-maor/count-by.dart'; // קיבוץ+ספירה (משימות פר-מודול/אחראי)
import '../dart-maor/grand-total.dart'; // Σ-לפי-מפתח
import '../dart-maor/shekel.dart'; // פורמט ₪
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי
import '../dart-maor/finder-matches.dart'; // חריגה: סינון רב-צירי AND
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה
import '../dart-maor/bulk-mail-recipients.dart'; // תדרוך-במייל: נמענים ייחודיים-תקינים
import '../dart-maor/norm-email.dart'; // שקע-נרמול-מייל
import '../dart-maor/holiday-of.dart'; // יום-חופש: חג לפי תאריך-עברי (סוכות/ר״ה/…)
import '../dart-maor/heb-parts.dart'; // תאריך-עברי מ-DateTime
import '../dart-maor/holidays.dart'; // טבלת-החגים (דאטה)
import '../dart-maor/upcoming-holidays.dart'; // חגים-קרובים בחלון-ימים
import '../dart/band.dart'; // דירוג: 3-פסים לפי ספים (value≥high⇒2 · ≥mid⇒1 · אחרת 0)

const _acc = DsTokens.accent;
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════════════════ חוזה-דאטה · DashInput (שקעי-קלט מהמודולים · חוק-1 שכן-מוזרק) ═══════════════════════
// כל מודול = Map באותה צורה: {id,label,glyph,route,enabled,error?,kpi:{...},tasks:[...],series:{...}}.
// מודול לא-מופעל (enabled:false) / בשגיאה (error) ⇒ מקום-שמור בלוח, לא אפס-מזויף. מודול חסר ⇒ '—'.
// משימה = 12 עמודות-המפרט (שקעים): id · kind · module(נגזר) · title · owner · opened(ISO) · due(ISO) ·
//   students(השפעה) · ils(השפעה ₪) · action(תווית-הפעולה-בלחיצה) · link(drill-down) · status · note · history · context · sev?(חומרת-המודול)
class DashInput {
  const DashInput({
    required this.today,
    required this.modules,
    this.schoolHolidays = const [],
    this.goals = const {},
    this.lastYear = const {},
    this.grades = const [],
    this.staff = const [],
  });
  final String today; // ISO — מוזרק, לעולם לא Date.now (VERIFY-LAWS)
  final List<Map<String, dynamic>> modules;
  final List<Map<String, String>> schoolHolidays; // [{iso,name}] — לוח-המוסד (מהמודול חוגים/מערכת)
  final Map<String, num> goals; // יעדים-שנתיים {attendancePct, collectionPct, riskCount}
  final Map<String, num> lastYear; // אותם מדדים שנה-שעברה (השוואה)
  final List<Map<String, dynamic>> grades; // [{name, attendancePct, riskCount, students}] — השוואת-שכבות
  final List<Map<String, dynamic>> staff; // [{name,email,role}] — נמעני-תדרוך + האצלה

  // ─── דמו-אמת: רק שדות עם מקור במפרטי-המודולים (SPEC-<M>-FULL · שורת-KPI של כל מודול) ───
  //   תלמידים: SPEC-STUDENTS §KPI(10) · נוכחות: SPEC-ATTENDANCE §KPI(10) · חוגים: SPEC-COURSES §KPI(10) ·
  //   מורים: SPEC-TEACHERS §KPI(10) · חדרים: SPEC-ROOMS §KPI(10) · גבייה: SPEC-FEES §KPI(10) · הורים: SPEC-PARENTS §KPI(10) ·
  //   מלאי: schoolos.dart `_InvData` (sev≥1 על פעילים: טונר·נייר·ערכות-מעבדה = 3 · CLOSED-INVENTORY).
  static const demo = DashInput(
    today: '2026-09-04',
    goals: {'attendancePct': 94, 'collectionPct': 90, 'riskCount': 10},
    lastYear: {'attendancePct': 91.2, 'collectionPct': 84, 'riskCount': 19, 'students': 1203},
    grades: [
      {'name': 'ז׳', 'attendancePct': 95.1, 'riskCount': 2, 'students': 212},
      {'name': 'ח׳', 'attendancePct': 93.4, 'riskCount': 3, 'students': 208},
      {'name': 'ט׳', 'attendancePct': 86.2, 'riskCount': 6, 'students': 215},
      {'name': 'י׳', 'attendancePct': 92.8, 'riskCount': 2, 'students': 204},
      {'name': 'י״א', 'attendancePct': 93.9, 'riskCount': 1, 'students': 209},
      {'name': 'י״ב', 'attendancePct': 91.5, 'riskCount': 0, 'students': 200},
    ],
    staff: [
      {'name': 'מנהלת', 'email': 'mgr@school', 'role': 'admin'},
      {'name': 'רכזת שכבה ט׳', 'email': 'coord9@school', 'role': 'coordinator'},
      {'name': 'יועצת', 'email': 'counsel@school', 'role': 'coordinator'},
      {'name': 'מזכירות', 'email': 'office@school', 'role': 'staff'},
      {'name': 'אב-בית', 'email': '', 'role': 'staff'}, // ללא-מייל ⇒ נופל מנמעני-התדרוך (bulkMailRecipients)
      {'name': 'גזברות', 'email': 'FIN@school ', 'role': 'finance'}, // נרמול (normEmail) ⇒ fin@school
    ],
    schoolHolidays: [
      {'iso': '2026-09-11', 'name': 'ערב ראש השנה — יום קצר'},
      {'iso': '2026-10-04', 'name': 'חופשת סוכות (לוח-המוסד)'},
    ],
    modules: [
      {
        'id': 'students', 'label': 'תלמידים', 'glyph': '🎓', 'route': '/students', 'enabled': true,
        'kpi': {'total': 1248, 'active': 1231, 'riskHigh': 14, 'riskMid': 27, 'openInquiries': 5},
        'series': {'riskCount': [22, 21, 19, 18, 17, 16, 15, 15, 14, 13, 14, 14]},
        'tasks': [
          {'id': 'stu:risk-9', 'kind': 'student.risk', 'grade': 'ט׳', 'title': '6 תלמידי שכבה ט׳ חצו סף-סיכון גבוה', 'owner': 'יועצת', 'opened': '2026-08-31', 'due': '2026-09-04', 'students': 6, 'ils': 0, 'sev': 'risk',
            'action': 'פתח ועדת-שילוב', 'link': '/students?risk=high&grade=9', 'status': 'open', 'note': 'האות-המוביל: היעדרויות', 'history': [{'iso': '2026-08-31', 'what': 'ציון-סיכון עלה מעל 70'}, {'iso': '2026-09-02', 'what': 'יועצת יידעה מחנכים'}], 'context': {'שכבה': 'ט׳', 'ממוצע-סיכון': '74', 'אות-מוביל': 'היעדרויות'}},
          {'id': 'stu:noparent', 'kind': 'student.contact', 'title': '9 תלמידים ללא הורה מעודכן', 'owner': 'מזכירות', 'opened': '2026-08-20', 'due': '2026-09-10', 'students': 9, 'ils': 0,
            'action': 'פתח רשימת-עדכון', 'link': '/students?filter=noParent', 'status': 'open', 'note': '', 'history': [{'iso': '2026-08-20', 'what': 'זוהה בייבוא-שנתי'}], 'context': {'מקור': 'ייבוא 20.8'}},
        ],
      },
      {
        'id': 'attendance', 'label': 'נוכחות', 'glyph': '🗓', 'route': '/attendance', 'enabled': true,
        'kpi': {'presentToday': 1147, 'absentToday': 84, 'late': 31, 'monthPct': 93.1, 'dropRisk': 11, 'unregisteredClasses': 3},
        'series': {'attendancePct': [92.4, 93.0, 93.8, 94.1, 93.6, 92.9, 91.8, 90.5, 93.2, 93.9, 93.4, 93.1], 'weeklyPct': [94.2, 93.8, 93.5, 90.1]},
        'tasks': [
          {'id': 'att:unreg', 'kind': 'attendance.unregistered', 'title': '3 כיתות טרם נרשמה נוכחות היום', 'owner': 'רכזת שכבה ט׳', 'opened': '2026-09-04', 'due': '2026-09-04', 'students': 87, 'ils': 0, 'sev': 'due',
            'action': 'שלח תזכורת למורים', 'link': '/attendance?today=unregistered', 'status': 'open', 'note': 'ט׳-1 · ט׳-3 · י׳-2', 'history': [], 'context': {'כיתות': 'ט׳-1 · ט׳-3 · י׳-2', 'שעה-אחרונה': '10:00'}},
          {'id': 'att:streak', 'kind': 'attendance.streak', 'title': '4 תלמידים ברצף-היעדרות ≥3 ימים', 'owner': 'רכזת שכבה ט׳', 'opened': '2026-09-01', 'due': '2026-09-03', 'students': 4, 'ils': 0, 'sev': 'risk',
            'action': 'התקשר להורים', 'link': '/attendance?streak=3', 'status': 'open', 'note': 'התרעת-רצף אוטומטית', 'history': [{'iso': '2026-09-01', 'what': 'התרעת-רצף נוצרה'}], 'context': {'רצף-מקס': '5 ימים'}},
        ],
      },
      {
        'id': 'courses', 'label': 'חוגים/מערכת', 'glyph': '📚', 'route': '/courses', 'enabled': true,
        'kpi': {'active': 42, 'weekLessons': 318, 'enrolled': 1180, 'occupancyPct': 81, 'conflicts': 2, 'noTeacher': 1, 'belowMin': 3, 'waitlist': 27},
        'tasks': [
          {'id': 'crs:conf', 'kind': 'schedule.conflict', 'title': '2 התנגשויות-מערכת (מורה/חדר באותו slot)', 'owner': 'מנהלת', 'opened': '2026-09-02', 'due': '2026-09-04', 'students': 58, 'ils': 0, 'sev': 'due',
            'action': 'פתור התנגשות', 'link': '/courses?conflicts=1', 'status': 'open', 'note': 'יום ג׳ 10:00 · חדר 12 · מורה כהן', 'history': [{'iso': '2026-09-02', 'what': 'זוהה בשכפול-סמסטר'}], 'context': {'slot': 'ג׳ 10:00', 'חדר': '12'}},
          {'id': 'crs:belowmin', 'kind': 'course.belowMin', 'title': '3 חוגים מתחת-למינימום (לא-כלכליים)', 'owner': 'מנהלת', 'opened': '2026-08-25', 'due': '2026-09-15', 'students': 19, 'ils': 8400,
            'action': 'החלט: איחוד/ביטול', 'link': '/courses?belowMin=1', 'status': 'open', 'note': 'רובוטיקה · שח · כדורעף', 'history': [], 'context': {'חוגים': 'רובוטיקה · שח · כדורעף', 'חוסר-הכנסה': '₪8,400'}},
        ],
      },
      {
        'id': 'teachers', 'label': 'מורים', 'glyph': '🧑‍🏫', 'route': '/teachers', 'enabled': true,
        'kpi': {'staff': 86, 'active': 84, 'absentToday': 3, 'noTeacherToday': 2, 'openSubs': 1, 'overloaded': 4, 'contractsExpiring': 2},
        'tasks': [
          {'id': 'tch:noteacher', 'kind': 'teacher.uncovered', 'title': '2 שיעורים ללא-מורה היום', 'owner': 'מנהלת', 'opened': '2026-09-04', 'due': '2026-09-04', 'students': 61, 'ils': 0, 'sev': 'due',
            'action': 'שבץ מחליף', 'link': '/teachers?uncovered=today', 'status': 'open', 'note': '11:00 מתמטיקה י׳-2 · 12:00 אנגלית ח׳-1', 'history': [{'iso': '2026-09-04', 'what': 'דיווח-היעדרות 07:10'}], 'context': {'שיעורים': '11:00 · 12:00'}},
          {'id': 'tch:contracts', 'kind': 'teacher.contract', 'title': '2 חוזים פגים החודש', 'owner': 'מנהלת', 'opened': '2026-08-15', 'due': '2026-09-20', 'students': 0, 'ils': 0,
            'action': 'פתח חידוש-חוזה', 'link': '/teachers?contracts=expiring', 'status': 'open', 'note': '', 'history': [], 'context': {}},
        ],
      },
      {
        'id': 'rooms', 'label': 'חדרים', 'glyph': '🏫', 'route': '/rooms', 'enabled': true,
        'kpi': {'total': 38, 'busyNow': 29, 'freeNow': 9, 'utilPct': 76, 'conflicts': 1, 'openFaults': 4, 'unavailable': 2, 'pendingBookings': 3},
        'tasks': [
          {'id': 'rm:faults', 'kind': 'room.fault', 'title': '4 תקלות פתוחות · 2 חדרים לא-זמינים', 'owner': 'אב-בית', 'opened': '2026-08-18', 'due': '2026-09-01', 'students': 120, 'ils': 0,
            'action': 'פתח תקלות', 'link': '/rooms?faults=open', 'status': 'open', 'note': 'מזגן 7 · מקרן 12 · דלת 3 · חלון 21', 'history': [{'iso': '2026-08-18', 'what': 'נפתחה תקלה ראשונה'}, {'iso': '2026-08-28', 'what': 'הוזמן טכנאי'}], 'context': {'חדרים-לא-זמינים': '7 · 12'}},
          {'id': 'rm:bookings', 'kind': 'room.booking', 'title': '3 הזמנות-חדר ממתינות לאישור', 'owner': 'מזכירות', 'opened': '2026-09-03', 'due': '2026-09-06', 'students': 0, 'ils': 0,
            'action': 'אשר הזמנות', 'link': '/rooms?bookings=pending', 'status': 'open', 'note': '', 'history': [], 'context': {}},
        ],
      },
      {
        'id': 'fees', 'label': 'גבייה', 'glyph': '💳', 'route': '/fees', 'enabled': true,
        'kpi': {'chargedYear': 3120000, 'collected': 2683000, 'openBalance': 437000, 'collectionPct': 86, 'familiesInDebt': 61, 'oldDebt': 118000, 'expectedMonth': 262000},
        'series': {'collectionPct': [78, 80, 82, 83, 84, 84, 85, 85, 85, 86, 86, 86]},
        'tasks': [
          {'id': 'fee:old', 'kind': 'fee.oldDebt', 'title': '17 משפחות בחוב-ותיק (>90 יום) · ₪118,000', 'owner': 'גזברות', 'opened': '2026-06-01', 'due': '2026-08-31', 'students': 23, 'ils': 118000,
            'action': 'פתח תוכנית-הסדר', 'link': '/fees?debt=old', 'status': 'open', 'note': 'ללא-בושה: הסדר-תשלומים / מלגה', 'history': [{'iso': '2026-06-01', 'what': 'חוב חצה 90 יום'}, {'iso': '2026-07-15', 'what': 'תזכורת-2 נשלחה'}], 'context': {'משפחות': '17', 'סכום': '₪118,000'}},
          {'id': 'fee:month', 'kind': 'fee.expected', 'title': 'צפוי-החודש ₪262,000 · 8 הו״ק נכשלו', 'owner': 'גזברות', 'opened': '2026-09-02', 'due': '2026-09-10', 'students': 0, 'ils': 262000,
            'action': 'פתח הו״ק כושלות', 'link': '/fees?hok=failed', 'status': 'open', 'note': '', 'history': [], 'context': {'הו״ק-נכשלו': '8'}},
        ],
      },
      {
        'id': 'parents', 'label': 'הורים', 'glyph': '👨‍👩‍👧', 'route': '/parents', 'enabled': true,
        'kpi': {'families': 812, 'contactOk': 771, 'noContact': 41, 'sentMonth': 1290, 'readPct': 88, 'consentsPending': 24, 'consentsExpiring': 12, 'openInquiries': 9, 'avgResponseHrs': 18},
        'tasks': [
          {'id': 'par:consent', 'kind': 'parent.consent', 'title': '12 אישורי-הורים פגים לפני טיול-סוכות', 'owner': 'מזכירות', 'opened': '2026-08-28', 'due': '2026-09-08', 'students': 12, 'ils': 0,
            'action': 'שלח בקשת-אישור', 'link': '/parents?consents=expiring', 'status': 'open', 'note': 'טיול 5.10', 'history': [{'iso': '2026-08-28', 'what': 'סריקת-פקיעה אוטומטית'}], 'context': {'אירוע': 'טיול-סוכות 5.10'}},
          {'id': 'par:inq', 'kind': 'parent.inquiry', 'title': '9 פניות-הורים פתוחות · 2 מעל SLA', 'owner': 'יועצת', 'opened': '2026-08-27', 'due': '2026-09-02', 'students': 9, 'ils': 0, 'sev': 'due',
            'action': 'פתח פניות', 'link': '/parents?inquiries=open', 'status': 'open', 'note': '', 'history': [{'iso': '2026-08-27', 'what': 'פנייה ראשונה נפתחה'}], 'context': {'מעל-SLA': '2'}},
          {'id': 'par:done', 'kind': 'parent.inquiry', 'title': 'פנייה #218 טופלה במודול', 'owner': 'יועצת', 'opened': '2026-08-20', 'due': '2026-08-25', 'students': 1, 'ils': 0,
            'action': 'פתח פנייה', 'link': '/parents?inquiry=218', 'status': 'done', 'note': 'ניקוי-אוטומטי: בוצע במודול-המקור', 'history': [{'iso': '2026-08-25', 'what': 'נסגרה במודול-ההורים'}], 'context': {}},
        ],
      },
      {
        'id': 'inventory', 'label': 'מלאי', 'glyph': '📦', 'route': '/inventory', 'enabled': true,
        // מקור: schoolos.dart `_InvData.sev` על פעילים — טונר(2) · נייר(2) · ערכות-מעבדה(2, גירעון-הקצאה) ⇒ 3 דורשי-הזמנה
        'kpi': {'items': 5, 'needsOrder': 3, 'belowMin': 3, 'out': 0, 'expiring': 1},
        'tasks': [
          {'id': 'inv:order', 'kind': 'inventory.order', 'title': '3 פריטים דורשי-הזמנה היום (טונר · נייר A4 · ערכות-מעבדה)', 'owner': 'מזכירות', 'opened': '2026-09-03', 'due': '2026-09-04', 'students': 0, 'ils': 8697, 'sev': 'due',
            'action': 'פתח מסך-מלאי', 'link': '/inventory?filter=order', 'status': 'open', 'note': 'ימים-עד-ריקון < זמן-אספקה', 'history': [{'iso': '2026-09-03', 'what': 'עברו את קו-ההזמנה'}], 'context': {'עלות-הזמנה': '₪8,697'}},
          {'id': 'inv:expiry', 'kind': 'inventory.expiry', 'title': 'חומרי-ניקוי פוקעים 8.9', 'owner': 'אב-בית', 'opened': '2026-09-01', 'due': '2026-09-08', 'students': 0, 'ils': 1280,
            'action': 'פתח פקיעות', 'link': '/inventory?filter=expiry', 'status': 'open', 'note': '', 'history': [], 'context': {}},
        ],
      },
      // מודול לא-מופעל (מצב-מיוחד "נתון-לא-זמין" ⇒ מקום-שמור, לא אפס-מזויף)
      {'id': 'library', 'label': 'ספרייה', 'glyph': '📖', 'route': '/library', 'enabled': false, 'kpi': {}, 'tasks': []},
      // מודול בשגיאה (מצב-מיוחד "שגיאה-במודול-אחד — הלוח ממשיך")
      {'id': 'transport', 'label': 'הסעות', 'glyph': '🚌', 'route': '/transport', 'enabled': true, 'error': 'שרת-ההסעות לא הגיב (timeout 8s)', 'kpi': {}, 'tasks': []},
    ],
  );
}

// ═══════════════════════ המנוע-הטהור · _DashData (לוגיקה + State · אפס-DOM) ═══════════════════════
class _DashData {
  _DashData(this.input);
  final DashInput input;
  String get today => input.today;

  // ─── כללי-דחיפות (עריכים · state) — ספי-band + SLA-פר-סוג (ברירת-מחדל לפי-סוג; ניתן לערוך ב-UI) ───
  int hi = 12, mid = 5; // ספי band(score): ≥hi ⇒ 🔴 · ≥mid ⇒ 🟠 · אחרת 🟢
  // חוזה-SLA פר-סוג-משימה (kind-prefix ⇒ תווית + ימים) — הימים עריכים ב-UI; סוג לא-מוכר ⇒ 5 ימים
  static const kindLabels = {'attendance': 'נוכחות', 'teacher': 'מורים', 'schedule': 'מערכת', 'student': 'תלמידים', 'parent': 'הורים', 'inventory': 'מלאי', 'room': 'חדרים', 'course': 'חוגים', 'fee': 'גבייה'};
  final Map<String, int> slaDays = {
    'attendance': 1, 'teacher': 1, 'schedule': 2, 'student': 3, 'parent': 3, 'inventory': 3, 'room': 7, 'course': 10, 'fee': 14,
  };
  static String kindOf(Map<String, dynamic> t) => (t['kind'] as String).split('.').first;
  static String kindLabel(String k) => kindLabels[k] ?? k;
  int slaOf(Map<String, dynamic> t) => slaDays[kindOf(t)] ?? 5;

  // ─── State של הלוח (חוק-1 · מצב=חיווט): טופל · נדחה(סיבה) · הואצל(למי) · KPI-מוצמדים · יעדים-שהוגדרו · אודיט ───
  final Set<String> doneIds = {};
  final Map<String, String> deferred = {};
  final Map<String, String> delegated = {};
  final Set<String> pinned = {};
  final Map<String, num> goalOverride = {};
  final List<Map<String, String>> audit = []; // [{iso,who,what}] — פעולות-הלוח (מצב-בלבד; המודולים לא נכתבים)
  void log(String who, String what) => audit.insert(0, {'iso': today, 'who': who, 'what': what});

  // ─── מודולים ───
  List<Map<String, dynamic>> get modules => input.modules;
  Map<String, dynamic>? module(String id) {
    for (final m in modules) {
      if (m['id'] == id) return m;
    }
    return null;
  }
  bool live(String id) {
    final m = module(id);
    return m != null && m['enabled'] == true && m['error'] == null;
  }
  num? kpi(String mod, String key) {
    if (!live(mod)) return null;
    final v = (module(mod)!['kpi'] as Map)[key];
    return v is num ? v : null;
  }

  // ═══ פעולה-1 · איסוף = cockpitQueue (שקעי-קבוצות: דחוף-היום · בסיכון · שאר) ⇒ {tasks,total} ═══
  //   הקבוצות מוזנות מהמודולים (ניקוי-אוטומטי: status=='done' במודול ⇒ יוצא מהתור). owner מוחלף בהאצלה.
  List<Map<String, dynamic>> _flat() => [
        for (final m in modules)
          if (live(m['id'] as String))
            for (final t in (m['tasks'] as List))
              if ((t as Map)['status'] != 'done')
                {...t.cast<String, dynamic>(), 'module': m['id'], 'moduleLabel': m['label'], 'glyph': m['glyph'], 'route': m['route'],
                  if (delegated[t['id']] != null) 'owner': delegated[t['id']]},
      ];
  List _grp(List sups, String iso, [num? _]) => [for (final t in sups) if (sev(t as Map<String, dynamic>) == 2) t];
  List _grp1(List sups, String iso) => [for (final t in sups) if (sev(t as Map<String, dynamic>) == 1) t];
  List _grp0(List sups, String iso) => [for (final t in sups) if (sev(t as Map<String, dynamic>) == 0) t];
  Map<String, dynamic> queue() => cockpitQueue(_flat(), today, 0, _grp, _grp1, _grp0);
  List<Map<String, dynamic>> get tasks => (queue()['tasks'] as List).cast<Map<String, dynamic>>();
  Map<String, dynamic> progress() => cockpitProgress(queue(), doneIds);

  // ═══ פעולה-3 · דירוג = חיבור-מודלים בהחלטה (23-ד): band(השפעה×ותק) ∨ SLA-פרוץ ∨ חומרת-המודול ═══
  int since(Map<String, dynamic> t) {
    final d = dayDiff('${t['opened'] ?? ''}', today);
    return d.isFinite ? d.toInt() : 0;
  }
  int dueIn(Map<String, dynamic> t) {
    final d = dayDiff('${t['due'] ?? ''}', today);
    return d.isFinite ? -d.toInt() : 0; // חיובי = עוד X ימים · שלילי = באיחור
  }
  // השפעה מאוחדת = תלמידים + ₪/500 (שני-האותות יחד, לא בחירה)
  num impact(Map<String, dynamic> t) => ((t['students'] as num?) ?? 0) + (((t['ils'] as num?) ?? 0) / 500);
  // ציון-דחיפות דינמי = השפעה × (1 + ותק/SLA)
  num score(Map<String, dynamic> t) => impact(t) * (1 + since(t) / slaOf(t));
  bool slaBreached(Map<String, dynamic> t) => taskOverdue(t, today) || since(t) > slaOf(t); // ∨ שני-המודלים
  bool isDone(Map<String, dynamic> t) => doneIds.contains(t['id']);
  int sev(Map<String, dynamic> t) {
    if (isDone(t) || deferred.containsKey(t['id'])) return 0;
    final b = band(score(t).round(), hi, mid); // מנוע-מדף band (dart/band.dart)
    if (slaBreached(t)) return 2; // SLA-פרוץ ⇒ העלאה (אוטומציה)
    final own = t['sev']; // חומרת-המודול: due ⇒ לפחות 🔴 · risk ⇒ לפחות 🟠
    if (own == 'due') return 2;
    if (own == 'risk' && b < 1) return 1;
    return b;
  }
  String statusOf(Map<String, dynamic> t) => isDone(t) ? 'בוצע' : deferred.containsKey(t['id']) ? 'נדחה' : delegated.containsKey(t['id']) ? 'הואצל' : 'פתוח';

  // ═══ פעולה-2 · הערכה = KPI-12 (חוזה-KPI: label·glyph·מודול·מפתח/נגזרת · מקום-שמור כשאין-מקור) ═══
  //   כל KPI = get(kpi-map) ⇒ num?; null ⇒ '—' + שבב "לא-זמין" (חוק-7). tone: 1=ok 2=danger 3=warn לפי-סף.
  late final List<Map<String, dynamic>> kpiDefs = [
    {'key': 'students', 'label': '🎓 תלמידים-פעילים', 'mod': 'students', 'get': () => kpi('students', 'active')},
    {'key': 'attToday', 'label': '🗓 נוכחות-היום', 'mod': 'attendance', 'pct': true, 'get': () {
        final p = kpi('attendance', 'presentToday'), a = kpi('attendance', 'absentToday');
        return (p == null || a == null || p + a == 0) ? null : p / (p + a) * 100;
      }, 'bad': (num v) => v < (goal('attendancePct') ?? 0)},
    {'key': 'risk', 'label': '🚨 תלמידים-בסיכון', 'mod': 'students', 'get': () => kpi('students', 'riskHigh'), 'bad': (num v) => v > (goal('riskCount') ?? 0)},
    {'key': 'noTeacher', 'label': '🧑‍🏫 שיעורים-ללא-מורה', 'mod': 'teachers', 'get': () => kpi('teachers', 'noTeacherToday'), 'bad': (num v) => v > 0},
    {'key': 'absentT', 'label': '🤒 מורים-נעדרים', 'mod': 'teachers', 'get': () => kpi('teachers', 'absentToday'), 'warn': (num v) => v > 0},
    {'key': 'conflicts', 'label': '⚡ התנגשויות-מערכת', 'mod': 'courses', 'get': () { // חיבור שני-מודולים (חוגים+חדרים), לא בחירה
        final c = kpi('courses', 'conflicts'), r = kpi('rooms', 'conflicts');
        return (c == null && r == null) ? null : (c ?? 0) + (r ?? 0);
      }, 'bad': (num v) => v > 0},
    {'key': 'collect', 'label': '💳 גבייה', 'mod': 'fees', 'pct': true, 'get': () {
        final c = kpi('fees', 'collected'), ch = kpi('fees', 'chargedYear');
        return (c == null || ch == null || ch == 0) ? null : c / ch * 100;
      }, 'bad': (num v) => v < (goal('collectionPct') ?? 0)},
    {'key': 'oldDebt', 'label': '⏳ חוב-ותיק', 'mod': 'fees', 'ils': true, 'get': () => kpi('fees', 'oldDebt'), 'warn': (num v) => v > 0},
    {'key': 'consents', 'label': '✍️ אישורי-הורים-פגים', 'mod': 'parents', 'get': () => kpi('parents', 'consentsExpiring'), 'warn': (num v) => v > 0},
    {'key': 'inquiries', 'label': '📨 פניות-פתוחות', 'mod': 'parents', 'get': () { // הורים + תלמידים יחד
        final p = kpi('parents', 'openInquiries'), s = kpi('students', 'openInquiries');
        return (p == null && s == null) ? null : (p ?? 0) + (s ?? 0);
      }, 'warn': (num v) => v > 0},
    {'key': 'faults', 'label': '🔧 חדרים-תקולים', 'mod': 'rooms', 'get': () => kpi('rooms', 'unavailable'), 'warn': (num v) => v > 0},
    {'key': 'invOrder', 'label': '📦 מלאי-דורש-הזמנה', 'mod': 'inventory', 'get': () => kpi('inventory', 'needsOrder'), 'bad': (num v) => v > 0},
  ];
  num? kpiValue(Map<String, dynamic> d) => (d['get'] as num? Function())();
  String kpiText(Map<String, dynamic> d) {
    final v = kpiValue(d);
    if (v == null) return '—';
    if (d['pct'] == true) return '${v.toStringAsFixed(1)}%';
    if (d['ils'] == true) return shekel(v.round());
    return v is int ? '$v' : v.toStringAsFixed(0);
  }
  int kpiTone(Map<String, dynamic> d) { // 0=נייטרלי 1=ok 2=danger 3=warn
    final v = kpiValue(d);
    if (v == null) return 0;
    if (d['bad'] != null) return (d['bad'] as bool Function(num))(v) ? 2 : 1;
    if (d['warn'] != null) return (d['warn'] as bool Function(num))(v) ? 3 : 1;
    return 0;
  }
  num? goal(String key) => goalOverride[key] ?? input.goals[key];

  // ═══ פעולה-4 · איתור = smartFilter⊕smartScore⊕normSearch · חריגה = finderMatches · טווח = dateInRange ═══
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _terms(Map<String, dynamic> t) => ['${t['title']}', '${t['moduleLabel']}', '${t['owner']}', '${t['note'] ?? ''}', '${t['kind']}'];
  List<Map<String, dynamic>> search(List<Map<String, dynamic>> items, String q) =>
      (smartFilter(q, items, (it) => _terms(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // צירי-חריגה (AND על נעילות): module · sev · owner · sla · status · kind
  String _axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) {
    final t = f as Map<String, dynamic>;
    switch (axis) {
      case 'module': return '${t['module']}';
      case 'sev': return '${sev(t)}';
      case 'owner': return '${t['owner']}';
      case 'sla': return slaBreached(t) && !isDone(t) ? '1' : '0';
      case 'status': return statusOf(t);
      case 'kind': return (t['kind'] as String).split('.').first;
      case 'grade': return '${t['grade'] ?? ''}'; // שכבה/כיתה — מקום-שמור: מאיר רק כשמשימה נושאת grade
    }
    return '';
  }
  List<Map<String, dynamic>> filter(List<Map<String, dynamic>> items, Map<String, String> locks) =>
      finderMatches({'families': items}, Map<dynamic, dynamic>.from(locks), _axisValue).cast<Map<String, dynamic>>();

  // טווח: 0 היום · 1 שבוע · 2 חודש · 3 שנה ⇒ [from,to]. משימה בטווח = due ≤ to (כולל באיחור) — "מה על השולחן עד סוף החלון".
  static const rangeDays = [0, 7, 30, 365];
  String shift(int days) {
    final d = DateTime.parse('${today}T12:00:00').add(Duration(days: days));
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
  String rangeTo(int r) => shift(rangeDays[r]);
  List<Map<String, dynamic>> inRange(List<Map<String, dynamic>> items, int r) =>
      items.where((t) => dateInRange('${t['due'] ?? today}', null, rangeTo(r))).toList();
  String rangeText(int r) => r == 0 ? 'היום' : rangeLabel({'from': today, 'to': rangeTo(r)}, fmtDate, const {'k1': 'הכל', 'k2': 'מ-', 'k3': 'עד '});

  // ═══ פעולה-6 · מגמה = trendFromScan על סדרה-חודשית (מחצית-חדשה מול ישנה ⇒ dir/pct) ═══
  List<num>? series(String mod, String key) {
    if (!live(mod)) return null;
    final s = (module(mod)!['series'] as Map?)?[key];
    return s is List ? s.cast<num>() : null;
  }
  Map<String, dynamic>? trend(String mod, String key) {
    final s = series(mod, key);
    return s == null || s.isEmpty ? null : trendFromScan({'monthly': s});
  }
  // תחזית (30/90) = ערך-אחרון + שיפוע-חודשי × n (שיפוע = (מחצית-חדשה−ישנה)/מחצית)
  num? forecast(String mod, String key, int months) {
    final s = series(mod, key);
    if (s == null || s.length < 2) return null;
    final h = s.length ~/ 2;
    num older = 0, newer = 0;
    for (var i = 0; i < h; i++) older += s[i];
    for (var i = s.length - h; i < s.length; i++) newer += s[i];
    final slope = (newer - older) / h / h;
    return s.last + slope * months;
  }
  // קפיצת-מגמה שבועית: ירידה ≥ 3 נק׳ בשבוע האחרון מול הקודם (אוטומציה)
  num? weeklyJump() {
    final w = series('attendance', 'weeklyPct');
    return (w == null || w.length < 2) ? null : w.last - w[w.length - 2];
  }
  // השוואת-שכבות: חריגה-סטטיסטית = |x−ממוצע| > 1.5σ (ממוצע/σ מורכבים מ-grandTotal + dart:math)
  // ═══ פעולה-7 · אימות+תדרוך = cockpitWorkListText · cockpitCsvRows⊕toCsv⊕csvEscape⊕exportAllowed · holidayOf ═══
  static const _kindT = {'k1': '🔴', 'k2': '🟠', 'k3': '🟢', 'k4': 'ללא שם'};
  Map<String, dynamic> _queueFor(List<Map<String, dynamic>> ts) => {
        'tasks': [for (final t in ts) {'kind': sev(t) == 2 ? 'call' : sev(t) == 1 ? 'thanks' : 'hok', 'name': '${t['moduleLabel']} · ${t['title']}', 'phone': '${t['owner']}', 'reason': '${t['action']} · ${dueIn(t) < 0 ? 'באיחור ${-dueIn(t)} י׳' : 'יעד ${fmtDate('${t['due']}')}'}'}],
        'total': ts.length,
      };
  String briefText(List<Map<String, dynamic>> ts) {
    final head = [
      '☀️ תדרוך-בוקר · ${fmtDate(today)} · ${ts.length} משימות · ${ts.where((t) => sev(t) == 2).length} דחופות',
      for (final d in kpiDefs) '${d['label']}: ${kpiText(d)}',
      '',
    ];
    return '${head.join('\n')}${cockpitWorkListText(_queueFor(ts), _kindT)}';
  }
  static const _csvT = {'k1': 'דחוף', 'k2': 'בקרוב', 'k3': 'רגיל', 'k4': 'דחיפות', 'k5': 'משימה', 'k6': 'אחראי', 'k7': 'פעולה·יעד'};
  String csvOf(List<Map<String, dynamic>> ts) => toCsv(cockpitCsvRows(_queueFor(ts), _csvT), csvEscape) as String;
  bool exportOk(int role) => exportAllowed(false) && can(role, 'dash.export');
  List<Map<String, dynamic>> get briefRecipients => bulkMailRecipients(input.staff, (e) => normEmail(e));

  // יום-חופש: חג לפי הלוח-העברי (holidayOf⊕hebParts⊕HOLIDAYS) ∨ לוח-המוסד (schoolHolidays). שני-המקורות מחוברים.
  static String _term(String k) => const {'chnvkh': 'חנוכה', 'tsvm-yz-btmvz-ndchh': 'צום י״ז בתמוז נדחה', 'tshah-bab-ndchh': 'תשעה באב נדחה', 'tsvm-gdlyh-ndchh': 'צום גדליה נדחה', 'tanyt-astr-mvkdm': 'תענית אסתר מוקדם'}[k] ?? k;
  static Map<String, dynamic> _hp(DateTime d) => hebParts(d);
  // שקע scanHebYear(year) ⇒ {has30}: סריקת-שנה עברית — אילו חודשים בני-30 (דרוש רק ל-ג׳ טבת ⇒ חנוכה)
  static Map _scanHebYear(dynamic year) {
    final has30 = <String>{};
    final start = DateTime((year as int) - 3761, 8, 15, 12);
    for (var i = 0; i < 400; i++) {
      final p = hebParts(start.add(Duration(days: i)));
      if (p['year'] == year && p['day'] == 30) has30.add(p['month'] as String);
    }
    return {'has30': has30};
  }
  static String? hebHoliday(DateTime d) => holidayOf(d, _hp, _scanHebYear, HOLIDAYS, term: _term);
  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  String? get holidayToday {
    for (final h in input.schoolHolidays) {
      if (h['iso'] == today) return h['name'];
    }
    return hebHoliday(DateTime.parse('${today}T12:00:00'));
  }
  List<Map<String, dynamic>> get upcoming => upcomingHolidays(today, hebHoliday, _iso, 45);

  // ═══ הרשאות (חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction · 4 מבטים ═══
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👑 מנהל/ת', 'email': 'mgr@school', 'config': {'adminEmails': ['mgr@school']}},
    {'label': '🧭 רכז/ת', 'email': 'coord9@school', 'config': {'features': {'dash.act': true, 'dash.module.students': true, 'dash.module.attendance': true, 'dash.module.courses': true, 'dash.module.parents': true}}},
    {'label': '🏛 ועד/בעלים', 'email': 'board@school', 'config': {'features': {'dash.summary': true}}},
    {'label': '💰 כספים', 'email': 'fin@school', 'config': {'features': {'dash.module.fees': true, 'dash.export': true}}},
  ];
  static bool _isAdmin(Map<String, dynamic> c, String e) => roleOf(c, e) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['email'] as String, false, key, _isAdmin);
  }
  static bool seesModule(int role, String mod) => can(role, 'dash.module.$mod');
  static bool summaryOnly(int role) => can(role, 'dash.summary') && !_isAdmin((roleDefs[role]['config'] as Map).cast<String, dynamic>(), roleDefs[role]['email'] as String);
  // מבט-סיכום (ועד): רואה מונים של כל המודולים (אפס-פרטים ברנדר); רכז/כספים: רק המודולים שהוקצו
  List<Map<String, dynamic>> forRole(List<Map<String, dynamic>> ts, int role) =>
      summaryOnly(role) ? ts : ts.where((t) => seesModule(role, t['module'] as String)).toList();
  // KPI פר-מבט · מוצמדים-ראשונים (הצמד-KPI = state; מיון יציב לפי סדר-החוזה)
  List<Map<String, dynamic>> kpisForRole(int role) {
    final ks = summaryOnly(role) ? kpiDefs : kpiDefs.where((d) => seesModule(role, d['mod'] as String)).toList();
    return [...ks.where((k) => pinned.contains(k['key'])), ...ks.where((k) => !pinned.contains(k['key']))];
  }

  // ═══ חוזה-עמודות · 12 עמודות-המפרט (חוק-7 · מקום-שמור): נגזרת=תמיד · שדה=מוארת רק כשיש-ערך ═══
  late final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    {'label': 'דחיפות', 'get': (Map<String, dynamic> t) => const {2: '🔴', 1: '🟠', 0: '🟢'}[sev(t)]!},
    {'label': 'מודול', 'get': (Map<String, dynamic> t) => '${t['glyph']} ${t['moduleLabel']}'},
    {'label': 'תיאור', 'get': (Map<String, dynamic> t) => '${t['title']}'},
    {'key': 'owner', 'label': 'אחראי'},
    {'label': 'מאז', 'get': (Map<String, dynamic> t) => '${since(t)} י׳'},
    {'label': 'השפעה', 'get': (Map<String, dynamic> t) => [if (((t['students'] as num?) ?? 0) > 0) '${t['students']} תל׳', if (((t['ils'] as num?) ?? 0) > 0) shekel((t['ils'] as num).round())].join(' · ')},
    {'key': 'action', 'label': 'פעולה'},
    {'label': 'סטטוס', 'get': (Map<String, dynamic> t) => statusOf(t)},
    {'label': 'יעד', 'get': (Map<String, dynamic> t) => fmtDate('${t['due'] ?? ''}')},
    {'label': 'SLA', 'get': (Map<String, dynamic> t) => slaBreached(t) && !isDone(t) ? '⛔ פרוץ' : '${slaOf(t)} י׳'},
    {'key': 'link', 'label': 'קישור'},
    {'key': 'note', 'label': 'הערה'},
    {'key': 'grade', 'label': 'שכבה'}, // מקום-שמור (מואר כשמשימה נושאת grade)
    {'key': 'assignedBy', 'label': 'הוקצה ע״י'}, // מקום-שמור
    {'key': 'escalatedTo', 'label': 'הוסלם ל-'}, // מקום-שמור
  ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || rows.any((t) => t[c['key']] != null && '${t[c['key']]}'.trim().isNotEmpty);

  // ═══ מקום-שמור · יכולות-המפרט ללא מקור-אמת (חוק-7): מאירות כשיגיע נתון/שקע — לא מזייפים, לא משמיטים ═══
  static const reserved = <Map<String, String>>[
    {'key': 'benchmark', 'label': 'benchmark חיצוני', 'why': 'אין מקור-השוואה חיצוני במודולים'},
    {'key': 'ministryReport', 'label': 'דוח-למשרד-החינוך', 'why': 'אין תבנית/סכמה רשמית מוזנת'},
    {'key': 'budgetVsActual', 'label': 'תקציב-מול-ביצוע', 'why': 'אין מודול-תקציב (רק גבייה)'},
    {'key': 'authorityCharter', 'label': 'אמנת-סמכות (מה הלוח רשאי לבצע לבד)', 'why': 'הכרעת-בעלים — הלוח אפס-כתיבה'},
    {'key': 'pdfExport', 'label': 'ייצוא PDF', 'why': 'אין מנוע-PDF במדף (רק pdfSafe לטקסט)'},
    {'key': 'autoMail0500', 'label': 'שליחת-תדרוך אוטומטית 05:00', 'why': 'דורש מתזמן-שרת; הטקסט+הנמענים מוכנים'},
    {'key': 'autoMonthly', 'label': 'דוח-חודשי אוטומטי', 'why': 'דורש מתזמן-שרת; הדוח עצמו מופק בלחיצה'},
    {'key': 'crossSearchModules', 'label': 'חיפוש-חוצה בתוך רשומות-המודולים', 'why': 'הלוח מחפש במשימות-המודולים; רשומות-גולמיות (תלמיד/חשבונית) = שקע-חיפוש של כל מודול'},
  ];
}

// ═══════════════════════ המסך · DashboardScreen (חיווט-בשקעים · אפס-ציור-ביד) ═══════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({this.input, this.onOpenModule, super.key});
  final DashInput? input; // שקע-הקלט (null ⇒ דמו-אמת)
  final void Function(String route)? onOpenModule; // שקע-drill-down: הפעולה מבוצעת במודול-המקור (המנהל מחבר ניווט)
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late _DashData d = _DashData(widget.input ?? DashInput.demo);
  // שקע-הקלט התחלף (מודולים רועננו / today חדש) ⇒ מנוע חדש — ה-State לא נשאר על קלט ישן (נתפס בבדיקת-widget)
  @override
  void didUpdateWidget(DashboardScreen old) {
    super.didUpdateWidget(old);
    if (!identical(old.input, widget.input)) d = _DashData(widget.input ?? DashInput.demo);
  }
  int _role = 0; // 0 מנהל · 1 רכז · 2 ועד · 3 כספים
  int _range = 0; // 0 היום · 1 שבוע · 2 חודש · 3 שנה
  int _tab = 0; // 9 טאבים
  int _mode = 0; // 0 🎯 טריאז' · 1 📋 טבלה (12 עמודות)
  String _q = '';
  final Map<String, String> _locks = {}; // צירי-חריגה פעילים (finderMatches)
  String? _error;
  // ─── שקעי-עזר ───
  Widget _gap([double h = 10]) => SizedBox(height: h);
  Widget _seg(List<String> items, int sel, ValueChanged<int> on) => Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: SegmentedSwitch(items: items, selected: sel, onSelect: on)),
      );
  Widget _wrap(List<Widget> kids, {double top = 6}) => Padding(padding: EdgeInsets.only(top: top, right: 4), child: Wrap(spacing: 8, runSpacing: 6, children: kids));
  Widget _title(String s) => Text(s, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800));
  void _open(String route) {
    d.log(_DashData.roleDefs[_role]['label'] as String, 'פתח מודול $route');
    final f = widget.onOpenModule;
    if (f != null) {
      f(route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('drill-down: $route (שקע-ניווט של המנהל)')));
    }
    setState(() {});
  }

  // ═══ טאב-0 · תדרוך-היום: טריאז' (DsSection פר-דחיפות) או טבלה (DsTable · 12 עמודות) ═══
  List<Widget> _briefTab(List<Map<String, dynamic>> visible, List<Map<String, dynamic>> open, Map<int, List<Map<String, dynamic>>> buckets, Map<int, String> secTitle, Map<int, int> secTone, String? holiday) => [
        Row(children: [
          Expanded(child: _seg(const ['🎯 טריאז׳', '📋 טבלה'], _mode, (i) => setState(() => _mode = i))),
          if (_DashData.can(_role, 'dash.act')) ...[
            const SizedBox(width: 6),
            SoftButton(label: '☀️ שלח-תדרוך', tone: 1, onTap: () => _openBrief(open)),
          ],
        ]),
        _gap(10),
        if (holiday != null)
          const EmptyState(glyph: '🏖', message: 'יום-חופש — התור מוקפא. ה-KPI וההתרעות למעלה נשארים חיים.')
        else if (d.tasks.isEmpty)
          const EmptyState(glyph: '🎉', message: 'אין משימות פתוחות — בוקר ירוק!')
        else if (visible.isEmpty)
          EmptyState(glyph: '🔍', message: d.inRange(d.forRole(d.tasks, _role), _range).isEmpty ? 'תקופה-ללא-דאטה: אין משימות עד ${d.rangeText(_range)}' : 'אין משימות תואמות לחיפוש/סינון')
        else if (_mode == 1)
          _table(visible)
        else
          for (final st in const [2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              DsSection(title: '${secTitle[st]} · ${buckets[st]!.length}', tone: secTone[st]!, children: [for (final t in buckets[st]!) _row(t)]),
      ];

  // שורת-משימה: MediaRow(כותרת) + עובדות-שבב (מאז · השפעה · SLA · אחראי · סטטוס) + פעולה-בלחיצה + פתיחת-פאנל
  Widget _row(Map<String, dynamic> t) {
    final done = d.isDone(t);
    final due = d.dueIn(t);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: MediaRow(glyph: t['glyph'] as String, title: '${t['title']}', subtitle: '${t['moduleLabel']} · ${t['owner']} · ${due < 0 ? 'באיחור ${-due} י׳' : due == 0 ? 'יעד היום' : 'יעד בעוד $due י׳'}')),
            IconButton(onPressed: () => _openPanel(t), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'פרטים ופעולות'),
          ]),
          _wrap([
            StatusChip(label: '⏱ מאז ${d.since(t)} י׳', tone: 0),
            if (((t['students'] as num?) ?? 0) > 0) StatusChip(label: '🎓 ${t['students']} תלמידים', tone: 0),
            if (((t['ils'] as num?) ?? 0) > 0) StatusChip(label: shekel((t['ils'] as num).round()), tone: 0),
            StatusChip(label: d.slaBreached(t) && !done ? '⛔ SLA פרוץ (${d.slaOf(t)} י׳)' : 'SLA ${d.slaOf(t)} י׳', tone: d.slaBreached(t) && !done ? 2 : 1),
            StatusChip(label: d.statusOf(t), tone: done ? 1 : 0),
            if (d.deferred[t['id']] != null) StatusChip(label: 'סיבה: ${d.deferred[t['id']]}', tone: 3),
          ]),
          if (!done && _DashData.can(_role, 'dash.act'))
            _wrap([
              SoftButton(label: '▶ ${t['action']}', tone: 1, onTap: () => _open('${t['link']}')),
              SoftButton(label: '✅ בוצע', tone: 0, onTap: () => setState(() { d.doneIds.add(t['id'] as String); d.log(t['owner'] as String, 'סימן בוצע: ${t['title']}'); })),
            ], top: 8),
        ]),
      ),
    );
  }

  // 📋 טבלה: DsTable מונחה-חוזה (columnDefs · 12 עמודות + מקום-שמור) — לא DataGrid
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in d.columnDefs) if (_DashData.colShown(c, rows)) c];
    return DsTable(
      labels: [for (final c in cols) c['label'] as String],
      rows: [for (final t in rows) [for (final c in cols) c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(t) : '${t[c['key']] ?? '—'}']],
    );
  }

  // ═══ טאב-1 · KPI מלא: ערך + מקור + הצמדה + מקום-שמור ═══
  List<Widget> _kpiTab(List<Map<String, dynamic>> kpis) => [
        DsSection(title: '📊 KPI חוצה-מוסד · ${kpis.length} · לפי מקור-אמת', children: [
          for (final k in kpis)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(child: MediaRow(glyph: d.module(k['mod'] as String)?['glyph'] as String? ?? '•', title: '${k['label']}', subtitle: d.live(k['mod'] as String) ? 'מקור: מודול ${d.module(k['mod'] as String)?['label']}' : 'נתון-לא-זמין (מודול ${k['mod']} לא מופעל/בשגיאה) — מקום-שמור')),
                BareStat(value: d.kpiText(k), label: const ['', '✅', '🔴', '🟠'][d.kpiTone(k)], inkColor: const [_ink, _ok, _danger, _warning][d.kpiTone(k)], mutedColor: _muted),
                SoftButton(label: d.pinned.contains(k['key']) ? '📌 הסר' : '📌 הצמד', tone: 0, onTap: () => setState(() => d.pinned.contains(k['key']) ? d.pinned.remove(k['key']) : d.pinned.add(k['key'] as String))),
              ]),
            ),
        ]),
        DsSection(title: '🧩 מקום-שמור · ${_DashData.reserved.length} יכולות ללא מקור-אמת (מאירות כשיגיע נתון)', tone: 3, children: [
          for (final r in _DashData.reserved) TimelineItem(title: r['label']!, time: 'שמור', body: r['why']),
        ]),
      ];

  // ═══ טאב-2 · מגמות: trendFromScan ⇒ TrendStat (דלתא-אחוזית) + NeonBars על **הפער-מהיעד** פר-חודש ═══
  //   (אימות-רנדר תפס הרכבת-יתר: סדרת-אחוזים 90–94 מנורמלת-למקסימום נראית שטוחה ⇒ הבר מודד פער-מיעד = ההחלטה.)
  List<Widget> _trendsTab() {
    final defs = [
      ('attendance', 'attendancePct', '🗓 נוכחות חודשית %', true, 'attendancePct', false),
      ('fees', 'collectionPct', '💳 גבייה מצטברת %', true, 'collectionPct', false),
      ('students', 'riskCount', '🚨 תלמידים-בסיכון (מונה)', false, 'riskCount', true),
    ];
    return [
      for (final (mod, key, label, pct, goalKey, lowerBetter) in defs)
        () {
          final s = d.series(mod, key);
          final tr = d.trend(mod, key);
          if (s == null || tr == null) return DsSection(title: label, tone: 3, children: [const EmptyState(glyph: '📭', message: 'תקופה-ללא-דאטה / מודול לא-זמין — מקום-שמור')]);
          final goal = d.goal(goalKey);
          String mLabel(int i) => i == s.length - 1 ? 'החודש' : 'לפני ${s.length - 1 - i} ח׳';
          final dir = tr['dir'];
          final good = dir == 'flat' ? null : (dir == 'up') != lowerBetter;
          return DsSection(title: label, children: [
            TrendStat(value: pct ? '${s.last}%' : '${s.last}', delta: (tr['pct'] as num).toDouble(), label: 'אחרון מול ${s.length ~/ 2} חודשים קודמים · ${dir == 'up' ? 'עולה' : dir == 'down' ? 'יורד' : 'יציב'}${good == null ? '' : good ? ' · לטובה' : ' · לרעה'}'),
            _gap(),
            if (goal == null)
              NeonBars(labels: [for (var i = 0; i < s.length; i++) mLabel(i)], values: [for (final v in s) v.toDouble()], tone: 0)
            else ...[
              _title('פער מהיעד ($goal) פר-חודש — בר ארוך = רחוק מהיעד · 0 = ביעד'),
              _gap(6),
              NeonBars(
                labels: [for (var i = 0; i < s.length; i++) '${mLabel(i)} · ${s[i]}${pct ? '%' : ''}'],
                values: [for (final v in s) math.max(0, lowerBetter ? v - goal : goal - v).toDouble()],
                tone: 3,
              ),
            ],
          ]);
        }(),
    ];
  }

  // ═══ טאב-4 · יעדים-שנתיים: מדד-מול-יעד (StatRow) + תחזית 30/90 + הגדר-יעד ═══
  List<String> _goalsAtRisk() {
    final out = <String>[];
    for (final g in _goalDefs()) {
      final f = g.$5;
      final goal = d.goal(g.$1);
      if (f == null || goal == null) continue;
      final ok = g.$4 ? f <= goal : f >= goal;
      if (!ok) out.add('יעד-בסיכון: ${g.$2} — תחזית-90 ${f.toStringAsFixed(1)} מול יעד $goal');
    }
    return out;
  }
  // (key, label, now, lowerBetter, forecast90)
  List<(String, String, num?, bool, num?)> _goalDefs() => [
        ('attendancePct', 'נוכחות %', d.kpiValue(d.kpiDefs[1]), false, d.forecast('attendance', 'attendancePct', 3)),
        ('collectionPct', 'גבייה %', d.kpiValue(d.kpiDefs[6]), false, d.forecast('fees', 'collectionPct', 3)),
        ('riskCount', 'תלמידים-בסיכון', d.kpiValue(d.kpiDefs[2]), true, d.forecast('students', 'riskCount', 3)),
      ];
  List<Widget> _goalsTab() => [
        for (final g in _goalDefs())
          () {
            final goal = d.goal(g.$1);
            final now = g.$3;
            if (goal == null || now == null) return DsSection(title: g.$2, tone: 3, children: [const EmptyState(glyph: '📭', message: 'אין יעד/נתון — מקום-שמור')]);
            final frac = g.$4 ? (now == 0 ? 1.0 : (goal / now).clamp(0.0, 1.0)) : (goal == 0 ? 1.0 : (now / goal).clamp(0.0, 1.0));
            final met = g.$4 ? now <= goal : now >= goal;
            final f30 = g.$4 ? d.forecast(g.$1 == 'riskCount' ? 'students' : 'fees', g.$1, 1) : d.forecast(g.$1 == 'attendancePct' ? 'attendance' : 'fees', g.$1, 1);
            return DsSection(title: '🎯 ${g.$2} · ${met ? '✅ ביעד' : '⚠️ מתחת ליעד'}', tone: met ? 1 : 3, children: [
              StatRow(label: 'מדד מול יעד', value: '${now.toStringAsFixed(1)} מתוך $goal', fraction: frac),
              _gap(8),
              Row(children: [
                BareStat(value: now.toStringAsFixed(1), label: 'עכשיו', inkColor: _ink, mutedColor: _muted),
                BareStat(value: f30 == null ? '—' : f30.toStringAsFixed(1), label: 'תחזית-30', inkColor: _ink, mutedColor: _muted),
                BareStat(value: g.$5 == null ? '—' : g.$5!.toStringAsFixed(1), label: 'תחזית-90', inkColor: g.$5 == null ? _muted : ((g.$4 ? g.$5! <= goal : g.$5! >= goal) ? _ok : _danger), mutedColor: _muted),
              ]),
              if (_DashData.can(_role, 'dash.goals') || _DashData.can(_role, 'dash.act'))
                _wrap([
                  SoftButton(label: '🎯 יעד −1', tone: 0, onTap: () => setState(() { d.goalOverride[g.$1] = goal - 1; d.log('מנהל', 'יעד ${g.$2}: ${goal - 1}'); })),
                  SoftButton(label: '🎯 יעד +1', tone: 0, onTap: () => setState(() { d.goalOverride[g.$1] = goal + 1; d.log('מנהל', 'יעד ${g.$2}: ${goal + 1}'); })),
                ], top: 8),
            ]);
          }(),
      ];

  // ═══ טאב-5 · דוחות: הפק-דוח (שבועי/חודשי/שנתי) · תדרוך · CSV · הדפס · מקום-שמור (PDF/משרד) ═══
  List<Widget> _reportsTab(List<Map<String, dynamic>> open) => [
        DsSection(title: '📄 דוחות ותוצרים', children: [
          _wrap([
            SoftButton(label: '📅 דוח שבועי', tone: 0, onTap: () => _openText('דוח שבועי · עד ${fmtDate(d.rangeTo(1))}', d.briefText(d.inRange(open, 1)))),
            SoftButton(label: '🗓 דוח חודשי', tone: 0, onTap: () => _openText('דוח חודשי · עד ${fmtDate(d.rangeTo(2))}', d.briefText(d.inRange(open, 2)))),
            SoftButton(label: '📆 דוח שנתי', tone: 0, onTap: () => _openText('דוח שנתי · עד ${fmtDate(d.rangeTo(3))}', d.briefText(d.inRange(open, 3)))),
            SoftButton(label: '🖨 הדפס-לוח', tone: 0, onTap: () => _openText('הדפסה · לוח-הנהלה', d.briefText(open))),
            if (d.exportOk(_role)) SoftButton(label: '⬇ CSV', tone: 0, onTap: () => _openText('ייצוא CSV', d.csvOf(open), ltr: true)),
          ], top: 0),
          _gap(10),
          _wrap([
            const StatusChip(label: '🏛 דוח-למשרד-החינוך · מקום-שמור (אין סכמה)', tone: 3),
            const StatusChip(label: '📎 PDF · מקום-שמור (אין מנוע-PDF במדף)', tone: 3),
          ], top: 0),
        ]),
        DsSection(title: '☀️ תדרוך-בוקר (טקסט-מוכן · 05:00 אוטומטי = מקום-שמור למתזמן)', children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
            child: SelectableText(d.briefText(open), style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
          ),
        ]),
      ];

  // ═══ פאנל-משימה-נבחרת (GlassCard · bottom-sheet): מקור · הקשר-מלא · היסטוריה · אחראי · פעולה-בלחיצה · השפעה-אם-לא · פעולות ═══
  void _openPanel(Map<String, dynamic> t) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
        final done = d.isDone(t);
        final ctxMap = (t['context'] as Map?) ?? const {};
        final hist = (t['history'] as List?) ?? const [];
        final canAct = _DashData.can(_role, 'dash.act') && !done;
        return DraggableScrollableSheet(
          initialChildSize: 0.75, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                MediaRow(glyph: t['glyph'] as String, title: '${t['title']}', subtitle: 'מקור: ${t['moduleLabel']} · ${t['kind']} · ${d.statusOf(t)}'),
                _gap(12),
                Row(children: [
                  BareStat(value: const {2: '🔴', 1: '🟠', 0: '🟢'}[d.sev(t)]!, label: 'דחיפות', inkColor: _ink, mutedColor: _muted),
                  BareStat(value: d.score(t).toStringAsFixed(1), label: 'ציון (השפעה×ותק)', inkColor: _ink, mutedColor: _muted),
                  BareStat(value: '${d.since(t)} י׳', label: 'מאז', inkColor: d.slaBreached(t) ? _danger : _ink, mutedColor: _muted),
                  BareStat(value: fmtDate('${t['due']}'), label: 'יעד', inkColor: d.dueIn(t) < 0 ? _danger : _ink, mutedColor: _muted),
                ]),
                _gap(10),
                _title('הקשר-מלא (מי/מה/כמה/מאז)'),
                _wrap([
                  StatusChip(label: '👤 ${t['owner']}', tone: 0),
                  if (((t['students'] as num?) ?? 0) > 0) StatusChip(label: '🎓 ${t['students']} תלמידים', tone: 0),
                  if (((t['ils'] as num?) ?? 0) > 0) StatusChip(label: '💰 ${shekel((t['ils'] as num).round())}', tone: 0),
                  for (final e in ctxMap.entries) StatusChip(label: '${e.key}: ${e.value}', tone: 0),
                  if ('${t['note'] ?? ''}'.isNotEmpty) StatusChip(label: '📝 ${t['note']}', tone: 0),
                ]),
                _gap(12),
                AlertBanner(glyph: '⚠️', tone: d.sev(t) == 2 ? 2 : 3, message: 'השפעה-אם-לא: ${_impactIfNot(t)}'),
                _gap(14),
                _title('פעולות'),
                _gap(8),
                if (!canAct) AlertBanner(message: done ? 'המשימה סומנה כבוצעה' : 'צפייה-בלבד — אין הרשאת-פעולה במבט זה', glyph: '🔒', tone: 2)
                else _wrap([
                  SoftButton(label: '▶ ${t['action']} (במודול)', tone: 1, onTap: () { Navigator.of(ctx).pop(); _open('${t['link']}'); }),
                  SoftButton(label: '✅ סמן-בוצע', tone: 0, onTap: () => act(() { d.doneIds.add(t['id'] as String); d.log('${t['owner']}', 'בוצע: ${t['title']}'); })),
                  for (final why in const ['ממתין-למידע', 'לא-דחוף', 'תלוי-בגורם-חיצוני'])
                    SoftButton(label: '⏸ דחה · $why', tone: 3, onTap: () => act(() { d.deferred[t['id'] as String] = why; d.log('${t['owner']}', 'נדחה ($why): ${t['title']}'); })),
                  for (final s in d.input.staff)
                    if (s['name'] != t['owner']) SoftButton(label: '🤝 האצל ל-${s['name']}', tone: 0, onTap: () => act(() { d.delegated[t['id'] as String] = s['name'] as String; d.log('${t['owner']}', 'הואצל ל-${s['name']}: ${t['title']}'); })),
                  SoftButton(label: '🧭 פתח-מודול ${t['moduleLabel']}', tone: 0, onTap: () { Navigator.of(ctx).pop(); _open('${t['route']}'); }),
                ], top: 0),
                _gap(16),
                _title('היסטוריה · ${hist.length}'),
                _gap(8),
                if (hist.isEmpty) const EmptyState(glyph: '📭', message: 'אין היסטוריה רשומה במודול-המקור')
                else for (final h in hist) TimelineItem(title: '${(h as Map)['what']}', time: fmtDate('${h['iso']}'), body: '${t['moduleLabel']}'),
              ]),
            ),
          ),
        );
      }),
    );
  }
  String _impactIfNot(Map<String, dynamic> t) {
    final s = (t['students'] as num?) ?? 0, ils = (t['ils'] as num?) ?? 0;
    final parts = [if (s > 0) '$s תלמידים נפגעים', if (ils > 0) '${shekel(ils.round())} בסיכון', 'הציון עולה ל-${(d.impact(t) * (1 + (d.since(t) + d.slaOf(t)) / d.slaOf(t))).toStringAsFixed(1)} תוך SLA נוסף'];
    return parts.join(' · ');
  }

  // ═══ כללי-דחיפות (עריכים): ספי-band + SLA-פר-סוג — GlassCard + BareStat + SoftButton ═══
  void _openRules() {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
        return DraggableScrollableSheet(
          initialChildSize: 0.7, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                const MediaRow(glyph: '⚙️', title: 'כללי-דחיפות', subtitle: 'ציון = השפעה × (1 + ותק/SLA) · 🔴 ≥ סף-עליון · 🟠 ≥ סף-אמצע · SLA-פרוץ = 🔴'),
                _gap(12),
                Row(children: [
                  BareStat(value: '${d.hi}', label: 'סף 🔴', inkColor: _danger, mutedColor: _muted),
                  BareStat(value: '${d.mid}', label: 'סף 🟠', inkColor: _warning, mutedColor: _muted),
                ]),
                _wrap([
                  SoftButton(label: '🔴 −1', tone: 0, onTap: () => act(() => d.hi = math.max(d.mid + 1, d.hi - 1))),
                  SoftButton(label: '🔴 +1', tone: 0, onTap: () => act(() => d.hi += 1)),
                  SoftButton(label: '🟠 −1', tone: 0, onTap: () => act(() => d.mid = math.max(1, d.mid - 1))),
                  SoftButton(label: '🟠 +1', tone: 0, onTap: () => act(() => d.mid = math.min(d.hi - 1, d.mid + 1))),
                ]),
                _gap(14),
                _title('SLA פר-סוג (ימים)'),
                _gap(6),
                for (final e in d.slaDays.entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      Expanded(child: StatRow(label: _DashData.kindLabel(e.key), value: '${e.value} י׳', fraction: (e.value / 14).clamp(0.0, 1.0))),
                      const SizedBox(width: 6),
                      SoftButton(label: '−', tone: 0, onTap: () => act(() => d.slaDays[e.key] = math.max(1, e.value - 1))),
                      const SizedBox(width: 4),
                      SoftButton(label: '+', tone: 0, onTap: () => act(() => d.slaDays[e.key] = e.value + 1)),
                    ]),
                  ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // ═══ שלח-תדרוך-בוקר: נמענים (bulkMailRecipients⊕normEmail) + הטקסט (cockpitWorkListText) — השליחה עצמה = שקע-שרת (מקום-שמור) ═══
  void _openBrief(List<Map<String, dynamic>> open) {
    final rec = d.briefRecipients;
    _openText('☀️ תדרוך-בוקר · ${rec.length} נמענים תקינים: ${rec.map((r) => '${r['name']} <${r['email']}>').join(' · ')}\n(שליחה בפועל = שקע-מייל של ההצבה — מקום-שמור)', d.briefText(open));
    d.log(_DashData.roleDefs[_role]['label'] as String, 'הכין תדרוך-בוקר ל-${rec.length} נמענים');
  }

  // תצוגת-טקסט (דוח/CSV/תדרוך) בפאנל — SelectableText להעתקה (ההורדה חסומה בסנדבוקס)
  void _openText(String title, String body, {bool ltr = false}) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: GlassCard(
            child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              MediaRow(glyph: '📄', title: title.split('\n').first, subtitle: title.contains('\n') ? title.split('\n').skip(1).join(' ') : '${body.split('\n').length} שורות'),
              _gap(10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                child: SelectableText(body, textDirection: ltr ? TextDirection.ltr : TextDirection.rtl, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // רענון ⇒ מצב-טעינה שמור (חיבור-אסינק אמיתי יאיר אותו זהה); שגיאה-כללית = מקום-שמור (_error)
  @override
  Widget build(BuildContext context) {
    final summary = _DashData.summaryOnly(_role);
    // ── הצינור: איסוף⇒הרשאה⇒טווח⇒איתור⇒חריגה (רץ פעם-אחת; מזין טריאז' + טבלה + KPI + תדרוך) ──
    final all = d.forRole(d.tasks, _role);
    final ranged = d.inRange(all, _range);
    final visible = d.filter(d.search(ranged, _q), _locks);
    final open = visible.where((t) => !d.isDone(t)).toList();
    final red = open.where((t) => d.sev(t) == 2).length;
    final prog = d.progress();
    final kpis = d.kpisForRole(_role);
    final holiday = d.holidayToday;
    final jump = d.weeklyJump();
    final breached = open.where(d.slaBreached).length;
    // דלי-טריאז' (הכרעה): 🔴 ⇒ 🟠 ⇒ 🟢 ⇒ ✅ — מדורג בתוך-הדלי לפי ציון-דחיפות יורד
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: [], -1: []};
    for (final t in visible) {
      buckets[d.isDone(t) ? -1 : d.sev(t)]!.add(t);
    }
    for (final b in buckets.values) {
      b.sort((a, b) => d.score(b).compareTo(d.score(a)));
    }
    const secTitle = {2: '🔴 דורש-החלטה היום', 1: '🟠 בסיכון · השבוע', 0: '🟢 במעקב', -1: '✅ טופל'};
    const secTone = {2: 2, 1: 3, 0: 1, -1: 1};
    final firstAction = buckets[2]!.isNotEmpty ? buckets[2]!.first : buckets[1]!.isNotEmpty ? buckets[1]!.first : null;

    return DsScaffold(title: 'DashboardScreen', subtitle: 'DashboardScreen · מודול-משנה מחולל · 4 בונים מחווטים-לשקעי-הזהב', icon: '🧬', children: [
      _gap(8),
      _seg([for (final r in _DashData.roleDefs) r['label'] as String], _role, (i) => setState(() { _role = i; if (_DashData.summaryOnly(i)) _tab = 7; })),
      ..._trendsTab(),
      ..._goalsTab(),
      // בונים-פנימיים (מורכבים דרך הקורא שלהם, לא ברמת-המסך): _wrap, _title, _row, _table
      // מקום-שמור (חוק-7): בונים בלי שקע-פתיר במודול-המשנה — _briefTab, _kpiTab, _reportsTab
    ]);
  }
}
