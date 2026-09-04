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

  @override
  Widget build(BuildContext context) {
    final live = _CoursesData.liveCourses;
    final clashes = _CoursesData.kpiClashes;
    // דירוג לפי דחיפות-מאוחדת (התנגשות ראשונה), ואז לפי תפוסה-יורדת
    final ranked = [...live]..sort((a, b) {
        final s = _CoursesData.sev(b).compareTo(_CoursesData.sev(a));
        return s != 0 ? s : _CoursesData.occupancy(b).compareTo(_CoursesData.occupancy(a));
      });
    return DsScaffold(
      title: 'חוגים ומערכת', subtitle: '${live.length} חוגים חיים · ${_CoursesData.teachers.length} מורים · ${_CoursesData.rooms.where((r) => r['active'] == true).length} חדרים', icon: '📚',
      children: [
        // בורר-תצוגה (SegmentedSwitch מבוקר) — ארגון = פעולת-יסוד עם אטום משלה
        Align(
          alignment: Alignment.centerRight,
          child: SegmentedSwitch(items: const ['📅 גריד', '📋 רשימה', '👩‍🏫 פר-מורה', '🚪 פר-חדר'], selected: _view, onSelect: (i) => setState(() => _view = i)),
        ),
        _gap(12),
        // KPI-10: hero=התנגשויות (המטרה: "אף שיבוץ לא יתנגש") + 10 מדדי-מצב (BareStat נושאי-ערך-אמת)
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
        else
          DsSection(title: 'חוגים · לפי דחיפות', children: [for (final c in ranked) _row(c)]),
      ],
    );
  }

  Widget _row(Map<String, dynamic> c) {
    final t = _CoursesData.teacherOf(c), r = _CoursesData.roomOf(c);
    final sess = (sessionsOf(c) as List).map((s) => '${dayNames[s['day'] as int]} ${s['time']}').join(' · ');
    final sev = _CoursesData.sev(c);
    final tone = sev >= 2 ? 2 : sev == 1 ? 3 : _CoursesData.isFull(c) ? 3 : 1;
    final label = sev == 3 ? '⚠️ התנגשות' : _CoursesData.noTeacher(c) ? '🚫 ללא-מורה' : _CoursesData.noRoom(c) ? '🚪 ללא-חדר' : sev == 1 ? '📉 מתחת-מינ׳' : _CoursesData.isFull(c) ? '🈵 מלא' : '🟢 תקין';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Expanded(child: MediaRow(glyph: '📚', title: '${c['name']}', subtitle: '${t?['name'] ?? '—'} · ${r?['name'] ?? '—'} · $sess · ${_CoursesData.enrolled(c)}/${_CoursesData.capacity(c)}')),
        StatusChip(label: label, tone: tone),
        if (_CoursesData.waitlist(c).isNotEmpty) ...[const SizedBox(width: 6), StatusChip(label: '⏳ ${_CoursesData.waitlist(c).length}', tone: 0)],
      ]),
    );
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
}
