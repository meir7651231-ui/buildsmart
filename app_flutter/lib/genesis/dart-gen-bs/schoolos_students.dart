// 🎓 SchoolOS · מודול-תלמידים — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) מול SPEC-STUDENTS-FULL-2026-09-04.
// מטרה: "לדעת מי כל תלמיד באמת — לימודית, חברתית, רגשית ומשפחתית — ולראות את מי-שנופל לפני שהוא נופל."
// פעולות-יסוד (לא אזורי-מפרט): איתור · הערכת-מצב · חיבור-אותות-להכרעה · זיהוי-חריגה · הכרעה · ביצוע · אימות.
// כל חלקיק-תובנה = הרכבת כמה אטומי-מדף (תצוגה ⊕ לוגיקה); עובדה (תווית+ערך) = אטום-יחיד לגיטימי.
// אפס-זיוף (§20-ג): רק שדות עם מקור-אמת באימפריה (סכמת-maor: Member · Family · Enrollment · Course ·
// Teacher · WorkTask · OrgEvent · AuditEntry — `dart-maor/schema-fields.dart`). שדה חסר-מקור = מקום-שמור (חוק-7).
// זהות/קשר/תאריך מוזרקים (חוק-6): today · roleDefs · db — לעולם לא אטום.
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart'; // DsScaffold · DsSection · DsTokens (שלד+סקשן)
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/bare_stat.dart'; // עובדה: ערך+תווית חשופים (KPI נושא-ערך, לא StatBlock המזייף)
import '../dart-ui-bs/premium/surfaces/gradient_card.dart'; // מיכל-KPI
import '../dart-ui-bs/premium/surfaces/stat_hero.dart'; // המטרה בראש: מספר-ענק
import '../dart-ui-bs/premium/actions/soft_button.dart'; // פעולה (label+onTap+tone)
import '../dart-ui-bs/premium/feedback/alert_banner.dart'; // התרעה/מצב-שגיאה
import '../dart-maor/age-of.dart'; // גיל מתאריך-לידה (Member.birth)
import '../dart-maor/grade-order.dart'; // סדר-כיתות א׳..יב׳ (שכבה)
import '../dart-maor/grade-index.dart'; // אינדקס-כיתה (מיון לפי שכבה)
import '../dart-maor/clamp-scale.dart'; // נרמול-אות לגבולות 0..1
import '../dart-maor/grand-total.dart'; // Σ-לפי-מפתח (ממוצעים · סכומים)
import '../dart-maor/count-by.dart'; // ספירה-לפי-מפתח (KPI · קיבוץ)
import '../dart-maor/intel-trend-from-scan.dart'; // מגמה: חצי-חדש מול חצי-ישן ⇒ dir/pct
import '../dart-maor/enroll-summary.dart'; // סיכום-רישום: נוכחויות/חיסורים/noshow (Enrollment)
import '../dart-maor/month-key.dart'; // מפתח-חודש YYYY-MM
import '../dart-maor/task-overdue.dart'; // משימה באיחור (WorkTask.due < today ולא-בוצעה)
import '../dart-maor/cockpit-days-since.dart'; // ימים-מאז (iso→today)
import '../dart-maor/format-israeli-phone.dart'; // טלפון-הורה מעוצב
import '../dart-maor/fmt-date.dart'; // תאריך dd/mm/yyyy
import '../dart-ui-bs/ds/ds_table.dart'; // טבלה-אמיתית (labels+rows, מיון-בלחיצה) — לא DataGrid המזייף
import '../dart-ui-bs/premium/actions/segmented_switch.dart'; // בורר-מבט/מיון מבוקר
import '../dart-ui-bs/premium/lists/media_row.dart'; // שורת-תלמיד: glyph+title+subtitle
import '../dart-ui-bs/premium/lists/stat_row.dart'; // בר-סיכון: label+value+fraction
import '../dart-ui-bs/premium/feedback/status_chip.dart'; // שבב: אות-מוביל · פעולה · דגל · סטטוס
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // מצב "אין-תלמידים/אין-תוצאות"
import '../dart-maor/name-sort-key.dart'; // מיון-לפי-שם (מנורמל, בלי תארים)
import '../dart-maor/norm-search.dart'; // נרמול-עברי (סופיות/ניקוד) — שקע ל-nameSortKey ולחיפוש

const _acc = DsTokens.accent;
// פיגמנטים מוזרקים לאטומי-מדף טהורים (חוק-6: צבע=הצבה, לא ציור)
const _danger = Color(0xFFF43F5E);
const _ok = Color(0xFF34D399);
const _muted = Color(0xFF9AA0BE);
const _ink = Color(0xFFF2F3FF);
const _warning = Color(0xFFF59E0B);

// ═══════════════════════════════════════════════════════════════════════════════════════════
// 🔴 דאטה-אמת (§20-ג) — db בצורת-Db של maor (schema-fields.dart): families[members] · enrollments ·
//    courses · teachers · tasks · events · audit. תלמיד = Member בתוך Family + רישומיו (Enrollment).
//    כל שדה-מפרט ממופה למקור: תמונה⇒מקום-שמור · ת״ז⇒Member.idNum · כיתה⇒Member.grade · מחנך⇒Course.teacherId ·
//    לידה/גיל⇒Member.birth⊕ageOf · מין⇒Member.gender · סטטוס⇒Enrollment.status · נוכחות⇒presents/absences ·
//    הורה⇒Family.mother/father/phone · הצטרפות⇒Enrollment.enrolledAt · שפת-בית⇒Family.language ·
//    כתובת⇒Family.address/city · אחים⇒Family.members · רפואי⇒Member.health · אישורי-מדיה⇒Member.mPhotos/mVideos ·
//    סוציו-אקונומי⇒Family.tzedaka/discount (מוגן) · מסמכים⇒Family.docs · פניות⇒tasks(ref.kind=family) ·
//    אירועים⇒events(famId) · אודיט⇒audit{at,who,act,what} · היסטוריית-כיתות⇒enrollments(renewedToId)+courses.year.
//    ⛔ ללא-מקור באימפריה (מקום-שמור, לא זיוף): ציונים · התנהגות · חברתי-רגשי · אבחונים · תרופות · IEP · הסעה ·
//    ציוני-חוץ · תיק-רפואי · חונך · תפקידים · הישגים · תעודות-קודמות · אישורי-טיולים/תרופות.
// ═══════════════════════════════════════════════════════════════════════════════════════════
class _StuData {
  static const today = '2026-09-04'; // תאריך-הזרקה דטרמיניסטי (אין DateTime.now במנוע)
  static final DateTime todayDt = DateTime(2026, 9, 4, 12);
  static const yearStart = '2026-09-01'; // תחילת שנה״ל (academicYearLabel: ≥ספטמבר)

  // רשימת-ימים ⇒ ISO (עוזר-דאטה דטרמיניסטי; הצורה הסופית = IsoDate[] כמו Enrollment.presents)
  static List<String> _d(String ym, List<int> days) => [for (final d in days) '$ym-${d.toString().padLeft(2, '0')}'];
  static List<Map<String, dynamic>> _abs(String ym, List<int> days, {String reason = 'ללא-סיבה', bool justified = false, bool noshow = false}) =>
      [for (final d in days) {'date': '$ym-${d.toString().padLeft(2, '0')}', 'reason': reason, 'justified': justified, 'noshow': noshow}];

  static Map<String, dynamic> seed() => {
        'teachers': [
          {'id': 't1', 'name': 'רותי אלמוג', 'phone': '0521110001', 'email': 'ruti@school'},
          {'id': 't2', 'name': 'דוד פרץ', 'phone': '0521110002', 'email': 'david@school'},
          {'id': 't3', 'name': 'מיכל שרון', 'phone': '0521110003', 'email': 'michal@school'},
          {'id': 't4', 'name': 'יוסי כהן', 'phone': '0521110004', 'email': 'yossi@school'},
        ],
        // כיתת-חינוך = Course (teacherId · year · start/end · gradeMin/Max) — מקור: Course
        'courses': [
          {'id': 'c-i1', 'name': 'י׳-1 · כיתת-חינוך', 'teacherId': 't1', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'gradeMin': 'י', 'gradeMax': 'י', 'cat': 'חינוך'},
          {'id': 'c-i2', 'name': 'י׳-2 · כיתת-חינוך', 'teacherId': 't4', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'gradeMin': 'י', 'gradeMax': 'י', 'cat': 'חינוך'},
          {'id': 'c-t3', 'name': 'ט׳-3 · כיתת-חינוך', 'teacherId': 't2', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'gradeMin': 'ט', 'gradeMax': 'ט', 'cat': 'חינוך'},
          {'id': 'c-h2', 'name': 'ח׳-2 · כיתת-חינוך', 'teacherId': 't3', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'gradeMin': 'ח', 'gradeMax': 'ח', 'cat': 'חינוך'},
          {'id': 'c-z1', 'name': 'ז׳-1 · כיתת-חינוך', 'teacherId': 't3', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'gradeMin': 'ז', 'gradeMax': 'ז', 'cat': 'חינוך'},
          {'id': 'c-ib1', 'name': 'יב׳-1 · כיתת-חינוך', 'teacherId': 't4', 'start': '2025-09-01', 'end': '2026-06-20', 'year': '2025/26', 'gradeMin': 'יב', 'gradeMax': 'יב', 'cat': 'חינוך'},
          {'id': 'c-t1-25', 'name': 'ט׳-1 · כיתת-חינוך', 'teacherId': 't2', 'start': '2025-09-01', 'end': '2026-06-20', 'year': '2025/26', 'gradeMin': 'ט', 'gradeMax': 'ט', 'cat': 'חינוך'},
          {'id': 'c-robot', 'name': 'חוג רובוטיקה', 'teacherId': 't2', 'start': '2026-09-01', 'end': '2027-06-20', 'year': '2026/27', 'cat': 'חוג'},
        ],
        // משפחה = Family (schema-fields) · ילד = Member. שדות-אמת בלבד.
        'families': [
          {'id': 'f1', 'name': 'שמעוני', 'father': 'אבי', 'mother': 'דנה', 'phone': '0528811223', 'phone2': '0528811224', 'email': '', 'city': 'חולון', 'address': 'הבנים 12', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2024-08-20',
            'docs': [{'id': 'd1', 'name': 'טופס-רישום-2024.pdf', 'addedAt': '2024-08-20'}, {'id': 'd2', 'name': 'אישור-מדיה-חתום.pdf', 'addedAt': '2025-09-02'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm1', 'first': 'רון', 'gender': 'm', 'birth': '2010-11-03', 'idNum': '210079190', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': false, 'notes': 'מוסח בשיעורי-בוקר; מגיב טוב לעידוד.'},
              {'id': 'm2', 'first': 'נועה', 'gender': 'f', 'birth': '2013-09-12', 'idNum': '210134623', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ז', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f2', 'name': 'אוחיון', 'father': '', 'mother': 'שרית', 'phone': '0543322110', 'phone2': '', 'email': '', 'city': 'בת-ים', 'address': 'רוטשילד 4', 'language': 'צרפתית', 'maritalStatus': 'גרושה', 'status': 'active', 'tzedaka': 'מלגה', 'discount': '50', 'notes': 'אם יחידנית · עובדת במשמרות', 'createdAt': '2023-08-15',
            'docs': [{'id': 'd3', 'name': 'אישור-מלגה.pdf', 'addedAt': '2025-10-01'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm3', 'first': 'ליאור', 'gender': 'm', 'birth': '2011-05-20', 'idNum': '210205894', 'phone': '0551234567', 'school': 'תיכון עתיד', 'grade': 'ט', 'health': 'אסתמה — משאף בתיק', 'mSefach': true, 'mInvite': true, 'mRecommend': false, 'mPhotos': false, 'mVideos': false, 'notes': 'נעדר הרבה מאז יוני; לבדוק מול הבית.'},
            ]},
          {'id': 'f3', 'name': 'נחום', 'father': 'משה', 'mother': 'אורית', 'phone': '', 'phone2': '', 'email': '', 'city': 'ראשון-לציון', 'address': 'הרצל 88', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2022-09-01',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm4', 'first': 'הדר', 'gender': 'f', 'birth': '2012-02-14', 'idNum': '210261327', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ח', 'health': '', 'mSefach': true, 'mInvite': false, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f4', 'name': 'ביטון', 'father': 'יעקב', 'mother': 'רחל', 'phone': '0507712345', 'phone2': '', 'email': '', 'city': 'חולון', 'address': 'סוקולוב 3', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2021-08-30',
            'docs': [{'id': 'd4', 'name': 'תעודת-סיום-יב.pdf', 'addedAt': '2026-06-25'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm5', 'first': 'מאיה', 'gender': 'f', 'birth': '2010-07-08', 'idNum': '210324679', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': 'מובילה חברתית בכיתה.'},
              {'id': 'm6', 'first': 'עומר', 'gender': 'm', 'birth': '2008-03-30', 'idNum': '210395950', 'phone': '0521239876', 'school': 'תיכון עתיד', 'grade': 'יב', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f5', 'name': 'לוי', 'father': 'אייל', 'mother': 'טל', 'phone': '0539988776', 'phone2': '', 'email': '', 'city': 'חולון', 'address': 'ויצמן 21', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'pending', 'tzedaka': '', 'discount': '', 'notes': 'משפחה חדשה — עברו מעיר אחרת', 'createdAt': '2026-08-25',
            'docs': [{'id': 'd5', 'name': 'טופס-רישום-2026.pdf', 'addedAt': '2026-08-25'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm7', 'first': 'נועה', 'gender': 'f', 'birth': '2010-09-25', 'idNum': '210467221', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': false, 'mVideos': false, 'notes': ''},
            ]},
          // רשומה-כפולה חשודה (ייבוא): אותו טלפון + אותו שם-ילד + אותה לידה ⇒ זיהוי-כפולים (findDuplicateGroups)
          {'id': 'f6', 'name': 'לוי', 'father': '', 'mother': 'טל', 'phone': '0539988776', 'phone2': '', 'email': '', 'city': 'חולון', 'address': '', 'language': '', 'maritalStatus': '', 'status': 'pending', 'tzedaka': '', 'discount': '', 'notes': 'נוצר מייבוא-CSV 2.9', 'createdAt': '2026-09-02',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm8', 'first': 'נועה', 'gender': 'f', 'birth': '2010-09-25', 'idNum': '', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'mSefach': false, 'mInvite': false, 'mRecommend': false, 'mPhotos': false, 'mVideos': false, 'notes': ''},
            ]},
          {'id': 'f7', 'name': 'מזרחי', 'father': 'שלמה', 'mother': 'לימור', 'phone': '0581122334', 'phone2': '', 'email': '', 'city': 'בת-ים', 'address': 'בלפור 9', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'inactive', 'tzedaka': '', 'discount': '', 'notes': 'עברו לירושלים 3/2026', 'createdAt': '2022-08-28',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm9', 'first': 'יובל', 'gender': 'm', 'birth': '2011-12-01', 'idNum': '210538492', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ט', 'health': '', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f8', 'name': 'כהן', 'father': 'רועי', 'mother': 'שירה', 'phone': '0526677889', 'phone2': '', 'email': '', 'city': 'ראשון-לציון', 'address': 'ז׳בוטינסקי 40', 'language': 'רוסית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2024-08-18',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm10', 'first': 'איתי', 'gender': 'm', 'birth': '2012-06-17', 'idNum': '210665196', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ח', 'health': 'אלרגיה לבוטנים (אפיפן)', 'mSefach': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': false, 'notes': 'הוקפא לחודש — אשפוז; חוזר 1.10'},
            ]},
        ],
        // רישום = Enrollment: memberId · courseId · status(active/paused/ended/wait) · presents[] · absences[] · enrolledAt · endedAt · renewedToId
        'enrollments': [
          {'id': 'e1', 'memberId': 'm1', 'courseId': 'c-i1', 'status': 'active', 'enrolledAt': '2025-09-01', 'group': '', 'note': '',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25, 26, 27, 31]), ..._d('2026-06', [1, 2, 3, 7, 8, 9, 10, 14, 15, 16, 17, 21, 22, 23]), ..._d('2026-09', [1, 2])],
            'absences': [..._abs('2026-06', [4, 18, 24], reason: 'ללא-סיבה'), ..._abs('2026-09', [3], noshow: true)]},
          {'id': 'e2', 'memberId': 'm2', 'courseId': 'c-z1', 'status': 'active', 'enrolledAt': '2026-09-01', 'group': '', 'note': '',
            'presents': [..._d('2026-09', [1, 2, 3])], 'absences': []},
          {'id': 'e3', 'memberId': 'm3', 'courseId': 'c-t3', 'status': 'active', 'enrolledAt': '2025-09-01', 'group': '', 'note': '',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25, 26, 27]), ..._d('2026-06', [1, 2, 7, 8, 14, 21]), ..._d('2026-09', [1])],
            'absences': [..._abs('2026-05', [31]), ..._abs('2026-06', [3, 9, 10, 15, 16, 17, 22, 23, 24], reason: 'ללא-סיבה', noshow: true), ..._abs('2026-09', [2, 3], reason: 'ללא-סיבה', noshow: true)]},
          {'id': 'e3b', 'memberId': 'm3', 'courseId': 'c-robot', 'status': 'active', 'enrolledAt': '2026-09-01', 'group': '', 'note': '', 'presents': [..._d('2026-09', [2])], 'absences': []},
          {'id': 'e4', 'memberId': 'm4', 'courseId': 'c-h2', 'status': 'active', 'enrolledAt': '2025-09-01', 'group': '', 'note': '',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25, 26, 27, 31]), ..._d('2026-06', [1, 2, 3, 7, 8, 9, 10, 14, 15, 16, 21, 22]), ..._d('2026-09', [1, 2, 3])],
            'absences': [..._abs('2026-06', [17, 23, 24], reason: 'מחלה', justified: true)]},
          {'id': 'e5', 'memberId': 'm5', 'courseId': 'c-i2', 'status': 'active', 'enrolledAt': '2025-09-01', 'group': '', 'note': '',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25, 26, 27, 31]), ..._d('2026-06', [1, 2, 3, 7, 8, 9, 10, 14, 15, 16, 17, 21, 22, 23, 24]), ..._d('2026-09', [1, 2, 3])],
            'absences': [..._abs('2026-05', [14], reason: 'אירוע-משפחתי', justified: true)]},
          // בוגר: רישום-יב שהסתיים בסוף שנה״ל (סטטוס ended + כיתה יב ⇒ 'בוגר')
          {'id': 'e6', 'memberId': 'm6', 'courseId': 'c-ib1', 'status': 'ended', 'enrolledAt': '2025-09-01', 'endedAt': '2026-06-20', 'group': '', 'note': 'סיים בהצטיינות',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25, 26, 27, 31]), ..._d('2026-06', [1, 2, 3, 7, 8, 9, 10, 14, 15, 16, 17])], 'absences': []},
          {'id': 'e7', 'memberId': 'm7', 'courseId': 'c-i1', 'status': 'active', 'enrolledAt': '2026-09-01', 'group': '', 'note': 'עברה מבית-ספר אחר',
            'presents': [..._d('2026-09', [1, 2])], 'absences': [..._abs('2026-09', [3], reason: 'ללא-סיבה')]},
          {'id': 'e8', 'memberId': 'm8', 'courseId': 'c-i1', 'status': 'wait', 'enrolledAt': '2026-09-02', 'group': '', 'note': 'ייבוא', 'presents': [], 'absences': []},
          // עזב: רישום שהסתיים באמצע שנה (endedAt לפני סוף-הקורס)
          {'id': 'e9', 'memberId': 'm9', 'courseId': 'c-t1-25', 'status': 'ended', 'enrolledAt': '2025-09-01', 'endedAt': '2026-03-15', 'group': '', 'note': 'מעבר דירה',
            'presents': [..._d('2026-03', [1, 2, 3, 4, 8, 9, 10])], 'absences': [..._abs('2026-03', [11, 12], reason: 'ללא-סיבה')]},
          // הוקפא: רישום paused (אשפוז) — מצב-מיוחד
          {'id': 'e10', 'memberId': 'm10', 'courseId': 'c-h2', 'status': 'paused', 'enrolledAt': '2025-09-01', 'group': '', 'note': 'אשפוז — חוזר 1.10',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25]), ..._d('2026-06', [1, 2, 3, 7, 8, 9, 10, 14, 15])],
            'absences': [..._abs('2026-05', [26, 27, 31], reason: 'מחלה', justified: true), ..._abs('2026-06', [16, 17, 21, 22, 23, 24], reason: 'מחלה', justified: true)]},
          // היסטוריית-כיתות: רישום-שנה-קודמת של רון (renewedToId ⇒ e1)
          {'id': 'e0', 'memberId': 'm1', 'courseId': 'c-t1-25', 'status': 'ended', 'enrolledAt': '2025-09-01', 'endedAt': '2026-06-20', 'group': '', 'note': '', 'renewedToId': 'e1',
            'presents': [..._d('2026-05', [3, 4, 5, 6, 10, 11, 12, 13, 17, 18, 19, 20, 24, 25, 26, 27, 31]), ..._d('2026-06', [1, 2, 3, 7, 8, 9, 10, 14, 15, 16, 17, 21, 22, 23])], 'absences': [..._abs('2026-06', [4, 18, 24])]},
        ],
        // פניות/משימות = WorkTask: assignee · by · title · ref{kind,id} · pri · due · createdAt · doneAt · note
        'tasks': [
          {'id': 'k1', 'assignee': 'counselor@school', 'by': 'ruti@school', 'title': 'פנייה ליועצת: ליאור אוחיון — היעדרויות', 'ref': {'kind': 'family', 'id': 'f2', 'memberId': 'm3'}, 'pri': 1, 'due': '2026-09-01', 'createdAt': '2026-06-20', 'doneAt': '', 'note': 'לא נוצר קשר עם הבית'},
          {'id': 'k2', 'assignee': 'office@school', 'by': 'ruti@school', 'title': 'אישור-טיולים פג — רון שמעוני', 'ref': {'kind': 'family', 'id': 'f1', 'memberId': 'm1', 'consent': 'trips'}, 'pri': 2, 'due': '2026-09-10', 'createdAt': '2026-08-20', 'doneAt': '', 'note': ''},
          {'id': 'k3', 'assignee': 'office@school', 'by': 'michal@school', 'title': 'אישור-תרופות פג — איתי כהן', 'ref': {'kind': 'family', 'id': 'f8', 'memberId': 'm10', 'consent': 'meds'}, 'pri': 1, 'due': '2026-08-30', 'createdAt': '2026-08-01', 'doneAt': '', 'note': ''},
          {'id': 'k4', 'assignee': 'ruti@school', 'by': 'ruti@school', 'title': 'שיחת-הכרות — נועה לוי', 'ref': {'kind': 'family', 'id': 'f5', 'memberId': 'm7'}, 'pri': 2, 'due': '2026-09-08', 'createdAt': '2026-09-01', 'doneAt': '', 'note': ''},
          {'id': 'k5', 'assignee': 'counselor@school', 'by': 'michal@school', 'title': 'פנייה ליועצת: הדר נחום — אין קשר עם ההורים', 'ref': {'kind': 'family', 'id': 'f3', 'memberId': 'm4'}, 'pri': 2, 'due': '2026-06-30', 'createdAt': '2026-06-10', 'doneAt': '2026-06-28', 'note': 'נסגר — הושג קשר דרך הסבתא'},
        ],
        // אירועים = OrgEvent (famId · date · title · type · done) — ציר-זמן-תלמיד
        'events': [
          {'id': 'v1', 'title': 'שיחת-מחנכת עם ההורים', 'date': '2026-06-22', 'time': '17:00', 'type': 'meeting', 'famId': 'f2', 'priority': 'high', 'done': true},
          {'id': 'v2', 'title': 'ועדת-שילוב', 'date': '2026-09-09', 'time': '13:00', 'type': 'meeting', 'famId': 'f2', 'priority': 'high', 'done': false},
          {'id': 'v3', 'title': 'שיחת-הכרות משפחה חדשה', 'date': '2026-09-08', 'time': '16:30', 'type': 'meeting', 'famId': 'f5', 'priority': 'normal', 'done': false},
          {'id': 'v4', 'title': 'יום-הורים', 'date': '2026-06-15', 'time': '18:00', 'type': 'meeting', 'famId': 'f1', 'priority': 'normal', 'done': true},
        ],
        // אודיט = AuditEntry {at, who, act, what} — טבעת-אודיט (pullAuditRing/pushAuditRing = תפר-ההתמדה, כאן בזיכרון)
        'audit': [
          {'at': '2026-09-01T08:10', 'who': 'office@school', 'act': 'update', 'what': 'm7 · רישום לכיתה י׳-1'},
          {'at': '2026-09-02T09:30', 'who': 'office@school', 'act': 'import', 'what': 'f6 · ייבוא-CSV (3 שורות)'},
          {'at': '2026-08-31T12:00', 'who': 'ruti@school', 'act': 'note', 'what': 'm1 · הערת-מחנכת'},
          {'at': '2026-06-20T10:00', 'who': 'ruti@school', 'act': 'ticket', 'what': 'm3 · פנייה ליועצת'},
        ],
      };

  static Map<String, dynamic> db = seed();
  static void use(Map<String, dynamic> d) { db = d; _cache = null; }
  static void reset() { db = seed(); _cache = null; }

  // ─── תלמיד = שיטוח Member⊕Family⊕Enrollments (נגזר, לא stored) ───
  static List<Map<String, dynamic>>? _cache;
  static List<Map<String, dynamic>> get students => _cache ??= _build();
  static List<Map<String, dynamic>> _build() {
    final out = <Map<String, dynamic>>[];
    for (final f in (db['families'] as List).cast<Map<String, dynamic>>()) {
      for (final m in (f['members'] as List).cast<Map<String, dynamic>>()) {
        out.add({...m, 'family': f, 'famId': f['id'], 'name': '${m['first']} ${f['name']}', 'last': f['name']});
      }
    }
    return out;
  }
  static Map<String, dynamic>? byId(String id) {
    for (final s in students) { if (s['id'] == id) return s; }
    return null;
  }
  static List<Map<String, dynamic>> enrollmentsOf(Map<String, dynamic> s) =>
      [for (final e in (db['enrollments'] as List).cast<Map<String, dynamic>>()) if (e['memberId'] == s['id']) e];
  static Map<String, dynamic>? courseOf(String? id) {
    for (final c in (db['courses'] as List).cast<Map<String, dynamic>>()) { if (c['id'] == id) return c; }
    return null;
  }
  static Map<String, dynamic>? teacherOf(String? id) {
    for (final t in (db['teachers'] as List).cast<Map<String, dynamic>>()) { if (t['id'] == id) return t; }
    return null;
  }
  // הרישום-הראשי = כיתת-החינוך הפעילה (cat=חינוך), אחרת האחרון
  static Map<String, dynamic>? mainEnrollment(Map<String, dynamic> s) {
    final es = enrollmentsOf(s);
    if (es.isEmpty) return null;
    for (final e in es) { if (courseOf(e['courseId'] as String?)?['cat'] == 'חינוך' && e['status'] != 'ended') return e; }
    es.sort((a, b) => '${b['enrolledAt']}'.compareTo('${a['enrolledAt']}'));
    return es.first;
  }
  static String className(Map<String, dynamic> s) {
    final c = courseOf(mainEnrollment(s)?['courseId'] as String?);
    final n = (c?['name'] as String?) ?? '';
    return n.contains(' · ') ? n.split(' · ').first : (s['grade'] as String? ?? '—');
  }
  static String teacherName(Map<String, dynamic> s) => (teacherOf(courseOf(mainEnrollment(s)?['courseId'] as String?)?['teacherId'] as String?)?['name'] as String?) ?? '—';
  static int? age(Map<String, dynamic> s) => ageOf(s['birth'] as String?, todayDt);
  static int gradeIdx(Map<String, dynamic> s) => gradeIndex(s['grade'] as String?, gradeOrder);

  // ─── סטטוס-תלמיד (4 ערכי-המפרט) נגזר מ-Enrollment.status + כיתה: active⇒פעיל · paused⇒הוקפא · ended+יב⇒בוגר · ended⇒עזב ───
  static final Map<String, String> _statusOverride = {}; // פעולות (הקפא/החזר/סמן-עזב/בוגר) = state
  static String status(Map<String, dynamic> s) {
    final o = _statusOverride[s['id']];
    if (o != null) return o;
    final e = mainEnrollment(s);
    if (e == null) return 'פעיל';
    final st = e['status'];
    if (st == 'paused') return 'הוקפא';
    if (st == 'ended') return s['grade'] == 'יב' ? 'בוגר' : 'עזב';
    if (st == 'wait') return 'ממתין/ה'; // רשימת-המתנה (Enrollment.status=wait) — עדיין לא תלמיד/ה פעיל/ה
    return 'פעיל';
  }
  static bool isActive(Map<String, dynamic> s) => status(s) == 'פעיל';
  static List<Map<String, dynamic>> get active => students.where(isActive).toList();
  static List<Map<String, dynamic>> get inactive => students.where((s) => !isActive(s)).toList();
  static bool isNew(Map<String, dynamic> s) => enrollmentsOf(s).every((e) => '${e['enrolledAt']}'.compareTo(yearStart) >= 0);

  // ─── נוכחות (מקור: Enrollment.presents/absences ⊕ enrollSummary מהמדף) ───
  static const _enrollT = {'k1': 'פעיל', 'k2': 'מוקפא', 'k3': 'הסתיים', 'k4': 'המתנה'};
  static Map<String, dynamic> summary(Map<String, dynamic> e) => enrollSummary(e, (e) => 0, (e) => 0, _enrollT); // payBal/paidOf = שקעים לא-רלוונטיים (0)
  static List<String> presentsOf(Map<String, dynamic> s) => [for (final e in enrollmentsOf(s)) ...((e['presents'] as List?) ?? const []).cast<String>()];
  static List<Map<String, dynamic>> absencesOf(Map<String, dynamic> s) => [for (final e in enrollmentsOf(s)) ...((e['absences'] as List?) ?? const []).cast<Map<String, dynamic>>()];
  static int presents(Map<String, dynamic> s) => grandTotal(enrollmentsOf(s), (e) => summary(e as Map<String, dynamic>)['presents'] as int).toInt();
  static int absences(Map<String, dynamic> s) => grandTotal(enrollmentsOf(s), (e) => summary(e as Map<String, dynamic>)['absences'] as int).toInt();
  static int noshow(Map<String, dynamic> s) => grandTotal(enrollmentsOf(s), (e) => summary(e as Map<String, dynamic>)['noshow'] as int).toInt();
  static double? attendance(Map<String, dynamic> s) { // יחס-נוכחות 0..1 (null = אין נתון)
    final p = presents(s), a = absences(s);
    return p + a == 0 ? null : p / (p + a);
  }
  static int attendancePct(Map<String, dynamic> s) => ((attendance(s) ?? 0) * 100).round();
  // מגמה (מהמדף trendFromScan): סדרת יחסי-נוכחות חודשיים ⇒ חצי-חדש מול חצי-ישן ⇒ {dir, pct}
  static List<String> months(Map<String, dynamic> s) {
    final ks = <String>{for (final d in presentsOf(s)) monthKey(d), for (final a in absencesOf(s)) monthKey(a['date'] as String)}.toList()..sort();
    return ks;
  }
  static double monthRate(Map<String, dynamic> s, String ym) {
    final p = presentsOf(s).where((d) => monthKey(d) == ym).length;
    final a = absencesOf(s).where((x) => monthKey(x['date'] as String) == ym).length;
    return p + a == 0 ? 0 : p / (p + a);
  }
  static Map<String, dynamic> trend(Map<String, dynamic> s, {int lastN = 4}) {
    final ms = months(s);
    final tail = ms.length > lastN ? ms.sublist(ms.length - lastN) : ms;
    if (tail.length < 2) return const {'dir': 'flat', 'pct': 0};
    return trendFromScan({'monthly': [for (final m in tail) monthRate(s, m) * 100]});
  }
  static Map<String, dynamic> trend30(Map<String, dynamic> s) => trend(s, lastN: 2); // חודש-אחרון מול קודמו
  static Map<String, dynamic> trend90(Map<String, dynamic> s) => trend(s, lastN: 4); // חלון-רבעוני

  // ─── משפחה (מקור: Family) ───
  static Map<String, dynamic> fam(Map<String, dynamic> s) => s['family'] as Map<String, dynamic>;
  static String parentName(Map<String, dynamic> s) {
    final f = fam(s);
    final m = (f['mother'] as String?) ?? '', d = (f['father'] as String?) ?? '';
    return m.isNotEmpty ? m : d.isNotEmpty ? d : '—';
  }
  static String parentPhone(Map<String, dynamic> s) => formatIsraeliPhone(fam(s)['phone'] ?? '');
  static bool parentMissing(Map<String, dynamic> s) => (fam(s)['phone'] as String? ?? '').isEmpty; // ללא-הורה-מעודכן = אין טלפון-קשר
  static List<Map<String, dynamic>> siblings(Map<String, dynamic> s) => students.where((o) => o['famId'] == s['famId'] && o['id'] != s['id']).toList();

  // ─── פניות/משימות (מקור: WorkTask ref{kind:'family', memberId}) ───
  static List<Map<String, dynamic>> tasks() => (db['tasks'] as List).cast<Map<String, dynamic>>();
  static List<Map<String, dynamic>> tasksOf(Map<String, dynamic> s) => [for (final t in tasks()) if ((t['ref'] as Map?)?['memberId'] == s['id'] || ((t['ref'] as Map?)?['memberId'] == null && (t['ref'] as Map?)?['id'] == s['famId'])) t];
  static List<Map<String, dynamic>> openTasksOf(Map<String, dynamic> s) => tasksOf(s).where((t) => '${t['doneAt'] ?? ''}'.isEmpty).toList();
  static bool hasOpenTicket(Map<String, dynamic> s) => openTasksOf(s).isNotEmpty;
  static bool hasOverdue(Map<String, dynamic> s) => openTasksOf(s).any((t) => taskOverdue(t, today));

  // ═══ ציון-סיכון מאוחד (הכרעה 23-ד: חיבור-כל-האותות בהחלטה) — חוזה-אותות = מקום-שמור (חוק-7) ═══
  //   כל אות: key · label · weight · get(s)⇒0..1 או null (אין-נתון ⇒ שקט, המשקל מנורמל על הזמינים).
  //   אותות עם מקור-אמת: נוכחות (presents/absences) · מגמה (trendFromScan) · משפחתי (Family+WorkTask).
  //   מקום-שמור (אפס-זיוף): ציונים (s['grades'] מפה מקצוע⇒ציון) · התנהגות (s['behavior'] אירועים/חודש) · חברתי-רגשי (s['social'] 0..1).
  //   כשיגיע נתון לרשומה — האות מאיר לבד, אפס-שינוי-קוד (מבחן-הקונכייה).
  static const minSample = 5; // אות-נוכחות דורש ≥5 מפגשים (נתפס ברנדר: תלמידה חדשה עם 3 מפגשים קיבלה 40 נק׳ מחיסור-אחד)
  static double? _attN(Map<String, dynamic> s) {
    final r = attendance(s);
    if (r == null || presents(s) + absences(s) < minSample) return null;
    final base = clampScale((0.92 - r) / 0.25, 0.0, 1.0).toDouble(); // <92% מתחיל לעלות · 67% = מלא
    final ns = noshow(s) >= 2 ? 0.6 : 0.0; // אי-הופעות חוזרות = אות עצמאי
    return base > ns ? base : ns;
  }
  static double? _trendN(Map<String, dynamic> s) {
    final t = trend90(s);
    if (t['dir'] != 'down') return months(s).length < 2 ? null : 0.0;
    return clampScale(-(t['pct'] as num) / 40, 0.0, 1.0).toDouble();
  }
  static double _famN(Map<String, dynamic> s) {
    var v = 0.0;
    if (parentMissing(s)) v += 0.5;
    final st = fam(s)['status'];
    if (st == 'pending' || st == 'inactive') v += 0.3;
    if (hasOverdue(s)) v += 0.3;
    return clampScale(v, 0.0, 1.0).toDouble();
  }
  static double? _gradesN(Map<String, dynamic> s) { // מקום-שמור: מפה מקצוע⇒ציון (0..100)
    final g = s['grades'];
    if (g is! Map || g.isEmpty) return null;
    final avg = grandTotal(g.values.toList(), (v) => v as num) / g.length;
    return clampScale((75 - avg) / 30, 0.0, 1.0).toDouble();
  }
  static double? _behaviorN(Map<String, dynamic> s) { // מקום-שמור: אירועי-התנהגות בחודש
    final b = s['behavior'];
    return b is num ? clampScale(b / 4, 0.0, 1.0).toDouble() : null;
  }
  static double? _socialN(Map<String, dynamic> s) { // מקום-שמור: מדד חברתי-רגשי 0..1 (1=מצוקה)
    final v = s['social'];
    return v is num ? clampScale(v, 0.0, 1.0).toDouble() : null;
  }
  static final List<Map<String, Object>> signalDefs = <Map<String, Object>>[
    {'key': 'attendance', 'label': 'נוכחות', 'weight': 40, 'get': _attN},
    {'key': 'trend', 'label': 'מגמה', 'weight': 15, 'get': _trendN},
    {'key': 'family', 'label': 'משפחתי', 'weight': 15, 'get': (Map<String, dynamic> s) => _famN(s)},
    {'key': 'grades', 'label': 'ציונים', 'weight': 15, 'get': _gradesN},     // מקום-שמור
    {'key': 'behavior', 'label': 'התנהגות', 'weight': 10, 'get': _behaviorN}, // מקום-שמור
    {'key': 'social', 'label': 'חברתי-רגשי', 'weight': 5, 'get': _socialN}, // מקום-שמור
  ];
  // פירוק-האותות: {key, label, weight, value(0..1|null), contribution(נק׳)}
  static List<Map<String, dynamic>> signals(Map<String, dynamic> s) {
    final rows = <Map<String, dynamic>>[];
    for (final d in signalDefs) {
      final v = (d['get'] as double? Function(Map<String, dynamic>))(s);
      rows.add({'key': d['key'], 'label': d['label'], 'weight': d['weight'], 'value': v});
    }
    final wAvail = grandTotal(rows.where((r) => r['value'] != null).toList(), (r) => (r as Map)['weight'] as int);
    for (final r in rows) {
      r['contribution'] = r['value'] == null || wAvail == 0 ? 0.0 : (r['value'] as double) * (r['weight'] as int) * 100 / wAvail;
    }
    return rows;
  }
  static int risk(Map<String, dynamic> s) => grandTotal(signals(s), (r) => (r as Map)['contribution'] as double).round().clamp(0, 100);
  static Map<String, dynamic>? leading(Map<String, dynamic> s) { // האות-המוביל = התרומה הגדולה
    Map<String, dynamic>? best;
    for (final r in signals(s)) { if (r['value'] != null && (best == null || (r['contribution'] as double) > (best['contribution'] as double))) best = r; }
    return best;
  }
  static int band(Map<String, dynamic> s) { final r = risk(s); return r >= 55 ? 2 : r >= 30 ? 1 : 0; } // 2=גבוה · 1=בינוני · 0=נמוך
  static String bandLabel(int b) => b == 2 ? 'סיכון גבוה' : b == 1 ? 'סיכון בינוני' : 'יציב';
  // הפעולה-הנכונה-עכשיו: נגזרת מ-band ⊕ האות-המוביל (הכרעה = חיבור, לא בחירה)
  static String action(Map<String, dynamic> s) {
    final b = band(s), l = leading(s)?['key'];
    if (!isActive(s)) return status(s) == 'הוקפא' ? 'מעקב-חזרה + עדכון הורים' : 'ארכיון — אין פעולה';
    if (b == 0) return 'מעקב שגרתי';
    if (l == 'family') return b == 2 ? 'יועץ/ת + השגת קשר-הורה היום' : 'עדכון פרטי-הורה + שיחה';
    if (l == 'trend') return b == 2 ? 'שיחה אישית + יידוע הורים' : 'שיחה אישית השבוע';
    if (l == 'grades') return b == 2 ? 'תוכנית-תגבור + שיחת-הורים' : 'תגבור במקצוע החלש';
    if (l == 'behavior' || l == 'social') return b == 2 ? 'יועץ/ת + ועדת-שילוב' : 'שיחת-יועץ/ת';
    return b == 2 ? 'ועדת-שילוב + ביקור-בית' : 'שיחת-מחנך/ת + יידוע-הורים';
  }
  static int get highN => active.where((s) => band(s) == 2).length;
  static int get midN => active.where((s) => band(s) == 1).length;

  // ─── KPI (הערכת-מצב · הכל מנועי-מדף/שדות-אמת) ───
  static int? get avgAttendance {
    final withData = active.where((s) => attendance(s) != null).toList();
    if (withData.isEmpty) return null;
    return (grandTotal(withData, (s) => attendance(s as Map<String, dynamic>)!) * 100 / withData.length).round();
  }
  // מקום-שמור: ממוצע-ציונים מואר רק כשרשומה כלשהי נושאת grades
  static int? get avgGrades {
    final withData = active.where((s) => s['grades'] is Map && (s['grades'] as Map).isNotEmpty).toList();
    if (withData.isEmpty) return null;
    return (grandTotal(withData, (s) { final g = (s as Map)['grades'] as Map; return grandTotal(g.values.toList(), (v) => v as num) / g.length; }) / withData.length).round();
  }
  static int get medicalN => active.where((s) => '${s['health'] ?? ''}'.isNotEmpty).length;
  static int get noParentN => active.where(parentMissing).length;
  static int get openTicketsN => tasks().where((t) => '${t['doneAt'] ?? ''}'.isEmpty && (t['ref'] as Map?)?['kind'] == 'family').length;
  static int get newN => active.where(isNew).length;
  static List<List<Object>> byClass() => countBy(active, (s) => className(s as Map<String, dynamic>));
  static int daysSince(String iso) => cockpitDaysSince(iso, today).toInt();
  static String fmt(String? iso) => fmtDate(iso);

  // ─── מיון (איתור·דירוג): סיכון-יורד · כיתה (gradeIndex⊕שם-כיתה) · שם (nameSortKey⊕normSearch) ───
  static const Map<String, String> _finals = {'k1': 'כ', 'k2': 'מ', 'k3': 'נ', 'k4': 'פ', 'k5': 'צ'};
  static String norm(dynamic q) => normSearch(q, _finals);
  static String sortKey(Map<String, dynamic> s) => nameSortKey(s['name'], norm, const <String>{});
  static List<Map<String, dynamic>> sorted(List<Map<String, dynamic>> xs, int mode) {
    final out = [...xs];
    if (mode == 1) {
      out.sort((a, b) { final c = gradeIdx(a).compareTo(gradeIdx(b)); return c != 0 ? c : className(a).compareTo(className(b)) != 0 ? className(a).compareTo(className(b)) : sortKey(a).compareTo(sortKey(b)); });
    } else if (mode == 2) {
      out.sort((a, b) => sortKey(a).compareTo(sortKey(b)));
    } else {
      out.sort((a, b) => risk(b).compareTo(risk(a)));
    }
    return out;
  }

  // ─── דגלים (מפרט: צרכים/רגישות/רפואי): רפואי ⇐ Member.health (מקור-אמת) · צרכים/רגישות ⇐ פנקס-דגלים (פעולה "הוסף-דגל") ───
  static final Map<String, List<String>> flagLedger = {};
  static List<String> flags(Map<String, dynamic> s) => [
        if ('${s['health'] ?? ''}'.isNotEmpty) '🩺 רפואי',
        ...(flagLedger[s['id']] ?? const []),
        if (s['needs'] != null) '♿ צרכים', // מקום-שמור: שדה-צרכים ברשומה
      ];
  // עדכון-אחרון (נגזר מטבעת-האודיט: הרשומה האחרונה שמזכירה את התלמיד; אין updatedAt בסכמה)
  static List<Map<String, dynamic>> audit() => (db['audit'] as List).cast<Map<String, dynamic>>();
  static String lastUpdate(Map<String, dynamic> s) {
    String best = '';
    for (final a in audit()) { if ('${a['what']}'.startsWith('${s['id']} ') && '${a['at']}'.compareTo(best) > 0) best = '${a['at']}'; }
    return best.isEmpty ? '—' : fmt(best.substring(0, 10));
  }
  static String trendArrow(Map<String, dynamic> s) { final t = trend90(s); return t['dir'] == 'down' ? '↓ ${t['pct']}%' : t['dir'] == 'up' ? '↑ +${t['pct']}%' : '→'; }
  static String maskId(String? id) => (id == null || id.isEmpty) ? '—' : '•••••${id.substring(id.length - 4)}'; // ת״ז מוסתרת (ברירת-מחדל; חשיפה = הרשאה)

  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 18 עמודות-המפרט כשקעי-דאטה ═══
  //   נגזרת(get) = תמיד-מוצגת · שדה(key) = מוארת רק כשרשומה כלשהי נושאת ערך (חסר ⇒ שקט). fmt = עיצוב-ערך אופציונלי.
  //   הוספת שדה לרשומה (photo/grades/…) ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    {'key': 'photo', 'label': 'תמונה'},                                                   // מקום-שמור (ImageProvider/URL)
    {'label': 'שם-מלא', 'get': (Map<String, dynamic> s) => '${s['name']}'},
    {'label': 'מס׳', 'get': (Map<String, dynamic> s) => '${s['id']}'},
    {'label': 'ת״ז', 'get': (Map<String, dynamic> s) => maskId(s['idNum'] as String?)}, // מוסתר-פר-הרשאה
    {'label': 'כיתה', 'get': (Map<String, dynamic> s) => className(s)},
    {'label': 'מחנך/ת', 'get': (Map<String, dynamic> s) => teacherName(s)},
    {'label': 'לידה/גיל', 'get': (Map<String, dynamic> s) => '${fmt(s['birth'] as String?)} · ${age(s) ?? '—'}'},
    {'label': 'מין', 'get': (Map<String, dynamic> s) => s['gender'] == 'f' ? 'נ' : s['gender'] == 'm' ? 'ז' : '—'},
    {'label': 'סטטוס', 'get': (Map<String, dynamic> s) => status(s)},
    {'label': 'סיכון', 'get': (Map<String, dynamic> s) => '${risk(s)}'},
    {'label': 'נוכחות%', 'get': (Map<String, dynamic> s) => attendance(s) == null ? '—' : '${attendancePct(s)}'},
    {'key': 'grades', 'label': 'ממוצע-ציונים', 'fmt': (Object? g) => g is Map && g.isNotEmpty ? '${(grandTotal(g.values.toList(), (v) => v as num) / g.length).round()}' : '—'}, // מקום-שמור
    {'label': 'מגמה', 'get': (Map<String, dynamic> s) => trendArrow(s)},
    {'label': 'דגלים', 'get': (Map<String, dynamic> s) => flags(s).isEmpty ? '—' : flags(s).join(' ')},
    {'label': 'הורה+טלפון', 'get': (Map<String, dynamic> s) => parentMissing(s) ? '${parentName(s)} · ⛔ אין טלפון' : '${parentName(s)} · ${parentPhone(s)}'},
    {'label': 'הצטרפות', 'get': (Map<String, dynamic> s) => fmt(mainEnrollment(s)?['enrolledAt'] as String?)},
    {'label': 'פנייה-פתוחה', 'get': (Map<String, dynamic> s) => hasOpenTicket(s) ? '📨 ${openTasksOf(s).length}' : '—'},
    {'label': 'עדכון-אחרון', 'get': (Map<String, dynamic> s) => lastUpdate(s)},
  ];
  static bool colShown(Map<String, Object?> c, List<Map<String, dynamic>> rows) =>
      c['get'] != null || rows.any((s) => s[c['key']] != null && '${s[c['key']]}'.trim().isNotEmpty);
  static String cell(Map<String, Object?> c, Map<String, dynamic> s) {
    if (c['get'] != null) return (c['get'] as String Function(Map<String, dynamic>))(s);
    final v = s[c['key']];
    if (c['fmt'] != null) return (c['fmt'] as String Function(Object?))(v);
    return v == null ? '—' : '$v';
  }
}

// ═══════════════════════════════════════════════════════════════════════════════════════════
class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, this.db}); // db מוזרק (חוק-6) — null ⇒ דאטה-האמת המובנית
  final Map<String, dynamic>? db;
  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  String _q = ''; // איתור (DsSearch)
  int _mode = 0; // 0=🎯 טריאז' (קיבוץ-פר-סיכון) · 1=📋 טבלה (columnDefs) — SegmentedSwitch→תצוגה
  int _sort = 0; // 0=סיכון · 1=כיתה · 2=שם — SegmentedSwitch→דירוג
  bool _loading = false; // מצב-מסך שמור: טעינה
  String? _error; // מצב-מסך שמור: שגיאה (מקום-שמור — מאיר כש-fetch נכשל)

  @override
  void initState() {
    super.initState();
    if (widget.db != null) _StuData.use(widget.db!); else _StuData.reset();
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);

  @override
  Widget build(BuildContext context) {
    final all = _StuData.active;
    final avgAtt = _StuData.avgAttendance, avgGr = _StuData.avgGrades;
    // דירוג (מיון-נבחר) ⇒ הנראים (פעילים); לא-פעילים בסקשן-ארכיון נפרד
    final visible = _StuData.sorted(all, _sort);
    final inactiveVisible = _StuData.sorted(_StuData.inactive, _sort);
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: []};
    for (final s in visible) { buckets[_StuData.band(s)]!.add(s); }
    return DsScaffold(
      title: 'תלמידים', subtitle: '${_StuData.students.length} תלמידים · ${_StuData.byClass().length} כיתות · ${_StuData.highN} בסיכון-גבוה', icon: '🎓',
      children: [
        // פס-עליון: חיפוש-מבוקר + רענון (מצב-טעינה) + רישום + ייבוא + ייצוא
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔄', tone: 0, onTap: _refresh)),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '➕ תלמיד', tone: 1, onTap: () {})),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '📥 ייבוא', tone: 0, onTap: () {})),
        ]),
        // KPI-10 (המפרט): hero = המטרה (מי-נופל) + 10 מדדי-מצב (BareStat נושאי-ערך; חסר-נתון ⇒ '—' מקום-שמור)
        GradientCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            StatHero(value: '${_StuData.highN}', label: 'תלמידים בסיכון-גבוה — לפעול עכשיו'),
            const SizedBox(height: 14),
            Row(children: [
              BareStat(value: '${_StuData.students.length}', label: '🎓 סך-תלמידים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${all.length}', label: '✅ פעילים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_StuData.newN}', label: '🆕 חדשים-השנה', inkColor: _acc, mutedColor: _muted),
              BareStat(value: '${_StuData.highN}', label: '🔴 סיכון-גבוה', inkColor: _StuData.highN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_StuData.midN}', label: '🟠 סיכון-בינוני', inkColor: _StuData.midN > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              BareStat(value: avgAtt == null ? '—' : '$avgAtt%', label: '📅 ממוצע-נוכחות', inkColor: (avgAtt ?? 100) < 85 ? _warning : _ok, mutedColor: _muted),
              BareStat(value: avgGr == null ? '—' : '$avgGr', label: '📝 ממוצע-ציונים', inkColor: avgGr == null ? _muted : _ink, mutedColor: _muted), // מקום-שמור
              BareStat(value: '${_StuData.medicalN}', label: '🩺 רפואי/צרכים', inkColor: _ink, mutedColor: _muted),
              BareStat(value: '${_StuData.noParentN}', label: '📵 ללא-הורה-מעודכן', inkColor: _StuData.noParentN > 0 ? _danger : _ok, mutedColor: _muted),
              BareStat(value: '${_StuData.openTicketsN}', label: '📨 פניות-פתוחות', inkColor: _StuData.openTicketsN > 0 ? _warning : _ok, mutedColor: _muted),
            ]),
          ]),
        ),
        _gap(8),
        // בורר-מבט (🎯 טריאז' · 📋 טבלה) + בורר-דירוג (סיכון · כיתה · שם) — ארגון = פעולת-יסוד עם אטום משלה
        Row(children: [
          SegmentedSwitch(items: const ['🎯 טריאז׳', '📋 טבלה'], selected: _mode, onSelect: (i) => setState(() => _mode = i)),
          const Spacer(),
          SegmentedSwitch(items: const ['⚠ סיכון', '🏫 כיתה', '🔤 שם'], selected: _sort, onSelect: (i) => setState(() => _sort = i)),
        ]),
        _gap(10),
        // מצבי-מסך שמורים (טעינה/שגיאה) ⇒ אחרת התוכן: ריק · טבלה · טריאז'
        if (_loading)
          _loadingView()
        else if (_error != null)
          AlertBanner(glyph: '⚠️', tone: 2, message: _error!)
        else if (_StuData.students.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '🎓', message: 'אין תלמידים עדיין — רשום תלמיד ראשון או ייבא'))
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.only(top: 24), child: EmptyState(glyph: '🔍', message: 'אין תלמידים תואמים לחיפוש/סינון'))
        else if (_mode == 1)
          _table(visible)
        else ...[
          // טריאז' — פעולת-יסוד "הכרעה" מקבצת פר-band (הדחוף בראש כקבוצה); בתוך כל דלי — סדר-הדירוג הנבחר
          for (final b in const [2, 1, 0])
            if (buckets[b]!.isNotEmpty)
              DsSection(title: '${_secTitle[b]} · ${buckets[b]!.length}', tone: _secTone[b]!, children: [for (final s in buckets[b]!) _row(s)]),
        ],
        // מצב-מיוחד: לא-פעילים (הוקפא/עזב/בוגר) — מחוץ לתפעול, גלויים כארכיון
        if (_mode == 0 && inactiveVisible.isNotEmpty) ...[
          _gap(10),
          DsSection(title: '🗂 לא-פעילים · ${inactiveVisible.length}', tone: 0, children: [for (final s in inactiveVisible) _row(s)]),
        ],
      ],
    );
  }

  static const _secTitle = {2: '🔴 סיכון גבוה — לפעול היום', 1: '🟠 סיכון בינוני — לעקוב השבוע', 0: '🟢 יציבים'};
  static const _secTone = {2: 2, 1: 3, 0: 1};

  // שורת-תלמיד (טריאז'): זהות (MediaRow) + בר-סיכון (StatRow) + האות-המוביל ⊕ הפעולה-הנכונה-עכשיו (StatusChip×2) + דגלים/סטטוס
  //   MediaRow בולע קליק (InkWell פנימי) ⇒ כפתור-שברון נפרד כשקע-הפתיחה (לקח-המלאי).
  Widget _row(Map<String, dynamic> s) {
    final r = _StuData.risk(s), b = _StuData.band(s), active = _StuData.isActive(s);
    final tone = b == 2 ? 2 : b == 1 ? 3 : 1;
    final lead = _StuData.leading(s);
    final glyph = !active ? '🗂' : b == 2 ? '🔴' : b == 1 ? '🟠' : '🟢';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: MediaRow(glyph: glyph, title: '${s['name']}', subtitle: '${_StuData.className(s)} · ${_StuData.teacherName(s)} · גיל ${_StuData.age(s) ?? '—'}')),
            IconButton(onPressed: () => _openPanel(s), icon: const Icon(Icons.chevron_left, color: _acc, size: 26), tooltip: 'כרטיס-תלמיד'),
          ]),
          _gap(8),
          StatRow(label: active ? 'ציון-סיכון מאוחד' : 'ציון-סיכון (ארכיון)', value: 'סיכון $r · ${_StuData.bandLabel(b)}', fraction: (r / 100).clamp(0.0, 1.0)),
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 4),
            child: Wrap(spacing: 8, runSpacing: 6, children: [
              if (!active) StatusChip(label: _StuData.status(s), tone: 0),
              if (active && b > 0 && lead != null) StatusChip(label: 'האות: ${lead['label']} (${(lead['contribution'] as double).round()} נק׳)', tone: tone),
              StatusChip(label: '👉 ${_StuData.action(s)}', tone: active && b > 0 ? tone : 0),
              for (final f in _StuData.flags(s)) StatusChip(label: f, tone: 0),
              if (_StuData.hasOpenTicket(s)) StatusChip(label: '📨 פנייה פתוחה', tone: 3),
              if (_StuData.parentMissing(s)) const StatusChip(label: '📵 ללא-הורה-מעודכן', tone: 2),
              if (_StuData.isNew(s)) const StatusChip(label: '🆕 חדש/ה השנה', tone: 0),
            ]),
          ),
        ]),
      ),
    );
  }

  // 📋 מבט-טבלה: DsTable מונחה-חוזה (columnDefs · מקום-שמור חוק-7). אפס-DataGrid (מזייף int rows).
  Widget _table(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in _StuData.columnDefs) if (_StuData.colShown(c, rows)) c];
    return DsTable(labels: [for (final c in cols) c['label'] as String], rows: [for (final s in rows) [for (final c in cols) _StuData.cell(c, s)]]);
  }

  void _openPanel(Map<String, dynamic> s) {} // גל 3: כרטיס-תלמיד-נבחר

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה)
  void _refresh() {
    setState(() { _loading = true; _error = null; });
    Future.delayed(const Duration(milliseconds: 700), () { if (mounted) setState(() => _loading = false); });
  }

  // מצב-טעינה שמור: Column-מרוכז (לא Center — קורס ברשימה-נגללת · לקח-המלאי)
  Widget _loadingView() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, children: [
          CircularProgressIndicator(color: _acc),
          const SizedBox(height: 14),
          const Text('טוען תלמידים…', style: TextStyle(color: _muted, fontSize: 14)),
        ]),
      );
}
