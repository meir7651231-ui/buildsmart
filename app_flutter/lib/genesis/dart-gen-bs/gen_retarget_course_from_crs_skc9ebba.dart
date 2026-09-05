// 🎯 CourseScreen — retarget של schoolos_courses.dart לישות Course (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module schoolos_courses.dart --entity Course
//   זרע-ראשי: courses (מועמדים: courses(23/27) enrollments(10/18) rooms(9/12) families(8/8) teachers(6/6)) · מיפוי שם 23 · ערוץ 0 · טיפוס-יחיד 0 · מקום-שמור 3 · חוזה-מנוע (לא משתנה) 1
//   id⇒id(name) · name⇒name(name) · teacherId⇒teacherId(name) · roomId⇒roomId(name) · cat⇒cat(name) · semester⇒semester(name) · sector⇒sector(name) · start⇒start(name) · end⇒end(name) · sessions⇒sessions(name) · time⇒time(name) · maxStudents⇒maxStudents(name) · price⇒price(name) · gender⇒gender(name) · ageMin⇒ageMin(name) · ageMax⇒ageMax(name) · gradeMin⇒gradeMin(name) · gradeMax⇒gradeMax(name) · description⇒description(name) · notes⇒notes(name) · files⇒files(name) · perLesson⇒perLesson(name) · lessonPrice⇒lessonPrice(name) · day⇒∅(engine-contract) · label⇒∅(reserved(6 מועמדים)) · kind⇒∅(reserved(6 מועמדים)) · data⇒∅(reserved(6 מועמדים))
//   עור-forge (G12c/e): BareStat⇒ForgeStatPlain ×0 (ב-Wrap) · ×20 (ב-Row, Expanded) · פנימיים: button×32 statusChip×10 banner×15 emptyState×18 mediaRow×12 · StatHero⇒ForgeStatPlain ×1 · KpiTile⇒— · DsNavTile⇒— — fields לפי תפקידי-חריצים; צבעי-מצב-DS לא מועברים
//   תפר-עובדות (G9b): CourseFacts · count=courses.length (static-const) · מדדים 8 · hero=kpiNoTeacher · שורות-מדד (G10a) kpiActive/kpiFull/kpiNoTeacher · תפר-כניסה initialPanelId · תפר-סינון-מדד initialMetric · תפר-הזרקה ∅
//   שדות-Course בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): price1, price2, price1Name, price2Name, price3, price3Name, model, size, weekday, audience, img, lessonPrice1, lessonPrice2, lessonPrice3, year, prevYearId · תוויות: מונחי course (חוג/—) ⇒ Course (חוג/—) · 0 החלפות · הזרע = זרע-הצבה של המקור, לא ערך-אמת של Course
// 📚 SchoolOS · חוגים ומערכת-שעות (COURSES) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד).
// מפרט (SSOT · "מה"): knowledge/SPEC-COURSES-FULL-2026-09-04.md · הסטנדרט: מסך-המלאי (schoolos.dart).
// 🎯 המטרה: "שכל שיעור יקרה — עם מורה, בחדר, לתלמידים הנכונים, בזמן — ושאף שיבוץ לא יתנגש ואף מקום לא יתבזבז."
// פעולות-היסוד (צעד-2, לא אזורי-מפרט): איתור · הערכת-תפוסה · זיהוי-חריגה (התנגשות/ללא-מורה/ללא-חדר/מלא/מתחת-מינ׳)
//   · הכרעה (דחיפות-מאוחדת) · ביצוע (שיבוץ/העלאה/הקצאה/ביטול/סיום/שכפול) · אימות (היסטוריה/גבייה/ייצוא).
// מחלקה ציבורית יחידה: CourseScreen (const, ללא main) — המנהל מחבר ניווט-ביתי.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/bare_stat.dart'; // עובדה-אטומית (ערך+תווית, צבע מוזרק) — לא StatBlock המזייף
import '../dart-ui-bs/premium/surfaces/gradient_card.dart';
import '../dart-ui-bs/premium/surfaces/stat_hero.dart';
import '../dart-ui-bs/premium/lists/media_row.dart';
import '../dart-ui-bs/premium/feedback/status_chip.dart';
import '../dart-ui-bs/premium/feedback/empty_state.dart';
import '../dart-ui-bs/premium/actions/segmented_switch.dart';
import '../dart-ui-bs/premium/lists/stat_row.dart'; // יחס (תפוסה/ניצולת) = בר-מילוי, לא linear_progress המזייף
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows, מיון-בלחיצה) — לא DataGrid המזייף
import '../dart-ui-bs/ds/ds_search.dart'; // חיפוש-מבוקר (value+onChanged) — פעולת-יסוד "איתור"
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר (selected/onTap, צבעים מוזרקים)
import '../dart-ui-bs/ds/ds_field.dart'; // שדה-טקסט מבוקר (ערוך: שם-חוג)
import '../dart-ui-bs/ds/ds_number_field.dart'; // שדה-מספר מבוקר (ערוך: קיבולת)
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל-פאנל (child שרירותי) — פאנל-צד
import '../dart-ui-bs/premium/actions/soft_button.dart'; // פעולה (label/onTap/tone)
import '../dart-ui-bs/premium/feedback/alert_banner.dart'; // התראה/תוצאת-פעולה (message/tone/glyph)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // פריט-ציר-זמן (title/time/body) — לא timeline_flow המזייף
import '../dart-maor/enroll-count.dart'; // נרשמים-חיים לחוג (לא wait/ended) — מנוע-אמת ממאור
import '../dart-maor/waitlist-for.dart'; // רשימת-המתנה מסודרת לפי enrolledAt — מנוע-אמת ממאור
import '../dart-maor/sessions-of.dart'; // מפגשי-חוג (sessions או weekday/time) — מנוע-אמת ממאור
import '../dart-maor/schedule-clash-text.dart'; // התנגשות-תלמיד: אותו יום+שעה בחוג-אחר — מנוע-אמת ממאור
import '../dart-maor/time-to-min.dart'; // 'HH:MM' ⇒ דקות (NaN לפורמט-שגוי) — מנוע-אמת ממאור
import '../dart-maor/pay-bal.dart'; // חוב-פתוח פר-הרשמה (totalDue+carry−paid) — מנוע-אמת ממאור
import '../dart-maor/paid-of.dart'; // Σ תשלומים — מנוע-אמת ממאור
import '../dart-maor/intel-trend-from-scan.dart'; // מגמה מחצי-ישן מול חצי-חדש ⇒ up/down/flat — מנוע-אמת ממאור
import '../dart-maor/intel-day-diff.dart'; // הפרש-ימים ISO — מנוע-אמת ממאור
import '../dart-maor/inactive-room-courses.dart'; // חוגים שחדרם חסר/לא-פעיל — מנוע-אמת ממאור
import '../dart-maor/grand-total.dart'; // Σ-לפי-מפתח — מנוע-אמת ממאור
import '../dart-maor/shekel.dart'; // פורמט ₪ — מנוע-אמת ממאור
import '../dart-maor/week-day-names.dart'; // שמות-ימים (ראשון..שבת) — אטום-דאטה ממאור
import '../dart-maor/semester-options.dart'; // אפשרויות-סמסטר (שנתי/חצי שנתי) — אטום-דאטה ממאור
import '../dart-maor/min-to-hm.dart'; // דקות ⇒ 'HH:MM' (תוויות-שעה בגריד) — מנוע-אמת ממאור
import '../dart-maor/courses-of-teacher.dart'; // חוגי-מורה (מבט פר-מורה) — מנוע-אמת ממאור
import '../dart-maor/weekly-room-sessions.dart'; // מפגשים/שבוע פר-חדר (ניצולת) — מנוע-אמת ממאור
import '../dart-maor/clamp-scale.dart'; // הצמדה לגבולות (יחס-ניצולת) — מנוע-אמת ממאור
import '../dart-maor/course-fits-member.dart'; // דרישות-קדם: מגדר/גיל/שכבה — מנוע-אמת ממאור
import '../dart-maor/grade-fits.dart'; // שכבת-יעד gradeMin..gradeMax — מנוע-אמת ממאור
import '../dart-maor/grade-index.dart'; // אינדקס-שכבה בסדר-הכיתות — מנוע-אמת ממאור
import '../dart-maor/grade-order.dart'; // סדר-הכיתות (גן..יב) — אטום-דאטה ממאור
import '../dart-maor/age-of.dart'; // גיל מתאריך-לידה מול "עכשיו" מוזרק — מנוע-אמת ממאור
import '../dart-maor/enroll-summary.dart'; // סיכום-הרשמה: נוכחויות/חיסורים/noshow/יתרה — מנוע-אמת ממאור
import '../dart-maor/enrollment-paid-status.dart'; // paid/partial/unpaid — מנוע-אמת ממאור
import '../dart-maor/enroll-status-meta.dart'; // תווית-סטטוס-הרשמה (term מוזרק) — מנוע-אמת ממאור
import '../dart-maor/presents-in-month.dart'; // נוכחויות בחודש-הנוכחי — מנוע-אמת ממאור
import '../dart-maor/next-session-date.dart'; // השיעור-הבא (now מוזרק) — מנוע-אמת ממאור
import '../dart-maor/duplicate-course.dart'; // שכפל-חוג (id חדש + סיומת-עותק) — מנוע-אמת ממאור
import '../dart-maor/next-year-course-draft.dart'; // שכפול-סמסטר/שנה: טיוטה לשנה-הבאה — מנוע-אמת ממאור
import '../dart-maor/next-year-dates.dart'; // הזזת-תאריכים בשנה — מנוע-אמת ממאור
import '../dart-maor/academic-year-label.dart'; // תווית שנת-לימודים (2027/28) — מנוע-אמת ממאור
import '../dart-maor/default-course-dates.dart'; // תאריכי-ברירת-מחדל לחוג-חדש (1.9–31.7) — מנוע-אמת ממאור
import '../dart-maor/wa-link.dart'; // קישור WhatsApp (שלח-הודעה-לחוג) — מנוע-אמת ממאור
import '../dart-maor/wa-digits.dart'; // נרמול-ספרות-טלפון — מנוע-אמת ממאור
import '../dart-maor/room-info-label.dart'; // תווית-חדר (משבצת/קיבולת/נגישות/ציוד) — מנוע-אמת ממאור
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון — מנוע-אמת ממאור
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND — מנוע-אמת ממאור
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (סופיות/ניקוד) — מנוע-אמת ממאור
import '../dart-maor/finder-matches.dart'; // חריגה/סינון: סינון-רב-צירי AND על נעילות — מנוע-אמת ממאור
import '../dart-maor/count-by.dart'; // קיבוץ-ומניה (צ׳יפי-תחום עם מונה) — מנוע-אמת ממאור
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל admin/teacher/staff — מנוע-אמת ממאור
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה פר-מפתח — מנוע-אמת ממאור
import '../dart-maor/teacher-id-of.dart'; // הרשאות: מזהה-המורה של המשתמש (החוגים-שלו) — מנוע-אמת ממאור
import '../dart-maor/heb-parts.dart'; // לוח-עברי: תאריך ⇒ {day, month(EN), year} — מנוע-אמת ממאור
import '../dart-maor/holidays.dart'; // מפת-חגים 'Tishri 1' ⇒ שם — אטום-דאטה ממאור
import '../dart-maor/upcoming-holidays.dart'; // חגים קרובים בחלון-ימים (holidayOf מוזרק) — מנוע-אמת ממאור
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM — מנוע-אמת ממאור
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא (חוסם CSV-injection) — מנוע-אמת ממאור
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע — מנוע-אמת ממאור
import '../dart-maor/ics-escape.dart'; // ייצוא iCal: הגנת-טקסט-ICS — מנוע-אמת ממאור
import '../dart-forge-bs/selection/selection.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/status/status.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/feedback/feedback.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/list/list.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/spatial/spatial.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (חוק-6: צבע=הצבה, לא ציור)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════ דאטה-אמת + מנוע-טהור (אפס-DOM) · חוזה-הדאטה של החוגים ═══════════
// 🔴 סכמת-הישויות = **רק** שדות עם מקור-אמת במאור (new/dart-maor/schema-fields.dart · צילום domain.ts):
//   Course: id·name·teacherId·roomId·description·price·start·end·sessions[{day,time,label}]·maxStudents·gender·
//           ageMin·ageMax·cat·semester·sector·gradeMin·gradeMax·notes·files[{id,name,kind,data}]·perLesson·lessonPrice·year·prevYearId
//   Enrollment: id·memberId·courseId·group·absences[{date,reason,noshow}]·presents[]·payments[{rid,date,amount,method}]·
//           totalDue·dueDate·status(active|paused|ended|wait)·note·enrolledAt·endedAt·paidFull·renew
//   Room: id·name·active·slot·cap·location·rate·from·to·access·eq · Teacher: id·name·phone·email·specialty·payRate
//   Member: id·first·gender·birth·grade · Family: id·name·members[] · OrgEvent: id·title·date·time·roomId·done
//   ⛔ ללא-מקור-אמת ⇒ **מקום-שמור** (שקע בחוזה, מאיר כשיגיע נתון), לא זיוף: code · minStudents · equipment ·
//      prerequisites · substituteTeacherId · online · certificate · cancelPolicy · syllabus · recordings · grades.
class _CourseData {
  static const today = '2026-09-04'; // תאריך-הזרקה דטרמיניסטי (VERIFY: אין DateTime.now במנוע)

  static const teachers = <Map<String, dynamic>>[
    {'id': 't1', 'name': 'רות כהן', 'phone': '050-0000001', 'email': 'rut@school', 'specialty': 'מוזיקה', 'payRate': 180},
    {'id': 't2', 'name': 'יוסי לוי', 'phone': '050-0000002', 'email': 'yosi@school', 'specialty': 'מדעים', 'payRate': 200},
    {'id': 't3', 'name': 'מיכל ברק', 'phone': '050-0000003', 'email': 'michal@school', 'specialty': 'אומנות', 'payRate': 160},
    {'id': 't4', 'name': 'דני אשכנזי', 'phone': '050-0000004', 'email': 'dani@school', 'specialty': 'ספורט', 'payRate': 150},
  ];
  static const rooms = <Map<String, dynamic>>[
    {'id': 'r1', 'name': 'אולם מוזיקה', 'active': true, 'slot': 60, 'cap': 20, 'location': 'קומה 1', 'rate': 40, 'from': '14:00', 'to': '20:00', 'access': true, 'eq': {'piano': true, 'projector': false}},
    {'id': 'r2', 'name': 'מעבדת מדעים', 'active': true, 'slot': 90, 'cap': 16, 'location': 'קומה 2', 'rate': 60, 'from': '14:00', 'to': '19:00', 'access': false, 'eq': {'lab': true, 'projector': true}},
    {'id': 'r3', 'name': 'חדר אומנות', 'active': true, 'slot': 60, 'cap': 18, 'location': 'קומה 1', 'rate': 30, 'from': '14:00', 'to': '20:00', 'access': true, 'eq': {'sink': true}},
    {'id': 'r4', 'name': 'מגרש חוץ', 'active': false, 'slot': 60, 'cap': 30, 'location': 'חצר', 'rate': 0, 'from': '14:00', 'to': '18:00', 'access': true, 'eq': <String, bool>{}}, // חדר לא-פעיל (מצב "ללא-חדר")
  ];
  // חוגים — sessions בצורת CourseSession {day(0=ראשון..6),time,label}. תאריכים ISO. semester = semesterOptions ממאור.
  static const courses = <Map<String, dynamic>>[
    {'id': 'c1', 'name': 'גיטרה מתחילים', 'teacherId': 't1', 'roomId': 'r1', 'cat': 'מוזיקה', 'semester': 'שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-06-30',
      'sessions': [{'day': 0, 'time': '16:00', 'label': ''}], 'maxStudents': 12, 'price': 220, 'gender': 'all', 'ageMin': 9, 'ageMax': 12, 'gradeMin': 'ד', 'gradeMax': 'ו',
      'description': 'יסודות הגיטרה הקלאסית', 'notes': '', 'files': [{'id': 'f1', 'name': 'ספר-אקורדים.pdf', 'kind': 'file', 'data': ''}]},
    {'id': 'c2', 'name': 'רובוטיקה', 'teacherId': 't2', 'roomId': 'r2', 'cat': 'מדעים', 'semester': 'שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-06-30',
      'sessions': [{'day': 1, 'time': '16:00', 'label': ''}, {'day': 3, 'time': '16:00', 'label': ''}], 'maxStudents': 10, 'price': 320, 'gender': 'all', 'ageMin': 10, 'ageMax': 14, 'gradeMin': 'ה', 'gradeMax': 'ח',
      'description': 'בניית רובוטים ותכנות', 'notes': 'דורש מחשב נייד', 'files': <Map<String, dynamic>>[]},
    {'id': 'c3', 'name': 'ציור וקרמיקה', 'teacherId': 't3', 'roomId': 'r3', 'cat': 'אומנות', 'semester': 'חצי שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-01-31',
      'sessions': [{'day': 2, 'time': '15:00', 'label': ''}], 'maxStudents': 8, 'price': 180, 'gender': 'all', 'ageMin': 7, 'ageMax': 11, 'gradeMin': 'ב', 'gradeMax': 'ה',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[]},
    {'id': 'c4', 'name': 'כדורסל', 'teacherId': 't4', 'roomId': 'r4', 'cat': 'ספורט', 'semester': 'שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-06-30',
      'sessions': [{'day': 1, 'time': '16:00', 'label': ''}], 'maxStudents': 15, 'price': 150, 'gender': 'all', 'ageMin': 9, 'ageMax': 13, 'gradeMin': 'ד', 'gradeMax': 'ז',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[], 'perLesson': true, 'lessonPrice': 40},
    {'id': 'c5', 'name': 'מקהלה', 'teacherId': 't1', 'roomId': 'r1', 'cat': 'מוזיקה', 'semester': 'שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-06-30',
      'sessions': [{'day': 0, 'time': '16:00', 'label': ''}], 'maxStudents': 25, 'price': 120, 'gender': 'all', 'ageMin': 8, 'ageMax': 14, 'gradeMin': 'ג', 'gradeMax': 'ח',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[]}, // ⚠️ מתנגש עם c1: אותה מורה + אותו חדר + אותו slot
    {'id': 'c6', 'name': 'שחמט', 'teacherId': '', 'roomId': 'r3', 'cat': 'חשיבה', 'semester': 'חצי שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-01-31',
      'sessions': [{'day': 4, 'time': '15:00', 'label': ''}], 'maxStudents': 12, 'price': 140, 'gender': 'all', 'ageMin': 7, 'ageMax': 13, 'gradeMin': 'ב', 'gradeMax': 'ז',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[], 'perLesson': true, 'lessonPrice': 35}, // ללא-מורה · מתחת-מינ׳-כלכלי
    {'id': 'c7', 'name': 'תיאטרון', 'teacherId': 't3', 'roomId': 'r3', 'cat': 'אומנות', 'semester': 'שנתי', 'sector': 'כללי', 'start': '2026-09-01', 'end': '2027-06-30',
      'sessions': [{'day': 2, 'time': '17:00', 'label': ''}], 'maxStudents': 14, 'price': 190, 'gender': 'all', 'ageMin': 10, 'ageMax': 14, 'gradeMin': 'ה', 'gradeMax': 'ח',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[]},
    {'id': 'c8', 'name': 'אנגלית מדוברת (קיץ)', 'teacherId': 't2', 'roomId': 'r2', 'cat': 'שפות', 'semester': 'חצי שנתי', 'sector': 'כללי', 'start': '2026-07-01', 'end': '2026-08-20',
      'sessions': [{'day': 3, 'time': '10:00', 'label': ''}], 'maxStudents': 12, 'price': 200, 'gender': 'all', 'ageMin': 9, 'ageMax': 13, 'gradeMin': 'ד', 'gradeMax': 'ז',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[]}, // הסתיים (end < today)
  ];
  // משפחות+חברים בצורת-האמת (Family.members[Member]) — שם-תצוגה = first + שם-משפחה
  static const families = <Map<String, dynamic>>[
    {'id': 'f1', 'name': 'ישראלי', 'phone': '052-0000011', 'members': [{'id': 'm1', 'first': 'נועה', 'gender': 'f', 'birth': '2016-03-02', 'grade': 'ה'}, {'id': 'm2', 'first': 'איתי', 'gender': 'm', 'birth': '2014-07-15', 'grade': 'ז'}]},
    {'id': 'f2', 'name': 'מזרחי', 'phone': '052-0000012', 'members': [{'id': 'm3', 'first': 'תמר', 'gender': 'f', 'birth': '2015-11-20', 'grade': 'ו'}]},
    {'id': 'f3', 'name': 'פרץ', 'phone': '052-0000013', 'members': [{'id': 'm4', 'first': 'יונתן', 'gender': 'm', 'birth': '2017-01-09', 'grade': 'ד'}, {'id': 'm5', 'first': 'שירה', 'gender': 'f', 'birth': '2013-05-30', 'grade': 'ח'}]},
    {'id': 'f4', 'name': 'אברהם', 'phone': '052-0000014', 'members': [{'id': 'm6', 'first': 'עומר', 'gender': 'm', 'birth': '2016-09-12', 'grade': 'ה'}]},
    {'id': 'f5', 'name': 'דהן', 'phone': '052-0000015', 'members': [{'id': 'm7', 'first': 'ליה', 'gender': 'f', 'birth': '2018-02-14', 'grade': 'ג'}, {'id': 'm8', 'first': 'רועי', 'gender': 'm', 'birth': '2015-06-06', 'grade': 'ו'}]},
    {'id': 'f6', 'name': 'חדד', 'phone': '052-0000016', 'members': [{'id': 'm9', 'first': 'מאיה', 'gender': 'f', 'birth': '2014-12-01', 'grade': 'ז'}]},
    {'id': 'f7', 'name': 'ביטון', 'phone': '052-0000017', 'members': [{'id': 'm10', 'first': 'אורי', 'gender': 'm', 'birth': '2016-04-22', 'grade': 'ה'}]},
    {'id': 'f8', 'name': 'סעדון', 'phone': '052-0000018', 'members': [{'id': 'm11', 'first': 'הילה', 'gender': 'f', 'birth': '2017-08-08', 'grade': 'ד'}]},
  ];
  // הרשמות בצורת-Enrollment. status: active|paused|ended|wait · payments[{rid,date,amount,method}] · presents/absences
  static const enrollments = <Map<String, dynamic>>[
    {'id': 'e1', 'memberId': 'm1', 'courseId': 'c1', 'status': 'active', 'enrolledAt': '2026-08-20', 'group': '', 'totalDue': 2200, 'dueDate': '2026-09-10', 'note': '', 'payments': [{'rid': 'p1', 'date': '2026-08-20', 'amount': 1100, 'method': 'אשראי'}], 'presents': ['2026-09-06'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e2', 'memberId': 'm3', 'courseId': 'c1', 'status': 'active', 'enrolledAt': '2026-08-22', 'group': '', 'totalDue': 2200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p2', 'date': '2026-08-22', 'amount': 2200, 'method': 'העברה'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e3', 'memberId': 'm4', 'courseId': 'c1', 'status': 'active', 'enrolledAt': '2026-08-25', 'group': '', 'totalDue': 2200, 'dueDate': '2026-09-15', 'note': '', 'payments': <Map<String, dynamic>>[], 'presents': <String>[], 'absences': [{'date': '2026-09-06', 'reason': 'מחלה', 'noshow': false}]},
    {'id': 'e4', 'memberId': 'm6', 'courseId': 'c1', 'status': 'paused', 'enrolledAt': '2026-08-25', 'group': '', 'totalDue': 2200, 'dueDate': '', 'note': 'חופשה', 'payments': [{'rid': 'p3', 'date': '2026-08-25', 'amount': 500, 'method': 'מזומן'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e5', 'memberId': 'm2', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-18', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p4', 'date': '2026-08-18', 'amount': 3200, 'method': 'אשראי'}], 'presents': ['2026-09-01', '2026-09-03'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e6', 'memberId': 'm5', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-19', 'group': '', 'totalDue': 3200, 'dueDate': '2026-09-20', 'note': '', 'payments': [{'rid': 'p5', 'date': '2026-08-19', 'amount': 1600, 'method': 'אשראי'}], 'presents': ['2026-09-01'], 'absences': [{'date': '2026-09-03', 'reason': '', 'noshow': true}]},
    {'id': 'e7', 'memberId': 'm8', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-26', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p6', 'date': '2026-08-26', 'amount': 3200, 'method': 'העברה'}], 'presents': ['2026-09-01', '2026-09-03'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e8', 'memberId': 'm9', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-27', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p7', 'date': '2026-08-27', 'amount': 3200, 'method': 'אשראי'}], 'presents': ['2026-09-01', '2026-09-03'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e9', 'memberId': 'm10', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-28', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p8', 'date': '2026-08-28', 'amount': 3200, 'method': 'אשראי'}], 'presents': ['2026-09-01'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e10', 'memberId': 'm1', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-29', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p9', 'date': '2026-08-29', 'amount': 3200, 'method': 'אשראי'}], 'presents': ['2026-09-01', '2026-09-03'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e11', 'memberId': 'm3', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-30', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p10', 'date': '2026-08-30', 'amount': 3200, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e12', 'memberId': 'm4', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-08-31', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p11', 'date': '2026-08-31', 'amount': 3200, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e13', 'memberId': 'm6', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-09-01', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p12', 'date': '2026-09-01', 'amount': 3200, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e14', 'memberId': 'm7', 'courseId': 'c2', 'status': 'active', 'enrolledAt': '2026-09-02', 'group': '', 'totalDue': 3200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p13', 'date': '2026-09-02', 'amount': 3200, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e15', 'memberId': 'm11', 'courseId': 'c2', 'status': 'wait', 'enrolledAt': '2026-09-02', 'group': '', 'totalDue': 0, 'dueDate': '', 'note': '', 'payments': <Map<String, dynamic>>[], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]}, // המתנה #1 (חוג מלא 10/10)
    {'id': 'e16', 'memberId': 'm5', 'courseId': 'c7', 'status': 'wait', 'enrolledAt': '2026-09-03', 'group': '', 'totalDue': 0, 'dueDate': '', 'note': '', 'payments': <Map<String, dynamic>>[], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e17', 'memberId': 'm7', 'courseId': 'c3', 'status': 'active', 'enrolledAt': '2026-08-21', 'group': '', 'totalDue': 900, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p14', 'date': '2026-08-21', 'amount': 900, 'method': 'מזומן'}], 'presents': ['2026-09-01'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e18', 'memberId': 'm11', 'courseId': 'c3', 'status': 'active', 'enrolledAt': '2026-08-23', 'group': '', 'totalDue': 900, 'dueDate': '2026-09-08', 'note': '', 'payments': <Map<String, dynamic>>[], 'presents': ['2026-09-01'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e19', 'memberId': 'm2', 'courseId': 'c4', 'status': 'active', 'enrolledAt': '2026-08-24', 'group': '', 'totalDue': 1500, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p15', 'date': '2026-08-24', 'amount': 1500, 'method': 'אשראי'}], 'presents': ['2026-09-01'], 'absences': <Map<String, dynamic>>[]}, // ⚠️ m2 גם ב-c2 שני 16:00 ⇒ התנגשות-תלמיד
    {'id': 'e20', 'memberId': 'm8', 'courseId': 'c4', 'status': 'active', 'enrolledAt': '2026-08-26', 'group': '', 'totalDue': 1500, 'dueDate': '2026-09-30', 'note': '', 'payments': [{'rid': 'p16', 'date': '2026-08-26', 'amount': 700, 'method': 'מזומן'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e21', 'memberId': 'm10', 'courseId': 'c4', 'status': 'active', 'enrolledAt': '2026-09-03', 'group': '', 'totalDue': 1500, 'dueDate': '', 'note': '', 'payments': <Map<String, dynamic>>[], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e22', 'memberId': 'm9', 'courseId': 'c5', 'status': 'active', 'enrolledAt': '2026-08-20', 'group': '', 'totalDue': 1200, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p17', 'date': '2026-08-20', 'amount': 1200, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e23', 'memberId': 'm4', 'courseId': 'c6', 'status': 'active', 'enrolledAt': '2026-08-28', 'group': '', 'totalDue': 1400, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p18', 'date': '2026-08-28', 'amount': 1400, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e24', 'memberId': 'm6', 'courseId': 'c7', 'status': 'active', 'enrolledAt': '2026-07-10', 'group': '', 'totalDue': 1900, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p19', 'date': '2026-07-10', 'amount': 1900, 'method': 'אשראי'}], 'presents': ['2026-09-02'], 'absences': <Map<String, dynamic>>[]},
    {'id': 'e25', 'memberId': 'm1', 'courseId': 'c8', 'status': 'ended', 'enrolledAt': '2026-06-20', 'endedAt': '2026-08-20', 'group': '', 'totalDue': 2000, 'dueDate': '', 'note': '', 'payments': [{'rid': 'p20', 'date': '2026-06-20', 'amount': 2000, 'method': 'אשראי'}], 'presents': <String>[], 'absences': <Map<String, dynamic>>[]},
  ];
  static const events = <Map<String, dynamic>>[]; // OrgEvent (חדר תפוס לאירוע) — מקום-שמור, ריק בדמו

  // ─── פנקס-פעולות (מצב=חיווט · חוק-1): הבסיס const = מקור-האמת; הפעולות רושמות שינוי + רשומת-היסטוריה ───
  static final List<Map<String, dynamic>> extraEnrollments = []; // הרשמות מפעולות (שבץ/העלה/העבר)
  static final Map<String, String> statusOverride = {}; // enrollmentId ⇒ status חדש (הסר/העלה/סיים)
  static final Map<String, Map<String, dynamic>> courseOverride = {}; // courseId ⇒ {teacherId?, roomId?, ended?}
  static final List<Map<String, dynamic>> extraCourses = []; // חוגים משכפול (duplicateCourse/nextYearCourseDraft)
  static final Set<String> cancelledSessions = {}; // 'courseId|iso' — ביטול-שיעור-יחיד (חג/חד-פעמי)
  static final Map<String, String> substitutes = {}; // 'courseId|iso' ⇒ teacherId (החלף-מורה חד-פעמי)
  static final List<Map<String, dynamic>> history = []; // אודיט: {at, who, act, what, courseId} (בצורת AuditEntry + מפתח-חוג)
  static void log(String who, String act, String what, [String courseId = '']) =>
      history.insert(0, {'at': today, 'who': who, 'act': act, 'what': what, 'courseId': courseId});
  static int _seq = 0;
  static String nextId(String prefix) => '$prefix${++_seq}';
  static bool autoPromote = true; // אוטומציה: העלאה-אוטומטית מהמתנה כשמתפנה-מקום (ניתן-לכיבוי)

  static List<Map<String, dynamic>> get allCourses => [
        for (final c in [...courses, ...extraCourses]) {...c, ...?courseOverride[c['id']]},
      ];
  static List<Map<String, dynamic>> get allEnrollments => [
        for (final e in [...enrollments, ...extraEnrollments]) {...e, if (statusOverride[e['id']] != null) 'status': statusOverride[e['id']]},
      ];
  // db בצורת-הקלט של מנועי-מאור (Db: courses·enrollments·rooms·teachers·families·events)
  static Map<String, dynamic> get db => {
        'courses': allCourses, 'enrollments': allEnrollments, 'rooms': rooms, 'teachers': teachers, 'families': families, 'events': events,
      };

  // ─── ישויות-קשורות (חיפוש-לפי-מזהה) ───
  static Map<String, dynamic>? teacherOf(Map<String, dynamic> c) {
    for (final t in teachers) {
      if (t['id'] == c['teacherId']) return t;
    }
    return null;
  }
  static Map<String, dynamic>? roomOf(Map<String, dynamic> c) {
    for (final r in rooms) {
      if (r['id'] == c['roomId']) return r;
    }
    return null;
  }
  static Map<String, dynamic>? memberOf(dynamic id) {
    for (final f in families) {
      for (final m in (f['members'] as List)) {
        if (m['id'] == id) return {...(m as Map).cast<String, dynamic>(), 'famName': f['name'], 'famPhone': f['phone']};
      }
    }
    return null;
  }
  static String memberName(dynamic id) {
    final m = memberOf(id);
    return m == null ? '$id' : '${m['first']} ${m['famName']}';
  }

  // ─── מחזור-חיים (נגזרת מתאריכי-אמת · אין שדה-status על Course במאור) ───
  //   מתוכנן (start>today) · פעיל · הסתיים (end<today או סיום-מרוכז) · בוטל (override)
  static String lifecycle(Map<String, dynamic> c) {
    if (c['cancelled'] == true) return 'בוטל';
    if (c['ended'] == true) return 'הסתיים';
    final end = '${c['end'] ?? ''}', start = '${c['start'] ?? ''}';
    if (end.isNotEmpty && end.compareTo(today) < 0) return 'הסתיים';
    if (start.isNotEmpty && start.compareTo(today) > 0) return 'מתוכנן';
    return 'פעיל';
  }
  static bool isLive(Map<String, dynamic> c) => lifecycle(c) == 'פעיל' || lifecycle(c) == 'מתוכנן';
  static List<Map<String, dynamic>> get liveCourses => allCourses.where(isLive).toList();

  // ─── הערכת-תפוסה (פעולת-יסוד · מנועי-מדף) ───
  static int enrolled(Map<String, dynamic> c) => enrollCount(db, c['id']); // מנוע-אמת: לא wait/ended
  static int capacity(Map<String, dynamic> c) => (c['maxStudents'] as int?) ?? 0;
  static List<Map<String, dynamic>> waitlist(Map<String, dynamic> c) => (waitlistFor(allEnrollments, c['id']) as List).cast<Map<String, dynamic>>();
  static bool isFull(Map<String, dynamic> c) => capacity(c) > 0 && enrolled(c) >= capacity(c);
  static double occupancy(Map<String, dynamic> c) => capacity(c) == 0 ? 0 : enrolled(c) / capacity(c);
  static List<Map<String, dynamic>> enrollmentsOf(Map<String, dynamic> c) => allEnrollments.where((e) => e['courseId'] == c['id']).toList();
  static List<Map<String, dynamic>> liveEnrollmentsOf(Map<String, dynamic> c) =>
      enrollmentsOf(c).where((e) => e['status'] != 'wait' && e['status'] != 'ended').toList();

  // ─── מינימום-לפתיחה (23-ד · חיבור-מודלים): minStudents (מקום-שמור, אין במאור) ∨ נקודת-איזון-כלכלית ───
  //   נקודת-איזון = ⌈(שכר-מורה-לשיעור + עלות-חדר-לשיעור) ÷ מחיר-לשיעור⌉ — רק כשכל שלושת המקורות באותה יחידה
  //   (perLesson+lessonPrice של Course · payRate של Teacher · rate של Room — כולם שדות-אמת). אחרת ⇒ null (שקט, לא זיוף).
  static int? breakEven(Map<String, dynamic> c) {
    if (c['perLesson'] != true) return null;
    final lp = (c['lessonPrice'] as num?) ?? 0;
    if (lp <= 0) return null;
    final pay = (teacherOf(c)?['payRate'] as num?) ?? 0;
    final room = (roomOf(c)?['rate'] as num?) ?? 0;
    return ((pay + room) / lp).ceil();
  }
  static int? minToOpen(Map<String, dynamic> c) => (c['minStudents'] as int?) ?? breakEven(c);
  static bool belowMin(Map<String, dynamic> c) {
    final m = minToOpen(c);
    return m != null && enrolled(c) < m;
  }

  // ─── זיהוי-חריגה · התנגשויות (מורה/חדר = הרכבת sessionsOf⊕timeToMin · תלמיד = scheduleClashText ממאור) ───
  static bool _sameSlot(Map<String, dynamic> a, Map<String, dynamic> b) {
    for (final s1 in (sessionsOf(a) as List)) {
      for (final s2 in (sessionsOf(b) as List)) {
        final t1 = timeToMin(s1['time']), t2 = timeToMin(s2['time']);
        if (s1['day'] == s2['day'] && t1 is num && t2 is num && !t1.isNaN && t1 == t2) return true;
      }
    }
    return false;
  }
  // התנגשויות של חוג: [{kind: 'teacher'|'room'|'student', with: שם-החוג-האחר, who?: תלמיד, detail}]
  static List<Map<String, String>> clashesOf(Map<String, dynamic> c) {
    final out = <Map<String, String>>[];
    if (!isLive(c)) return out;
    for (final o in liveCourses) {
      if (o['id'] == c['id'] || !_sameSlot(c, o)) continue;
      if ('${c['teacherId']}'.isNotEmpty && c['teacherId'] == o['teacherId']) out.add({'kind': 'teacher', 'with': '${o['name']}', 'detail': 'מורה ${teacherOf(c)?['name'] ?? ''}'});
      if ('${c['roomId']}'.isNotEmpty && c['roomId'] == o['roomId']) out.add({'kind': 'room', 'with': '${o['name']}', 'detail': 'חדר ${roomOf(c)?['name'] ?? ''}'});
    }
    // תלמיד: מנוע-מאור scheduleClashText לכל נרשם-חי (T: k1=סטטוס-שמוחרג · k2/k3=תבנית-הטקסט)
    for (final e in liveEnrollmentsOf(c)) {
      final txt = scheduleClashText(db, e['memberId'], c, sessionsOf, dayNames, const {'k1': 'ended', 'k2': 'מתנגש עם ', 'k3': ' · '});
      if (txt != null) {
        // הטקסט מהמנוע: k2 + שם-החוג-האחר + k3 + יום שעה ⇒ החוג-האחר = בין k2 ל-k3
        final other = '$txt'.substring('מתנגש עם '.length).split(' · ').first;
        out.add({'kind': 'student', 'with': other, 'who': memberName(e['memberId']), 'detail': '${memberName(e['memberId'])} $txt'});
      }
    }
    return out;
  }
  static bool hasClash(Map<String, dynamic> c) => clashesOf(c).isNotEmpty;
  static bool noTeacher(Map<String, dynamic> c) => teacherOf(c) == null;
  // ללא-חדר = מנוע-מאור inactiveRoomCourses (חדר חסר או לא-פעיל), פר-חוג
  static List<Map<String, dynamic>> get roomlessRows =>
      inactiveRoomCourses(db, today, null, (cfg, k, fb) => fb, const {'k2': 'חדר', 'k3': ' לא-קיים'});
  static bool noRoom(Map<String, dynamic> c) => roomlessRows.any((r) => (r['course'] as Map)['id'] == c['id']);
  static String? roomlessReason(Map<String, dynamic> c) {
    for (final r in roomlessRows) {
      if ((r['course'] as Map)['id'] == c['id']) return '${r['roomName']}';
    }
    return null;
  }

  // ─── הכרעה · דחיפות-מאוחדת (23-ד): התנגשות(3) > ללא-מורה/ללא-חדר(2) > מתחת-מינ׳(1) > מלא⇒המתנה(0.5) > תקין(0) ───
  static int sev(Map<String, dynamic> c) {
    if (!isLive(c)) return -1;
    if (hasClash(c)) return 3;
    if (noTeacher(c) || noRoom(c)) return 2;
    if (belowMin(c)) return 1;
    return 0;
  }

  // ─── גבייה-פר-חוג (מנועי-מאור payBal⊕paidOf) ───
  static num _paid(Map e) => paidOf(e);
  static num debtOf(Map<String, dynamic> e) => payBal(e, _paid);
  static num courseDebt(Map<String, dynamic> c) => grandTotal(liveEnrollmentsOf(c), (e) => debtOf(e as Map<String, dynamic>));
  static num courseCollected(Map<String, dynamic> c) => grandTotal(enrollmentsOf(c), (e) => paidOf(e as Map));

  // ─── מגמת-הרשמה (מנוע-מאור trendFromScan על [30-60 ימים אחורה, 30 ימים אחרונים]) ───
  static Map<String, dynamic> trend(Map<String, dynamic> c) {
    var older = 0, newer = 0;
    for (final e in enrollmentsOf(c)) {
      final d = dayDiff('${e['enrolledAt']}', today);
      if (d >= 0 && d < 30) newer++;
      if (d >= 30 && d < 60) older++;
    }
    return trendFromScan({'monthly': [older, newer]});
  }
  static String trendLabel(Map<String, dynamic> c) {
    final t = trend(c);
    return t['dir'] == 'up' ? '↑ ${t['pct']}%' : t['dir'] == 'down' ? '↓ ${(t['pct'] as int).abs()}%' : '→ יציב';
  }

  // ─── שיעורים-השבוע: Σ מפגשי-חוגים-חיים בשבוע-הנוכחי, פחות ביטולים-יחידים ───
  static String _iso(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String weekStart() {
    final d = DateTime.parse('${today}T12:00:00');
    return _iso(DateTime(d.year, d.month, d.day - (d.weekday % 7)));
  }
  static String isoOfDayThisWeek(int day) {
    final ws = DateTime.parse('${weekStart()}T12:00:00');
    return _iso(DateTime(ws.year, ws.month, ws.day + day));
  }
  static int lessonsThisWeek() {
    var n = 0;
    for (final c in liveCourses) {
      if (!hasSessions(c)) continue;
      for (final s in (sessionsOf(c) as List)) {
        if (s['day'] is int && !cancelledSessions.contains('${c['id']}|${isoOfDayThisWeek(s['day'] as int)}')) n++;
      }
    }
    return n;
  }

  // ─── גריד-שבועי: שעות = טווח מפגשי-החוגים-החיים (timeToMin), צעד 60; תוויות = minToHM ───
  static String _pad2(int n) => n.toString().padLeft(2, '0');
  static String hm(int min) => minToHM(min, _pad2);
  static List<int> gridHours(List<Map<String, dynamic>> cs) {
    int lo = 24 * 60, hi = 0;
    for (final c in cs) {
      for (final s in (sessionsOf(c) as List)) {
        final t = timeToMin(s['time']);
        if (t is num && !t.isNaN) {
          if (t < lo) lo = t.toInt();
          if (t >= hi) hi = t.toInt() + 60;
        }
      }
    }
    if (lo >= hi) return const [];
    lo -= lo % 60;
    return [for (var h = lo; h < hi; h += 60) h];
  }
  // חוגים בתא (יום×שעה): מפגש שנופל בתוך [h, h+60)
  static List<Map<String, dynamic>> inCell(List<Map<String, dynamic>> cs, int day, int h) => [
        for (final c in cs)
          if ((sessionsOf(c) as List).any((s) {
            final t = timeToMin(s['time']);
            return s['day'] == day && t is num && !t.isNaN && t >= h && t < h + 60;
          }))
            c,
      ];
  static bool isCancelled(Map<String, dynamic> c, String iso) => cancelledSessions.contains('${c['id']}|$iso');
  static String isoOfDay(int day, int weekOffset) {
    final ws = DateTime.parse('${weekStart()}T12:00:00');
    return _iso(DateTime(ws.year, ws.month, ws.day + day + 7 * weekOffset));
  }

  // ─── ניצולת-חדר (מטרת-הנהלה): מפגשים/שבוע (מנוע weeklyRoomSessions) מול קיבולת-משבצות = 6 ימים × (to−from)/slot ───
  static List<dynamic> _sessList(dynamic c) => sessionsOf(c) as List;
  static int roomWeekly(Map<String, dynamic> r) => weeklyRoomSessions(db, r['id'], today, _sessList).toInt();
  static int roomSlotsPerWeek(Map<String, dynamic> r) {
    final from = timeToMin(r['from']), to = timeToMin(r['to']);
    final slot = (r['slot'] as num?) ?? 60;
    if (from is! num || to is! num || from.isNaN || to.isNaN || slot <= 0 || to <= from) return 0;
    return ((to - from) / slot).floor() * 6;
  }
  static double roomUtil(Map<String, dynamic> r) {
    final cap = roomSlotsPerWeek(r);
    return cap == 0 ? 0 : clampScale(roomWeekly(r) / cap, 0.0, 1.0).toDouble();
  }
  static List<Map<String, dynamic>> coursesOf(Map<String, dynamic> t) => (coursesOfTeacher(liveCourses, t['id']) as List).cast<Map<String, dynamic>>();
  static int weeklyOf(List<Map<String, dynamic>> cs) => grandTotal(cs, (c) => hasSessions(c as Map<String, dynamic>) ? (sessionsOf(c) as List).length : 0).toInt();

  // ─── סינון-סמסטר (פס-עליון): 0=הכל · i>0 ⇒ semesterOptions[i-1] (אטום-דאטה ממאור) ───
  static List<Map<String, dynamic>> bySemester(List<Map<String, dynamic>> cs, int sem) =>
      sem == 0 ? cs : cs.where((c) => c['semester'] == semesterOptions[sem - 1]).toList();

  static String sessionsLabel(Map<String, dynamic> c) =>
      hasSessions(c) ? (sessionsOf(c) as List).where((s) => s['day'] is int).map((s) => '${dayNames[s['day'] as int]} ${s['time']}').join(' · ') : 'ללא-מפגשים';
  static String statusLabel(Map<String, dynamic> c) {
    final lc = lifecycle(c);
    if (lc != 'פעיל') return lc == 'מתוכנן' ? '🗓 מתוכנן' : lc == 'בוטל' ? '⛔ בוטל' : '🏁 הסתיים';
    final sv = sev(c);
    return sv == 3 ? '⚠️ התנגשות' : noTeacher(c) ? '🚫 ללא-מורה' : noRoom(c) ? '🚪 ללא-חדר' : sv == 1 ? '📉 מתחת-מינ׳' : semesterUndefined(c) ? '📆 סמסטר לא-מוגדר' : isFull(c) ? '🈵 מלא' : '🟢 פעיל';
  }

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 18 עמודות-הליבה של המפרט + סטטוס ═══
  //   נגזרת(get)=תמיד-מוצגת · שדה(key בלי get)=מוארת רק כשחוג נושא ערך, חסר ⇒ שקט (אפס-זיוף).
  //   'code' אין במאור ⇒ מקום-שמור: הוספת {'code': …} לחוג ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    // ═══ חוזה-העמודות של Course (G5h · חוק-7): 16 שדות-סכמה בלי מקור בזרע — עמודות-מקום-שמור, לא מזויפות ולא מושמטות ═══
    {'key': 'price1', 'label': 'price1'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'price2', 'label': 'price2'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'price1Name', 'label': 'price1Name'}, // G5h · מקום-שמור: שדה-Course מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'price2Name', 'label': 'price2Name'}, // G5h · מקום-שמור: שדה-Course מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'price3', 'label': 'price3'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'price3Name', 'label': 'price3Name'}, // G5h · מקום-שמור: שדה-Course מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'model', 'label': 'model'}, // G5h · מקום-שמור: שדה-Course מהסכמה (PricingModel) — מאיר כשהנתון מוזרם
    {'key': 'size', 'label': 'size'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'weekday', 'label': 'weekday'}, // G5h · מקום-שמור: שדה-Course מהסכמה (Weekday) — מאיר כשהנתון מוזרם
    {'key': 'audience', 'label': 'audience'}, // G5h · מקום-שמור: שדה-Course מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'img', 'label': 'img'}, // G5h · מקום-שמור: שדה-Course מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'lessonPrice1', 'label': 'lessonPrice1'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'lessonPrice2', 'label': 'lessonPrice2'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'lessonPrice3', 'label': 'lessonPrice3'}, // G5h · מקום-שמור: שדה-Course מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'year', 'label': 'year'}, // G5h · מקום-שמור: שדה-Course מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'prevYearId', 'label': 'prevYearId'}, // G5h · מקום-שמור: שדה-Course מהסכמה (Id) — מאיר כשהנתון מוזרם
    {'label': 'שם-חוג', 'get': (Map<String, dynamic> c) => '${c['name']}'},
    {'key': 'code', 'label': 'קוד'},                                                   // מקום-שמור
    {'label': 'תחום', 'get': (Map<String, dynamic> c) => '${c['cat'] ?? '—'}'},
    {'label': 'מורה', 'get': (Map<String, dynamic> c) => '${teacherOf(c)?['name'] ?? '—'}'},
    {'label': 'חדר', 'get': (Map<String, dynamic> c) => '${roomOf(c)?['name'] ?? '—'}'},
    {'label': 'יום+שעה', 'get': (Map<String, dynamic> c) => sessionsLabel(c)},
    {'label': 'משך', 'get': (Map<String, dynamic> c) => roomOf(c) == null ? '—' : '${roomOf(c)!['slot']} דק׳'}, // מקור: Room.slot
    {'label': 'תדירות', 'get': (Map<String, dynamic> c) => hasSessions(c) ? '×${(sessionsOf(c) as List).length}/שבוע' : '—'},
    {'label': 'סמסטר', 'get': (Map<String, dynamic> c) => '${c['semester'] ?? '—'} · ${c['start']}–${c['end']}'},
    {'label': 'קיבולת', 'get': (Map<String, dynamic> c) => '${capacity(c)}'},
    {'label': 'רשומים', 'get': (Map<String, dynamic> c) => '${enrolled(c)}'},
    {'label': 'תפוסה%', 'get': (Map<String, dynamic> c) => '${(occupancy(c) * 100).round()}%'},
    {'label': 'המתנה', 'get': (Map<String, dynamic> c) => '${waitlist(c).length}'},
    {'label': 'מינ׳-לפתיחה', 'get': (Map<String, dynamic> c) => minToOpen(c) == null ? '—' : '${minToOpen(c)}${c['minStudents'] == null ? ' (איזון)' : ''}'},
    {'label': 'מחיר', 'get': (Map<String, dynamic> c) => c['perLesson'] == true ? '${shekel(c['lessonPrice'])}/שיעור' : shekel(c['price'])},
    {'label': 'חוב-פתוח', 'get': (Map<String, dynamic> c) => shekel(courseDebt(c).toInt())},
    {'key': '__status', 'label': 'סטטוס'},
    {'label': 'מגמת-הרשמה', 'get': (Map<String, dynamic> c) => trendLabel(c)},
  ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || c['key'] == '__status' || rows.any((r) => r[c['key']] != null && '${r[c['key']]}'.trim().isNotEmpty);

  // ═══ ביצוע (פעולת-יסוד) · כל פעולה = מנועי-מדף ⊕ פנקס-מצב ⊕ רשומת-אודיט ═══
  static final DateTime nowAt = DateTime.parse('${today}T09:00:00'); // "עכשיו" מוזרק (חוק: אין DateTime.now במנוע)
  static DateTime _atNoon(String iso) => DateTime.parse('${iso}T12:00:00');
  static Map<String, dynamic>? courseById(dynamic id) => allCourses.where((c) => c['id'] == id).firstOrNull;
  static Map<String, dynamic>? enrollmentById(dynamic id) => allEnrollments.where((e) => e['id'] == id).firstOrNull;
  // תלמידים שאינם רשומים-חיים/ממתינים לחוג (מועמדים לשיבוץ/הזמנה)
  static List<Map<String, dynamic>> candidates(Map<String, dynamic> c) {
    final taken = {for (final e in enrollmentsOf(c)) if (e['status'] != 'ended') e['memberId']};
    return [for (final f in families) for (final m in (f['members'] as List)) if (!taken.contains(m['id'])) memberOf(m['id'])!];
  }
  // דרישות-קדם (courseFitsMember ⊕ gradeFits ⊕ gradeIndex ⊕ gradeOrder ⊕ ageOf) ⇒ null=מתאים · אחרת סיבה
  static bool _gradeFits(dynamic c, dynamic grade) =>
      gradeFits({'gradeMin': '${c['gradeMin'] ?? ''}', 'gradeMax': '${c['gradeMax'] ?? ''}'}, grade as String?, (g) => gradeIndex(g, gradeOrder));
  static String? fitReason(Map<String, dynamic> c, Map<String, dynamic> m) {
    final age = ageOf(m['birth'] as String?, nowAt);
    if (courseFitsMember(c, m['gender'], age, m['grade'], _gradeFits)) return null;
    if (!_gradeFits(c, m['grade'])) return 'שכבה ${m['grade']} מחוץ ל-${c['gradeMin']}–${c['gradeMax']}';
    if (age != null && ((c['ageMin'] is num && age < c['ageMin']) || (c['ageMax'] is num && age > c['ageMax']))) return 'גיל $age מחוץ ל-${c['ageMin']}–${c['ageMax']}';
    return 'מגדר לא-תואם';
  }
  // התנגשות-תלמיד בזמן-אמת (scheduleClashText ממאור) — חוסמת-שיבוץ
  static String? clashReason(Map<String, dynamic> c, dynamic memberId) {
    final txt = scheduleClashText(db, memberId, c, sessionsOf, dayNames, const {'k1': 'ended', 'k2': 'מתנגש עם ', 'k3': ' · '});
    return txt == null ? null : '$txt';
  }
  static Map<String, dynamic> _newEnrollment(Map<String, dynamic> c, dynamic memberId, String status) => {
        'id': nextId('e-new-'), 'memberId': memberId, 'courseId': c['id'], 'status': status, 'enrolledAt': today, 'group': '',
        'totalDue': c['perLesson'] == true ? 0 : ((c['price'] as num?) ?? 0) * 10, 'dueDate': '', 'note': '', 'payments': <Map<String, dynamic>>[],
        'presents': <String>[], 'absences': <Map<String, dynamic>>[],
      };
  // 🎓 שבץ-תלמיד: קדם ⊕ התנגשות ⊕ קיבולת ⇒ enrolled / waitlisted / blocked
  static String enroll(Map<String, dynamic> c, dynamic memberId, String who) {
    final m = memberOf(memberId);
    if (m == null) return 'blocked:תלמיד לא נמצא';
    final fit = fitReason(c, m);
    if (fit != null) return 'blocked:דרישות-קדם — $fit';
    final clash = clashReason(c, memberId);
    if (clash != null) return 'blocked:התנגשות — ${memberName(memberId)} $clash';
    final status = isFull(c) ? 'wait' : 'active';
    extraEnrollments.add(_newEnrollment(c, memberId, status));
    log(who, status == 'wait' ? 'המתנה' : 'שיבוץ', '${memberName(memberId)} ⇐ ${c['name']}${status == 'wait' ? ' (מלא ⇒ המתנה)' : ''}', c['id'] as String);
    return status == 'wait' ? 'waitlisted' : 'enrolled';
  }
  // ⏳ הזמן-להמתנה (ישירות, גם כשיש מקום — לפי בקשה)
  static String invite(Map<String, dynamic> c, dynamic memberId, String who) {
    final m = memberOf(memberId);
    if (m == null) return 'blocked:תלמיד לא נמצא';
    final fit = fitReason(c, m);
    if (fit != null) return 'blocked:דרישות-קדם — $fit';
    extraEnrollments.add(_newEnrollment(c, memberId, 'wait'));
    log(who, 'המתנה', '${memberName(memberId)} הוזמן/ה להמתנה ⇐ ${c['name']}', c['id'] as String);
    return 'waitlisted';
  }
  // ➖ הסר-תלמיד ⇒ מקום מתפנה ⇒ העלאה-אוטומטית של ראש-ההמתנה (waitlistFor = סדר-אמת)
  static String remove(Map<String, dynamic> e, String who) {
    statusOverride[e['id'] as String] = 'ended';
    final c = courseById(e['courseId'])!;
    log(who, 'הסרה', '${memberName(e['memberId'])} ⇐ ${c['name']}', c['id'] as String);
    final promoted = autoPromote ? promoteNext(c, 'אוטומציה') : null;
    return promoted == null ? 'removed' : 'removed+promoted:$promoted';
  }
  static String? promoteNext(Map<String, dynamic> c, String who) {
    if (isFull(c)) return null;
    final w = waitlist(c);
    if (w.isEmpty) return null;
    statusOverride[w.first['id'] as String] = 'active';
    log(who, 'העלאה-מהמתנה', '${memberName(w.first['memberId'])} ⇐ ${c['name']}', c['id'] as String);
    return memberName(w.first['memberId']);
  }
  // ⬆ העלה-מהמתנה (ידני): נחסם כשהחוג מלא
  static String promote(Map<String, dynamic> e, String who) {
    final c = courseById(e['courseId'])!;
    if (isFull(c)) return 'blocked:החוג מלא (${enrolled(c)}/${capacity(c)}) — הסר תלמיד או הגדל קיבולת';
    final clash = clashReason(c, e['memberId']);
    if (clash != null) return 'blocked:התנגשות — ${memberName(e['memberId'])} $clash';
    statusOverride[e['id'] as String] = 'active';
    log(who, 'העלאה-מהמתנה', '${memberName(e['memberId'])} ⇐ ${c['name']}', c['id'] as String);
    return 'promoted';
  }
  // 🔁 העבר-תלמיד-בין-חוגים = שיבוץ-ליעד (עם כל הבדיקות) ואז הסרה-מהמקור
  static String move(Map<String, dynamic> e, Map<String, dynamic> target, String who) {
    final r = enroll(target, e['memberId'], who);
    if (r.startsWith('blocked')) return r;
    remove(e, who);
    return 'moved:$r';
  }
  // 👩‍🏫 הקצה-מורה / 🚪 הקצה-חדר — התנגשות חוסמת-שיבוץ (סימולציה לפני-ביצוע)
  static bool _wouldClash(Map<String, dynamic> c, String key, dynamic id) {
    final sim = {...c, key: id};
    return liveCourses.any((o) => o['id'] != c['id'] && o[key] == id && '$id'.isNotEmpty && _sameSlot(sim, o));
  }
  static String assignTeacher(Map<String, dynamic> c, dynamic tid, String who) {
    if (_wouldClash(c, 'teacherId', tid)) return 'blocked:התנגשות-מורה — ${teachers.where((t) => t['id'] == tid).firstOrNull?['name']} מלמד/ת חוג-אחר באותו slot';
    courseOverride[c['id'] as String] = {...?courseOverride[c['id']], 'teacherId': tid};
    log(who, 'הקצאת-מורה', '${teachers.where((t) => t['id'] == tid).firstOrNull?['name']} ⇐ ${c['name']}', c['id'] as String);
    return 'assigned';
  }
  static String assignRoom(Map<String, dynamic> c, dynamic rid, String who) {
    if (_wouldClash(c, 'roomId', rid)) return 'blocked:התנגשות-חדר — ${rooms.where((r) => r['id'] == rid).firstOrNull?['name']} תפוס באותו slot';
    courseOverride[c['id'] as String] = {...?courseOverride[c['id']], 'roomId': rid};
    log(who, 'הקצאת-חדר', '${rooms.where((r) => r['id'] == rid).firstOrNull?['name']} ⇐ ${c['name']}', c['id'] as String);
    return 'assigned';
  }
  // 🔄 החלף-מורה חד-פעמי (לשיעור-הקרוב) — לא משנה את החוג
  static void substitute(Map<String, dynamic> c, String iso, dynamic tid, String who) {
    substitutes['${c['id']}|$iso'] = '$tid';
    log(who, 'מורה-מחליף', '${teachers.where((t) => t['id'] == tid).firstOrNull?['name']} ב-$iso ⇐ ${c['name']}', c['id'] as String);
  }
  // ✖ בטל-שיעור-יחיד (toggle)
  static void cancelSession(Map<String, dynamic> c, String iso, String who, [String reason = 'חד-פעמי']) {
    final k = '${c['id']}|$iso';
    if (cancelledSessions.remove(k)) {
      log(who, 'שחזור-שיעור', '$iso ⇐ ${c['name']}', c['id'] as String);
    } else {
      cancelledSessions.add(k);
      log(who, 'ביטול-שיעור', '$iso · $reason ⇐ ${c['name']}', c['id'] as String);
    }
  }
  // 🏁 סיים-חוג (מרוכז): החוג + כל ההרשמות-החיות ⇒ ended
  static void endCourse(Map<String, dynamic> c, String who) {
    courseOverride[c['id'] as String] = {...?courseOverride[c['id']], 'ended': true};
    for (final e in liveEnrollmentsOf(c)) {
      statusOverride[e['id'] as String] = 'ended';
    }
    log(who, 'סיום-חוג', '${c['name']} · ${liveEnrollmentsOf(c).length} הרשמות נסגרו', c['id'] as String);
  }
  // ✏️ ערוך: שם / קיבולת (הגדלת-קיבולת ⇒ העלאה-אוטומטית מהמתנה)
  static void edit(Map<String, dynamic> c, String key, dynamic value, String who) {
    courseOverride[c['id'] as String] = {...?courseOverride[c['id']], key: value};
    log(who, 'עריכה', '$key=$value ⇐ ${c['name']}', c['id'] as String);
    if (key == 'maxStudents' && autoPromote) {
      while (promoteNext(courseById(c['id'])!, 'אוטומציה') != null) {}
    }
  }
  // 📄 שכפל-חוג (duplicateCourse ממאור: id חדש + סיומת-עותק, אותם תאריכים) — העותק יורש slot ⇒ המנוע יסמן התנגשות עד שישובץ מחדש
  static Map<String, dynamic> duplicate(Map<String, dynamic> c, String who) {
    final copy = duplicateCourse(c, nextId('c-copy-'), {'start': c['start'], 'end': c['end']}, term: (k) => k == 'avtk' ? ' (עותק)' : k);
    extraCourses.add(copy);
    log(who, 'שכפול-חוג', '${copy['name']}', copy['id'] as String);
    return copy;
  }
  // 📑 שכפל-סמסטר/שנה (nextYearCourseDraft⊕nextYearDates⊕academicYearLabel ממאור) — "חכם": מסמן טיוטות בלי-מורה/בלי-חדר-פעיל
  static Map<String, int> duplicateSemester(int sem, String who) {
    var created = 0, flagged = 0;
    for (final c in bySemester(liveCourses, sem)) {
      if (c['prevYearId'] != null) continue; // כבר טיוטת-שכפול
      final draft = nextYearCourseDraft(
        c, nextId('c-next-'),
        (st, en) => nextYearDates('$st', '$en', _atNoon, _iso),
        (st) => academicYearLabel('$st', _atNoon),
      ).cast<String, dynamic>();
      extraCourses.add(draft);
      created++;
      if (noTeacher(draft) || roomOf(draft) == null || roomOf(draft)!['active'] != true) flagged++;
    }
    log(who, 'שכפול-סמסטר', '$created טיוטות לשנה-הבאה · $flagged דורשות-טיפול (מורה/חדר)');
    return {'created': created, 'flagged': flagged};
  }
  // ➕ חוג-חדש (defaultCourseDates ממאור) — נולד ללא-מורה/ללא-חדר ⇒ מצבי-החריגה מאירים מיד
  static Map<String, dynamic> newCourse(String who) {
    final dates = defaultCourseDates(today);
    final c = <String, dynamic>{
      'id': nextId('c-new-'), 'name': 'חוג חדש', 'teacherId': '', 'roomId': '', 'cat': '', 'semester': '', 'sector': 'כללי', // semester ריק = "סמסטר לא-מוגדר" עד שנבחר
      'start': dates['start'], 'end': dates['end'], 'sessions': <Map<String, dynamic>>[], 'maxStudents': 0, 'price': 0, 'gender': 'all',
      'description': '', 'notes': '', 'files': <Map<String, dynamic>>[],
    };
    extraCourses.add(c);
    log(who, 'חוג-חדש', '${c['name']} · ${dates['start']}–${dates['end']}', c['id'] as String);
    return c;
  }
  // 💬 שלח-הודעה-לחוג: קישור-WhatsApp פר-משפחה (waLink⊕waDigits ממאור) — הזהות (טלפון) מוזרקת מהדאטה, לא באטום
  static List<Map<String, String>> waLinks(Map<String, dynamic> c, String text) => [
        for (final e in liveEnrollmentsOf(c))
          () {
            final m = memberOf(e['memberId']);
            final href = waLink(m?['famPhone'], text, waDigits);
            return {'name': memberName(e['memberId']), 'href': href == null ? '—' : '$href'};
          }(),
      ];

  // ─── אימות: נוכחות · גבייה · שיעורים-הבאים · מקום-שמור ───
  static const _statusT = {'k1': 'פעיל', 'k2': 'מוקפא', 'k3': 'הסתיים', 'k4': 'רשימת-המתנה'};
  static Map<String, dynamic> summary(Map<String, dynamic> e) => enrollSummary(e, (x) => payBal(x, _paid), (x) => paidOf(x), _statusT);
  static String paidStatus(Map<String, dynamic> e) => enrollmentPaidStatus(e, (x) => payBal(x, _paid), (x) => paidOf(x));
  static String paidLabel(Map<String, dynamic> e) => const {'paid': '✅ שולם', 'partial': '🟠 חלקי', 'unpaid': '🔴 לא-שולם'}[paidStatus(e)]!;
  static String enrollStatusLabel(Map<String, dynamic> e) =>
      enrollStatusMeta(e, term: (k) => const {'mvkpa': 'מוקפא', 'hstyym': 'הסתיים', 'rshymthmtnh': 'המתנה', 'payl': 'פעיל'}[k] ?? k)['label']!;
  static int presentsThisMonth(Map<String, dynamic> e) => presentsInMonth((e['presents'] as List?)?.cast<Object?>(), today);
  static double attendanceRate(Map<String, dynamic> c) {
    var p = 0, a = 0;
    for (final e in liveEnrollmentsOf(c)) {
      final sm = summary(e);
      p += sm['presents'] as int;
      a += sm['absences'] as int;
    }
    return p + a == 0 ? 0 : p / (p + a);
  }
  static num courseExpected(Map<String, dynamic> c) => grandTotal(liveEnrollmentsOf(c), (e) => ((e as Map)['totalDue'] as num?) ?? 0);
  // השיעורים-הבאים: nextSessionDate (מנוע) מופעל n פעמים מ-"עכשיו" המוזרק
  // מפגש-אמיתי = יום(int)+שעה(HH:MM תקינה). חוג-חדש נולד בלי מפגשים ⇒ sessionsOf נופל ל-{weekday:null,time:null} ⇒ חובה לגדר
  //   (הבדיקה 8ב תפסה: nextSessionDate עשה `as int` על null ⇒ קריסת-build באוטומציות. §6: לא "מתקמפל" — נבדק).
  static bool hasSessions(Map<String, dynamic> c) => (sessionsOf(c) as List).any((s) {
        final t = timeToMin(s['time']);
        return s['day'] is int && t is num && !t.isNaN;
      });
  static List<DateTime> upcoming(Map<String, dynamic> c, int n) {
    final out = <DateTime>[];
    if (!hasSessions(c)) return out;
    var from = nowAt;
    for (var i = 0; i < n; i++) {
      final d = nextSessionDate(c, from, sessionsOf);
      if (d == null) break;
      out.add(d);
      from = d.add(const Duration(minutes: 1));
    }
    return out;
  }
  static String roomLabel(Map<String, dynamic> c) {
    final r = roomOf(c);
    return r == null ? '—' : '${r['name']} · ${roomInfoLabel(r, const {'k1': 'משבצת ', 'k2': ' דק׳', 'k3': ' · עד ', 'k4': ' תלמידים', 'k5': ' · נגיש'})}';
  }
  // חוזה-שדות-מטא של הפאנל (חוק-7): שדה-אמת מוצג כשקיים · שדה חסר-מקור = מקום-שמור שמאיר כשיגיע
  static const metaFields = <Map<String, String>>[
    {'key': 'cat', 'prefix': '🗂 ', 'suffix': ''},
    {'key': 'semester', 'prefix': '📆 ', 'suffix': ''},
    {'key': 'gradeMin', 'prefix': '🎒 שכבות ', 'suffix': '–'},
    {'key': 'gradeMax', 'prefix': '', 'suffix': ''},
    {'key': 'ageMin', 'prefix': '🎂 גיל ', 'suffix': '+'},
    {'key': 'description', 'prefix': '📝 ', 'suffix': ''},
    {'key': 'notes', 'prefix': '📌 ', 'suffix': ''},
    {'key': 'year', 'prefix': '🗓 שנה ', 'suffix': ''},
    {'key': 'code', 'prefix': '🔖 ', 'suffix': ''},                 // מקום-שמור
    {'key': 'prerequisites', 'prefix': '📚 קדם: ', 'suffix': ''},   // מקום-שמור
    {'key': 'equipment', 'prefix': '🧰 ', 'suffix': ''},            // מקום-שמור
    {'key': 'online', 'prefix': '💻 ', 'suffix': ''},               // מקום-שמור (מקוון/היברידי)
    {'key': 'certificate', 'prefix': '🎓 תעודה: ', 'suffix': ''},  // מקום-שמור
    {'key': 'cancelPolicy', 'prefix': '↩ ביטול: ', 'suffix': ''},   // מקום-שמור
    {'key': 'actualStart', 'prefix': '▶ התחלה-בפועל ', 'suffix': ''}, // מקום-שמור
    {'key': 'actualEnd', 'prefix': '⏹ סיום-בפועל ', 'suffix': ''},   // מקום-שמור
    {'key': 'scholarship', 'prefix': '🎗 מלגה: ', 'suffix': ''},     // מקום-שמור (תלמידים-ללא-תשלום)
    {'key': 'template', 'prefix': '🧩 תבנית: ', 'suffix': ''},      // מקום-שמור (תבנית-שיעור לשכפול)
  ];

  // ═══ איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — לא `.contains` שטוח ═══
  //   נרמול-עברי (סופיות/ניקוד) + ניקוד רב-מילתי AND + סינון-ציון-0 + מיון-יורד-לפי-רלוונטיות. השקעים מוזרקים (חוק-1).
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String _norm(dynamic q) => normSearch(q, _finals);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> _termsOf(Map<String, dynamic> c) => [
        '${c['name']}', '${c['cat'] ?? ''}', '${c['semester'] ?? ''}', '${teacherOf(c)?['name'] ?? ''}', '${roomOf(c)?['name'] ?? ''}', '${c['description'] ?? ''}', '${c['code'] ?? ''}',
      ];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> cs, String q) =>
      (smartFilter(q, cs, (c) => _termsOf(c as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();

  // ═══ חריגה/סינון (הכרעה 23-ג) = FilterChipPill ⊕ finderMatches — 13 צירים · AND על נעילות ═══
  //   ציר-מצב (state): clash · noTeacher · noRoom · full · open · belowMin · waiting · ended
  //   צירי-ממד: cat · teacher · room · day · hour · grade (שכבה בתוך gradeMin..gradeMax) — סמסטר=SegmentedSwitch · טקסט=DsSearch
  static String axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis, Map<String, String> locks) {
    final c = f as Map<String, dynamic>;
    final want = locks['$axis'] ?? '';
    switch ('$axis') {
      case 'state':
        switch (want) {
          case 'clash': return hasClash(c) ? want : '';
          case 'noTeacher': return noTeacher(c) ? want : '';
          case 'noRoom': return noRoom(c) ? want : '';
          case 'full': return isFull(c) ? want : '';
          case 'open': return !isFull(c) && isLive(c) ? want : '';
          case 'belowMin': return belowMin(c) ? want : '';
          case 'waiting': return waitlist(c).isNotEmpty ? want : '';
          case 'ended': return !isLive(c) ? want : '';
        }
        return '';
      case 'cat': return '${c['cat'] ?? ''}';
      case 'teacher': return '${c['teacherId'] ?? ''}';
      case 'room': return '${c['roomId'] ?? ''}';
      case 'day': return (sessionsOf(c) as List).any((s) => '${s['day']}' == want) ? want : '';
      case 'hour':
        return (sessionsOf(c) as List).any((s) { final t = timeToMin(s['time']); return t is num && !t.isNaN && '${(t ~/ 60)}' == want; }) ? want : '';
      case 'grade': return _gradeFits(c, want) ? want : '';
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> cs, Map<String, String> locks) =>
      finderMatches({'families': cs}, locks, (db, f, axis) => axisValue(db, f, axis, locks)).cast<Map<String, dynamic>>();
  static int countState(List<Map<String, dynamic>> cs, String st) => filter(cs, {'state': st}).length;
  // תחומים עם מונה (countBy ממאור) — צ׳יפי-תחום דינמיים מהדאטה, לא רשימה-קשיחה
  static List<List<Object>> catCounts(List<Map<String, dynamic>> cs) => countBy(cs, (c) => '${(c as Map)['cat'] ?? ''}');
  static const stateChips = <List<String>>[
    ['clash', '⚠️ התנגשות'], ['noTeacher', '🚫 ללא-מורה'], ['noRoom', '🚪 ללא-חדר'], ['full', '🈵 מלא'],
    ['open', '🟢 פנוי'], ['belowMin', '📉 מתחת-מינ׳'], ['waiting', '⏳ המתנה>0'], ['ended', '🏁 הסתיימו'],
  ];

  // ═══ הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction ⊕ teacherIdOf ═══
  //   6 זהויות-דמו מוזרקות (לא אטום!). מפתחות-פעולה: crs.new·duplicate·enroll·remove·move·waitlist·assignTeacher·
  //   assignRoom·cancel·end·message·export·print·edit·attendance·fees·util·self. מורה = roles.teachers{email⇒id} ⇒ "החוגים-שלי".
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👑 רכז/ת', 'email': 'coord@school', 'config': {'adminEmails': ['coord@school']}}, // admin ⇒ הכל
    {'label': '👩‍🏫 מורה', 'email': 'rut@school', 'config': {'roles': {'teachers': {'rut@school': 't1'}}, 'features': {'crs.attendance': true, 'crs.message': true, 'crs.cancel': true}}},
    {'label': '🗂 מזכירות', 'email': 'office@school', 'config': {'features': {'crs.enroll': true, 'crs.remove': true, 'crs.move': true, 'crs.waitlist': true, 'crs.fees': true, 'crs.message': true, 'crs.export': true, 'crs.print': true}}},
    {'label': '📊 הנהלה', 'email': 'mgmt@school', 'config': {'features': {'crs.util': true, 'crs.fees': true, 'crs.end': true, 'crs.export': true, 'crs.print': true, 'crs.duplicate': true}}},
    {'label': '👨‍👩‍👧 הורה', 'email': 'parent@school', 'familyId': 'f1', 'config': {'features': {'crs.self': true}}}, // המערכת-שלי + הרשמה-עצמית (מופעל)
    {'label': '👁 צפייה', 'email': 'view@school', 'config': <String, dynamic>{}}, // staff ללא-הרשאות
  ];
  static Map<String, dynamic> _cfg(int role) => (roleDefs[role]['config'] as Map).cast<String, dynamic>();
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) => canGrantedAction(_cfg(role), roleDefs[role]['email'] as String, false, key, _isAdmin);
  static String roleName(int role) => roleOf(_cfg(role), roleDefs[role]['email'] as String);
  static dynamic myTeacherId(int role) => teacherIdOf(_cfg(role), roleDefs[role]['email']);
  static String? myFamilyId(int role) => roleDefs[role]['familyId'] as String?;
  // המערכת-שלי (הורה): חוגים שבהם חבר-משפחה רשום/ממתין
  static List<Map<String, dynamic>> familyCourses(List<Map<String, dynamic>> cs, String famId) {
    final fam = families.where((f) => f['id'] == famId).firstOrNull;
    if (fam == null) return const [];
    final ids = {for (final m in (fam['members'] as List)) m['id']};
    return cs.where((c) => enrollmentsOf(c).any((e) => ids.contains(e['memberId']) && e['status'] != 'ended')).toList();
  }
  // גידור-תצוגה לפי תפקיד: מורה ⇒ coursesOfTeacher(החוגים-שלו) · הורה ⇒ familyCourses · אחרת הכל
  static List<Map<String, dynamic>> scopeFor(int role, List<Map<String, dynamic>> cs) {
    final tid = myTeacherId(role);
    if (tid != null) return (coursesOfTeacher(cs, tid) as List).cast<Map<String, dynamic>>();
    final fid = myFamilyId(role);
    if (fid != null) return familyCourses(cs, fid);
    return cs;
  }
  // הרשמה-עצמית (הורה ⇒ סטטוס wait = "רכז מאשר"; כל בדיקות-הקדם/התנגשות חלות)
  static String selfEnroll(Map<String, dynamic> c, dynamic memberId, String who) {
    final m = memberOf(memberId);
    if (m == null) return 'blocked:תלמיד לא נמצא';
    final fit = fitReason(c, m);
    if (fit != null) return 'blocked:דרישות-קדם — $fit';
    final clash = clashReason(c, memberId);
    if (clash != null) return 'blocked:התנגשות — ${memberName(memberId)} $clash';
    extraEnrollments.add(_newEnrollment(c, memberId, 'wait'));
    log(who, 'הרשמה-עצמית', '${memberName(memberId)} ⇐ ${c['name']} (ממתין לאישור-רכז)', c['id'] as String);
    return 'pending';
  }
  // ⛔ בטל-חוג (מצב "בוטל" — נבדל מ"הסתיים")
  static void cancelCourse(Map<String, dynamic> c, String who) {
    courseOverride[c['id'] as String] = {...?courseOverride[c['id']], 'cancelled': true};
    for (final e in liveEnrollmentsOf(c)) {
      statusOverride[e['id'] as String] = 'ended';
    }
    log(who, 'ביטול-חוג', '${c['name']}', c['id'] as String);
  }
  // סמסטר-לא-מוגדר: חוג בלי semester תקין (מצב-מיוחד)
  static bool semesterUndefined(Map<String, dynamic> c) => !semesterOptions.contains(c['semester']);

  // ═══ אוטומציות-חכמות (23-ג · פרואקטיבי) — המערכת מזהירה ומציעה לפני שהשיעור נפגע ═══
  // 📅 סנכרון-לוח: חג ⇒ ביטול-אוטו + הודעה — hebParts ⊕ HOLIDAYS ⊕ upcomingHolidays (מנועי-מאור, אפס-תאריכים-קשיחים)
  static String? holidayName(DateTime d) {
    final p = hebParts(d);
    return HOLIDAYS['${p['month']} ${p['day']}'];
  }
  static List<Map<String, dynamic>> get upcomingHolidayList => upcomingHolidays(today, holidayName, _iso, 45);
  // שיעורים שנופלים על חג (45 ימים קדימה) ועדיין לא בוטלו: [{course, iso, name}]
  static List<Map<String, dynamic>> holidayLessons() {
    final out = <Map<String, dynamic>>[];
    for (final c in liveCourses) {
      for (final dt in upcoming(c, 14)) {
        if (dayDiff(today, _iso(dt)) > 45) break;
        final h = holidayName(dt);
        if (h != null && !isCancelled(c, _iso(dt))) out.add({'course': c, 'iso': _iso(dt), 'name': h});
      }
    }
    return out;
  }
  static int autoCancelHolidays(String who) {
    final hl = holidayLessons();
    for (final h in hl) {
      cancelSession(h['course'] as Map<String, dynamic>, h['iso'] as String, who, 'חג: ${h['name']}');
    }
    return hl.length;
  }
  // 🚪 הצעת-חדר-חלופי: חדר פעיל, פנוי בכל ה-slots של החוג, בקיבולת מספקת
  static List<Map<String, dynamic>> freeRooms(Map<String, dynamic> c) => [
        for (final r in rooms)
          if (r['active'] == true && r['id'] != c['roomId'] && (capacity(c) == 0 || (r['cap'] as int) >= capacity(c)) &&
              !liveCourses.any((o) => o['id'] != c['id'] && o['roomId'] == r['id'] && _sameSlot(c, o)))
            r,
      ];
  // 👩‍🏫 הצעת-מורה-מחליף/חלופי: פנוי ב-slots של החוג; התמחות=תחום קודם
  static List<Map<String, dynamic>> freeTeachers(Map<String, dynamic> c) {
    final out = [
      for (final t in teachers)
        if (t['id'] != c['teacherId'] && !liveCourses.any((o) => o['id'] != c['id'] && o['teacherId'] == t['id'] && _sameSlot(c, o))) t,
    ];
    out.sort((a, b) => (b['specialty'] == c['cat'] ? 1 : 0).compareTo(a['specialty'] == c['cat'] ? 1 : 0));
    return out;
  }
  // 📉 התרעת-מתחת-מינימום X ימים לפני: ימים-עד-התחלה (שלילי = כבר התחיל) — dayDiff ממאור
  static int daysToStart(Map<String, dynamic> c) => -dayDiff('${c['start']}', today).toInt();
  static const belowMinWarnDays = 14; // חלון-התרעה (קלט-תכנון)
  static List<Map<String, dynamic>> get belowMinAlerts => liveCourses.where((c) => belowMin(c) && daysToStart(c) <= belowMinWarnDays).toList();
  // ⏳ המתנה-עם-מקום: ממתינים בחוג שאינו מלא (למשל אחרי הגדלת-קיבולת) ⇒ העלאה מוצעת
  static List<Map<String, dynamic>> get promotable => liveCourses.where((c) => !isFull(c) && waitlist(c).isNotEmpty).toList();
  // 🔔 תזכורת-לתלמידים: שיעורים ב-48 השעות הקרובות (nextSessionDate) ⇒ הודעה למשפחות (waLink)
  static List<Map<String, dynamic>> reminders() => [
        for (final c in liveCourses)
          for (final dt in upcoming(c, 1))
            if (dt.difference(nowAt).inHours <= 48 && !isCancelled(c, _iso(dt))) {'course': c, 'dt': dt},
      ];
  // 📈 אות-ביקוש (תחזית לסמסטר-הבא): מלא ∨ ממתינים ∨ מגמה-עולה ⇒ "פתח קבוצה נוספת". היסטוריה-רב-סמסטרית = מקום-שמור.
  static List<Map<String, dynamic>> get demandSignals => liveCourses.where((c) => isFull(c) || waitlist(c).isNotEmpty || trend(c)['dir'] == 'up').toList();
  // 📊 דוח-ניצולת: ממוצע-ניצולת-חדרים-פעילים · עומס-מורים ממוצע (מפגשים/שבוע)
  static int get avgRoomUtilPct {
    final act = rooms.where((r) => r['active'] == true).toList();
    return act.isEmpty ? 0 : (grandTotal(act, (r) => roomUtil(r as Map<String, dynamic>)) / act.length * 100).round();
  }
  static double get avgTeacherLoad => teachers.isEmpty ? 0 : grandTotal(teachers, (t) => weeklyOf(coursesOf(t as Map<String, dynamic>))) / teachers.length;

  // ═══ ייצוא (הכרעה 23-ג) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed · iCal = icsEscape ═══
  //   CSV = עמודות-החוזה המוארות (columnDefs) על הרשימה-הנראית · iCal = 6 השיעורים-הבאים פר-חוג (מבוטל ⇒ STATUS:CANCELLED)
  static List<List<Object?>> csvRows(List<Map<String, dynamic>> cs) {
    final cols = [for (final c in columnDefs) if (colShown(c, cs)) c];
    return [
      [for (final c in cols) c['label']],
      for (final r in cs)
        [for (final c in cols) c['key'] == '__status' ? statusLabel(r) : c['get'] != null ? (c['get'] as String Function(Map<String, dynamic>))(r) : '${r[c['key']] ?? ''}'],
    ];
  }
  static String csvOf(List<Map<String, dynamic>> cs) => toCsv(csvRows(cs), csvEscape) as String;
  static bool exportOk(int role) => exportAllowed(false) && can(role, 'crs.export'); // שער-ייצוא ⊕ הרשאה
  static String _icsStamp(DateTime d) => '${_iso(d).replaceAll('-', '')}T${_pad2(d.hour)}${_pad2(d.minute)}00';
  static String icsOf(List<Map<String, dynamic>> cs) {
    final L = <String>['BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//SchoolOS//courses//HE'];
    for (final c in cs) {
      for (final dt in upcoming(c, 6)) {
        final iso = _iso(dt);
        L.addAll([
          'BEGIN:VEVENT', 'UID:${c['id']}-$iso@schoolos', 'DTSTART:${_icsStamp(dt)}',
          'DTEND:${_icsStamp(dt.add(Duration(minutes: (roomOf(c)?['slot'] as int?) ?? 60)))}',
          'SUMMARY:${icsEscape('${c['name']}')}', 'LOCATION:${icsEscape(roomOf(c)?['name'] as String?)}',
          'DESCRIPTION:${icsEscape('${teacherOf(c)?['name'] ?? 'ללא-מורה'} · ${enrolled(c)}/${capacity(c)}')}',
          if (isCancelled(c, iso)) 'STATUS:CANCELLED',
          'END:VEVENT',
        ]);
      }
    }
    L.add('END:VCALENDAR');
    return L.join('\r\n');
  }
  // חוזה-שדות-מטא של הרשמה (חוק-7): tier=שדה-אמת (Enrollment.tier) · scholarship (מלגה) = מקום-שמור
  static const enrollMetaFields = <Map<String, String>>[
    {'key': 'tier', 'prefix': '🏷 מסלול ', 'suffix': ''},
    {'key': 'group', 'prefix': '👥 ', 'suffix': ''},
    {'key': 'renew', 'prefix': '🔁 חידוש: ', 'suffix': ''},
    {'key': 'scholarship', 'prefix': '🎗 מלגה: ', 'suffix': ''}, // מקום-שמור (תלמידים-ללא-תשלום)
    {'key': 'note', 'prefix': '📝 ', 'suffix': ''},
  ];

  // ─── KPI-10 (המפרט) — כולם מנועי-מדף/נגזרות-אמת, אפס-StatBlock ───
  static int get kpiActive => allCourses.where((c) => lifecycle(c) == 'פעיל').length;
  static List<Map<String, dynamic>> get rowsOf_kpiActive => allCourses.where((c) => lifecycle(c) == 'פעיל').cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד kpiActive (מהצורה של ה-getter, לא מילון)
  static int get kpiLessonsWeek => lessonsThisWeek();
  static int get kpiEnrolled => grandTotal(liveCourses, (c) => enrolled(c as Map<String, dynamic>)).toInt();
  static int get kpiOccupancyPct {
    final withCap = liveCourses.where((c) => capacity(c) > 0).toList();
    if (withCap.isEmpty) return 0;
    return (grandTotal(withCap, (c) => occupancy(c as Map<String, dynamic>)) / withCap.length * 100).round();
  }
  static int get kpiFull => liveCourses.where(isFull).length;
  static List<Map<String, dynamic>> get rowsOf_kpiFull => liveCourses.where(isFull).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד kpiFull (מהצורה של ה-getter, לא מילון)
  static int get kpiWaiting => grandTotal(liveCourses, (c) => waitlist(c as Map<String, dynamic>).length).toInt();
  // התנגשויות ייחודיות (זוג-חוגים×סוג, תלמיד×זוג) — לא כפל-ספירה משני צידי-הזוג
  static Set<String> get uniqueClashes {
    final out = <String>{};
    for (final c in liveCourses) {
      for (final k in clashesOf(c)) {
        final ids = ['${c['name']}', k['with']!]..sort();
        out.add('${k['kind']}|${ids.join('~')}|${k['who'] ?? ''}');
      }
    }
    return out;
  }
  static int get kpiClashes => uniqueClashes.length;
  static int get kpiNoTeacher => liveCourses.where(noTeacher).length;
  static List<Map<String, dynamic>> get rowsOf_kpiNoTeacher => liveCourses.where(noTeacher).cast<Map<String, dynamic>>().toList(); // G10a · שורות-המדד kpiNoTeacher (מהצורה של ה-getter, לא מילון)
  static int get kpiBelowMin => liveCourses.where(belowMin).length;
  static bool get kpiBelowMinKnown => liveCourses.any((c) => minToOpen(c) != null); // מקום-שמור: אין מינימום לאף חוג ⇒ '—'
  static num get kpiDebt => grandTotal(liveCourses, (c) => courseDebt(c as Map<String, dynamic>));
}

// ═══════════ המסך · CourseScreen (const · ללא main · המנהל מחבר ניווט) ═══════════
class CourseScreen extends StatefulWidget {
  const CourseScreen({this.initialMetric, this.initialPanelId, super.key});
  final String? initialMetric; // G10b · תפר-סינון: מפתח-מדד (CourseFacts.metricDefs) ⇒ הטבלה מסוננת לשורות-המדד; null ⇒ ביט-זהה
  final String? initialPanelId; // G10a · תפר-כניסה: מזהה-רשומה שכרטיסה נפתח אחרי הפריים-הראשון (צורת initialPanel של זהב-המורים; הרכזת קופצת לרשומת-ה-hero)
  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

  String? _metric; // G10b · המדד הנעול (null = ללא סינון-מדד)
class _CourseScreenState extends State<CourseScreen> {
  @override
  void initState() {
    super.initState();
    _metric = widget.initialMetric != null && CourseFacts.heroRows(widget.initialMetric!).isNotEmpty ? widget.initialMetric : null; // G10b · מדד בלי שורות ⇒ אין סינון (לא טבלה-ריקה בשקט)
    final p0 = widget.initialPanelId == null ? null : CourseFacts.byId(widget.initialPanelId!); // G10a
    if (p0 != null) WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _openPanel(p0); });
  }
  int _view = 0; // 0=📅 גריד-שבועי · 1=📋 רשימה · 2=👩‍🏫 פר-מורה · 3=🚪 פר-חדר (SegmentedSwitch→תצוגה)
  int _week = 0; // 0=השבוע · 1=שבוע-הבא (בורר-שבוע · פס-עליון)
  int _sem = 0; // 0=הכל · 1..=semesterOptions (בורר-סמסטר · פס-עליון)
  int _role = 0; // 0 רכז · 1 מורה · 2 מזכירות · 3 הנהלה · 4 הורה · 5 צפייה (חוק-6 זהות-מוזרקת; בורר מדגים גידור)
  bool _loading = false; // מצב-מסך שמור: טעינה (רענון מדגים; חיבור-אסינק עתידי מאיר אותו)
  String? _error; // מצב-מסך שמור: שגיאה (מקום-שמור — מאיר כש-fetch נכשל; null בזרימה-התקינה)
  String _q = ''; // חיפוש-איתור (DsSearch → smartFilter)
  final Map<String, String> _locks = {}; // נעילות-סינון פר-ציר (FilterChipPill → finderMatches)
  bool _adv = false; // סינון-מתקדם (צירי-ממד) פתוח
  int _tab = 0; // טאב-פאנל: 0 סקירה · 1 נרשמים · 2 המתנה · 3 מערכת · 4 נוכחות · 5 גבייה · 6 חומרים · 7 היסטוריה · 8 אודיט
  String? _pick; // בורר פתוח בפאנל: enroll · invite · teacher · sub · room · move:<eid> · message · null
  String? _msg; // תוצאת-פעולה אחרונה (AlertBanner)
  int _msgTone = 1;
  bool _edit = false; // מצב-עריכה (DsField/DsNumberField)
  String get _who => _CourseData.roleDefs[_role]['label'] as String; // זהות-הפועל = התפקיד-הנבחר (חוק-6: מוזרקת)
  bool _can(String key) => _CourseData.can(_role, key);

  @override
  Widget build(BuildContext context) {
    // גידור-תצוגה לפי תפקיד (roleOf⊕teacherIdOf): מורה רואה את החוגים-שלו · הורה את המערכת-שלי · אחרים הכל
    final live = _CourseData.scopeFor(_role, _CourseData.bySemester(_CourseData.liveCourses, _sem));
    final clashes = _CourseData.kpiClashes;
    final semEmpty = _sem > 0 && _CourseData.bySemester(_CourseData.liveCourses, _sem).isEmpty; // מצב: סמסטר לא-מוגדר/ריק
    // איתור⊕חריגה (23-ג): search=DsSearch⊕smartFilter⊕smartScore⊕normSearch · filter=finderMatches (AND על נעילות).
    //   'ended' מסנן מכל-החוגים (גם הסתיימו); אחרת מהחיים. הפייפליין רץ פעם-אחת ומזין גריד/רשימה/פר-מורה/פר-חדר.
    final base = _locks['state'] == 'ended' ? _CourseData.scopeFor(_role, _CourseData.bySemester(_CourseData.allCourses, _sem)) : live;
    final visibleAll = _CourseData.filter(_CourseData.search(base, _q), _locks);
    final visible = _metric == null ? visibleAll : visibleAll.where((r) => CourseFacts.heroRows(_metric!).any((h) => '${h[CourseFacts.idKey] ?? h['id']}' == '${r[CourseFacts.idKey] ?? r['id']}')).toList(); // G10b · סינון-לפי-מדד (זהות לפי מזהה — שורות-המדד וטבלת-המסך אותו סוג-רשומה, L66)
    // דירוג לפי דחיפות-מאוחדת (התנגשות ראשונה), ואז לפי תפוסה-יורדת
    final ranked = [...visible]..sort((a, b) {
        final s = _CourseData.sev(b).compareTo(_CourseData.sev(a));
        return s != 0 ? s : _CourseData.occupancy(b).compareTo(_CourseData.occupancy(a));
      });
    // טריאז' — פעולת-יסוד "הכרעה" מקבצת פר-דחיפות (3 התנגשות · 2 ללא-מורה/חדר · 1 מתחת-מינ׳ · 0 תקין · -1 הסתיים)
    final buckets = <int, List<Map<String, dynamic>>>{3: [], 2: [], 1: [], 0: [], -1: []};
    for (final c in ranked) {
      buckets[_CourseData.sev(c)]!.add(c);
    }
    const secTitle = {3: '⚠️ התנגשות — חוסם', 2: '🚫 ללא-מורה / ללא-חדר', 1: '📉 מתחת-למינימום', 0: '🟢 תקין', -1: '🏁 הסתיימו / בוטלו'};
    const secTone = {3: 2, 2: 2, 1: 3, 0: 1, -1: 0};
    return DsScaffold(title: 'חוגים ומערכת', subtitle: '${live.length} חוגים חיים · ${_CourseData.teachers.length} מורים · ${_CourseData.rooms.where((r) => r['active'] == true).length} חדרים', icon: '📚', header: false, children: [ForgeCenteredPageHeader(fields: ['', 'חוגים ומערכת', '${live.length} חוגים חיים · ${_CourseData.teachers.length} מורים · ${_CourseData.rooms.where((r) => r['active'] == true).length} חדרים']), ...[
        // ═══ סינון-לפי-מדד (G10b): הרכזת שלחה מדד ⇒ הטבלה מוגבלת לשורותיו; הבאנר = עובדת-הסינון, הכפתור מסיר ═══
        if (_metric != null) ForgeSectionPill(items: [['מסונן למדד: ${CourseFacts.metricDefs.firstWhere((d) => d['key'] == _metric, orElse: () => const {'label': ''})['label']} · ${visible.length} מתוך ${visibleAll.length}']], variants: const <int>[0]),
        if (_metric != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _metric = null), child: ForgeSoftButton(fields: ['✖ בטל סינון-מדד']))),
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות ותצוגה פר-תפקיד (roleOf⊕canGrantedAction⊕teacherIdOf)
        Align(
          alignment: Alignment.centerRight,
          child: FittedBox(fit: BoxFit.scaleDown, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in [for (final r in _CourseData.roleDefs) r['label'] as String]) [s]], selected: {_role}, onSelect: (i) => setState(() { _role = i; _locks.clear(); }))),
        ),
        _gap(8),
        // פס-עליון: בורר-שבוע/סמסטר + בורר-תצוגה (SegmentedSwitch מבוקר ×3) — ארגון = פעולת-יסוד עם אטום משלה
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
          ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['📅 השבוע', '⏭ שבוע הבא']) [s]], selected: {_week}, onSelect: (i) => setState(() => _week = i)),
          ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in ['הכל', ...semesterOptions]) [s]], selected: {_sem}, onSelect: (i) => setState(() => _sem = i)),
        ]),
        _gap(8),
        Align(
          alignment: Alignment.centerRight,
          child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['📅 גריד', '📋 רשימה', '👩‍🏫 פר-מורה', '🚪 פר-חדר']) [s]], selected: {_view}, onSelect: (i) => setState(() => _view = i)),
        ),
        _gap(8),
        // פס-עליון · פעולות-גלובליות: חוג-חדש (defaultCourseDates) · שכפל-סמסטר (nextYearCourseDraft) · הדפס-מערכת
        Wrap(spacing: 8, runSpacing: 6, children: [
          // רענון — מדגים את מצב-הטעינה השמור (חיבור-אסינק אמיתי יאיר אותו זהה)
          GestureDetector(behavior: HitTestBehavior.opaque, onTap: _refresh, child: ForgeSoftButton(fields: ['🔄'])),
          if (_can('crs.new')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _act(() => _CourseData.newCourse(_who), 'נוצר חוג-חדש (ללא-מורה/ללא-חדר — שבץ בפאנל)'), child: ForgeSoftButton(fields: ['➕ חוג-חדש'])),
          if (_can('crs.duplicate')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
            final r = _CourseData.duplicateSemester(_sem, _who);
            _flash('שכפול-סמסטר: ${r['created']} טיוטות לשנה-הבאה · ${r['flagged']} דורשות מורה/חדר', r['flagged']! > 0 ? 3 : 1);
          }, child: ForgeSoftButton(fields: ['📑 שכפל-סמסטר'])),
          if (_can('crs.print')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openPrint(live), child: ForgeSoftButton(fields: ['🖨 הדפס-מערכת'])),
          if (_CourseData.exportOk(_role)) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _openExport(visible), child: ForgeSoftButton(fields: ['⬇ ייצוא'])),
          ForgeStatusChip(items: [['תפקיד: ${_CourseData.roleName(_role)}${_CourseData.myTeacherId(_role) != null ? ' · החוגים-שלי' : _CourseData.myFamilyId(_role) != null ? ' · המערכת-שלי' : ''}']], variants: const <int>[0]),
        ]),
        _gap(6),
        // איתור: חיפוש-מבוקר (DsSearch → smartFilter⊕smartScore⊕normSearch) + סינון-מתקדם
        Row(children: [
          Expanded(child: ForgeDsSearch(control: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v), bare: true))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _adv = !_adv), child: ForgeSoftButton(fields: [_adv ? '🔎 פחות' : '🔎 סינון']))),
        ]),
        // חריגה: צ׳יפי-מצב (FilterChipPill ⊕ finderMatches) עם מונים-אמת
        Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[(('הכל · ${live.length}'), ((_locks[('state')] ?? '') == ('')), () => setState(() { if (('').isEmpty || ((_locks[('state')] ?? '') == (''))) { _locks.remove(('state')); } else { _locks[('state')] = (''); } })), for (final st in _CourseData.stateChips) (('${st[1]} · ${_CourseData.countState(st[0] == 'ended' ? _CourseData.bySemester(_CourseData.allCourses, _sem) : live, st[0])}'), ((_locks[('state')] ?? '') == (st[0])), () => setState(() { if ((st[0]).isEmpty || ((_locks[('state')] ?? '') == (st[0]))) { _locks.remove(('state')); } else { _locks[('state')] = (st[0]); } }))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
        if (_adv) ...[
          _gap(8),
          // צירי-ממד: תחום (countBy) · מורה · חדר · יום · שעה · שכבה — נעילה-אחת פר-ציר, AND בין צירים
          Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[for (final cc in _CourseData.catCounts(live)) if ('${cc[0]}'.isNotEmpty) (('🗂 ${cc[0]} · ${cc[1]}'), ((_locks[('cat')] ?? '') == ('${cc[0]}')), () => setState(() { if (('${cc[0]}').isEmpty || ((_locks[('cat')] ?? '') == ('${cc[0]}'))) { _locks.remove(('cat')); } else { _locks[('cat')] = ('${cc[0]}'); } }))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
          _gap(6),
          Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[for (final t in _CourseData.teachers) (('👩‍🏫 ${t['name']}'), ((_locks[('teacher')] ?? '') == ('${t['id']}')), () => setState(() { if (('${t['id']}').isEmpty || ((_locks[('teacher')] ?? '') == ('${t['id']}'))) { _locks.remove(('teacher')); } else { _locks[('teacher')] = ('${t['id']}'); } }))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
          _gap(6),
          Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[for (final r in _CourseData.rooms) (('🚪 ${r['name']}'), ((_locks[('room')] ?? '') == ('${r['id']}')), () => setState(() { if (('${r['id']}').isEmpty || ((_locks[('room')] ?? '') == ('${r['id']}'))) { _locks.remove(('room')); } else { _locks[('room')] = ('${r['id']}'); } }))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
          _gap(6),
          Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[for (var dd = 0; dd < 6; dd++) (('📅 ${dayNames[dd]}'), ((_locks[('day')] ?? '') == ('$dd')), () => setState(() { if (('$dd').isEmpty || ((_locks[('day')] ?? '') == ('$dd'))) { _locks.remove(('day')); } else { _locks[('day')] = ('$dd'); } })), for (final h in _CourseData.gridHours(_CourseData.liveCourses)) (('🕐 ${_CourseData.hm(h)}'), ((_locks[('hour')] ?? '') == ('${h ~/ 60}')), () => setState(() { if (('${h ~/ 60}').isEmpty || ((_locks[('hour')] ?? '') == ('${h ~/ 60}'))) { _locks.remove(('hour')); } else { _locks[('hour')] = ('${h ~/ 60}'); } }))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
          _gap(6),
          Builder(builder: (_) { final chips = <(String, bool, VoidCallback)>[for (final g in gradeOrder.sublist(1, 9)) (('🎒 $g'), ((_locks[('grade')] ?? '') == (g)), () => setState(() { if ((g).isEmpty || ((_locks[('grade')] ?? '') == (g))) { _locks.remove(('grade')); } else { _locks[('grade')] = (g); } }))]; return ForgeFacetChip(bare: true, items: [for (final ch in chips) [ch.$1]], selected: <int>{for (final (k, ch) in chips.indexed) if (ch.$2) k}, onSelect: (k) => chips[k].$3()); }),
        ],
        if (_msg != null) ...[_gap(8), ForgeSectionPill(items: [[_msg!]], variants: [const <int>[0, 0, 0, 0][(_msgTone) % 4]])],
        _gap(12),
        // KPI-10: hero=התנגשויות (המטרה: "אף שיבוץ לא יתנגש") + 9 מדדי-מצב (BareStat נושאי-ערך-אמת)
        ForgeStripPanelFrame(fields: ['', ''], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: ForgeStatPlain(fields: ['התנגשויות (מורה/חדר/תלמיד)', '$clashes'])),
            _gap(14),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['📚 פעילים', '${_CourseData.kpiActive}'])),
              Expanded(child: ForgeStatPlain(fields: ['🗓 שיעורים-השבוע', '${_CourseData.kpiLessonsWeek}'])),
              Expanded(child: ForgeStatPlain(fields: ['🎓 רשומים', '${_CourseData.kpiEnrolled}'])),
              Expanded(child: ForgeStatPlain(fields: ['📈 תפוסה-ממוצ׳', '${_CourseData.kpiOccupancyPct}%'])),
              Expanded(child: ForgeStatPlain(fields: ['🈵 מלאים', '${_CourseData.kpiFull}'])),
            ]),
            _gap(12),
            Row(children: [
              Expanded(child: ForgeStatPlain(fields: ['⏳ בהמתנה', '${_CourseData.kpiWaiting}'])),
              Expanded(child: ForgeStatPlain(fields: ['🚫 ללא-מורה', '${_CourseData.kpiNoTeacher}'])),
              Expanded(child: ForgeStatPlain(fields: ['📉 מתחת-מינ׳', _CourseData.kpiBelowMinKnown ? '${_CourseData.kpiBelowMin}' : '—'])),
              Expanded(child: ForgeStatPlain(fields: ['💳 חוב-פתוח', shekel(_CourseData.kpiDebt.toInt())])),
            ]),
          ])),
        _gap(10),
        // 🤖 מרכז-אוטומציות (23-ג · פרואקטיבי): המערכת מתריעה ומציעה לפני שדבר נשמט — כל התראה = מנוע ⊕ AlertBanner ⊕ פעולה
        if (!_loading && _CourseData.myFamilyId(_role) == null) ..._automations(live),
        // מצבי-מסך שמורים (מקום-שמור): טעינה + שגיאה מאירים במצב-אמת; סמסטר-ריק; אין-חוגים; אחרת התוכן הרגיל.
        if (_loading)
          _loadingView()
        else if (_error != null)
          ForgeSectionPill(items: [[_error!]], variants: const <int>[0])
        else if (semEmpty)
          ForgeSearchEmptyState(fields: ['סמסטר "${semesterOptions[_sem - 1]}" לא מוגדר — אין חוגים משובצים בו', ''])
        else if (live.isEmpty)
          ForgeSearchEmptyState(fields: [_CourseData.myTeacherId(_role) != null ? 'אין חוגים משובצים למורה זה' : _CourseData.myFamilyId(_role) != null ? 'אין חוגים למשפחה — הירשמו מהקטלוג' : 'אין חוגים — צור חוג-חדש או שכפל סמסטר', ''])
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: ForgeSearchEmptyState(fields: ['אין חוגים תואמים לחיפוש/סינון', '']))
        else if (_view == 1)
          ForgeTitledSection(fields: ['📋 רשימת-חוגים · ${visible.length} · ${_CourseData.columnDefs.where((c) => _CourseData.colShown(c, visible)).length} עמודות', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[_table(ranked)]]))
        else if (_view == 2)
          ..._byTeacher(visible)
        else if (_view == 3)
          ..._byRoom(visible)
        else ...[
          ForgeTitledSection(fields: ['📅 מערכת-שעות · ${_week == 0 ? 'השבוע' : 'שבוע הבא'} (${_CourseData.isoOfDay(0, _week)} – ${_CourseData.isoOfDay(5, _week)})', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[_grid(visible)]])),
          for (final st in const [3, 2, 1, 0, -1])
            if (buckets[st]!.isNotEmpty)
              ForgeTitledSection(fields: ['${secTitle[st]} · ${buckets[st]!.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[for (final c in buckets[st]!) _row(c)]])),
        ],
        // הורה + הרשמה-עצמית מופעלת: קטלוג-חוגים פתוחים להרשמה (wait ⇒ רכז מאשר). כל בדיקות-הקדם/התנגשות חלות.
        if (_can('crs.self') && _CourseData.myFamilyId(_role) != null && !_loading) ..._selfCatalog(),
      ]]);
  }

  // מרכז-אוטומציות: חג⇒ביטול · מתחת-מינ׳ · חדר/מורה-חלופי · המתנה-עם-מקום · תזכורות · ביקוש · ניצולת
  List<Widget> _automations(List<Map<String, dynamic>> live) {
    final hl = _CourseData.holidayLessons();
    final rem = _CourseData.reminders();
    final bm = _CourseData.belowMinAlerts;
    final pr = _CourseData.promotable;
    final noRoomCs = live.where(_CourseData.noRoom).toList(), noTeacherCs = live.where(_CourseData.noTeacher).toList();
    final clashRooms = live.where((c) => _CourseData.clashesOf(c).any((k) => k['kind'] == 'room')).toList();
    final demand = _CourseData.demandSignals;
    Widget withAction(Widget banner, Widget? action) => action == null ? banner : Row(children: [Expanded(child: banner), const SizedBox(width: 6), action]);
    return [
      ForgeTitledSection(fields: ['🤖 אוטומציות · ${hl.length + rem.length + bm.length + pr.length + noRoomCs.length + noTeacherCs.length + clashRooms.length + demand.length} אותות', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        // דוח-ניצולת (BareStat×3 — עובדות): חדרים · עומס-מורים · חגים-קרובים
        Row(children: [
          Expanded(child: ForgeStatPlain(fields: ['🚪 ניצולת-חדרים', '${_CourseData.avgRoomUtilPct}%'])),
          Expanded(child: ForgeStatPlain(fields: ['👩‍🏫 מפגשים/מורה/שבוע', _CourseData.avgTeacherLoad.toStringAsFixed(1)])),
          Expanded(child: ForgeStatPlain(fields: ['🕎 חגים ב-45 ימים', '${_CourseData.upcomingHolidayList.length}'])),
        ]),
        _gap(8),
        // סנכרון-לוח: שיעורים על חג ⇒ ביטול-אוטו (+הודעה דרך שלח-הודעה)
        if (hl.isNotEmpty) withAction(
          ForgeSectionPill(items: [['${hl.length} שיעורים נופלים בחג: ${hl.map((h) => '${(h['course'] as Map)['name']} ${h['iso']} (${h['name']})').join(' · ')}']], variants: const <int>[0]),
          _can('crs.cancel') ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _act(() => _CourseData.autoCancelHolidays('אוטומציה'), '${hl.length} שיעורי-חג בוטלו אוטומטית — שלח הודעה למשפחות מהפאנל'), child: ForgeSoftButton(fields: ['✖ בטל-אוטו'])) : null),
        // מתחת-מינימום X ימים לפני/אחרי פתיחה — התרעה כלכלית
        for (final c in bm)
          ForgeSectionPill(items: [['${c['name']}: ${_CourseData.enrolled(c)} רשומים מול מינ׳ ${_CourseData.minToOpen(c)} · ${_CourseData.daysToStart(c) >= 0 ? 'מתחיל בעוד ${_CourseData.daysToStart(c)} ימים' : 'התחיל לפני ${-_CourseData.daysToStart(c)} ימים'} — לא-כלכלי']], variants: const <int>[0]),
        // הצעת-חדר-חלופי: ללא-חדר / התנגשות-חדר ⇒ חדרים פנויים ב-slot
        for (final c in [...noRoomCs, ...clashRooms])
          ForgeSectionPill(items: [['${c['name']} — ${_CourseData.noRoom(c) ? 'ללא-חדר' : 'התנגשות-חדר'} · חדר חלופי: ${_CourseData.freeRooms(c).isEmpty ? 'אין חדר פנוי ב-slot' : _CourseData.freeRooms(c).map((r) => '${r['name']} (${r['cap']})').join(' / ')}']], variants: const <int>[0]),
        // הצעת-מורה-מחליף: ללא-מורה ⇒ מורים פנויים ב-slot (התמחות תואמת קודם)
        for (final c in noTeacherCs)
          ForgeSectionPill(items: [['${c['name']} — ללא-מורה · מורה חלופי: ${_CourseData.freeTeachers(c).isEmpty ? 'אין מורה פנוי ב-slot' : _CourseData.freeTeachers(c).map((t) => '${t['name']}${t['specialty'] == c['cat'] ? ' ✓' : ''}').join(' / ')}']], variants: const <int>[0]),
        // המתנה-עם-מקום ⇒ העלאה
        for (final c in pr) withAction(
          ForgeSectionPill(items: [['${c['name']}: ${_CourseData.waitlist(c).length} ממתינים ויש ${_CourseData.capacity(c) - _CourseData.enrolled(c)} מקומות פנויים']], variants: const <int>[0]),
          _can('crs.waitlist') ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => _act(() { while (_CourseData.promoteNext(c, 'אוטומציה') != null) {} }, 'הממתינים הועלו'), child: ForgeSoftButton(fields: ['⬆ העלה'])) : null),
        // תזכורות 48h
        if (rem.isNotEmpty) ForgeSectionPill(items: [['תזכורת ל-48 השעות הקרובות: ${rem.map((r) => '${(r['course'] as Map)['name']} ${_CourseData._iso(r['dt'] as DateTime)} ${_CourseData.hm((r['dt'] as DateTime).hour * 60 + (r['dt'] as DateTime).minute)} (${_CourseData.liveEnrollmentsOf(r['course'] as Map<String, dynamic>).length} משפחות)').join(' · ')} — שלח-הודעה מהפאנל']], variants: const <int>[0]),
        // תחזית-ביקוש (אות-נוכחי; היסטוריה רב-סמסטרית = מקום-שמור)
        if (demand.isNotEmpty) ForgeSectionPill(items: [['ביקוש לסמסטר-הבא: ${demand.map((c) => '${c['name']} (${_CourseData.isFull(c) ? 'מלא' : ''}${_CourseData.waitlist(c).isNotEmpty ? ' +${_CourseData.waitlist(c).length} ממתינים' : ''}${_CourseData.trend(c)['dir'] == 'up' ? ' ↑' : ''})').join(' · ')} ⇒ שקול קבוצה נוספת']], variants: const <int>[0]),
        if (hl.isEmpty && bm.isEmpty && pr.isEmpty && noRoomCs.isEmpty && noTeacherCs.isEmpty && clashRooms.isEmpty && rem.isEmpty && demand.isEmpty)
          ForgeSearchEmptyState(fields: ['אין אותות — המערכת מסודרת', '']),
      ]])),
    ];
  }

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה)
  void _refresh() {
    setState(() { _loading = true; _error = null; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _loading = false); });
  }
  // מצב-טעינה שמור: מחוון + טקסט (אטום-מסגרת סטנדרטי; אפס ShimmerSkeleton מזייף). Column-מרוכז, לא Center (גובה-לא-חסום ברשימה).
  Widget _loadingView() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc),
          const SizedBox(height: 14),
          const Text('טוען מערכת…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );

  // קטלוג להרשמה-עצמית (הורה): חוגים-חיים שאין בהם חבר-משפחה · כפתור פר-תלמיד ⇒ selfEnroll (wait)
  List<Widget> _selfCatalog() {
    final fam = _CourseData.families.where((f) => f['id'] == _CourseData.myFamilyId(_role)).firstOrNull;
    if (fam == null) return const [];
    final mine = _CourseData.familyCourses(_CourseData.liveCourses, fam['id'] as String).map((c) => c['id']).toSet();
    final open = _CourseData.bySemester(_CourseData.liveCourses, _sem).where((c) => !mine.contains(c['id'])).toList();
    return [
      ForgeTitledSection(fields: ['🛒 הרשמה-עצמית · ${open.length} חוגים פתוחים (רכז/ת מאשר/ת)', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[
        if (open.isEmpty) ForgeSearchEmptyState(fields: ['אין חוגים נוספים להרשמה', '']),
        for (final c in open)
          Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
            Expanded(child: ForgeContactTile(fields: ['${c['name']}', '${_CourseData.sessionsLabel(c)} · ${_CourseData.enrolled(c)}/${_CourseData.capacity(c)} · שכבות ${c['gradeMin']}–${c['gradeMax']}'])),
            for (final m in (fam['members'] as List))
              Padding(padding: const EdgeInsets.only(left: 4), child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => setState(() => _result(_CourseData.selfEnroll(c, m['id'], _who), 'נרשם/ה — ממתין לאישור')), child: ForgeSoftButton(fields: ['➕ ${m['first']}']))),
          ])),
      ]])),
    ];
  }

  // 📅 גריד-מערכת-שעות: Table (ימים×שעות) · תא = StatusChip-לחיץ פר-חוג (tone=דחיפות) · מבוטל=✖ · ריק=שקט
  Widget _grid(List<Map<String, dynamic>> cs) {
    final hours = _CourseData.gridHours(cs);
    if (hours.isEmpty) return ForgeSearchEmptyState(fields: ['אין מפגשים משובצים', '']);
    const days = [0, 1, 2, 3, 4, 5];
    TableRow row(List<Widget> cells) => TableRow(children: [for (final w in cells) Padding(padding: const EdgeInsets.all(3), child: w)]);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const FixedColumnWidth(150),
        columnWidths: const {0: FixedColumnWidth(56)},
        border: TableBorder.all(color: DsTokens.line, width: 1),
        defaultVerticalAlignment: TableCellVerticalAlignment.top,
        children: [
          row([
            const SizedBox.shrink(),
            for (final dd in days) Center(child: Text('${dayNames[dd]}\n${_CourseData.isoOfDay(dd, _week).substring(5)}', textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800))),
          ]),
          for (final h in hours)
            row([
              Center(child: Text(_CourseData.hm(h), style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700))),
              for (final dd in days)
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final c in _CourseData.inCell(cs, dd, h)) _cell(c, _CourseData.isoOfDay(dd, _week)),
                ]),
            ]),
        ],
      ),
    );
  }

  Widget _cell(Map<String, dynamic> c, String iso) {
    final cancelled = _CourseData.isCancelled(c, iso);
    final sev = _CourseData.sev(c);
    final tone = cancelled ? 0 : sev >= 2 ? 2 : sev == 1 || _CourseData.isFull(c) ? 3 : 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: () => _openPanel(c),
        // FittedBox(scaleDown): שם-חוג ארוך מתכווץ לרוחב-התא במקום לגלוש (הרנדר תפס גלישה ב-112px)
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: ForgeStatusChip(items: [['${cancelled ? '✖ ' : ''}${c['name']} ${_CourseData.enrolled(c)}/${_CourseData.capacity(c)}']], variants: [const <int>[0, 1, 3, 2][(tone) % 4]]),
        ),
      ),
    );
  }

  // 📋 מבט-רשימה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid.
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _CourseData.columnDefs) if (_CourseData.colShown(c, rows)) c];
    return ForgeDataGrid(bare: true, columns: [for (final c in cols) c['label'] as String], items: [
        for (final r in rows)
          [
            for (final c in cols)
              if (c['key'] == '__status')
                _CourseData.statusLabel(r)
              else if (c['get'] != null)
                (c['get'] as String Function(Map<String, dynamic>))(r)
              else
                '${r[c['key']] ?? '—'}',
          ],
      ]);
  }

  // 👩‍🏫 פר-מורה: coursesOfTeacher (מנוע) ⊕ עומס = מפגשים/שבוע (BareStat) · סקשן "ללא-מורה" בנפרד (חריגה)
  List<Widget> _byTeacher(List<Map<String, dynamic>> live) {
    final orphan = live.where(_CourseData.noTeacher).toList();
    return [
      for (final t in _CourseData.teachers)
        () {
          final cs = live.where((c) => c['teacherId'] == t['id']).toList(); // הרשימה-הנראית (אחרי איתור+חריגה); coursesOfTeacher = אותו מנוע על כל-החיים
          return ForgeTitledSection(fields: ['👩‍🏫 ${t['name']} · ${t['specialty']}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Align(alignment: Alignment.centerLeft, child: ForgeStatusChip(items: [['${cs.length} חוגים · ${_CourseData.weeklyOf(cs)} מפגשים/שבוע']], variants: [const <int>[0, 1, 3, 2][(cs.isEmpty ? 0 : 1) % 4]])), ...cs.isEmpty ? [ForgeSearchEmptyState(fields: ['אין חוגים למורה זה', ''])] : [for (final c in cs) _row(c)]]));
        }(),
      if (orphan.isNotEmpty) ForgeTitledSection(fields: ['🚫 ללא-מורה · ${orphan.length}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [...[for (final c in orphan) _row(c)]])),
    ];
  }

  // 🚪 פר-חדר: weeklyRoomSessions (מנוע) ⊕ קיבולת-משבצות ⇒ ניצולת (StatRow) · חדר-לא-פעיל = חריגה
  List<Widget> _byRoom(List<Map<String, dynamic>> live) => [
        for (final r in _CourseData.rooms)
          () {
            final cs = live.where((c) => c['roomId'] == r['id']).toList(); // הרשימה-הנראית (אחרי איתור+חריגה)
            final active = r['active'] == true;
            final weekly = _CourseData.roomWeekly(r), cap = _CourseData.roomSlotsPerWeek(r);
            return ForgeTitledSection(fields: ['🚪 ${r['name']} · ${r['location']} · קיבולת ${r['cap']}', '', '', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Align(alignment: Alignment.centerLeft, child: ForgeStatusChip(items: [[active ? '${r['from']}–${r['to']} · ${r['slot']} דק׳' : 'לא-פעיל']], variants: [const <int>[0, 1, 3, 2][(active ? 0 : 2) % 4]])), ...[
                ForgeLinearProgressStatus(fields: ['ניצולת שבועית', '$weekly מתוך $cap משבצות'], values: [_CourseData.roomUtil(r)]),
                _gap(6),
                if (cs.isEmpty) ForgeSearchEmptyState(fields: ['אין חוגים בחדר', '']) else for (final c in cs) _row(c),
              ]]));
          }(),
      ];

  // צ׳יפ-סינון מבוקר: הזרקת-צבעים (חוק-6) + נעילת-ציר (tap שוב = שחרור). value=''=ציר-ללא-נעילה ("הכל")
  Widget _fchip(String axis, String value, String label) {
    final sel = (_locks[axis] ?? '') == value;
    return FilterChipPill(
      label: label, selected: sel,
      onTap: () => setState(() { if (value.isEmpty || sel) { _locks.remove(axis); } else { _locks[axis] = value; } }),
      activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15), inkColor: _ink,
      outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
    );
  }

  Widget _row(Map<String, dynamic> c) {
    final t = _CourseData.teacherOf(c), r = _CourseData.roomOf(c);
    final sev = _CourseData.sev(c);
    final tone = sev >= 2 ? 2 : sev == 1 ? 3 : _CourseData.isFull(c) ? 3 : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: ForgeContactTile(fields: ['${c['name']}', '${t?['name'] ?? '—'} · ${r?['name'] ?? '—'} · ${_CourseData.sessionsLabel(c)} · ${_CourseData.enrolled(c)}/${_CourseData.capacity(c)}'])),
        Flexible(child: ForgeStatusChip(items: [[_CourseData.statusLabel(c)]], variants: [const <int>[0, 1, 3, 2][(tone) % 4]])),
        if (_CourseData.waitlist(c).isNotEmpty) ...[const SizedBox(width: 6), ForgeStatusChip(items: [['⏳ ${_CourseData.waitlist(c).length}']], variants: const <int>[0])],
        // MediaRow בולע את הקליק (InkWell פנימי no-op) ⇒ כפתור-שברון נפרד כשקע-הבחירה
        IconButton(onPressed: () => _openPanel(c), icon: const Icon(Icons.chevron_left, color: _acc, size: 24), tooltip: 'פרטים ופעולות'),
      ]),
    );
  }

  void _flash(String m, int tone) => setState(() { _msg = m; _msgTone = tone; });
  void _act(void Function() f, String ok) { f(); _flash(ok, 1); }
  // תוצאת-מנוע ⇒ הודעה+tone (blocked=אדום · wait=כתום · אחרת ירוק)
  void _result(String r, String okMsg) {
    if (r.startsWith('blocked:')) return _flash('נחסם: ${r.substring(8)}', 2);
    if (r == 'waitlisted') return _flash('החוג מלא ⇒ נוסף לרשימת-ההמתנה', 3);
    if (r == 'pending') return _flash('ההרשמה נרשמה כבקשה — ממתינה לאישור רכז/ת (המתנה)', 3);
    if (r.startsWith('removed+promoted:')) return _flash('הוסר · מקום התפנה ⇒ ${r.substring(17)} הועלה/תה מההמתנה אוטומטית', 1);
    _flash(okMsg, 1);
  }

  // ═══ פאנל חוג-נבחר · GlassCard(child) בגיליון-תחתון · 9 טאבים (SegmentedSwitch) · פעולות (SoftButton) ═══
  void _openPanel(Map<String, dynamic> c0) {
    _tab = 0; _pick = null; _edit = false;
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void both(void Function() f) { f(); setSheet(() {}); setState(() {}); }
        final c = _CourseData.courseById(c0['id']) ?? c0; // מצב-חי (אחרי overrides)
        return DraggableScrollableSheet(
          initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.96, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                  Row(children: [
                    Expanded(child: ForgeContactTile(fields: ['${c['name']}', '${_CourseData.teacherOf(c)?['name'] ?? 'ללא-מורה'} · ${_CourseData.roomOf(c)?['name'] ?? 'ללא-חדר'} · ${_CourseData.sessionsLabel(c)}'])),
                    Flexible(child: ForgeStatusChip(items: [[_CourseData.statusLabel(c)]], variants: [const <int>[0, 1, 3, 2][(_CourseData.sev(c) >= 2 ? 2 : _CourseData.sev(c) == 1 ? 3 : 1) % 4]])),
                  ]),
                  _gap(8),
                  // 9 טאבים בשתי שורות-SegmentedSwitch (שורה-אחת גלשה מ-800px ⇒ טאב לא-נגיש · הרנדר תפס)
                  Wrap(spacing: 8, runSpacing: 6, alignment: WrapAlignment.end, children: [
                    FittedBox(fit: BoxFit.scaleDown, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['סקירה', 'נרשמים', 'המתנה', 'מערכת', 'נוכחות']) [s]], selected: {_tab < 5 ? _tab : -1}, onSelect: (i) => both(() { _tab = i; _pick = null; }))),
                    FittedBox(fit: BoxFit.scaleDown, child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['גבייה', 'חומרים', 'היסטוריה', 'אודיט']) [s]], selected: {_tab >= 5 ? _tab - 5 : -1}, onSelect: (i) => both(() { _tab = i + 5; _pick = null; }))),
                  ]),
                  _gap(10),
                  if (_msg != null) ...[ForgeSectionPill(items: [[_msg!]], variants: [const <int>[0, 0, 0, 0][(_msgTone) % 4]]), _gap(8)],
                  ...switch (_tab) {
                    1 => _tabEnrolled(c, both),
                    2 => _tabWaitlist(c, both),
                    3 => _tabSchedule(c, both),
                    4 => _tabAttendance(c),
                    5 => _tabFees(c),
                    6 => _tabMaterials(c),
                    7 => _tabHistory(c, false),
                    8 => _tabHistory(c, true),
                    _ => _tabOverview(c, both),
                  },
                ])),
            ),
          ),
        );
      }),
    ).whenComplete(() => setState(() => _msg = null));
  }

  Widget _h(String t) => Padding(padding: const EdgeInsets.only(top: 6, bottom: 6), child: Text(t, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)));

  // ── סקירה: תפוסה-מול-קיבולת (StatRow) · עובדות (BareStat/StatusChip) · התנגשויות (AlertBanner אדום) · שיעורים-הבאים · פעולות ──
  List<Widget> _tabOverview(Map<String, dynamic> c, void Function(void Function()) both) {
    final clashes = _CourseData.clashesOf(c);
    final next = _CourseData.upcoming(c, 3);
    return [
      ForgeLinearProgressStatus(fields: ['תפוסה מול קיבולת', '${_CourseData.enrolled(c)} מתוך ${_CourseData.capacity(c)}'], values: [_CourseData.occupancy(c)]),
      _gap(8),
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['רשומים', '${_CourseData.enrolled(c)}'])),
        Expanded(child: ForgeStatPlain(fields: ['בהמתנה', '${_CourseData.waitlist(c).length}'])),
        Expanded(child: ForgeStatPlain(fields: ['מינ׳-לפתיחה', _CourseData.minToOpen(c) == null ? '—' : '${_CourseData.minToOpen(c)}'])),
        Expanded(child: ForgeStatPlain(fields: ['מחיר', c['perLesson'] == true ? '${shekel(c['lessonPrice'])}/ש׳' : shekel(c['price'])])),
        Expanded(child: ForgeStatPlain(fields: ['מגמת-הרשמה', _CourseData.trendLabel(c)])),
      ]),
      _gap(6),
      ForgeContactTile(fields: [_CourseData.roomOf(c)?['name'] ?? 'ללא-חדר', _CourseData.roomLabel(c)]), // roomInfoLabel (מנוע) — טקסט-ארוך ⇒ שורה, לא שבב
      Wrap(spacing: 8, runSpacing: 6, children: [
        if (_CourseData.roomlessReason(c) != null) _chip('⚠️ ${_CourseData.roomlessReason(c)}', 2),
        if (_CourseData.noTeacher(c)) _chip('🚫 ללא-מורה — הקצה מורה', 2),
        ..._facts(c),
      ]),
      if (clashes.isNotEmpty) ...[
        _h('⚠️ התנגשויות · ${clashes.length} (חוסמות-שיבוץ)'),
        for (final k in clashes) ForgeSectionPill(items: [['${k['detail']} — ${k['with']}']], variants: const <int>[0]),
      ],
      if (_CourseData.noRoom(c) || _CourseData.clashesOf(c).any((k) => k['kind'] == 'room')) ...[
        _h('🚪 חדרים פנויים ב-slot (הצעת-חדר-חלופי)'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (_CourseData.freeRooms(c).isEmpty) ForgeStatusChip(items: [['אין חדר פנוי']], variants: const <int>[3]),
          for (final r in _CourseData.freeRooms(c))
            if (_can('crs.assignRoom')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _result(_CourseData.assignRoom(c, r['id'], _who), '${r['name']} הוקצה')), child: ForgeSoftButton(fields: ['🚪 ${r['name']} (${r['cap']})'])) else _chip('🚪 ${r['name']}', 0),
        ]),
      ],
      if (_CourseData.noTeacher(c) || _CourseData.clashesOf(c).any((k) => k['kind'] == 'teacher')) ...[
        _h('👩‍🏫 מורים פנויים ב-slot (הצעת-מורה-חלופי · ✓ התמחות תואמת)'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (_CourseData.freeTeachers(c).isEmpty) ForgeStatusChip(items: [['אין מורה פנוי']], variants: const <int>[3]),
          for (final t in _CourseData.freeTeachers(c))
            if (_can('crs.assignTeacher')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _result(_CourseData.assignTeacher(c, t['id'], _who), '${t['name']} הוקצה/תה')), child: ForgeSoftButton(fields: ['${t['name']}${t['specialty'] == c['cat'] ? ' ✓' : ''}'])) else _chip('${t['name']}', 0),
        ]),
      ],
      if (_CourseData.belowMin(c)) ForgeSectionPill(items: [['מתחת-למינימום: ${_CourseData.enrolled(c)} רשומים מול ${_CourseData.minToOpen(c)} (${c['minStudents'] == null ? 'נקודת-איזון: שכר-מורה+חדר ÷ מחיר-לשיעור' : 'מינימום-מוגדר'}) — לא-כלכלי']], variants: const <int>[0]),
      _h('📅 השיעורים הבאים'),
      if (next.isEmpty) ForgeSearchEmptyState(fields: ['אין מפגשים משובצים', '']) else for (final dt in next) _lessonTile(c, dt, both),
      _h('פעולות · ${_CourseData.roleDefs[_role]['label']}'),
      // פעולות מגודרות פר-הרשאה (canGrantedAction); אין-הרשאה ⇒ מצב נעילת-הרשאות (AlertBanner)
      Builder(builder: (_) {
        final acts = <Widget>[
          if (_can('crs.enroll')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'enroll' ? null : 'enroll'), child: ForgeSoftButton(fields: ['🎓 שבץ-תלמיד'])),
          if (_can('crs.waitlist')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'invite' ? null : 'invite'), child: ForgeSoftButton(fields: ['⏳ הזמן-להמתנה'])),
          if (_can('crs.assignTeacher')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'teacher' ? null : 'teacher'), child: ForgeSoftButton(fields: ['👩‍🏫 הקצה-מורה'])),
          if (_can('crs.assignTeacher')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'sub' ? null : 'sub'), child: ForgeSoftButton(fields: ['🔄 מורה-מחליף (חד-פעמי)'])),
          if (_can('crs.assignRoom')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'room' ? null : 'room'), child: ForgeSoftButton(fields: ['🚪 הקצה-חדר'])),
          if (_can('crs.edit')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _edit = !_edit), child: ForgeSoftButton(fields: ['✏️ ערוך'])),
          if (_can('crs.duplicate')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { final cp = _CourseData.duplicate(c, _who); _flash('נוצר ${cp['name']} — יורש slot ⇒ בדוק התנגשות והקצה מחדש', 3); }), child: ForgeSoftButton(fields: ['📄 שכפל-חוג'])),
          if (_can('crs.message')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'message' ? null : 'message'), child: ForgeSoftButton(fields: ['💬 שלח-הודעה'])),
          if (_can('crs.end')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _CourseData.endCourse(c, _who); _flash('${c['name']} הסתיים — ההרשמות נסגרו', 3); }), child: ForgeSoftButton(fields: ['🏁 סיים-חוג'])),
          if (_can('crs.end')) GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _CourseData.cancelCourse(c, _who); _flash('${c['name']} בוטל', 3); }), child: ForgeSoftButton(fields: ['⛔ בטל-חוג'])),
        ];
        return acts.isEmpty
            ? ForgeSectionPill(items: [['צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה']], variants: const <int>[0])
            : Wrap(spacing: 8, runSpacing: 8, children: acts);
      }),
      _gap(8),
      ..._picker(c, both),
      if (_edit) ...[
        _h('✏️ עריכה (שם · קיבולת — הגדלת-קיבולת מעלה מהמתנה אוטומטית)'),
        ForgeDsField(state: ('${c['name']}').toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: ['שם-חוג', ''], control: DsField(label: 'שם-חוג', hint: 'שם', value: '${c['name']}', onChanged: (v) => both(() => _CourseData.edit(c, 'name', v, _who)), bare: true)),
        ForgeDsNumberField(fields: ['קיבולת (maxStudents)'], control: DsNumberField(label: 'קיבולת (maxStudents)', value: '${_CourseData.capacity(c)}', onChanged: (v) { final n = int.tryParse(v); if (n != null) both(() => _CourseData.edit(c, 'maxStudents', n, _who)); }, bare: true)),
      ],
    ];
  }

  // בוררים (Wrap של SoftButton פר-מועמד) — כל בחירה עוברת דרך מנועי-הבדיקה
  List<Widget> _picker(Map<String, dynamic> c, void Function(void Function()) both) {
    final p = _pick;
    if (p == null) return const [];
    if (p == 'enroll' || p == 'invite') {
      final cands = _CourseData.candidates(c);
      return [
        _h(p == 'enroll' ? '🎓 בחר תלמיד לשיבוץ (קדם ⊕ התנגשות ⊕ קיבולת נבדקים)' : '⏳ בחר תלמיד להזמנה-להמתנה'),
        if (cands.isEmpty) ForgeSearchEmptyState(fields: ['כל התלמידים כבר רשומים/ממתינים', ''])
        else Wrap(spacing: 6, runSpacing: 6, children: [
          for (final m in cands)
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _pick = null; _result(p == 'enroll' ? _CourseData.enroll(c, m['id'], _who) : _CourseData.invite(c, m['id'], _who), '${m['first']} שובץ/ה ל-${c['name']}'); }), child: ForgeSoftButton(fields: ['${m['first']} ${m['famName']} · ${m['grade']}'])),
        ]),
      ];
    }
    if (p == 'teacher' || p == 'sub') {
      final iso = _CourseData.upcoming(c, 1).isEmpty ? _CourseData.today : _CourseData._iso(_CourseData.upcoming(c, 1).first);
      return [
        _h(p == 'teacher' ? '👩‍🏫 בחר מורה (התנגשות חוסמת)' : '🔄 מורה-מחליף לשיעור $iso'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final t in _CourseData.teachers)
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _pick = null; if (p == 'teacher') { _result(_CourseData.assignTeacher(c, t['id'], _who), '${t['name']} הוקצה/תה ל-${c['name']}'); } else { _CourseData.substitute(c, iso, t['id'], _who); _flash('${t['name']} מחליף/ה ב-$iso', 1); } }), child: ForgeSoftButton(fields: ['${t['name']} · ${t['specialty']}'])),
        ]),
      ];
    }
    if (p == 'room') {
      return [
        _h('🚪 בחר חדר (תפוס באותו slot ⇒ נחסם)'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final r in _CourseData.rooms.where((r) => r['active'] == true))
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _pick = null; _result(_CourseData.assignRoom(c, r['id'], _who), '${r['name']} הוקצה ל-${c['name']}'); }), child: ForgeSoftButton(fields: ['${r['name']} · ${r['cap']} · ${r['slot']} דק׳'])),
        ]),
      ];
    }
    if (p == 'message') {
      final links = _CourseData.waLinks(c, 'שלום, הודעה מחוג ${c['name']}: ');
      return [
        _h('💬 קישורי-WhatsApp למשפחות הנרשמים (waLink)'),
        if (links.isEmpty) ForgeSearchEmptyState(fields: ['אין נרשמים-חיים', '']) else for (final l in links) ForgeContactTile(fields: [l['name']!, l['href']!]),
      ];
    }
    if (p.startsWith('move:')) {
      final e = _CourseData.enrollmentById(p.substring(5));
      if (e == null) return const [];
      return [
        _h('🔁 העבר את ${_CourseData.memberName(e['memberId'])} אל…'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final t in _CourseData.liveCourses.where((t) => t['id'] != c['id']))
            GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _pick = null; _result(_CourseData.move(e, t, _who), 'הועבר/ה ל-${t['name']}'); }), child: ForgeSoftButton(fields: ['${t['name']} ${_CourseData.enrolled(t)}/${_CourseData.capacity(t)}'])),
        ]),
      ];
    }
    return const [];
  }

  // שיעור-בודד (TimelineItem): תאריך · מורה (מחליף?) · חדר · מבוטל? + בטל/שחזר
  Widget _lessonTile(Map<String, dynamic> c, DateTime dt, void Function(void Function()) both) {
    final iso = _CourseData._iso(dt);
    final cancelled = _CourseData.isCancelled(c, iso);
    final sub = _CourseData.substitutes['${c['id']}|$iso'];
    final subName = sub == null ? null : _CourseData.teachers.where((t) => t['id'] == sub).firstOrNull?['name'];
    return Row(children: [
      Expanded(child: ForgeNotifRow(items: [['${cancelled ? '✖ מבוטל · ' : ''}${dayNames[dt.weekday % 7]} ${_CourseData.hm(dt.hour * 60 + dt.minute)}${_CourseData.holidayName(dt) != null ? ' · 🕎 ${_CourseData.holidayName(dt)}' : ''}', iso]])),
      if (_can('crs.cancel')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() { _CourseData.cancelSession(c, iso, _who); _flash(cancelled ? 'השיעור $iso שוחזר' : 'השיעור $iso בוטל', cancelled ? 1 : 3); }), child: ForgeSoftButton(fields: [cancelled ? '↩ שחזר' : '✖ בטל']))),
    ]);
  }

  // ── נרשמים: שם · סטטוס (enrollStatusMeta) · תשלום (enrollmentPaidStatus) · חוב (payBal) · הסר/העבר ──
  List<Widget> _tabEnrolled(Map<String, dynamic> c, void Function(void Function()) both) {
    final es = _CourseData.liveEnrollmentsOf(c);
    return [
      _h('🎓 נרשמים · ${es.length} מתוך ${_CourseData.capacity(c)}'),
      if (es.isEmpty) ForgeSearchEmptyState(fields: ['אין נרשמים — שבץ תלמיד מהסקירה', '']),
      for (final e in es) ...[
        Row(children: [
          Expanded(child: ForgeContactTile(fields: [_CourseData.memberName(e['memberId']), '${_CourseData.enrollStatusLabel(e)} · ${_CourseData.paidLabel(e)}${_CourseData.debtOf(e) > 0 ? ' · חוב ${shekel(_CourseData.debtOf(e).toInt())}' : ''} · נרשם/ה ${e['enrolledAt']}'])),
          if (_can('crs.move')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'move:${e['id']}' ? null : 'move:${e['id']}'), child: ForgeSoftButton(fields: ['🔁']))),
          const SizedBox(width: 4),
          if (_can('crs.remove')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _result(_CourseData.remove(e, _who), '${_CourseData.memberName(e['memberId'])} הוסר/ה')), child: ForgeSoftButton(fields: ['➖ הסר']))),
        ]),
        // המקום-השמור של ההרשמה (חוק-7): tier/group/renew (אמת) · scholarship (מקום-שמור) — לולאה גנרית מעל enrollMetaFields
        Wrap(spacing: 6, runSpacing: 4, children: [
          for (final f in _CourseData.enrollMetaFields)
            if (e[f['key']] != null && '${e[f['key']]}'.trim().isNotEmpty) _chip('${f['prefix']}${e[f['key']]}${f['suffix']}', 0),
        ]),
        if (_pick == 'move:${e['id']}') ..._picker(c, both),
      ],
    ];
  }

  // ── המתנה: סדר-אמת (waitlistFor לפי enrolledAt) · העלה (נחסם כשמלא) · הזמן-להמתנה ──
  List<Widget> _tabWaitlist(Map<String, dynamic> c, void Function(void Function()) both) {
    final w = _CourseData.waitlist(c);
    return [
      Row(children: [
        Expanded(child: _h('⏳ רשימת-המתנה · ${w.length} · ${_CourseData.isFull(c) ? 'החוג מלא' : '${_CourseData.capacity(c) - _CourseData.enrolled(c)} מקומות פנויים'}')),
        if (_can('crs.waitlist')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _pick = _pick == 'invite' ? null : 'invite'), child: ForgeSoftButton(fields: ['⏳ הזמן-להמתנה']))),
      ]),
      ..._picker(c, both),
      if (w.isEmpty) ForgeSearchEmptyState(fields: ['אין ממתינים', '']),
      for (var i = 0; i < w.length; i++)
        Row(children: [
          Expanded(child: ForgeContactTile(fields: [_CourseData.memberName(w[i]['memberId']), 'ממתין/ה מ-${w[i]['enrolledAt']}${_CourseData.clashReason(c, w[i]['memberId']) != null ? ' · ⚠️ התנגשות' : ''}'])),
          if (_can('crs.waitlist')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _result(_CourseData.promote(w[i], _who), '${_CourseData.memberName(w[i]['memberId'])} הועלה/תה מההמתנה')), child: ForgeSoftButton(fields: ['⬆ העלה']))),
          const SizedBox(width: 4),
          if (_can('crs.waitlist')) Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () => both(() => _result(_CourseData.remove(w[i], _who), 'הוסר/ה מההמתנה')), child: ForgeSoftButton(fields: ['➖']))),
        ]),
      _gap(6),
      Row(children: [
        Expanded(child: Text('העלאה-אוטומטית כשמתפנה מקום', style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w700))),
        Flexible(child: ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['פועל', 'כבוי']) [s]], selected: {_CourseData.autoPromote ? 0 : 1}, onSelect: (i) => both(() => _CourseData.autoPromote = i == 0))),
      ]),
    ];
  }

  // ── מערכת: המפגשים-הקבועים (TimelineItem) + 6 השיעורים-הבאים עם בטל/שחזר ──
  List<Widget> _tabSchedule(Map<String, dynamic> c, void Function(void Function()) both) {
    final ss = sessionsOf(c) as List;
    final next = _CourseData.upcoming(c, 6);
    return [
      _h('🗓 מפגשים קבועים · ${ss.length}/שבוע · ${c['start']}–${c['end']}'),
      if (!_CourseData.hasSessions(c)) ForgeSearchEmptyState(fields: ['אין מפגשים קבועים — הגדר יום+שעה (מקום-שמור: עורך-מפגשים)', '']),
      for (final s in ss) if (s['day'] is int) ForgeNotifRow(items: [['${dayNames[s['day'] as int]} ${s['time']}', '${(s['label'] ?? '') == '' ? 'קבוצה יחידה' : s['label']}']]),
      _h('📅 השיעורים הבאים · ${next.length}'),
      if (next.isEmpty) ForgeSearchEmptyState(fields: ['אין מפגשים משובצים', '']) else for (final dt in next) _lessonTile(c, dt, both),
    ];
  }

  // ── נוכחות: שיעור-נוכחות של החוג (StatRow) + פר-נרשם (enrollSummary: נוכחויות/חיסורים/noshow/אחרון · presentsInMonth) ──
  List<Widget> _tabAttendance(Map<String, dynamic> c) {
    final es = _CourseData.liveEnrollmentsOf(c);
    final rate = _CourseData.attendanceRate(c);
    return [
      ForgeLinearProgressStatus(fields: ['נוכחות-החוג (נוכח ÷ (נוכח+נעדר))', '${(rate * 100).round()}%'], values: [rate]),
      _gap(8),
      if (es.isEmpty) ForgeSearchEmptyState(fields: ['אין נרשמים', '']),
      for (final e in es)
        () {
          final sm = _CourseData.summary(e);
          final tot = (sm['presents'] as int) + (sm['absences'] as int);
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            ForgeLinearProgressStatus(fields: [_CourseData.memberName(e['memberId']), '${sm['presents']}/$tot · החודש ${_CourseData.presentsThisMonth(e)}'], values: [tot == 0 ? 0 : (sm['presents'] as int) / tot]),
            Padding(padding: const EdgeInsets.only(top: 4, bottom: 8), child: Wrap(spacing: 6, children: [
              if ((sm['noshow'] as int) > 0) _chip('👻 noshow ${sm['noshow']}', 2),
              if ('${sm['lastPresent']}'.isNotEmpty) _chip('🕐 אחרון ${sm['lastPresent']}', 0),
              _chip('${sm['statusLabel']}', 0),
            ])),
          ]);
        }(),
    ];
  }

  // ── גבייה-פר-חוג: נגבה/צפוי/חוב (BareStat) · StatRow · פר-נרשם paid/partial/unpaid ──
  List<Widget> _tabFees(Map<String, dynamic> c) {
    final es = _CourseData.liveEnrollmentsOf(c);
    final exp = _CourseData.courseExpected(c), col = _CourseData.courseCollected(c), debt = _CourseData.courseDebt(c);
    return [
      Row(children: [
        Expanded(child: ForgeStatPlain(fields: ['צפוי (Σ totalDue)', shekel(exp.toInt())])),
        Expanded(child: ForgeStatPlain(fields: ['נגבה (Σ payments)', shekel(col.toInt())])),
        Expanded(child: ForgeStatPlain(fields: ['חוב-פתוח', shekel(debt.toInt())])),
      ]),
      _gap(8),
      ForgeLinearProgressStatus(fields: ['גבייה מול צפוי', exp == 0 ? '—' : '${(col / exp * 100).clamp(0, 100).round()}%'], values: [exp == 0 ? 0 : (col / exp).clamp(0.0, 1.0)]),
      _gap(8),
      for (final e in es)
        ForgeContactTile(fields: [_CourseData.memberName(e['memberId']), '${_CourseData.paidLabel(e)} · שולם ${shekel(paidOf(e).toInt())} מתוך ${shekel(((e['totalDue'] as num?) ?? 0).toInt())}${_CourseData.debtOf(e) > 0 ? ' · חוב ${shekel(_CourseData.debtOf(e).toInt())}' : ''}${'${e['dueDate'] ?? ''}'.isNotEmpty ? ' · לתשלום עד ${e['dueDate']}' : ''}']),
    ];
  }

  // ── חומרים: CourseFile[] (שדה-אמת) · סילבוס/הקלטות/ציונים = מקום-שמור (מאירים כשיגיע נתון) ──
  List<Widget> _tabMaterials(Map<String, dynamic> c) {
    final files = (c['files'] as List?) ?? const [];
    return [
      _h('📎 חומרי-לימוד · ${files.length}'),
      if (files.isEmpty) ForgeSearchEmptyState(fields: ['אין חומרים מצורפים', '']),
      for (final f in files) ForgeContactTile(fields: ['${f['name']}', '${f['kind']}${f['size'] != null ? ' · ${f['size']} B' : ''}']),
      for (final ph in const [['syllabus', '📘 סילבוס'], ['recordings', '🎥 הקלטות'], ['grades', '🏅 ציונים-פר-חוג']])
        if (c[ph[0]] != null) ForgeContactTile(fields: [ph[1], '${c[ph[0]]}']),
    ];
  }

  // ── היסטוריה (פר-חוג) / אודיט (כל המסך) — רשומות בצורת AuditEntry {at, who, act, what} ⇒ TimelineItem ──
  List<Widget> _tabHistory(Map<String, dynamic> c, bool all) {
    final rows = all ? _CourseData.history : _CourseData.history.where((h) => h['courseId'] == c['id']).toList();
    return [
      _h(all ? '🧾 אודיט · ${rows.length} פעולות במסך' : '🕓 היסטוריה · ${rows.length}'),
      if (rows.isEmpty) ForgeSearchEmptyState(fields: [all ? 'אין פעולות עדיין' : 'אין היסטוריה לחוג', '']),
      for (final h in rows) ForgeNotifRow(items: [['${h['act']} · ${h['who']}', '${h['at']}']]),
    ];
  }

  // המקום-השמור (חוק-7): לולאה גנרית מעל metaFields — שדה קיים ⇒ שבב; חסר ⇒ שקט
  List<Widget> _facts(Map<String, dynamic> c) => [
        for (final f in _CourseData.metaFields)
          if (c[f['key']] != null && '${c[f['key']]}'.trim().isNotEmpty) _chip('${f['prefix']}${c[f['key']]}${f['suffix']}', 0),
      ];
  // שבב-עובדה בטוח-לרוחב: טקסט ארוך מתכווץ (FittedBox) במקום לגלוש — StatusChip לבדו אינו עוטף
  Widget _chip(String label, int tone) => FittedBox(fit: BoxFit.scaleDown, alignment: AlignmentDirectional.centerStart, child: ForgeStatusChip(items: [[label]], variants: [const <int>[0, 1, 3, 2][(tone) % 4]]));

  // ⬇ ייצוא (23-ג): CSV (toCsv⊕csvEscape) · iCal (icsEscape) · PDF = מקום-שמור (שער-פלטפורמה) — תצוגה-מקדימה בסנדבוקס
  void _openExport(List<Map<String, dynamic>> cs) {
    var fmt = 0;
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        final text = fmt == 0 ? _CourseData.csvOf(cs) : fmt == 1 ? _CourseData.icsOf(cs) : '';
        return DraggableScrollableSheet(
          initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: Directionality(textDirection: TextDirection.rtl, child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                ForgeContactTile(fields: ['ייצוא', '${cs.length} חוגים · ${_CourseData.csvRows(cs).first.length} עמודות · שער-ייצוא פתוח']),
                _gap(8),
                ForgeSegmentedPillToggleSelection(bare: true, items: [for (final s in const ['CSV', 'iCal', 'PDF']) [s]], selected: {fmt}, onSelect: (i) => setSheet(() => fmt = i)),
                _gap(10),
                if (fmt == 2)
                  ForgeSectionPill(items: [['PDF — מקום-שמור: דורש שער-פלטפורמה (מנוע-PDF/הדפסה). השורות מוכנות ב-🖨 הדפס-מערכת; ההורדה תואר כשהשער יחובר.']], variants: const <int>[0])
                else ...[
                  Text(fmt == 0 ? 'תצוגה מקדימה (BOM + חסימת-הזרקה):' : 'תצוגה מקדימה (VCALENDAR · 6 שיעורים-הבאים פר-חוג · מבוטל=CANCELLED):', style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  _gap(8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                    child: SelectableText(text, textDirection: TextDirection.ltr, style: const TextStyle(color: _ink, fontSize: 12, height: 1.6)),
                  ),
                ],
              ]))),
          ),
        );
      }),
    );
  }

  // 🖨 הדפס-מערכת: תצוגת-הדפסה טקסטואלית של השבוע (SelectableText) — ההורדה/הדפסה חסומות בסנדבוקס
  void _openPrint(List<Map<String, dynamic>> cs) {
    final lines = <String>['מערכת-שעות · שבוע ${_CourseData.isoOfDay(0, _week)} – ${_CourseData.isoOfDay(5, _week)}', ''];
    for (var day = 0; day < 6; day++) {
      final iso = _CourseData.isoOfDay(day, _week);
      final items = <String>[];
      for (final h in _CourseData.gridHours(cs)) {
        for (final c in _CourseData.inCell(cs, day, h)) {
          items.add('  ${_CourseData.hm(h)}  ${c['name']}${_CourseData.isCancelled(c, iso) ? ' (מבוטל)' : ''} — ${_CourseData.teacherOf(c)?['name'] ?? 'ללא-מורה'} · ${_CourseData.roomOf(c)?['name'] ?? 'ללא-חדר'} · ${_CourseData.enrolled(c)}/${_CourseData.capacity(c)}');
        }
      }
      lines.add('${dayNames[day]} $iso${items.isEmpty ? ' — אין שיעורים' : ''}');
      lines.addAll(items);
    }
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.92, expand: false,
        builder: (ctx, scroll) => Padding(
          padding: const EdgeInsets.all(12),
          child: Directionality(textDirection: TextDirection.rtl, child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
              ForgeContactTile(fields: ['הדפסת-מערכת', '${lines.length} שורות · תצוגה-מקדימה (הדפסה = מקום-שמור לשער-פלטפורמה)']),
              _gap(10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)),
                child: SelectableText(lines.join('\n'), style: const TextStyle(color: _ink, fontSize: 12.5, height: 1.6)),
              ),
            ]))),
        ),
      ),
    );
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
}

// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): CourseFacts — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══
class CourseFacts {
  static const String entity = 'Course';
  static const String label = 'חוג'; // מונח-הישות מ-entity-terms (דאטה)
  static int get count => _CourseData.courses.length; // רשומות הזרע-הראשי "courses" (static-const)
  static const List<Map<String, String>> metricDefs = <Map<String, String>>[{'key': 'kpiActive', 'label': '📚 פעילים', 'tone': 'plain'}, {'key': 'kpiLessonsWeek', 'label': '🗓 שיעורים-השבוע', 'tone': 'plain'}, {'key': 'kpiEnrolled', 'label': '🎓 רשומים', 'tone': 'plain'}, {'key': 'kpiOccupancyPct', 'label': '📈 תפוסה-ממוצ׳', 'tone': 'plain'}, {'key': 'kpiFull', 'label': '🈵 מלאים', 'tone': 'plain'}, {'key': 'kpiWaiting', 'label': '⏳ בהמתנה', 'tone': 'plain'}, {'key': 'kpiNoTeacher', 'label': '🚫 ללא-מורה', 'tone': 'danger'}, {'key': 'avgRoomUtilPct', 'label': '🚪 ניצולת-חדרים', 'tone': 'plain'}]; // 8 מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי)
  static Map<String, String> get metrics => <String, String>{'kpiActive': '${_CourseData.kpiActive}', 'kpiLessonsWeek': '${_CourseData.kpiLessonsWeek}', 'kpiEnrolled': '${_CourseData.kpiEnrolled}', 'kpiOccupancyPct': '${_CourseData.kpiOccupancyPct}%', 'kpiFull': '${_CourseData.kpiFull}', 'kpiWaiting': '${_CourseData.kpiWaiting}', 'kpiNoTeacher': '${_CourseData.kpiNoTeacher}', 'avgRoomUtilPct': '${_CourseData.avgRoomUtilPct}%'};
  static const String heroKey = 'kpiNoTeacher'; // המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
  static String get hero => metrics[heroKey] ?? '$count';
  static String get heroLabel => '🚫 ללא-מורה';
  static const String idKey = 'id'; // מפתח-המזהה בזרע (אחרי retarget)
  static List<Map<String, dynamic>> get rows => _CourseData.courses; // כל רשומות הזרע-הראשי (static-const)
  static Map<String, dynamic>? byId(String id) { for (final r in [for (final k in const <String>['kpiActive', 'kpiFull', 'kpiNoTeacher']) ...heroRows(k), ...rows]) { if ('${r[idKey] ?? r['id']}' == id) return r; } return null; } // שורות-המדד קודם (הן מסוג-הרשומה שהפאנל צורך — בזהב-התלמידים הפאנל פותח תלמיד, הזרע-הראשי-לפי-מפתחות הוא families), ואז הזרע-הראשי
  static List<Map<String, dynamic>> heroRows(String key) { switch (key) { case 'kpiActive': return _CourseData.rowsOf_kpiActive; case 'kpiFull': return _CourseData.rowsOf_kpiFull; case 'kpiNoTeacher': return _CourseData.rowsOf_kpiNoTeacher; default: return const []; } } // G10a · 3 מדדים עם שורות (צורת X.where(P).length)
  static String? get heroFirstId { final r = heroRows(heroKey); return r.isEmpty ? null : '${r.first[idKey]}'; } // הרשומה-הראשונה של ה-hero — יעד-הקפיצה מהרכזת
}
