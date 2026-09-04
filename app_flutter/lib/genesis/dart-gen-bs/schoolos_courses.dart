// 📚 SchoolOS · חוגים ומערכת-שעות (COURSES) — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד).
// מפרט (SSOT · "מה"): knowledge/SPEC-COURSES-FULL-2026-09-04.md · הסטנדרט: מסך-המלאי (schoolos.dart).
// 🎯 המטרה: "שכל שיעור יקרה — עם מורה, בחדר, לתלמידים הנכונים, בזמן — ושאף שיבוץ לא יתנגש ואף מקום לא יתבזבז."
// פעולות-היסוד (צעד-2, לא אזורי-מפרט): איתור · הערכת-תפוסה · זיהוי-חריגה (התנגשות/ללא-מורה/ללא-חדר/מלא/מתחת-מינ׳)
//   · הכרעה (דחיפות-מאוחדת) · ביצוע (שיבוץ/העלאה/הקצאה/ביטול/סיום/שכפול) · אימות (היסטוריה/גבייה/ייצוא).
// מחלקה ציבורית יחידה: CoursesScreen (const, ללא main) — המנהל מחבר ניווט-ביתי.
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
class _CoursesData {
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
  static final List<Map<String, dynamic>> history = []; // אודיט: {at, who, act, what} (בצורת AuditEntry)
  static void log(String who, String act, String what) => history.insert(0, {'at': today, 'who': who, 'act': act, 'what': what});

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
      for (final s in (sessionsOf(c) as List)) {
        if (!cancelledSessions.contains('${c['id']}|${isoOfDayThisWeek(s['day'] as int)}')) n++;
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
  static List<Map<String, dynamic>> coursesInRoom(Map<String, dynamic> r) => liveCourses.where((c) => c['roomId'] == r['id']).toList();
  static List<Map<String, dynamic>> coursesOf(Map<String, dynamic> t) => (coursesOfTeacher(liveCourses, t['id']) as List).cast<Map<String, dynamic>>();
  static int weeklyOf(List<Map<String, dynamic>> cs) => grandTotal(cs, (c) => (sessionsOf(c) as List).length).toInt();

  // ─── סינון-סמסטר (פס-עליון): 0=הכל · i>0 ⇒ semesterOptions[i-1] (אטום-דאטה ממאור) ───
  static List<Map<String, dynamic>> bySemester(List<Map<String, dynamic>> cs, int sem) =>
      sem == 0 ? cs : cs.where((c) => c['semester'] == semesterOptions[sem - 1]).toList();

  static String sessionsLabel(Map<String, dynamic> c) => (sessionsOf(c) as List).map((s) => '${dayNames[s['day'] as int]} ${s['time']}').join(' · ');
  static String statusLabel(Map<String, dynamic> c) {
    final lc = lifecycle(c);
    if (lc != 'פעיל') return lc == 'מתוכנן' ? '🗓 מתוכנן' : lc == 'בוטל' ? '⛔ בוטל' : '🏁 הסתיים';
    final sv = sev(c);
    return sv == 3 ? '⚠️ התנגשות' : noTeacher(c) ? '🚫 ללא-מורה' : noRoom(c) ? '🚪 ללא-חדר' : sv == 1 ? '📉 מתחת-מינ׳' : isFull(c) ? '🈵 מלא' : '🟢 פעיל';
  }

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 18 עמודות-הליבה של המפרט + סטטוס ═══
  //   נגזרת(get)=תמיד-מוצגת · שדה(key בלי get)=מוארת רק כשחוג נושא ערך, חסר ⇒ שקט (אפס-זיוף).
  //   'code' אין במאור ⇒ מקום-שמור: הוספת {'code': …} לחוג ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    {'label': 'שם-חוג', 'get': (Map<String, dynamic> c) => '${c['name']}'},
    {'key': 'code', 'label': 'קוד'},                                                   // מקום-שמור
    {'label': 'תחום', 'get': (Map<String, dynamic> c) => '${c['cat'] ?? '—'}'},
    {'label': 'מורה', 'get': (Map<String, dynamic> c) => '${teacherOf(c)?['name'] ?? '—'}'},
    {'label': 'חדר', 'get': (Map<String, dynamic> c) => '${roomOf(c)?['name'] ?? '—'}'},
    {'label': 'יום+שעה', 'get': (Map<String, dynamic> c) => sessionsLabel(c)},
    {'label': 'משך', 'get': (Map<String, dynamic> c) => roomOf(c) == null ? '—' : '${roomOf(c)!['slot']} דק׳'}, // מקור: Room.slot
    {'label': 'תדירות', 'get': (Map<String, dynamic> c) => '×${(sessionsOf(c) as List).length}/שבוע'},
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

  // ─── KPI-10 (המפרט) — כולם מנועי-מדף/נגזרות-אמת, אפס-StatBlock ───
  static int get kpiActive => allCourses.where((c) => lifecycle(c) == 'פעיל').length;
  static int get kpiLessonsWeek => lessonsThisWeek();
  static int get kpiEnrolled => grandTotal(liveCourses, (c) => enrolled(c as Map<String, dynamic>)).toInt();
  static int get kpiOccupancyPct {
    final withCap = liveCourses.where((c) => capacity(c) > 0).toList();
    if (withCap.isEmpty) return 0;
    return (grandTotal(withCap, (c) => occupancy(c as Map<String, dynamic>)) / withCap.length * 100).round();
  }
  static int get kpiFull => liveCourses.where(isFull).length;
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
  static int get kpiBelowMin => liveCourses.where(belowMin).length;
  static bool get kpiBelowMinKnown => liveCourses.any((c) => minToOpen(c) != null); // מקום-שמור: אין מינימום לאף חוג ⇒ '—'
  static num get kpiDebt => grandTotal(liveCourses, (c) => courseDebt(c as Map<String, dynamic>));
}

// ═══════════ המסך · CoursesScreen (const · ללא main · המנהל מחבר ניווט) ═══════════
class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});
  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  int _view = 0; // 0=📅 גריד-שבועי · 1=📋 רשימה · 2=👩‍🏫 פר-מורה · 3=🚪 פר-חדר (SegmentedSwitch→תצוגה)
  int _week = 0; // 0=השבוע · 1=שבוע-הבא (בורר-שבוע · פס-עליון)
  int _sem = 0; // 0=הכל · 1..=semesterOptions (בורר-סמסטר · פס-עליון)
  String? _selected; // חוג-נבחר (גריד/רשימה ⇒ פאנל)

  @override
  Widget build(BuildContext context) {
    final live = _CoursesData.bySemester(_CoursesData.liveCourses, _sem);
    final clashes = _CoursesData.kpiClashes;
    // דירוג לפי דחיפות-מאוחדת (התנגשות ראשונה), ואז לפי תפוסה-יורדת
    final ranked = [...live]..sort((a, b) {
        final s = _CoursesData.sev(b).compareTo(_CoursesData.sev(a));
        return s != 0 ? s : _CoursesData.occupancy(b).compareTo(_CoursesData.occupancy(a));
      });
    final sel = _selected == null ? null : live.where((c) => c['id'] == _selected).firstOrNull;
    return DsScaffold(
      title: 'חוגים ומערכת', subtitle: '${live.length} חוגים חיים · ${_CoursesData.teachers.length} מורים · ${_CoursesData.rooms.where((r) => r['active'] == true).length} חדרים', icon: '📚',
      children: [
        // פס-עליון: בורר-שבוע/סמסטר + בורר-תצוגה (SegmentedSwitch מבוקר ×3) — ארגון = פעולת-יסוד עם אטום משלה
        Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.end, children: [
          SegmentedSwitch(items: const ['📅 השבוע', '⏭ שבוע הבא'], selected: _week, onSelect: (i) => setState(() => _week = i)),
          SegmentedSwitch(items: ['הכל', ...semesterOptions], selected: _sem, onSelect: (i) => setState(() => _sem = i)),
        ]),
        _gap(8),
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(items: const ['📅 גריד', '📋 רשימה', '👩‍🏫 פר-מורה', '🚪 פר-חדר'], selected: _view, onSelect: (i) => setState(() => _view = i)),
        ),
        _gap(12),
        // KPI-10: hero=התנגשויות (המטרה: "אף שיבוץ לא יתנגש") + 9 מדדי-מצב (BareStat נושאי-ערך-אמת)
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatHero(value: '$clashes', label: 'התנגשויות (מורה/חדר/תלמיד)'),
            _gap(14),
            Row(children: [
              BareStat(value: '${_CoursesData.kpiActive}', label: '📚 פעילים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_CoursesData.kpiLessonsWeek}', label: '🗓 שיעורים-השבוע', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_CoursesData.kpiEnrolled}', label: '🎓 רשומים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_CoursesData.kpiOccupancyPct}%', label: '📈 תפוסה-ממוצ׳', inkColor: _CoursesData.kpiOccupancyPct >= 80 ? _ok : _acc, mutedColor: _muted),
              BareStat(value: '${_CoursesData.kpiFull}', label: '🈵 מלאים', inkColor: _warning, mutedColor: _muted),
            ]),
            _gap(12),
            Row(children: [
              BareStat(value: '${_CoursesData.kpiWaiting}', label: '⏳ בהמתנה', inkColor: _CoursesData.kpiWaiting > 0 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: '${_CoursesData.kpiNoTeacher}', label: '🚫 ללא-מורה', inkColor: _CoursesData.kpiNoTeacher > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: _CoursesData.kpiBelowMinKnown ? '${_CoursesData.kpiBelowMin}' : '—', label: '📉 מתחת-מינ׳', inkColor: _CoursesData.kpiBelowMin > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: shekel(_CoursesData.kpiDebt.toInt()), label: '💳 חוב-פתוח', inkColor: _CoursesData.kpiDebt > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        _gap(10),
        if (live.isEmpty)
          const EmptyState(glyph: '📚', message: 'אין חוגים — צור חוג-חדש או שכפל סמסטר')
        else if (_view == 1)
          DsSection(title: '📋 רשימת-חוגים · ${live.length} · ${_CoursesData.columnDefs.where((c) => _CoursesData.colShown(c, live)).length} עמודות', children: [_table(ranked)])
        else if (_view == 2)
          ..._byTeacher(live)
        else if (_view == 3)
          ..._byRoom(live)
        else
          DsSection(title: '📅 מערכת-שעות · ${_week == 0 ? 'השבוע' : 'שבוע הבא'} (${_CoursesData.isoOfDay(0, _week)} – ${_CoursesData.isoOfDay(5, _week)})', children: [_grid(live)]),
        if (sel != null) ...[_gap(4), _selectedCard(sel)],
        if (_view != 1 && _view != 2 && _view != 3) DsSection(title: 'חוגים · לפי דחיפות', children: [for (final c in ranked) _row(c)]),
      ],
    );
  }

  // 📅 גריד-מערכת-שעות: Table (ימים×שעות) · תא = StatusChip-לחיץ פר-חוג (tone=דחיפות) · מבוטל=✖ · ריק=שקט
  Widget _grid(List<Map<String, dynamic>> cs) {
    final hours = _CoursesData.gridHours(cs);
    if (hours.isEmpty) return const EmptyState(glyph: '📅', message: 'אין מפגשים משובצים');
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
            for (final dd in days) Center(child: Text('${dayNames[dd]}\n${_CoursesData.isoOfDay(dd, _week).substring(5)}', textAlign: TextAlign.center, style: const TextStyle(color: _ink, fontSize: 12, fontWeight: FontWeight.w800))),
          ]),
          for (final h in hours)
            row([
              Center(child: Text(_CoursesData.hm(h), style: const TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w700))),
              for (final dd in days)
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  for (final c in _CoursesData.inCell(cs, dd, h)) _cell(c, _CoursesData.isoOfDay(dd, _week)),
                ]),
            ]),
        ],
      ),
    );
  }

  Widget _cell(Map<String, dynamic> c, String iso) {
    final cancelled = _CoursesData.isCancelled(c, iso);
    final sev = _CoursesData.sev(c);
    final tone = cancelled ? 0 : sev >= 2 ? 2 : sev == 1 || _CoursesData.isFull(c) ? 3 : 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: () => setState(() => _selected = c['id'] as String),
        // FittedBox(scaleDown): שם-חוג ארוך מתכווץ לרוחב-התא במקום לגלוש (הרנדר תפס גלישה ב-112px)
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: AlignmentDirectional.centerStart,
          child: StatusChip(label: '${cancelled ? '✖ ' : ''}${c['name']} ${_CoursesData.enrolled(c)}/${_CoursesData.capacity(c)}', tone: tone),
        ),
      ),
    );
  }

  // 📋 מבט-רשימה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid.
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _CoursesData.columnDefs) if (_CoursesData.colShown(c, rows)) c];
    return DsTable(
      labels: [for (final c in cols) c['label'] as String],
      rows: [
        for (final r in rows)
          [
            for (final c in cols)
              if (c['key'] == '__status')
                _CoursesData.statusLabel(r)
              else if (c['get'] != null)
                (c['get'] as String Function(Map<String, dynamic>))(r)
              else
                '${r[c['key']] ?? '—'}',
          ],
      ],
    );
  }

  // 👩‍🏫 פר-מורה: coursesOfTeacher (מנוע) ⊕ עומס = מפגשים/שבוע (BareStat) · סקשן "ללא-מורה" בנפרד (חריגה)
  List<Widget> _byTeacher(List<Map<String, dynamic>> live) {
    final orphan = live.where(_CoursesData.noTeacher).toList();
    return [
      for (final t in _CoursesData.teachers)
        () {
          final cs = _CoursesData.bySemester(_CoursesData.coursesOf(t), _sem);
          return DsSection(
            title: '👩‍🏫 ${t['name']} · ${t['specialty']}',
            trailing: StatusChip(label: '${cs.length} חוגים · ${_CoursesData.weeklyOf(cs)} מפגשים/שבוע', tone: cs.isEmpty ? 0 : 1),
            children: cs.isEmpty ? [const EmptyState(glyph: '🪑', message: 'אין חוגים למורה זה')] : [for (final c in cs) _row(c)],
          );
        }(),
      if (orphan.isNotEmpty) DsSection(title: '🚫 ללא-מורה · ${orphan.length}', tone: 2, children: [for (final c in orphan) _row(c)]),
    ];
  }

  // 🚪 פר-חדר: weeklyRoomSessions (מנוע) ⊕ קיבולת-משבצות ⇒ ניצולת (StatRow) · חדר-לא-פעיל = חריגה
  List<Widget> _byRoom(List<Map<String, dynamic>> live) => [
        for (final r in _CoursesData.rooms)
          () {
            final cs = _CoursesData.bySemester(_CoursesData.coursesInRoom(r), _sem);
            final active = r['active'] == true;
            final weekly = _CoursesData.roomWeekly(r), cap = _CoursesData.roomSlotsPerWeek(r);
            return DsSection(
              title: '🚪 ${r['name']} · ${r['location']} · קיבולת ${r['cap']}',
              tone: active ? 0 : 2,
              trailing: StatusChip(label: active ? '${r['from']}–${r['to']} · ${r['slot']} דק׳' : 'לא-פעיל', tone: active ? 0 : 2),
              children: [
                StatRow(label: 'ניצולת שבועית', value: '$weekly מתוך $cap משבצות', fraction: _CoursesData.roomUtil(r)),
                _gap(6),
                if (cs.isEmpty) const EmptyState(glyph: '🚪', message: 'אין חוגים בחדר') else for (final c in cs) _row(c),
              ],
            );
          }(),
      ];

  // כרטיס חוג-נבחר (גל 2: זהות + תפוסה-מול-קיבולת; גל 3 מרחיב לפאנל+טאבים+פעולות)
  Widget _selectedCard(Map<String, dynamic> c) => DsSection(
        title: '🎯 נבחר · ${c['name']}',
        trailing: StatusChip(label: _CoursesData.statusLabel(c), tone: _CoursesData.sev(c) >= 2 ? 2 : 1),
        children: [
          MediaRow(glyph: '📚', title: '${c['name']}', subtitle: '${_CoursesData.teacherOf(c)?['name'] ?? '—'} · ${_CoursesData.roomOf(c)?['name'] ?? '—'} · ${_CoursesData.sessionsLabel(c)}'),
          _gap(8),
          StatRow(label: 'תפוסה מול קיבולת', value: '${_CoursesData.enrolled(c)} מתוך ${_CoursesData.capacity(c)}', fraction: _CoursesData.occupancy(c)),
        ],
      );

  Widget _row(Map<String, dynamic> c) {
    final t = _CoursesData.teacherOf(c), r = _CoursesData.roomOf(c);
    final sev = _CoursesData.sev(c);
    final tone = sev >= 2 ? 2 : sev == 1 ? 3 : _CoursesData.isFull(c) ? 3 : 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: MediaRow(glyph: '📚', title: '${c['name']}', subtitle: '${t?['name'] ?? '—'} · ${r?['name'] ?? '—'} · ${_CoursesData.sessionsLabel(c)} · ${_CoursesData.enrolled(c)}/${_CoursesData.capacity(c)}')),
        StatusChip(label: _CoursesData.statusLabel(c), tone: tone),
        if (_CoursesData.waitlist(c).isNotEmpty) ...[const SizedBox(width: 6), StatusChip(label: '⏳ ${_CoursesData.waitlist(c).length}', tone: 0)],
        // MediaRow בולע את הקליק (InkWell פנימי no-op) ⇒ כפתור-שברון נפרד כשקע-הבחירה
        IconButton(onPressed: () => setState(() => _selected = c['id'] as String), icon: const Icon(Icons.chevron_left, color: _acc, size: 24), tooltip: 'פרטים ופעולות'),
      ]),
    );
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
}
