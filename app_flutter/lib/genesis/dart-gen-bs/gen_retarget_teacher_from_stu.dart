// 🎯 TeacherScreen — retarget של schoolos_students.dart לישות Teacher (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module schoolos_students.dart --entity Teacher
//   זרע-ראשי: families (מועמדים: families(27/33) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) tasks(9/12) enrollments(8/11) courses(6/9) events(6/8) teachers(4/4) audit(4/4)) · מיפוי שם 8 · ערוץ 0 · טיפוס-יחיד 2 · מקום-שמור 19 · חוזה-מנוע (לא משתנה) 4
//   id⇒id(name) · name⇒name(name) · phone⇒phone(name) · phone2⇒phone2(name) · email⇒email(name) · address⇒address(name) · notes⇒notes(name) · idNum⇒idNum(name) · status⇒∅(engine-contract) · createdAt⇒∅(engine-contract) · docs⇒∅(engine-contract) · members⇒∅(engine-contract) · father⇒∅(reserved(6 מועמדים)) · mother⇒∅(reserved(6 מועמדים)) · city⇒∅(reserved(6 מועמדים)) · language⇒∅(reserved(6 מועמדים)) · maritalStatus⇒∅(reserved(6 מועמדים)) · tzedaka⇒∅(reserved(6 מועמדים)) · discount⇒∅(reserved(6 מועמדים)) · addedAt⇒startDate(unique) · cred⇒∅(reserved) · log⇒∅(reserved) · first⇒∅(reserved(6 מועמדים)) · gender⇒∅(reserved(6 מועמדים)) · birth⇒∅(reserved) · school⇒∅(reserved(6 מועמדים)) · grade⇒∅(reserved(6 מועמדים)) · health⇒∅(reserved(6 מועמדים)) · mSefach⇒payToOther(unique) · mInvite⇒∅(reserved) · mRecommend⇒∅(reserved) · mPhotos⇒∅(reserved) · mVideos⇒∅(reserved)
//   תפר-עובדות (G9b): TeacherFacts · count=families.length (seed-db) · מדדים 6 · hero=highN
//   שדות-Teacher בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): specialty, payRate, payMethod, payeeName, payeePhone, payeeIdNum, bankName, bankBranch, bankAccount · תוויות: מונחי student (תלמיד/ה/תלמידים) ⇒ Teacher (מורה/—) · 2 החלפות · הזרע = זרע-הצבה של המקור, לא ערך-אמת של Teacher
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
import '../dart-ui-bs/premium/surfaces/glass_card.dart'; // מיכל כרטיס-תלמיד (child שרירותי) — פאנל-צד
import '../dart-ui-bs/premium/showcase/premium_avatar.dart'; // זהות: ראשי-תיבות + שקע-תמונה (image) — מקום-שמור לתמונה
import '../dart-ui-bs/premium/dataviz/gauge_meter.dart'; // מד-סיכון 0..1 (tone מוזרק לפי-band)
import '../dart-ui-bs/premium/dataviz/neon_bars.dart'; // פירוק-האותות / נוכחות-חודשית (labels+values)
import '../dart-ui-bs/premium/lists/timeline_item.dart'; // פריט ציר-זמן/הערה/חיסור/מסמך (title/time/body)
import '../dart-ui-bs/premium/lists/expandable_tile.dart'; // הערות-מחנך/ת פר-שנה״ל (title+body מתקפל)
import '../dart-ui-bs/ds/ds_field.dart'; // קלט-טקסט מבוקר (הערה · פנייה · רישום)
import '../dart-ui-bs/ds/ds_enum_field.dart'; // בחירה-מרשימה (העבר-כיתה · דגל)
import '../dart-maor/presents-in-month.dart'; // נוכחות-בחודש-הנוכחי (presents ⊕ today)
import '../dart-maor/student-history.dart'; // היסטוריית-רישומים/כיתות (enrollments⊕courses⊕renewedToId)
import '../dart-maor/academic-year-label.dart'; // תווית שנה״ל מתאריך-התחלה
import '../dart-maor/wa-link.dart'; // קישור-וואטסאפ להורה (phone+text)
import '../dart-maor/wa-digits.dart'; // נרמול-ספרות בינ״ל לוואטסאפ — שקע ל-waLink
import '../dart-maor/tel-href.dart'; // קישור-חיוג tel:
import '../dart-maor/parse-csv.dart'; // ייבוא: טקסט-CSV ⇒ שורות (מפריד אוטו · מרכאות)
import '../dart-ui-bs/screens__manager_dashboard_screen/filter_chip_pill.dart'; // צ׳יפ-סינון מבוקר (selected+onTap)
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/finder-matches.dart'; // חריגה: סינון-רב-צירי AND (מדף)
import '../dart-maor/num-match.dart'; // סף-מספרי ('0-79' · '80+') (מדף)
import '../dart-maor/norm-phone.dart'; // נרמול-טלפון לחיפוש-הורה
import '../dart-maor/role-of.dart'; // הרשאות: תפקיד-לפי-מייל admin/teacher/staff (מדף)
import '../dart-maor/can-granted-action.dart'; // הרשאות: גידור-פעולה פר-מפתח (מדף)
import '../dart-maor/find-duplicate-groups.dart'; // אוטומציה: זיהוי-כפולים (union-find על טלפון/מפתח-שם)
import '../dart-maor/merge-families.dart'; // פעולה: מיזוג-כפולים (keeper⊕losers ⇒ רשומה ממוזגת)
import '../dart-maor/norm-name.dart'; // מפתח-שם מנורמל לכפולים
import '../dart-maor/cockpit-at-risk.dart'; // אוטומציה: "שקטים" N ימים (ללא הערת-מחנך 90 יום)
import '../dart-maor/sup-score-bins.dart'; // השוואת-שכבה: התפלגות-ציונים ל-10 דליים (percentile)
import '../dart-maor/to-csv.dart'; // ייצוא: שורות⇒CSV+BOM (מדף)
import '../dart-maor/csv-escape.dart'; // ייצוא: הגנת-תא (חוסם CSV-injection) (מדף)
import '../dart-maor/export-allowed.dart'; // ייצוא: שער-יציאת-מידע (מדף)

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
        'teachers': <Map<String, dynamic>>[
          {'id': 't1', 'name': 'רותי אלמוג', 'phone': '0521110001', 'email': 'ruti@school'},
          {'id': 't2', 'name': 'דוד פרץ', 'phone': '0521110002', 'email': 'david@school'},
          {'id': 't3', 'name': 'מיכל שרון', 'phone': '0521110003', 'email': 'michal@school'},
          {'id': 't4', 'name': 'יוסי כהן', 'phone': '0521110004', 'email': 'yossi@school'},
        ],
        // כיתת-חינוך = Course (teacherId · year · start/end · gradeMin/Max) — מקור: Course
        'courses': <Map<String, dynamic>>[
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
        'families': <Map<String, dynamic>>[
          {'id': 'f1', 'name': 'שמעוני', 'father': 'אבי', 'mother': 'דנה', 'phone': '0528811223', 'phone2': '0528811224', 'email': '', 'city': 'חולון', 'address': 'הבנים 12', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2024-08-20',
            'docs': [{'id': 'd1', 'name': 'טופס-רישום-2024.pdf', 'startDate': '2024-08-20'}, {'id': 'd2', 'name': 'אישור-מדיה-חתום.pdf', 'startDate': '2025-09-02'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm1', 'first': 'רון', 'gender': 'm', 'birth': '2010-11-03', 'idNum': '210079190', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': false, 'notes': 'מוסח בשיעורי-בוקר; מגיב טוב לעידוד.'},
              {'id': 'm2', 'first': 'נועה', 'gender': 'f', 'birth': '2013-09-12', 'idNum': '210134623', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ז', 'health': '', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f2', 'name': 'אוחיון', 'father': '', 'mother': 'שרית', 'phone': '0543322110', 'phone2': '', 'email': '', 'city': 'בת-ים', 'address': 'רוטשילד 4', 'language': 'צרפתית', 'maritalStatus': 'גרושה', 'status': 'active', 'tzedaka': 'מלגה', 'discount': '50', 'notes': 'אם יחידנית · עובדת במשמרות', 'createdAt': '2023-08-15',
            'docs': [{'id': 'd3', 'name': 'אישור-מלגה.pdf', 'startDate': '2025-10-01'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm3', 'first': 'ליאור', 'gender': 'm', 'birth': '2011-05-20', 'idNum': '210205894', 'phone': '0551234567', 'school': 'תיכון עתיד', 'grade': 'ט', 'health': 'אסתמה — משאף בתיק', 'payToOther': true, 'mInvite': true, 'mRecommend': false, 'mPhotos': false, 'mVideos': false, 'notes': 'נעדר הרבה מאז יוני; לבדוק מול הבית.'},
            ]},
          {'id': 'f3', 'name': 'נחום', 'father': 'משה', 'mother': 'אורית', 'phone': '', 'phone2': '', 'email': '', 'city': 'ראשון-לציון', 'address': 'הרצל 88', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2022-09-01',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm4', 'first': 'הדר', 'gender': 'f', 'birth': '2012-02-14', 'idNum': '210261327', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ח', 'health': '', 'payToOther': true, 'mInvite': false, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f4', 'name': 'ביטון', 'father': 'יעקב', 'mother': 'רחל', 'phone': '0507712345', 'phone2': '', 'email': '', 'city': 'חולון', 'address': 'סוקולוב 3', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2021-08-30',
            'docs': [{'id': 'd4', 'name': 'תעודת-סיום-יב.pdf', 'startDate': '2026-06-25'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm5', 'first': 'מאיה', 'gender': 'f', 'birth': '2010-07-08', 'idNum': '210324679', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': 'מובילה חברתית בכיתה.'},
              {'id': 'm6', 'first': 'עומר', 'gender': 'm', 'birth': '2008-03-30', 'idNum': '210395950', 'phone': '0521239876', 'school': 'תיכון עתיד', 'grade': 'יב', 'health': '', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f5', 'name': 'לוי', 'father': 'אייל', 'mother': 'טל', 'phone': '0539988776', 'phone2': '', 'email': '', 'city': 'חולון', 'address': 'ויצמן 21', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'pending', 'tzedaka': '', 'discount': '', 'notes': 'משפחה חדשה — עברו מעיר אחרת', 'createdAt': '2026-08-25',
            'docs': [{'id': 'd5', 'name': 'טופס-רישום-2026.pdf', 'startDate': '2026-08-25'}], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm7', 'first': 'נועה', 'gender': 'f', 'birth': '2010-09-25', 'idNum': '210467221', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': false, 'mVideos': false, 'notes': ''},
            ]},
          // רשומה-כפולה חשודה (ייבוא): אותו טלפון + אותו שם-ילד + אותה לידה ⇒ זיהוי-כפולים (findDuplicateGroups)
          {'id': 'f6', 'name': 'לוי', 'father': '', 'mother': 'טל', 'phone': '0539988776', 'phone2': '', 'email': '', 'city': 'חולון', 'address': '', 'language': '', 'maritalStatus': '', 'status': 'pending', 'tzedaka': '', 'discount': '', 'notes': 'נוצר מייבוא-CSV 2.9', 'createdAt': '2026-09-02',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm8', 'first': 'נועה', 'gender': 'f', 'birth': '2010-09-25', 'idNum': '', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'י', 'health': '', 'payToOther': false, 'mInvite': false, 'mRecommend': false, 'mPhotos': false, 'mVideos': false, 'notes': ''},
            ]},
          {'id': 'f7', 'name': 'מזרחי', 'father': 'שלמה', 'mother': 'לימור', 'phone': '0581122334', 'phone2': '', 'email': '', 'city': 'בת-ים', 'address': 'בלפור 9', 'language': 'עברית', 'maritalStatus': 'נשואים', 'status': 'inactive', 'tzedaka': '', 'discount': '', 'notes': 'עברו לירושלים 3/2026', 'createdAt': '2022-08-28',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm9', 'first': 'יובל', 'gender': 'm', 'birth': '2011-12-01', 'idNum': '210538492', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ט', 'health': '', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': true, 'notes': ''},
            ]},
          {'id': 'f8', 'name': 'כהן', 'father': 'רועי', 'mother': 'שירה', 'phone': '0526677889', 'phone2': '', 'email': '', 'city': 'ראשון-לציון', 'address': 'ז׳בוטינסקי 40', 'language': 'רוסית', 'maritalStatus': 'נשואים', 'status': 'active', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': '2024-08-18',
            'docs': [], 'cred': {'score': 0, 'log': []},
            'members': [
              {'id': 'm10', 'first': 'איתי', 'gender': 'm', 'birth': '2012-06-17', 'idNum': '210665196', 'phone': '', 'school': 'תיכון עתיד', 'grade': 'ח', 'health': 'אלרגיה לבוטנים (אפיפן)', 'payToOther': true, 'mInvite': true, 'mRecommend': true, 'mPhotos': true, 'mVideos': false, 'notes': 'הוקפא לחודש — אשפוז; חוזר 1.10'},
            ]},
        ],
        // רישום = Enrollment: memberId · courseId · status(active/paused/ended/wait) · presents[] · absences[] · enrolledAt · endedAt · renewedToId
        'enrollments': <Map<String, dynamic>>[
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
        'tasks': <Map<String, dynamic>>[
          {'id': 'k1', 'assignee': 'counselor@school', 'by': 'ruti@school', 'title': 'פנייה ליועצת: ליאור אוחיון — היעדרויות', 'ref': {'kind': 'family', 'id': 'f2', 'memberId': 'm3'}, 'pri': 1, 'due': '2026-09-01', 'createdAt': '2026-06-20', 'doneAt': '', 'note': 'לא נוצר קשר עם הבית'},
          {'id': 'k2', 'assignee': 'office@school', 'by': 'ruti@school', 'title': 'אישור-טיולים פג — רון שמעוני', 'ref': {'kind': 'family', 'id': 'f1', 'memberId': 'm1', 'consent': 'trips'}, 'pri': 2, 'due': '2026-09-10', 'createdAt': '2026-08-20', 'doneAt': '', 'note': ''},
          {'id': 'k3', 'assignee': 'office@school', 'by': 'michal@school', 'title': 'אישור-תרופות פג — איתי כהן', 'ref': {'kind': 'family', 'id': 'f8', 'memberId': 'm10', 'consent': 'meds'}, 'pri': 1, 'due': '2026-08-30', 'createdAt': '2026-08-01', 'doneAt': '', 'note': ''},
          {'id': 'k4', 'assignee': 'ruti@school', 'by': 'ruti@school', 'title': 'שיחת-הכרות — נועה לוי', 'ref': {'kind': 'family', 'id': 'f5', 'memberId': 'm7'}, 'pri': 2, 'due': '2026-09-08', 'createdAt': '2026-09-01', 'doneAt': '', 'note': ''},
          {'id': 'k5', 'assignee': 'counselor@school', 'by': 'michal@school', 'title': 'פנייה ליועצת: הדר נחום — אין קשר עם ההורים', 'ref': {'kind': 'family', 'id': 'f3', 'memberId': 'm4'}, 'pri': 2, 'due': '2026-06-30', 'createdAt': '2026-06-10', 'doneAt': '2026-06-28', 'note': 'נסגר — הושג קשר דרך הסבתא'},
        ],
        // אירועים = OrgEvent (famId · date · title · type · done) — ציר-זמן-תלמיד
        'events': <Map<String, dynamic>>[
          {'id': 'v1', 'title': 'שיחת-מחנכת עם ההורים', 'date': '2026-06-22', 'time': '17:00', 'type': 'meeting', 'famId': 'f2', 'priority': 'high', 'done': true},
          {'id': 'v2', 'title': 'ועדת-שילוב', 'date': '2026-09-09', 'time': '13:00', 'type': 'meeting', 'famId': 'f2', 'priority': 'high', 'done': false},
          {'id': 'v3', 'title': 'שיחת-הכרות משפחה חדשה', 'date': '2026-09-08', 'time': '16:30', 'type': 'meeting', 'famId': 'f5', 'priority': 'normal', 'done': false},
          {'id': 'v4', 'title': 'יום-הורים', 'date': '2026-06-15', 'time': '18:00', 'type': 'meeting', 'famId': 'f1', 'priority': 'normal', 'done': true},
        ],
        // אודיט = AuditEntry {at, who, act, what} — טבעת-אודיט (pullAuditRing/pushAuditRing = תפר-ההתמדה, כאן בזיכרון)
        'audit': <Map<String, dynamic>>[
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
  static List<String> presentsOf(Map<String, dynamic> s) => [for (final e in enrollmentsOf(s)) for (final d in ((e['presents'] as List?) ?? const []).cast<String>()) if (_cutoff.isEmpty || d.compareTo(_cutoff) <= 0) d];
  static List<Map<String, dynamic>> absencesOf(Map<String, dynamic> s) => [for (final e in enrollmentsOf(s)) for (final a in ((e['absences'] as List?) ?? const []).cast<Map<String, dynamic>>()) if (_cutoff.isEmpty || '${a['date']}'.compareTo(_cutoff) <= 0) a];
  static int presents(Map<String, dynamic> s) => _cutoff.isEmpty ? grandTotal(enrollmentsOf(s), (e) => summary(e as Map<String, dynamic>)['presents'] as int).toInt() : presentsOf(s).length;
  static int absences(Map<String, dynamic> s) => _cutoff.isEmpty ? grandTotal(enrollmentsOf(s), (e) => summary(e as Map<String, dynamic>)['absences'] as int).toInt() : absencesOf(s).length;
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
  static int roleCtx = 0; // התפקיד-הפעיל (מוזרק מהמסך לפני רינדור-טבלה)
  static final List<Map<String, Object?>> columnDefs = <Map<String, Object?>>[
    // ═══ חוזה-העמודות של Teacher (G5h · חוק-7): 9 שדות-סכמה בלי מקור בזרע — עמודות-מקום-שמור, לא מזויפות ולא מושמטות ═══
    {'key': 'specialty', 'label': 'specialty'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'payRate', 'label': 'payRate'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (number) — מאיר כשהנתון מוזרם
    {'key': 'payMethod', 'label': 'payMethod'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה ('cash' | 'salary' | 'check' | '') — מאיר כשהנתון מוזרם
    {'key': 'payeeName', 'label': 'payeeName'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'payeePhone', 'label': 'payeePhone'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'payeeIdNum', 'label': 'payeeIdNum'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'bankName', 'label': 'bankName'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'bankBranch', 'label': 'bankBranch'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'bankAccount', 'label': 'bankAccount'}, // G5h · מקום-שמור: שדה-Teacher מהסכמה (string) — מאיר כשהנתון מוזרם
    {'key': 'photo', 'label': 'תמונה'},                                                   // מקום-שמור (ImageProvider/URL)
    {'label': 'שם-מלא', 'get': (Map<String, dynamic> s) => '${s['name']}'},
    {'label': 'מס׳', 'get': (Map<String, dynamic> s) => '${s['id']}'},
    {'label': 'ת״ז', 'get': (Map<String, dynamic> s) => can(roleCtx, 'stu.protected') ? protectedField(roleCtx, s, 'idNum', '${s['idNum'] ?? ''}') : maskId(s['idNum'] as String?)}, // מוסתר-פר-הרשאה (חשיפה נרשמת)
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
  // ═══ פנקס-פעולות (ביצוע = state · חוק-1 מצב=חיווט): כל פעולה כותבת לרשומות-האמת (db) + טבעת-אודיט ═══
  //   הבסיס נשאר seed() (מקור-האמת); reset() משחזר. כל פעולה = רשומה בצורת-הסכמה (WorkTask/OrgEvent/FamilyDoc/AuditEntry).
  static int _seq = 0;
  static String _at() { _seq++; return '${today}T${(12 + _seq ~/ 60).toString().padLeft(2, '0')}:${(_seq % 60).toString().padLeft(2, '0')}'; }
  static void log(String who, String act, String what) => (db['audit'] as List).add({'at': _at(), 'who': who, 'act': act, 'what': what});
  static final Map<String, List<Map<String, dynamic>>> noteLedger = {}; // הערות-מחנך/ת (פר-תלמיד · תאריך · כותב · סוג)
  static List<Map<String, dynamic>> notes(Map<String, dynamic> s) => [
        ...(noteLedger[s['id']] ?? const []),
        if ('${s['notes'] ?? ''}'.isNotEmpty) {'date': '', 'text': '${s['notes']}', 'by': 'רשומה', 'kind': 'note'}, // Member.notes (ללא-תאריך בסכמה)
      ];
  static String? lastNoteDate(Map<String, dynamic> s) { // התאריך-האחרון של הערה מתוארכת (הבסיס Member.notes אינו מתוארך)
    String best = '';
    for (final n in notes(s)) { if ('${n['date']}'.compareTo(best) > 0) best = '${n['date']}'; }
    return best.isEmpty ? null : best;
  }
  static void addNote(Map<String, dynamic> s, String text, String who, {String kind = 'note'}) {
    (noteLedger[s['id'] as String] ??= []).insert(0, {'date': today, 'text': text, 'by': who, 'kind': kind});
    log(who, 'note', '${s['id']} · הערה: ${text.length > 30 ? text.substring(0, 30) : text}');
  }
  static void addFlag(Map<String, dynamic> s, String flag, String who) {
    final l = flagLedger[s['id'] as String] ??= [];
    if (!l.contains(flag)) l.add(flag);
    log(who, 'flag', '${s['id']} · דגל: $flag');
  }
  static void openTicket(Map<String, dynamic> s, String title, String who, {String assignee = 'counselor@school', int pri = 1}) {
    (db['tasks'] as List).add({'id': 'k-${_seq + 1}', 'assignee': assignee, 'by': who, 'title': title, 'ref': {'kind': 'family', 'id': s['famId'], 'memberId': s['id']}, 'pri': pri, 'due': today, 'createdAt': today, 'doneAt': '', 'note': ''});
    log(who, 'ticket', '${s['id']} · פנייה: $title');
  }
  static void closeTicket(Map<String, dynamic> t, String who) { t['doneAt'] = today; log(who, 'ticket-close', '${(t['ref'] as Map)['memberId'] ?? ''} · נסגר: ${t['title']}'); }
  static void inviteMeeting(Map<String, dynamic> s, String title, String date, String who) {
    (db['events'] as List).add({'id': 'v-${_seq + 1}', 'title': title, 'date': date, 'time': '', 'type': 'meeting', 'famId': s['famId'], 'priority': 'normal', 'done': false});
    log(who, 'meeting', '${s['id']} · הזמנה: $title ($date)');
  }
  static void attachDoc(Map<String, dynamic> s, String name, String who) {
    (fam(s)['docs'] as List).add({'id': 'd-${_seq + 1}', 'name': name, 'startDate': today});
    log(who, 'doc', '${s['id']} · מסמך: $name');
  }
  static void deleteStudent(Map<String, dynamic> s, String who) { // מחיקה (מנהל/ת בלבד · המפרט): הסרת Member + רישומיו; משפחה ריקה מוסרת; נרשם באודיט
    final f = fam(s);
    (f['members'] as List).removeWhere((m) => (m as Map)['id'] == s['id']);
    if ((f['members'] as List).isEmpty) (db['families'] as List).remove(f);
    (db['enrollments'] as List).removeWhere((e) => (e as Map)['memberId'] == s['id']);
    _cache = null;
    log(who, 'delete', '${s['id']} · נמחק/ה: ${s['name']}');
  }
  static void setStatus(Map<String, dynamic> s, String st, String who) { // פעיל · הוקפא · עזב · בוגר — נכתב לרישום-הראשי (Enrollment.status)
    final e = mainEnrollment(s);
    if (e != null) {
      if (st == 'פעיל') { e['status'] = 'active'; e.remove('endedAt'); }
      else if (st == 'הוקפא') { e['status'] = 'paused'; }
      else { e['status'] = 'ended'; e['endedAt'] = today; }
    }
    if (st == 'בוגר' && s['grade'] != 'יב') _statusOverride[s['id'] as String] = 'בוגר'; else _statusOverride.remove(s['id']);
    log(who, 'status', '${s['id']} · סטטוס: $st');
  }
  static List<Map<String, dynamic>> homeroomCourses() => [for (final c in (db['courses'] as List).cast<Map<String, dynamic>>()) if (c['cat'] == 'חינוך' && '${c['end']}'.compareTo(today) >= 0) c];
  static void moveClass(Map<String, dynamic> s, String courseName, String who) {
    final c = homeroomCourses().where((c) => c['name'] == courseName).toList();
    if (c.isEmpty) return;
    final e = mainEnrollment(s);
    if (e != null) { e['courseId'] = c.first['id']; } else { (db['enrollments'] as List).add({'id': 'e-${_seq + 1}', 'memberId': s['id'], 'courseId': c.first['id'], 'status': 'active', 'enrolledAt': today, 'group': '', 'note': '', 'presents': [], 'absences': []}); }
    s['grade'] = c.first['gradeMin'] ?? s['grade'];
    log(who, 'move', '${s['id']} · הועבר/ה ל-${className(s)}');
  }
  static void editField(Map<String, dynamic> s, String key, String value, String who) { // עריכה = כתיבה לשדה-האמת (Member/Family)
    if (const {'phone', 'city', 'address', 'language', 'mother', 'father', 'email'}.contains(key)) { fam(s)[key] = value; } else { s[key] = value; }
    if (key == 'first') { s['name'] = '$value ${s['last']}'; }
    log(who, 'edit', '${s['id']} · $key');
  }
  // אישורי-הורים: מדיה (Member.mPhotos/mVideos/mInvite/mRecommend = מקור-אמת) · טיולים/תרופות = מקום-שמור (מוצגים דרך WorkTask.ref.consent)
  static const consentDefs = [
    {'key': 'mPhotos', 'label': 'צילום'}, {'key': 'mVideos', 'label': 'וידאו'}, {'key': 'mInvite', 'label': 'הזמנות'}, {'key': 'mRecommend', 'label': 'המלצות'},
  ];
  static void toggleConsent(Map<String, dynamic> s, String key, String who) { s[key] = !(s[key] == true); log(who, 'consent', '${s['id']} · $key=${s[key]}'); }
  static Map<String, dynamic>? consentTask(Map<String, dynamic> s, String kind) {
    for (final t in tasksOf(s)) { if ((t['ref'] as Map?)?['consent'] == kind) return t; }
    return null;
  }
  static String consentSlot(Map<String, dynamic> s, String kind) { // 'trips' · 'meds' — מקום-שמור; מואר רק כשיש משימת-אישור
    final t = consentTask(s, kind);
    if (t == null) return '—';
    if ('${t['doneAt'] ?? ''}'.isNotEmpty) return '✅ חודש';
    return taskOverdue(t, today) ? '⛔ פג' : '⏳ ממתין';
  }
  static void requestConsent(Map<String, dynamic> s, String kind, String who) {
    final label = kind == 'trips' ? 'אישור-טיולים' : 'אישור-תרופות';
    (db['tasks'] as List).add({'id': 'k-${_seq + 1}', 'assignee': 'office@school', 'by': who, 'title': '$label — בקשה מההורים · ${s['name']}', 'ref': {'kind': 'family', 'id': s['famId'], 'memberId': s['id'], 'consent': kind}, 'pri': 2, 'due': today, 'createdAt': today, 'doneAt': '', 'note': ''});
    log(who, 'consent-request', '${s['id']} · $label');
  }
  // רישום-תלמיד-חדש: Family+Member+Enrollment חדשים בצורת-הסכמה (מקור-אמת מרגע-היצירה)
  static void addStudent({required String first, required String last, required String courseName, required String birth, required String parent, required String phone, required String who}) {
    _seq++;
    final c = homeroomCourses().where((c) => c['name'] == courseName).toList();
    final fid = 'f-new-$_seq', mid = 'm-new-$_seq';
    (db['families'] as List).add({'id': fid, 'name': last, 'father': '', 'mother': parent, 'phone': phone, 'phone2': '', 'email': '', 'city': '', 'address': '', 'language': '', 'maritalStatus': '', 'status': 'pending', 'tzedaka': '', 'discount': '', 'notes': '', 'createdAt': today, 'docs': [], 'cred': {'score': 0, 'log': []},
      'members': [{'id': mid, 'first': first, 'gender': '', 'birth': birth, 'idNum': '', 'phone': '', 'school': '', 'grade': c.isEmpty ? '' : (c.first['gradeMin'] ?? ''), 'health': '', 'payToOther': false, 'mInvite': false, 'mRecommend': false, 'mPhotos': false, 'mVideos': false, 'notes': ''}]});
    if (c.isNotEmpty) (db['enrollments'] as List).add({'id': 'e-new-$_seq', 'memberId': mid, 'courseId': c.first['id'], 'status': 'active', 'enrolledAt': today, 'group': '', 'note': '', 'presents': [], 'absences': []});
    _cache = null;
    log(who, 'add', '$mid · רישום: $first $last');
  }
  // ייבוא-CSV (parseCsv מהמדף): עמודות שם-פרטי,משפחה,כיתה,לידה,הורה,טלפון ⇒ רישום פר-שורה; מחזיר {ok, skipped}
  static Map<String, int> importCsv(String text, String who) {
    final rows = parseCsv(text);
    var ok = 0, skipped = 0;
    for (var i = 0; i < rows.length; i++) {
      final r = rows[i];
      if (i == 0 && r.isNotEmpty && (r[0].contains('שם') || r[0].toLowerCase().contains('first'))) continue; // כותרת
      if (r.length < 3 || r[0].trim().isEmpty) { skipped++; continue; }
      addStudent(first: r[0].trim(), last: r[1].trim(), courseName: r[2].trim(), birth: r.length > 3 ? r[3].trim() : '', parent: r.length > 4 ? r[4].trim() : '', phone: r.length > 5 ? r[5].trim() : '', who: who);
      ok++;
    }
    log(who, 'import', 'ייבוא-CSV: $ok נוספו · $skipped נדחו');
    return {'ok': ok, 'skipped': skipped};
  }

  // ─── כרטיס-תלמיד: נגזרות לטאבים ───
  static DateTime _atNoon(String iso) => DateTime.parse('${iso.length > 10 ? iso.substring(0, 10) : iso}T12:00:00');
  static List<Map<String, Object?>> history(Map<String, dynamic> s) => studentHistory(
        {'enrollments': db['enrollments'], 'courses': db['courses']}, s['id'], (start) => academicYearLabel('$start', _atNoon), (e) => summary(e.cast<String, dynamic>()));
  static List<Map<String, dynamic>> coursesOf(Map<String, dynamic> s, {String? cat}) => [
        for (final e in enrollmentsOf(s)) if (e['status'] != 'ended' && courseOf(e['courseId'] as String?) != null && (cat == null || courseOf(e['courseId'] as String?)!['cat'] == cat)) courseOf(e['courseId'] as String?)!,
      ];
  static int presentsThisMonth(Map<String, dynamic> s) => presentsInMonth(presentsOf(s), today);
  static int absencesThisMonth(Map<String, dynamic> s) => absencesOf(s).where((a) => monthKey(a['date'] as String) == monthKey(today)).length;
  static List<Map<String, dynamic>> eventsOf(Map<String, dynamic> s) => [for (final v in (db['events'] as List).cast<Map<String, dynamic>>()) if (v['famId'] == s['famId']) v];
  static List<Map<String, dynamic>> auditOf(Map<String, dynamic> s) => [for (final a in audit()) if ('${a['what']}'.startsWith('${s['id']} ')) a]..sort((a, b) => '${b['at']}'.compareTo('${a['at']}'));
  // ציר-זמן מאוחד: אירועים ⊕ פניות ⊕ הערות ⊕ חיסורים ⊕ מסמכים — ממוזג ומדורג-תאריך-יורד (הרכבה, לא מקור-יחיד)
  static List<Map<String, String>> timeline(Map<String, dynamic> s) {
    final out = <Map<String, String>>[
      for (final v in eventsOf(s)) {'date': '${v['date']}', 'title': '📅 ${v['title']}${v['done'] == true ? ' ✓' : ''}', 'body': '${v['time'] ?? ''}'},
      for (final t in tasksOf(s)) {'date': '${t['createdAt']}', 'title': '📨 ${t['title']}', 'body': '${t['doneAt'] ?? ''}'.isEmpty ? 'פתוח · יעד ${fmt(t['due'] as String?)}' : 'נסגר ${fmt(t['doneAt'] as String?)}'},
      for (final n in notes(s)) if ('${n['date']}'.isNotEmpty) {'date': '${n['date']}', 'title': '📝 הערה · ${n['by']}', 'body': '${n['text']}'},
      for (final a in absencesOf(s)) {'date': '${a['date']}', 'title': a['noshow'] == true ? '⛔ אי-הופעה' : '🚫 חיסור', 'body': '${a['reason']}${a['justified'] == true ? ' · מוצדק' : ''}'},
      for (final d in (fam(s)['docs'] as List).cast<Map<String, dynamic>>()) {'date': '${d['startDate']}', 'title': '📎 ${d['name']}', 'body': ''},
    ];
    out.sort((a, b) => b['date']!.compareTo(a['date']!));
    return out;
  }
  static String? waOf(Map<String, dynamic> s, String text) => waLink(fam(s)['phone'], text, waDigits) as String?;
  static String? telOf(Map<String, dynamic> s) => telHref(fam(s)['phone']) as String?;
  static String card(Map<String, dynamic> s) => [ // כרטיס-להדפסה (טקסט): רק שדות-אמת, ת״ז מוסתרת
        'כרטיס-תלמיד · ${s['name']}', 'כיתה: ${className(s)} · מחנך/ת: ${teacherName(s)}', 'לידה: ${fmt(s['birth'] as String?)} · גיל ${age(s) ?? '—'} · ת״ז ${maskId(s['idNum'] as String?)}',
        'סטטוס: ${status(s)} · סיכון: ${risk(s)} (${bandLabel(band(s))})', 'נוכחות: ${attendance(s) == null ? '—' : '${attendancePct(s)}%'} · מגמה ${trendArrow(s)}',
        'הורה: ${parentName(s)} · ${parentPhone(s)}', 'כתובת: ${fam(s)['address']} ${fam(s)['city']}', 'פעולה: ${action(s)}', 'הודפס: ${fmt(today)}',
      ].join('\n');

  // ═══ איתור (הכרעה 23-ג) = DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch ⊕ normPhone ═══
  //   לא `.contains` שטוח — נרמול-עברי + ניקוד רב-מילתי AND + מיון-לפי-רלוונטיות. מונחים: שם · מס׳ · כיתה · מחנך · הורה · טלפון-הורה.
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  static List<String> terms(Map<String, dynamic> s) => ['${s['name']}', '${s['id']}', className(s), teacherName(s), parentName(s), normPhone(fam(s)['phone'] as String?), '${fam(s)['city']}'];
  static List<Map<String, dynamic>> search(List<Map<String, dynamic>> xs, String q) {
    final nq = normPhone(q); // חיפוש-טלפון: ספרות בלבד
    final query = RegExp(r'^[\d\s+-]{6,}$').hasMatch(q.trim()) && nq.isNotEmpty ? nq : q;
    return (smartFilter(query, xs, (it) => terms(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  }

  // ═══ חריגה/פילטרים (הכרעה 23-ג) = FilterChipPill⊕DsEnumField ⊕ finderMatches ⊕ numMatch ═══
  //   locks = {ציר: ערך} — AND בין צירים. צירי-המפרט: כיתה · שכבה · מחנך · סטטוס · סיכון · נוכחות<סף · ציונים<סף (מקום-שמור) ·
  //   דגל · ללא-אישור · פנייה · חדשים · יום-הולדת · אחים.
  static bool birthdayThisMonth(Map<String, dynamic> s) { final b = '${s['birth'] ?? ''}'; return b.length >= 7 && b.substring(5, 7) == today.substring(5, 7); }
  static bool noConsent(Map<String, dynamic> s) => consentDefs.any((c) => s[c['key']] != true) || consentSlot(s, 'trips').startsWith('⛔') || consentSlot(s, 'meds').startsWith('⛔');
  static bool hasFlag(Map<String, dynamic> s) => flags(s).isNotEmpty;
  static String level(Map<String, dynamic> s) => '${s['grade'] ?? ''}'.isEmpty ? '—' : '${s['grade']}׳';
  static String axisValue(Map<dynamic, dynamic> db, dynamic f, dynamic axis) {
    final s = f as Map<String, dynamic>;
    switch (axis) {
      case 'class': return className(s);
      case 'level': return level(s);
      case 'teacher': return teacherName(s);
      case 'status': return status(s);
      case 'risk': return '${band(s)}';
      case 'attBelow80': return attendance(s) != null && numMatch('0-79', attendancePct(s)) ? '1' : '0'; // סף דרך numMatch (מדף)
      case 'gradesBelow70': { final g = s['grades']; if (g is! Map || g.isEmpty) return '0'; return numMatch('0-69', grandTotal(g.values.toList(), (v) => v as num) / g.length) ? '1' : '0'; } // מקום-שמור
      case 'flag': return hasFlag(s) ? '1' : '0';
      case 'noConsent': return noConsent(s) ? '1' : '0';
      case 'ticket': return hasOpenTicket(s) ? '1' : '0';
      case 'noParent': return parentMissing(s) ? '1' : '0';
      case 'isNew': return isNew(s) ? '1' : '0';
      case 'birthday': return birthdayThisMonth(s) ? '1' : '0';
      case 'siblings': return siblings(s).isNotEmpty ? '1' : '0';
    }
    return '';
  }
  static List<Map<String, dynamic>> filter(List<Map<String, dynamic>> xs, Map<String, String> locks) =>
      finderMatches({'families': xs}, Map<dynamic, dynamic>.from(locks), axisValue).cast<Map<String, dynamic>>();
  static List<String> options(String axis) { // אפשרויות-ציר מהדאטה (לא מילון קשיח)
    final v = <String>{for (final s in students) axisValue({}, s, axis)}.toList()..sort();
    return ['הכל', ...v];
  }
  // צ׳יפי-חריגה מהירים: {axis, label}; המונה מחושב פר-צ׳יפ (countBy-דומה: ספירה על הרשימה)
  static const quickChips = [
    {'axis': 'risk', 'value': '2', 'label': '🔴 סיכון-גבוה'}, {'axis': 'risk', 'value': '1', 'label': '🟠 סיכון-בינוני'},
    {'axis': 'attBelow80', 'value': '1', 'label': '📉 נוכחות<80%'}, {'axis': 'gradesBelow70', 'value': '1', 'label': '📝 ציונים<70'},
    {'axis': 'noParent', 'value': '1', 'label': '📵 ללא-הורה'}, {'axis': 'ticket', 'value': '1', 'label': '📨 פנייה-פתוחה'},
    {'axis': 'flag', 'value': '1', 'label': '🚩 דגל'}, {'axis': 'noConsent', 'value': '1', 'label': '✗ ללא-אישור'},
    {'axis': 'isNew', 'value': '1', 'label': '🆕 חדשים'}, {'axis': 'birthday', 'value': '1', 'label': '🎂 יום-הולדת החודש'}, {'axis': 'siblings', 'value': '1', 'label': '👪 אחים'},
  ];
  static String countAxis(List<Map<String, dynamic>> xs, String axis, String value) { // מקום-שמור: ציר בלי שום נתון ⇒ '—' (לא '0' מזויף)
    if (axis == 'gradesBelow70' && !xs.any((s) => s['grades'] is Map && (s['grades'] as Map).isNotEmpty)) return '—';
    return '${xs.where((s) => axisValue({}, s, axis) == value).length}';
  }

  // ═══ הרשאות-פר-תפקיד (הכרעה 23-ג · חוק-6 זהות=הזרקה) = roleOf ⊕ canGrantedAction ⊕ scope ═══
  //   6 זהויות-דמו מוזרקות (לא אטום!). config בצורת-maor: adminEmails · roles.teachers · features. scope = גידור-נראות
  //   (מחנך/ת: הכיתה שלו/ה · הורה: ילדו/ה). שדות-מוגנים (ת״ז מלאה · רפואי · סוציו-אקונומי · אבחונים/תרופות) = stu.protected + לוג-חשיפה.
  static const roleDefs = <Map<String, dynamic>>[
    {'label': '👑 מנהל/ת', 'email': 'mgr@school', 'config': {'adminEmails': ['mgr@school']}}, // admin ⇒ הכל + מחיקה + אודיט
    {'label': '🧭 יועץ/ת', 'email': 'counselor@school', 'config': {'features': {'stu.protected': true, 'stu.ticket': true, 'stu.note': true, 'stu.flag': true, 'stu.edit': true, 'stu.export': true, 'stu.meeting': true, 'stu.doc': true, 'stu.consent': true, 'stu.parentMsg': true, 'stu.audit': true}}},
    {'label': '🍎 מחנך/ת', 'email': 'ruti@school', 'config': {'roles': {'teachers': {'ruti@school': 't1'}}, 'features': {'stu.note': true, 'stu.flag': true, 'stu.ticket': true, 'stu.meeting': true, 'stu.doc': true, 'stu.parentMsg': true}}, 'scope': {'teacherId': 't1'}},
    {'label': '🗂 מזכירות', 'email': 'office@school', 'config': {'features': {'stu.add': true, 'stu.edit': true, 'stu.move': true, 'stu.status': true, 'stu.import': true, 'stu.export': true, 'stu.doc': true, 'stu.consent': true, 'stu.merge': true}}},
    {'label': '👪 הורה', 'email': 'parent@family', 'config': <String, dynamic>{}, 'scope': {'famId': 'f1'}}, // ילדו/ה בלבד: זהות/נוכחות/ציונים
    {'label': '👁 צפייה', 'email': 'view@school', 'config': <String, dynamic>{}},
  ];
  static bool _isAdmin(Map<String, dynamic> config, String email) => roleOf(config, email) == 'admin';
  static bool can(int role, String key) {
    final r = roleDefs[role];
    return canGrantedAction((r['config'] as Map).cast<String, dynamic>(), r['email'] as String, false, key, _isAdmin);
  }
  static String roleName(int role) => roleOf((roleDefs[role]['config'] as Map).cast<String, dynamic>(), roleDefs[role]['email'] as String);
  static String who(int role) => roleDefs[role]['email'] as String;
  static bool isParent(int role) => (roleDefs[role]['scope'] as Map?)?['famId'] != null;
  static bool isTeacher(int role) => (roleDefs[role]['scope'] as Map?)?['teacherId'] != null;
  static List<Map<String, dynamic>> scoped(int role, List<Map<String, dynamic>> xs) {
    final sc = roleDefs[role]['scope'] as Map?;
    if (sc == null) return xs;
    if (sc['teacherId'] != null) return xs.where((s) => courseOf(mainEnrollment(s)?['courseId'] as String?)?['teacherId'] == sc['teacherId']).toList();
    if (sc['famId'] != null) return xs.where((s) => s['famId'] == sc['famId']).toList();
    return xs;
  }
  // חשיפת שדה-מוגן: מותרת ⇒ נרשמת בלוג-חשיפה (אודיט act=expose); אסורה ⇒ '🔒' (מצב פרטיות-נעולה)
  static final Set<String> _exposed = {}; // מניעת-כפילות ברינדור-חוזר (רשומה אחת פר תלמיד·שדה·תפקיד)
  static String protectedField(int role, Map<String, dynamic> s, String key, String value) {
    if (!can(role, 'stu.protected')) return '🔒';
    final k = '${who(role)}|${s['id']}|$key';
    if (_exposed.add(k)) log(who(role), 'expose', '${s['id']} · חשיפת שדה-מוגן: $key');
    return value.isEmpty ? '—' : value;
  }
  static const encryptionNote = 'הצפנה-במנוחה = תפר-ההתמדה (encryptDoc/isEncrypted/pushAuditRing) — מקום-שמור: מאיר כשמחברים אחסון';

  // ═══ אוטומציות-חכמות (הכרעה 23-ג · פרואקטיבי): המערכת מתריעה לפני שדבר נשמט — כולן מנועי-מדף/שדות-אמת ═══
  // 1. קפיצת-סיכון: ציון-היום מול ציון-לפני-30-יום (אותו מנוע על תת-הדאטה עד cutoff) — הפרש ≥15 = התרעה
  static String _cutoff = '';
  static int riskAt(Map<String, dynamic> s, String cutoffIso) {
    _cutoff = cutoffIso;
    try { return risk(s); } finally { _cutoff = ''; }
  }
  static List<Map<String, dynamic>> get riskJumps => [
        for (final s in active) if (risk(s) - riskAt(s, monthAgo) >= 15) {'s': s, 'now': risk(s), 'prev': riskAt(s, monthAgo)},
      ];
  static String get monthAgo => '${today.substring(0, 4)}-${(int.parse(today.substring(5, 7)) - 1).clamp(1, 12).toString().padLeft(2, '0')}-${today.substring(8)}';
  // 2. זיהוי-כפולים (findDuplicateGroups): מפתח-שם = שם-פרטי+משפחה+לידה מנורמל · טלפון-ילד/ה (טלפון-משפחה משותף לאחים ⇒ לא ציר)
  static List<List<String>> get duplicateGroups => findDuplicateGroups(
        students, (s) => [if ('${s['phone'] ?? ''}'.isNotEmpty) normPhone(s['phone'] as String)],
        (s) => '${normName(s['name'], norm)}|${s['birth'] ?? ''}'.replaceAll(RegExp(r'\|$'), '') == normName(s['name'], norm) ? '' : '${normName(s['name'], norm)}|${s['birth']}');
  static bool isDupSuspect(Map<String, dynamic> s) => duplicateGroups.any((g) => g.length > 1 && g.contains(s['id']));
  static List<Map<String, dynamic>> dupPeers(Map<String, dynamic> s) => [for (final g in duplicateGroups) if (g.contains(s['id'])) for (final id in g) if (id != s['id']) byId(id)!];
  // מיזוג: mergeFamilies(keeper, losers) ⇒ רשומת-משפחה ממוזגת מחליפה את keeper; losers מוסרים; רישומי-ה-loser מועברים ל-keeper-member
  static void mergeDuplicate(Map<String, dynamic> keep, Map<String, dynamic> lose, String who) {
    final fk = fam(keep), fl = fam(lose);
    if (fk['id'] != fl['id']) {
      final merged = mergeFamilies(fk, [fl], (p) => normPhone(p), (xs) { final seen = <dynamic>{}; return [for (final x in xs) if (seen.add((x as Map)['id'])) x]; }, term: (k) => k == 'mvzg' ? 'מוזג: ' : k);
      merged['members'] = [for (final m in (merged['members'] as List)) if ((m as Map)['id'] != lose['id']) m]; // הכפיל עצמו לא נשמר
      final fams = db['families'] as List;
      fams[fams.indexOf(fk)] = merged; fams.remove(fl);
    } else { (fk['members'] as List).removeWhere((m) => (m as Map)['id'] == lose['id']); }
    for (final e in (db['enrollments'] as List).cast<Map<String, dynamic>>()) { if (e['memberId'] == lose['id']) e['memberId'] = keep['id']; }
    _cache = null;
    log(who, 'merge', '${keep['id']} · מוזג ${lose['id']} (${lose['name']})');
  }
  // 3. ימי-הולדת החודש · 4. אישורים-פגים (taskOverdue על משימות-אישור) · 5. אחים-חדשים⇒קישור-אוטו (Family.members) · 6. ללא-הערת-מחנך 90 יום
  static List<Map<String, dynamic>> get birthdays => active.where(birthdayThisMonth).toList();
  static List<Map<String, dynamic>> get expiredConsents => [for (final t in tasks()) if ((t['ref'] as Map?)?['consent'] != null && '${t['doneAt'] ?? ''}'.isEmpty && taskOverdue(t, today)) t];
  static List<Map<String, dynamic>> get newSiblings => [for (final s in active) if (isNew(s) && siblings(s).isNotEmpty) s]; // חדש/ה עם אחים במוסד ⇒ הקישור כבר אוטומטי (אותה Family)
  static const noteSilentDays = 90;
  static List<Map<String, dynamic>> get noNote90 { // cockpitAtRisk (שקטים ≥N ימים מהערה-אחרונה) ∪ תלמידים בלי שום הערה מתוארכת
    final dated = active.where((s) => lastNoteDate(s) != null).toList();
    final silent = cockpitAtRisk(dated, today, noteSilentDays, (m) => notes(m.cast<String, dynamic>()).length, (m) => lastNoteDate(m.cast<String, dynamic>()) ?? '', (iso, t) => cockpitDaysSince(iso, t)).cast<Map<String, dynamic>>();
    return [...silent, ...active.where((s) => lastNoteDate(s) == null)];
  }
  // 7. השוואת-שכבה (percentile): התפלגות-סיכון בשכבה ל-10 דליים (supScoreBins · ציון×10 ⇒ דלי=עשירייה) + אחוזון = חלק-הנמוכים-ממני
  static List<Map<String, dynamic>> cohort(Map<String, dynamic> s) => active.where((o) => o['grade'] == s['grade']).toList();
  static List<int> cohortBins(Map<String, dynamic> s) => supScoreBins(cohort(s), supScore: (o, _) => risk(o as Map<String, dynamic>) * 10);
  static int percentile(Map<String, dynamic> s) { final c = cohort(s); if (c.length < 2) return 50; final me = risk(s); return (c.where((o) => risk(o) < me).length * 100 / (c.length - 1)).round().clamp(0, 100); }
  // 8. דוח-יועץ שבועי (טקסט מהאותות): סיכון-גבוה · קפיצות · פניות-פתוחות · ללא-הורה · אישורים-פגים
  static String weeklyReport() => [
        'דוח-יועץ/ת שבועי · ${fmt(today)}', 'תלמידים פעילים: ${active.length} · סיכון-גבוה: $highN · בינוני: $midN',
        'קפיצות-סיכון (30 יום): ${riskJumps.map((j) => '${(j['s'] as Map)['name']} ${j['prev']}→${j['now']}').join(', ')}'.replaceAll(': ,', ': —'),
        'פניות-פתוחות: $openTicketsN · ללא-הורה-מעודכן: $noParentN · אישורים-פגים: ${expiredConsents.length}',
        'ללא-הערת-מחנך/ת $noteSilentDays יום: ${noNote90.map((s) => s['name']).join(', ')}',
        'כפילויות-חשודות: ${duplicateGroups.where((g) => g.length > 1).length}', 'ימי-הולדת החודש: ${birthdays.map((s) => s['first']).join(', ')}',
        '', 'פעולות מומלצות:', for (final s in active.where((s) => band(s) > 0)) '· ${s['name']} (${risk(s)}): ${action(s)}',
      ].join('\n');
  // 9. מעבר-שנה (העברת-כיתות מרוכזת): כל תלמיד/ה פעיל/ה ⇒ כיתת-השכבה-הבאה (gradeOrder); יב ⇒ בוגר. תצוגה-מקדימה לפני ביצוע.
  static List<String> yearRolloverPreview() => [
        for (final s in active)
          () { final gi = gradeIdx(s); if (gi < 0) return '${s['name']}: כיתה לא-ידועה'; if (gi >= gradeOrder.length - 1) return '${s['name']}: יב ⇒ בוגר'; return '${s['name']}: ${gradeOrder[gi]} ⇒ ${gradeOrder[gi + 1]}'; }(),
      ];
  static Map<String, int> yearRolloverExecute(String who) { // ביצוע (מנהל/ת): כיתת-יעד לפי gradeMin של השכבה-הבאה; אין כיתה-יעד ⇒ מדולג (לא מומצא)
    var moved = 0, graduated = 0, skipped = 0;
    for (final s in [...active]) {
      final gi = gradeIdx(s);
      if (gi < 0) { skipped++; continue; }
      if (gi >= gradeOrder.length - 1) { setStatus(s, 'בוגר', who); graduated++; continue; }
      final next = gradeOrder[gi + 1];
      final target = homeroomCourses().where((c) => c['gradeMin'] == next).toList();
      if (target.isEmpty) { skipped++; continue; }
      moveClass(s, target.first['name'] as String, who); moved++;
    }
    log(who, 'rollover', 'מעבר-שנה: $moved הועברו · $graduated בוגרים · $skipped ללא כיתת-יעד');
    return {'moved': moved, 'graduated': graduated, 'skipped': skipped};
  }
  // (מקום-שמור) הערות-מחנך/ת פר-שנה״ל: קיבוץ הערות-מתוארכות לפי academicYearLabel
  static Map<String, List<Map<String, dynamic>>> notesByYear(Map<String, dynamic> s) {
    final out = <String, List<Map<String, dynamic>>>{};
    for (final n in notes(s)) { final d = '${n['date']}'; (out[d.isEmpty ? 'ללא-תאריך' : academicYearLabel(d, _atNoon)] ??= []).add(n); }
    return out;
  }
  // אינטגרציות: נוכחות⇒סיכון (signalDefs) · ציונים⇒סיכון (מקום-שמור grades) · גבייה⇒דגל-חוב (מקום-שמור s.feeDebt, רק-הנהלה) · הורים⇒קשר (Family) ·
  //   יומן⇒אירועים (OrgEvent.famId) · לוח-הנהלה⇒מונים (highN/midN/openTicketsN חשופים).
  static bool feeDebt(Map<String, dynamic> s) => s['feeDebt'] == true; // מקום-שמור: מאיר כשמודול-הגבייה כותב

  // ═══ ייצוא (23-ג) = SoftButton ⊕ toCsv ⊕ csvEscape ⊕ exportAllowed ⊕ הרשאה — שורות = עמודות-החוזה הנראות (ת״ז מוסתרת אלא-אם מוגן-מותר) ═══
  static String csvOf(List<Map<String, dynamic>> rows) {
    final cols = [for (final c in columnDefs) if (colShown(c, rows) && c['key'] != 'photo') c];
    return toCsv([[for (final c in cols) c['label']], for (final s in rows) [for (final c in cols) cell(c, s)]], csvEscape) as String;
  }
  static bool exportOk(int role) => exportAllowed(false) && can(role, 'stu.export');

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
class TeacherScreen extends StatefulWidget {
  const TeacherScreen({super.key, this.db}); // db מוזרק (חוק-6) — null ⇒ דאטה-האמת המובנית
  final Map<String, dynamic>? db;
  /// אינטגרציה לוח-הנהלה⇒מונים: המונים של המודול (המנהל מחווט; אין ייבוא-בין-מודולים)
  static Map<String, int> get counters => {
        'total': _StuData.students.length, 'active': _StuData.active.length, 'new': _StuData.newN, 'high': _StuData.highN, 'mid': _StuData.midN,
        'noParent': _StuData.noParentN, 'openTickets': _StuData.openTicketsN, 'medical': _StuData.medicalN, 'avgAttendance': _StuData.avgAttendance ?? -1, 'avgGrades': _StuData.avgGrades ?? -1,
      };
  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  String _q = ''; // איתור (DsSearch)
  int _mode = 0; // 0=🎯 טריאז' (קיבוץ-פר-סיכון) · 1=📋 טבלה (columnDefs) — SegmentedSwitch→תצוגה
  int _sort = 0; // 0=סיכון · 1=כיתה · 2=שם — SegmentedSwitch→דירוג
  final Map<String, String> _locks = {}; // צירי-סינון פעילים (finderMatches) — AND
  bool _filtersOpen = false; // פאנל-פילטרים (כיתה/שכבה/מחנך/סטטוס)
  int _role = 0; // 0=מנהל · 1=יועץ · 2=מחנך · 3=מזכירות · 4=הורה · 5=צפייה (חוק-6 זהות-מוזרקת; בורר מדגים גידור)
  bool _importing = false; // מצב-מיוחד: ייבוא-בתהליך
  Map<String, int>? _importResult; // תוצאת-ייבוא אחרונה
  String? _rollover; // תוצאת מעבר-שנה אחרונה
  bool _loading = false; // מצב-מסך שמור: טעינה
  String? _error; // מצב-מסך שמור: שגיאה (מקום-שמור — מאיר כש-fetch נכשל)

  @override
  void initState() {
    super.initState();
    if (widget.db != null) _StuData.use(widget.db!); else _StuData.reset();
  }
  @override
  void didUpdateWidget(covariant TeacherScreen old) { // שקע-קלט מתחלף ⇒ דאטה חדשה (נתפס בבדיקת-widget: pumpWidget מעדכן State, לא initState)
    super.didUpdateWidget(old);
    if (!identical(old.db, widget.db)) { if (widget.db != null) _StuData.use(widget.db!); else _StuData.reset(); _locks.clear(); _q = ''; }
  }

  Widget _gap([double h = 10]) => SizedBox(height: h);
  // צ׳יפ-סינון מבוקר: הזרקת-צבעים (חוק-6) + selected/onTap
  Widget _fchip(String label, bool selected, VoidCallback onTap) => FilterChipPill(
        label: label, selected: selected, onTap: onTap,
        activeFillColor: _acc, surfaceColor: const Color(0xFF14162E), activeTextColor: const Color(0xFF0B0B15), inkColor: _ink, outlineColor: const Color(0xFF2A2D4A), pillRadius: 999,
      );

  @override
  Widget build(BuildContext context) {
    _StuData.roleCtx = _role;
    final all = _StuData.scoped(_role, _StuData.active); // גידור-נראות: מחנך/ת=כיתתו · הורה=ילדו · אחרת הכל
    final avgAtt = _StuData.avgAttendance, avgGr = _StuData.avgGrades;
    // דירוג (מיון-נבחר) ⇒ הנראים (פעילים); לא-פעילים בסקשן-ארכיון נפרד
    // איתור⊕חריגה (23-ג): search=smartFilter⊕smartScore⊕normSearch · filter=finderMatches. הפייפליין מזין טריאז' וטבלה וארכיון.
    final visible = _StuData.filter(_StuData.search(_StuData.sorted(all, _sort), _q), _locks);
    final inactiveVisible = _StuData.filter(_StuData.search(_StuData.sorted(_StuData.scoped(_role, _StuData.inactive), _sort), _q), _locks);
    final buckets = <int, List<Map<String, dynamic>>>{2: [], 1: [], 0: []};
    for (final s in visible) { buckets[_StuData.band(s)]!.add(s); }
    return DsScaffold(
      title: 'תלמידים', subtitle: '${_StuData.students.length} תלמידים · ${_StuData.byClass().length} כיתות · ${_StuData.highN} בסיכון-גבוה', icon: '🎓',
      children: [
        // בורר-תפקיד (חוק-6 · זהות-מוזרקת) — מדגים גידור-הרשאות+נראות פר-תפקיד (roleOf⊕canGrantedAction⊕scope)
        Row(children: [
          Expanded(child: SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: SegmentedSwitch(items: [for (final r in _StuData.roleDefs) r['label'] as String], selected: _role, onSelect: (i) => setState(() => _role = i)))),
          const SizedBox(width: 8),
          StatusChip(label: 'תפקיד: ${_StuData.roleName(_role)}${_StuData.isTeacher(_role) ? ' · הכיתה שלי' : _StuData.isParent(_role) ? ' · ילדי בלבד' : ''}', tone: 0),
        ]),
        _gap(10),
        if (_StuData.isParent(_role)) ...[const AlertBanner(glyph: '👪', tone: 0, message: 'תצוגת-הורה: זהות · נוכחות · ציונים של ילדך בלבד. שדות-מוגנים ופעולות אינם זמינים.'), _gap(8)],
        // פס-עליון: חיפוש-מבוקר + רענון (מצב-טעינה) + רישום + ייבוא — מגודרים פר-הרשאה
        Row(children: [
          Expanded(child: DsSearch(value: _q, onChanged: (v) => setState(() => _q = v))),
          const SizedBox(width: 6),
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '🔄', tone: 0, onTap: _refresh)),
          const SizedBox(width: 6),
          if (_can('stu.add')) ...[Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '➕ תלמיד', tone: 1, onTap: () => _addForm(context))), const SizedBox(width: 6)],
          if (_can('stu.import')) Padding(padding: const EdgeInsets.only(bottom: 12), child: SoftButton(label: '📥 ייבוא', tone: 0, onTap: () => _importForm(context))),
        ]),
        // מצב-מיוחד: ייבוא-בתהליך / תוצאת-ייבוא
        if (_importing) ...[const AlertBanner(glyph: '📥', tone: 3, message: 'ייבוא בתהליך… מעבד שורות'), _gap(8)],
        if (_rollover != null) ...[AlertBanner(glyph: '🗓', tone: 1, message: _rollover!), _gap(8)],
        if (!_importing && _importResult != null) ...[AlertBanner(glyph: '📥', tone: 1, message: 'ייבוא הסתיים: ${_importResult!['ok']} נוספו · ${_importResult!['skipped']} נדחו'), _gap(8)],
        // צ׳יפי-חריגה (FilterChipPill מבוקר ⊕ finderMatches) — פעולת-יסוד "זיהוי-חריגה"; המונה = ספירת-הציר על הפעילים
        Wrap(spacing: 8, runSpacing: 6, children: [
          _fchip('הכל', _locks.isEmpty, () => setState(() => _locks.clear())),
          for (final c in _StuData.quickChips)
            _fchip('${c['label']} · ${_StuData.countAxis(all, c['axis']!, c['value']!)}', _locks[c['axis']] == c['value'],
                () => setState(() { if (_locks[c['axis']] == c['value']) { _locks.remove(c['axis']); } else { _locks[c['axis']!] = c['value']!; } })),
          _fchip(_filtersOpen ? '⚙ פילטרים ▴' : '⚙ פילטרים ▾', _filtersOpen, () => setState(() => _filtersOpen = !_filtersOpen)),
        ]),
        if (_filtersOpen) Row(children: [
          for (final ax in const [['class', 'כיתה'], ['level', 'שכבה'], ['teacher', 'מחנך/ת'], ['status', 'סטטוס']])
            Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 3), child: DsEnumField(label: ax[1], options: _StuData.options(ax[0]), value: _locks[ax[0]] ?? 'הכל',
                onChanged: (v) => setState(() { if (v == 'הכל' || v.isEmpty) { _locks.remove(ax[0]); } else { _locks[ax[0]] = v; } })))),
        ]),
        const SizedBox(height: 12),
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
        // מרכז-אוטומציות (23-ג · פרואקטיבי): קפיצת-סיכון · כפולים · אישורים-פגים · ללא-הערה-90 · ימי-הולדת · אחים-חדשים — AlertBanner פר-אות
        if (_StuData.riskJumps.isNotEmpty) ...[AlertBanner(glyph: '📈', tone: 2, message: 'קפיצת-סיכון (30 יום): ${_StuData.riskJumps.map((j) => '${(j['s'] as Map)['name']} ${j['prev']}→${j['now']}').join(' · ')}'), _gap(8)],
        if (_StuData.duplicateGroups.any((g) => g.length > 1) && _can('stu.merge')) ...[AlertBanner(glyph: '👯', tone: 3, message: 'כפילות-חשודה: ${_StuData.duplicateGroups.where((g) => g.length > 1).map((g) => g.map((id) => _StuData.byId(id)?['name'] ?? id).join(' ≈ ')).join(' · ')} — פתח/י כרטיס ⇒ מיזוג'), _gap(8)],
        if (_StuData.expiredConsents.isNotEmpty) ...[AlertBanner(glyph: '📄', tone: 3, message: '${_StuData.expiredConsents.length} אישורי-הורים פגו: ${_StuData.expiredConsents.map((t) => t['title']).join(' · ')}'), _gap(8)],
        if (_StuData.noNote90.isNotEmpty && !_StuData.isParent(_role)) ...[AlertBanner(glyph: '📝', tone: 0, message: 'ללא הערת-מחנך/ת ${_StuData.noteSilentDays} יום: ${_StuData.scoped(_role, _StuData.noNote90).map((s) => s['first']).join(' · ')}'), _gap(8)],
        if (_StuData.birthdays.isNotEmpty) ...[AlertBanner(glyph: '🎂', tone: 1, message: 'ימי-הולדת החודש: ${_StuData.scoped(_role, _StuData.birthdays).map((s) => '${s['first']} (${_StuData.fmt(s['birth'] as String?)})').join(' · ')}'), _gap(8)],
        if (_StuData.newSiblings.isNotEmpty && !_StuData.isParent(_role)) ...[AlertBanner(glyph: '👪', tone: 0, message: 'אחים-חדשים קושרו אוטומטית: ${_StuData.newSiblings.map((s) => '${s['first']} ↔ ${_StuData.siblings(s).map((o) => o['first']).join(',')}').join(' · ')}'), _gap(8)],
        // דוח-יועץ · מעבר-שנה · ייצוא — כלים-מרוכזים (מגודרים)
        Wrap(spacing: 8, runSpacing: 6, children: [
          if (_can('stu.ticket') || _StuData.roleName(_role) == 'admin') SoftButton(label: '🧭 דוח-יועץ שבועי', tone: 0, onTap: () => _showText(context, 'דוח-יועץ/ת שבועי', _StuData.weeklyReport())),
          if (_StuData.roleName(_role) == 'admin') SoftButton(label: '🗓 מעבר-שנה (תצוגה)', tone: 0, onTap: () => _showText(context, 'מעבר-שנה · העברת-כיתות מרוכזת (תצוגה-מקדימה)', _StuData.yearRolloverPreview().join('\n'))),
          if (_StuData.roleName(_role) == 'admin') SoftButton(label: '🗓 בצע מעבר-שנה', tone: 2, onTap: () => setState(() { final r = _StuData.yearRolloverExecute(_who); _importResult = null; _error = null; _rollover = 'מעבר-שנה בוצע: ${r['moved']} הועברו · ${r['graduated']} בוגרים · ${r['skipped']} ללא כיתת-יעד (לא הומצאה)'; })),
          if (_StuData.exportOk(_role)) SoftButton(label: '⬇ CSV (${visible.length})', tone: 0, onTap: () => _showText(context, 'ייצוא CSV · ${visible.length} תלמידים (BOM + חסימת-הזרקה)', _StuData.csvOf(visible))),
          if (_StuData.exportOk(_role)) SoftButton(label: '⬇ PDF — מקום-שמור', tone: 0, onTap: () => _showText(context, 'ייצוא PDF', 'מקום-שמור: אין מנוע-PDF במדף (§20-ג) — יאיר כשיתווסף; עד אז: הדפס-כרטיס (טקסט) + CSV.')),
        ]),
        _gap(8),
        // בורר-מבט (🎯 טריאז' · 📋 טבלה) + בורר-דירוג (סיכון · כיתה · שם) — ארגון = פעולת-יסוד עם אטום משלה
        Row(children: [
          SegmentedSwitch(items: const ['🎯 טריאז׳', '📋 טבלה'], selected: _mode, onSelect: (i) => setState(() => _mode = i)),
          const Spacer(),
          SegmentedSwitch(items: const ['⚠ סיכון', '🏫 כיתה', '🔤 שם'], selected: _sort, onSelect: (i) => setState(() => _sort = i)),
        ]),
        _gap(10),
        // מצבי-מסך: שגיאה (AlertBanner + סגירה) · טעינה ⇒ אחרת התוכן: ריק · טבלה · טריאז'
        if (_error != null) ...[Row(children: [Expanded(child: AlertBanner(glyph: '⚠️', tone: 2, message: _error!)), const SizedBox(width: 6), SoftButton(label: '✕', tone: 0, onTap: () => setState(() => _error = null))]), _gap(8)],
        if (_loading)
          _loadingView()
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
              if (_StuData.isDupSuspect(s)) const StatusChip(label: '👯 כפילות-חשודה', tone: 3),
              if (_StuData.feeDebt(s) && _StuData.roleName(_role) == 'admin') const StatusChip(label: '💳 חוב-גבייה', tone: 2), // מקום-שמור (גבייה⇒דגל, רק-הנהלה)
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

  // ═══ כרטיס-תלמיד-נבחר · GlassCard(child) · פעולת-יסוד "ביצוע"+"הערכה": כל האמת על תלמיד-אחד + הפעולה-הנכונה-עכשיו ═══
  //   זהות (PremiumAvatar + שקע-תמונה) · מד-סיכון (GaugeMeter) · הפעולה (AlertBanner) · 9 טאבים (SegmentedSwitch נגלל) ·
  //   פעולות (SoftButton) — כותבות לרשומות-האמת + אודיט, המסך והכרטיס מתעדכנים יחד.
  static const _tabs = ['סקירה', 'אקדמי', 'נוכחות', 'חברתי-רגשי', 'התנהגות', 'משפחה', 'מסמכים', 'ציר-זמן', 'אודיט'];
  final Map<String, int> _tab = {};
  String get _who => _StuData.who(_role); // זהות-מוזרקת (חוק-6) מבורר-התפקיד
  bool _can(String k) => _StuData.can(_role, k);

  void _openPanel(Map<String, dynamic> s) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheet) {
        void act(void Function() f) { f(); setSheet(() {}); setState(() {}); }
        final r = _StuData.risk(s), b = _StuData.band(s), tone = b == 2 ? 2 : b == 1 ? 3 : 1;
        final parentView = _StuData.isParent(_role);
        final tabs = parentView ? const ['סקירה', 'אקדמי', 'נוכחות'] : _tabs;
        final tab = (_tab[s['id']] ?? 0).clamp(0, tabs.length - 1);
        return DraggableScrollableSheet(
          initialChildSize: 0.86, minChildSize: 0.4, maxChildSize: 0.97, expand: false,
          builder: (ctx, scroll) => Padding(
            padding: const EdgeInsets.all(12),
            child: GlassCard(
              child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
                // זהות: אווטאר (ראשי-תיבות; image = מקום-שמור לתמונה) + שם + כיתה·מחנך·גיל·מין + סטטוס
                Row(children: [
                  PremiumAvatar(name: '${s['name']}', size: 56, image: s['photo'] is ImageProvider ? s['photo'] as ImageProvider : null),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${s['name']}', style: const TextStyle(color: _ink, fontSize: 19, fontWeight: FontWeight.w800)),
                    Text('${_StuData.className(s)} · ${_StuData.teacherName(s)} · גיל ${_StuData.age(s) ?? '—'} · ${s['gender'] == 'f' ? 'נ' : s['gender'] == 'm' ? 'ז' : '—'} · מס׳ ${s['id']} · ת״ז ${_can('stu.protected') ? _StuData.protectedField(_role, s, 'idNum', '${s['idNum'] ?? ''}') : _StuData.maskId(s['idNum'] as String?)}', style: const TextStyle(color: _muted, fontSize: 12.5)),
                  ])),
                  StatusChip(label: _StuData.status(s), tone: _StuData.isActive(s) ? 1 : 0),
                ]),
                _gap(12),
                // ציון-סיכון מאוחד (GaugeMeter, tone=band) + הפעולה-הנכונה-עכשיו (AlertBanner) — ההכרעה, לא רק המספר
                Row(children: [
                  GaugeMeter(value: r / 100, size: 150, tone: tone),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [BareStat(value: '$r', label: _StuData.bandLabel(b), inkColor: b == 2 ? _danger : b == 1 ? _warning : _ok, mutedColor: _muted)]), // BareStat=Expanded ⇒ חייב Row (נתפס בבדיקת-widget)
                    _gap(6),
                    AlertBanner(glyph: b == 2 ? '⏰' : b == 1 ? '📅' : '✅', tone: b == 2 ? 2 : b == 1 ? 3 : 1, message: '👉 ${_StuData.action(s)}'),
                  ])),
                ]),
                _gap(12),
                SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: SegmentedSwitch(items: tabs, selected: tab, onSelect: (i) => setSheet(() => _tab[s['id'] as String] = i))),
                _gap(12),
                ..._tabBody(ctx, s, tab, act),
                _gap(16),
                const Text('פעולות', style: TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)),
                _gap(8),
                // פעולות מגודרות פר-הרשאה (canGrantedAction); אין-הרשאה ⇒ מצב נעילת-הרשאות
                Builder(builder: (_) { final acts = _actions(ctx, s, act); return acts.isEmpty ? const AlertBanner(message: 'צפייה-בלבד — אין הרשאת-פעולה לתפקיד זה', glyph: '🔒', tone: 2) : Wrap(spacing: 8, runSpacing: 8, children: acts); }),
                _gap(8),
              ]),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _kv(String k, String v) => [Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Text(k, style: const TextStyle(color: _muted, fontSize: 13)), const SizedBox(width: 8), Expanded(child: Text(v, style: const TextStyle(color: _ink, fontSize: 13.5, fontWeight: FontWeight.w600)))]))];
  Widget _h(String t) => Padding(padding: const EdgeInsets.only(top: 6, bottom: 6), child: Text(t, style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w800)));
  // מקום-שמור (חוק-7): תווית+שקע — מואר כשמגיע נתון, עד אז מוצהר ולא מזויף
  Widget _slot(String label, String source) => AlertBanner(glyph: '▫', tone: 0, message: '$label — מקום-שמור · יאיר כשיגיע נתון ($source)');

  List<Widget> _tabBody(BuildContext ctx, Map<String, dynamic> s, int tab, void Function(void Function()) act) {
    switch (tab) {
      case 0: // סקירה: פירוק-האותות (NeonBars) · אותות-ללא-נתון (מקום-שמור) · מגמה 30/90 · נוכחות-חודש · הערות-אחרונות · דגלים · משפחה · פניות
        final sig = _StuData.signals(s), withData = sig.where((x) => x['value'] != null).toList(), noData = sig.where((x) => x['value'] == null).toList();
        final t30 = _StuData.trend30(s), t90 = _StuData.trend90(s);
        final ns = _StuData.notes(s);
        return [
          _h('פירוק-האותות · תרומה לציון-הסיכון (נק׳)'),
          if (withData.isEmpty) const EmptyState(glyph: '📊', message: 'אין עדיין אותות עם נתון') else
          NeonBars(labels: [for (final x in withData) '${x['label']}'], values: [for (final x in withData) (x['contribution'] as double)], tone: _StuData.band(s) == 2 ? 2 : _StuData.band(s) == 1 ? 3 : 1),
          if (noData.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 6, runSpacing: 6, children: [for (final x in noData) StatusChip(label: '▫ ${x['label']}: אין נתון (מקום-שמור)', tone: 0)])),
          _gap(10),
          Row(children: [
            BareStat(value: t30['dir'] == 'flat' ? '→' : '${t30['pct'] > 0 ? '+' : ''}${t30['pct']}%', label: 'מגמה-30 (נוכחות)', inkColor: t30['dir'] == 'down' ? _danger : _ok, mutedColor: _muted),
            BareStat(value: t90['dir'] == 'flat' ? '→' : '${t90['pct'] > 0 ? '+' : ''}${t90['pct']}%', label: 'מגמה-90 (נוכחות)', inkColor: t90['dir'] == 'down' ? _danger : _ok, mutedColor: _muted),
            BareStat(value: '${_StuData.presentsThisMonth(s)}/${_StuData.presentsThisMonth(s) + _StuData.absencesThisMonth(s)}', label: 'נוכחות-החודש', inkColor: _ink, mutedColor: _muted),
          ]),
          _gap(10),
          // השוואת-שכבה (percentile): התפלגות-הסיכון בשכבה (supScoreBins ⇒ NeonBars) + אחוזון-התלמיד
          _h('השוואת-שכבה ${_StuData.level(s)} · ${_StuData.cohort(s).length} תלמידים'),
          Row(children: [
            BareStat(value: '${_StuData.percentile(s)}', label: 'אחוזון-סיכון בשכבה (גבוה=חמור)', inkColor: _StuData.percentile(s) >= 75 ? _danger : _ink, mutedColor: _muted),
            BareStat(value: '${(grandTotal(_StuData.cohort(s), (o) => _StuData.risk(o as Map<String, dynamic>)) / (_StuData.cohort(s).isEmpty ? 1 : _StuData.cohort(s).length)).round()}', label: 'ממוצע-סיכון בשכבה', inkColor: _ink, mutedColor: _muted),
          ]),
          if (_StuData.cohort(s).length >= 2) NeonBars(labels: const ['0-9', '10-19', '20-29', '30-39', '40-49', '50-59', '60-69', '70-79', '80-89', '90+'], values: [for (final b in _StuData.cohortBins(s)) b.toDouble()], tone: 0),
          _gap(10),
          _h('הערות אחרונות · ${ns.length}'),
          if (ns.isEmpty) const EmptyState(glyph: '📝', message: 'אין הערות-מחנך/ת') else for (final n in ns.take(3)) TimelineItem(title: '📝 ${n['by']}', time: '${n['date']}'.isEmpty ? 'ללא-תאריך' : _StuData.fmt('${n['date']}'), body: '${n['text']}'),
          _h('דגלים'),
          Wrap(spacing: 6, runSpacing: 6, children: [for (final f in _StuData.flags(s)) StatusChip(label: f, tone: 3), if (_StuData.flags(s).isEmpty) const StatusChip(label: 'אין דגלים', tone: 0)]),
          _h('משפחה · פניות'),
          MediaRow(glyph: '👪', title: '${_StuData.parentName(s)} · ${_StuData.parentMissing(s) ? '⛔ אין טלפון' : _StuData.parentPhone(s)}', subtitle: 'אחים במוסד: ${_StuData.siblings(s).isEmpty ? 'אין' : _StuData.siblings(s).map((x) => x['first']).join(' · ')} · פניות פתוחות: ${_StuData.openTasksOf(s).length}'),
        ];
      case 1: // אקדמי: ציונים-לפי-מקצוע (מקום-שמור) · מגמה-אקדמית (מקום-שמור) · חוגים · היסטוריית-כיתות (studentHistory) · תעודות/IEP/חונך/ציוני-חוץ (מקום-שמור)
        final g = s['grades'];
        final hist = _StuData.history(s);
        return [
          _h('ציונים לפי מקצוע'),
          if (g is Map && g.isNotEmpty) ...[for (final e in g.entries) StatRow(label: '${e.key}', value: '${e.value}', fraction: ((e.value as num) / 100).clamp(0.0, 1.0))] else _slot('ציונים לפי מקצוע · ממוצע · מגמה-אקדמית', 'מודול-ציונים ⇒ s.grades'),
          _h('היסטוריית-כיתות ורישומים · ${hist.length}'),
          for (final h in hist) TimelineItem(title: '${h['courseName']}${h['fromRenewal'] == true ? ' · חידוש' : ''}', time: '${h['yearLabel']}', body: 'נוכחויות ${(h['summary'] as Map)['presents']} · חיסורים ${(h['summary'] as Map)['absences']} · ${(h['summary'] as Map)['statusLabel']}'),
          _h('מקומות-שמורים'),
          _slot('תעודות-קודמות', 'Family.docs מסוג תעודה'), _slot('תוכנית-אישית (IEP)', 's.iep'), _slot('חונך/ת', 's.mentor'), _slot('ציוני-חוץ (מבחנים ארציים)', 's.externalScores'),
        ];
      case 2: // נוכחות: מונים · חודשי (NeonBars) · חיסורים (TimelineItem)
        final ms = _StuData.months(s);
        final abs = _StuData.absencesOf(s)..sort((a, b) => '${b['date']}'.compareTo('${a['date']}'));
        return [
          Row(children: [
            BareStat(value: '${_StuData.presents(s)}', label: 'נוכחויות', inkColor: _ok, mutedColor: _muted),
            BareStat(value: '${_StuData.absences(s)}', label: 'חיסורים', inkColor: _StuData.absences(s) > 0 ? _warning : _ink, mutedColor: _muted),
            BareStat(value: '${_StuData.noshow(s)}', label: 'אי-הופעות', inkColor: _StuData.noshow(s) > 0 ? _danger : _ink, mutedColor: _muted),
            BareStat(value: _StuData.attendance(s) == null ? '—' : '${_StuData.attendancePct(s)}%', label: 'נוכחות%', inkColor: _acc, mutedColor: _muted),
          ]),
          _gap(10),
          _h('נוכחות חודשית (%)'),
          if (ms.isEmpty) const EmptyState(glyph: '📅', message: 'אין נתוני-נוכחות עדיין') else NeonBars(labels: ms, values: [for (final m in ms) _StuData.monthRate(s, m) * 100], tone: 0),
          _h('חיסורים · ${abs.length}'),
          if (abs.isEmpty) const EmptyState(glyph: '✅', message: 'אין חיסורים רשומים') else for (final a in abs.take(12)) TimelineItem(title: a['noshow'] == true ? '⛔ אי-הופעה' : '🚫 חיסור', time: _StuData.fmt(a['date'] as String?), body: '${a['reason']}${a['justified'] == true ? ' · מוצדק' : ' · לא-מוצדק'}'),
        ];
      case 3: // חברתי-רגשי: מקום-שמור + חוגים/מועדונים (מקור: Enrollment⊕Course.cat=חוג) + תפקידים/הישגים (מקום-שמור)
        final clubs = _StuData.coursesOf(s, cat: 'חוג');
        return [
          if (s['social'] is num) StatRow(label: 'מדד חברתי-רגשי (1=מצוקה)', value: '${s['social']}', fraction: (s['social'] as num).toDouble().clamp(0.0, 1.0)) else _slot('מדד חברתי-רגשי', 'שאלון/יועץ ⇒ s.social'),
          _h('מועדונים וחוגים · ${clubs.length}'),
          if (clubs.isEmpty) const EmptyState(glyph: '🎭', message: 'לא רשום/ה לחוגים') else for (final c in clubs) MediaRow(glyph: '🎭', title: '${c['name']}', subtitle: '${_StuData.teacherOf(c['teacherId'] as String?)?['name'] ?? ''}'),
          _h('מקומות-שמורים'), _slot('תפקידים', 's.roles'), _slot('הישגים', 's.achievements'),
        ];
      case 4: // התנהגות: מקום-שמור + הערות-התנהגות מהפנקס
        final bn = _StuData.notes(s).where((n) => n['kind'] == 'behavior').toList();
        return [
          if (s['behavior'] is num) Row(children: [BareStat(value: '${s['behavior']}', label: 'אירועי-התנהגות בחודש', inkColor: _warning, mutedColor: _muted)]) else _slot('אירועי-התנהגות', 'מודול-משמעת ⇒ s.behavior'),
          _h('הערות-מחנך/ת לפי שנה״ל'),
          for (final e in _StuData.notesByYear(s).entries) ExpandableTile(title: '${e.key} · ${e.value.length}', body: e.value.map((n) => '${'${n['date']}'.isEmpty ? '' : '${_StuData.fmt('${n['date']}')} · '}${n['by']}: ${n['text']}').join('\n')),
          _h('הערות-התנהגות · ${bn.length}'),
          if (bn.isEmpty) const EmptyState(glyph: '📝', message: 'אין הערות-התנהגות') else for (final n in bn) TimelineItem(title: '📝 ${n['by']}', time: _StuData.fmt('${n['date']}'), body: '${n['text']}'),
        ];
      case 5: // משפחה: הורים+קשר · כתובת · שפה · אחים · סוציו-אקונומי (מוגן) · אישורי-הורים · הסעה (מקום-שמור)
        final f = _StuData.fam(s);
        return [
          MediaRow(glyph: '👩', title: '${f['mother']}'.isEmpty ? 'אם: —' : 'אם: ${f['mother']}', subtitle: _StuData.parentMissing(s) ? '⛔ אין טלפון-קשר' : '${_StuData.parentPhone(s)} · ${_StuData.telOf(s) ?? ''}'),
          MediaRow(glyph: '👨', title: '${f['father']}'.isEmpty ? 'אב: —' : 'אב: ${f['father']}', subtitle: '${f['phone2']}'.isEmpty ? '' : formatIsraeliPhone(f['phone2'])),
          ..._kv('כתובת', '${f['address']} ${f['city']}'.trim().isEmpty ? '—' : '${f['address']} ${f['city']}'),
          ..._kv('שפת-בית', '${f['language']}'.isEmpty ? '—' : '${f['language']}'),
          ..._kv('מצב משפחתי', '${f['maritalStatus']}'.isEmpty ? '—' : '${f['maritalStatus']}'),
          ..._kv('סטטוס-משפחה', '${f['status']}'),
          _h('אחים במוסד · ${_StuData.siblings(s).length}'),
          if (_StuData.siblings(s).isEmpty) const StatusChip(label: 'אין אחים במוסד', tone: 0) else Wrap(spacing: 6, children: [for (final o in _StuData.siblings(s)) SoftButton(label: '🔗 ${o['first']} · ${_StuData.className(o)}', tone: 0, onTap: () { Navigator.of(ctx).pop(); _openPanel(o); })]),
          _h('מצב סוציו-אקונומי · 🔒 מוגן'),
          if (_can('stu.protected')) Wrap(spacing: 6, children: [StatusChip(label: 'סיוע: ${_StuData.protectedField(_role, s, 'tzedaka', '${f['tzedaka']}')}', tone: 3), StatusChip(label: 'הנחה: ${_StuData.protectedField(_role, s, 'discount', '${f['discount']}'.isEmpty ? '' : '${f['discount']}%')}', tone: 3), const StatusChip(label: '👁 נרשם בלוג-חשיפה', tone: 0)])
          else const StatusChip(label: '🔒 פרטיות-נעולה · יועץ/ת בלבד', tone: 2),
          _h('אישורי-הורים'),
          Wrap(spacing: 6, runSpacing: 6, children: [
            for (final c in _StuData.consentDefs) StatusChip(label: '${s[c['key']] == true ? '✅' : '✗'} ${c['label']}', tone: s[c['key']] == true ? 1 : 0),
            StatusChip(label: 'טיולים: ${_StuData.consentSlot(s, 'trips')}', tone: _StuData.consentSlot(s, 'trips').startsWith('⛔') ? 2 : 0),
            StatusChip(label: 'תרופות: ${_StuData.consentSlot(s, 'meds')}', tone: _StuData.consentSlot(s, 'meds').startsWith('⛔') ? 2 : 0),
          ]),
          _gap(6), _slot('הסעה', 's.transport'),
        ];
      case 6: // מסמכים: Family.docs · תיק-רפואי (Member.health מוגן) · תעודות (מקום-שמור)
        final docs = (_StuData.fam(s)['docs'] as List).cast<Map<String, dynamic>>();
        return [
          _h('מסמכים · ${docs.length}'),
          if (docs.isEmpty) const EmptyState(glyph: '📎', message: 'אין מסמכים') else for (final d in docs) TimelineItem(title: '📎 ${d['name']}', time: _StuData.fmt(d['startDate'] as String?)),
          _h('תיק-רפואי · 🔒 מוגן'),
          if ('${s['health'] ?? ''}'.isEmpty) const StatusChip(label: 'אין רישום רפואי', tone: 0)
          else if (_can('stu.protected')) StatusChip(label: '🩺 ${_StuData.protectedField(_role, s, 'health', '${s['health']}')} · 👁 נרשם בלוג-חשיפה', tone: 3)
          else const StatusChip(label: '🔒 פרטיות-נעולה · קיים רישום רפואי (יועץ/ת)', tone: 2),
          _gap(6), _slot('אבחונים', 's.diagnoses'), _slot('תרופות', 's.medications'),
        ];
      case 7: // ציר-זמן מאוחד
        final tl = _StuData.timeline(s);
        return [_h('ציר-זמן · ${tl.length}'), if (tl.isEmpty) const EmptyState(glyph: '🕒', message: 'אין אירועים') else for (final e in tl) TimelineItem(title: e['title']!, time: _StuData.fmt(e['date']), body: e['body']!.isEmpty ? null : e['body'])];
      default: // אודיט: רשומות-אודיט של התלמיד (at·who·act·what)
        final au = _StuData.auditOf(s);
        return [
          if (!_can('stu.audit') && _StuData.roleName(_role) != 'admin') const AlertBanner(glyph: '🔒', tone: 2, message: 'אודיט מלא — מנהל/ת ויועץ/ת בלבד') else ...[
            _h('אודיט · ${au.length}'), AlertBanner(glyph: '🗄', tone: 0, message: _StuData.encryptionNote),
            if (au.isEmpty) const EmptyState(glyph: '🧾', message: 'אין רשומות-אודיט') else for (final a in au) TimelineItem(title: '${a['act']}${a['act'] == 'expose' ? ' 👁' : ''} · ${a['who']}', time: '${a['at']}', body: '${a['what']}'),
          ],
        ];
    }
  }

  // 14+ פעולות (SoftButton) — כל פעולה כותבת לרשומת-האמת + אודיט. גל 5: גידור פר-תפקיד.
  List<Widget> _actions(BuildContext ctx, Map<String, dynamic> s, void Function(void Function()) act) {
    final active = _StuData.isActive(s), st = _StuData.status(s);
    if (_StuData.isParent(_role)) return const []; // הורה: צפייה בלבד
    return [
      if (_can('stu.edit')) SoftButton(label: '✏️ ערוך', tone: 0, onTap: () => _editForm(ctx, s, act)),
      if (_can('stu.move')) SoftButton(label: '🏫 העבר-כיתה', tone: 0, onTap: () => _pick(ctx, 'העבר-כיתה', [for (final c in _StuData.homeroomCourses()) c['name'] as String], (v) => act(() => _StuData.moveClass(s, v, _who)))),
      if (_can('stu.status') && active) SoftButton(label: '⏸ הקפא', tone: 3, onTap: () => act(() => _StuData.setStatus(s, 'הוקפא', _who))),
      if (_can('stu.status') && !active) SoftButton(label: '▶ החזר לפעיל', tone: 1, onTap: () => act(() => _StuData.setStatus(s, 'פעיל', _who))),
      if (_can('stu.status') && st != 'עזב') SoftButton(label: '🚪 סמן-עזב', tone: 2, onTap: () => act(() => _StuData.setStatus(s, 'עזב', _who))),
      if (_can('stu.status') && st != 'בוגר') SoftButton(label: '🎓 סמן-בוגר', tone: 0, onTap: () => act(() => _StuData.setStatus(s, 'בוגר', _who))),
      if (_can('stu.note')) SoftButton(label: '📝 הוסף-הערה', tone: 1, onTap: () => _prompt(ctx, 'הערת-מחנך/ת', 'מה קרה? מה סוכם?', (v) => act(() => _StuData.addNote(s, v, _who)))),
      if (_can('stu.note')) SoftButton(label: '⚠ הערת-התנהגות', tone: 3, onTap: () => _prompt(ctx, 'הערת-התנהגות', 'אירוע · תגובה', (v) => act(() => _StuData.addNote(s, v, _who, kind: 'behavior')))),
      if (_can('stu.flag')) SoftButton(label: '🚩 הוסף-דגל', tone: 3, onTap: () => _pick(ctx, 'הוסף-דגל', const ['♿ צרכים-מיוחדים', '💛 רגישות', '🩺 רפואי', '🗣 שפה', '🚌 הסעה'], (v) => act(() => _StuData.addFlag(s, v, _who)))),
      if (_can('stu.ticket')) SoftButton(label: '📨 פתח-פנייה (יועץ/ת)', tone: 2, onTap: () => _prompt(ctx, 'פנייה ליועץ/ת', 'נושא הפנייה', (v) => act(() => _StuData.openTicket(s, 'פנייה ליועצת: ${s['name']} — $v', _who)))),
      if (_can('stu.parentMsg')) SoftButton(label: '💬 שלח-להורה', tone: 0, onTap: () => _showText(ctx, 'הודעה להורה · ${_StuData.parentName(s)}', _StuData.waOf(s, 'שלום ${_StuData.parentName(s)}, מדברים מבית-הספר בעניין ${s['first']}. נשמח לשוחח.') ?? '⛔ אין טלפון-הורה מעודכן — לא ניתן לשלוח')),
      if (_can('stu.meeting')) SoftButton(label: '📅 הזמן-לשיחה', tone: 0, onTap: () => _prompt(ctx, 'הזמנה לשיחה', 'תאריך (YYYY-MM-DD)', (v) => act(() => _StuData.inviteMeeting(s, 'שיחה עם הורי ${s['first']}', v, _who)))),
      if (_can('stu.doc')) SoftButton(label: '📎 צרף-מסמך', tone: 0, onTap: () => _prompt(ctx, 'צרף-מסמך', 'שם המסמך', (v) => act(() => _StuData.attachDoc(s, v, _who)))),
      SoftButton(label: '🖨 הדפס-כרטיס', tone: 0, onTap: () => _showText(ctx, 'כרטיס-תלמיד להדפסה', _StuData.card(s))),
      if (_can('stu.merge')) for (final d in _StuData.dupPeers(s)) SoftButton(label: '👯 מזג ${d['id']} לכאן', tone: 3, onTap: () => act(() => _StuData.mergeDuplicate(s, d, _who))),
      if (_StuData.roleName(_role) == 'admin') SoftButton(label: '🗑 מחק רשומה', tone: 2, onTap: () { act(() => _StuData.deleteStudent(s, _who)); Navigator.of(ctx).pop(); }),
      if (_can('stu.consent')) SoftButton(label: '📷 אישור-מדיה: ${s['mPhotos'] == true ? 'בטל' : 'סמן'}', tone: 0, onTap: () => act(() => _StuData.toggleConsent(s, 'mPhotos', _who))),
      if (_can('stu.consent')) SoftButton(label: '🧳 בקש אישור-טיולים', tone: 0, onTap: () => act(() => _StuData.requestConsent(s, 'trips', _who))),
      if (_can('stu.ticket')) for (final t in _StuData.openTasksOf(s)) SoftButton(label: '✅ סגור פנייה ${t['id']}', tone: 1, onTap: () => act(() => _StuData.closeTicket(t, _who))), // תווית קצרה (גיליון ≤640px · נתפס בבדיקת-widget)
    ];
  }

  // ─── גיליונות-קלט (DsField/DsEnumField מהמדף) — קלט-אמת מהמשתמש, לא ערכים מומצאים ───
  void _prompt(BuildContext ctx, String title, String hint, void Function(String) onSave) {
    var v = '';
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => Padding(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(c2).viewInsets.bottom + 12),
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        DsField(label: title, hint: hint, value: v, onChanged: (x) => v = x),
        Row(children: [SoftButton(label: '💾 שמור', tone: 1, onTap: () { if (v.trim().isNotEmpty) { onSave(v.trim()); Navigator.of(c2).pop(); } })]),
      ])),
    ));
  }
  void _pick(BuildContext ctx, String title, List<String> options, void Function(String) onSave) {
    var v = options.isEmpty ? '' : options.first;
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, builder: (c2) => StatefulBuilder(builder: (c2, setS) => Padding(
      padding: const EdgeInsets.all(12),
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        DsEnumField(label: title, options: options, value: v, onChanged: (x) => setS(() => v = x)),
        Row(children: [SoftButton(label: '💾 שמור', tone: 1, onTap: () { if (v.isNotEmpty) { onSave(v); Navigator.of(c2).pop(); } })]),
      ])),
    )));
  }
  void _showText(BuildContext ctx, String title, String text) {
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => Padding(
      padding: const EdgeInsets.all(12),
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        _gap(8),
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF0C0D1E), borderRadius: BorderRadius.circular(10)), child: SelectableText(text, style: const TextStyle(color: _ink, fontSize: 13, height: 1.6))),
      ])),
    ));
  }
  // עריכה: שדות-אמת (Member.first/phone/school · Family.mother/father/phone/city/address/language)
  void _editForm(BuildContext ctx, Map<String, dynamic> s, void Function(void Function()) act) {
    final f = _StuData.fam(s);
    final vals = <String, String>{'first': '${s['first']}', 'school': '${s['school'] ?? ''}', 'mother': '${f['mother']}', 'father': '${f['father']}', 'phone': '${f['phone']}', 'city': '${f['city']}', 'address': '${f['address']}', 'language': '${f['language']}'};
    const labels = {'first': 'שם פרטי', 'school': 'בית-ספר', 'mother': 'אם', 'father': 'אב', 'phone': 'טלפון-הורה', 'city': 'ישוב', 'address': 'כתובת', 'language': 'שפת-בית'};
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => DraggableScrollableSheet(
      initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (c2, scroll) => Padding(padding: const EdgeInsets.all(12), child: GlassCard(child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
        Text('עריכה · ${s['name']}', style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        for (final k in vals.keys) DsField(label: labels[k]!, hint: '', value: vals[k]!, onChanged: (x) => vals[k] = x),
        _gap(8),
        Row(children: [SoftButton(label: '💾 שמור', tone: 1, onTap: () { act(() { for (final k in vals.keys) { if (vals[k] != '${k == 'first' || k == 'school' ? s[k] ?? '' : f[k]}') _StuData.editField(s, k, vals[k]!, _who); } }); Navigator.of(c2).pop(); })]),
      ]))),
    ));
  }
  // רישום-תלמיד-חדש (Family+Member+Enrollment)
  void _addForm(BuildContext ctx) {
    final vals = <String, String>{'first': '', 'last': '', 'birth': '', 'parent': '', 'phone': ''};
    final classes = [for (final c in _StuData.homeroomCourses()) c['name'] as String];
    var cls = classes.isEmpty ? '' : classes.first;
    const labels = {'first': 'שם פרטי', 'last': 'שם משפחה', 'birth': 'תאריך-לידה (YYYY-MM-DD)', 'parent': 'הורה ראשי', 'phone': 'טלפון-הורה'};
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => StatefulBuilder(builder: (c2, setS) => DraggableScrollableSheet(
      initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (c2, scroll) => Padding(padding: const EdgeInsets.all(12), child: GlassCard(child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
        const Text('רישום מורה חדש/ה', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        for (final k in vals.keys) DsField(label: labels[k]!, hint: '', value: vals[k]!, onChanged: (x) => vals[k] = x),
        DsEnumField(label: 'כיתה', options: classes, value: cls, onChanged: (x) => setS(() => cls = x)),
        _gap(8),
        Row(children: [SoftButton(label: '💾 רשום', tone: 1, onTap: () {
          if (vals['first']!.trim().isEmpty || vals['last']!.trim().isEmpty) return;
          setState(() => _StuData.addStudent(first: vals['first']!.trim(), last: vals['last']!.trim(), courseName: cls, birth: vals['birth']!.trim(), parent: vals['parent']!.trim(), phone: vals['phone']!.trim(), who: _who));
          Navigator.of(c2).pop();
        })]),
      ]))),
    )));
  }
  // ייבוא-CSV: הדבקת-טקסט ⇒ parseCsv ⇒ רישומים; מצב "ייבוא-בתהליך" שמור (מאיר בזמן העיבוד)
  void _importForm(BuildContext ctx) {
    var text = '';
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => Padding(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(c2).viewInsets.bottom + 12),
      child: GlassCard(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('ייבוא תלמידים (CSV)', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const Text('עמודות: שם-פרטי, שם-משפחה, כיתה, לידה, הורה, טלפון — שורה לכל מורה', style: TextStyle(color: _muted, fontSize: 12)),
        DsField(label: 'CSV', hint: 'דנה,כהן,י׳-1 · כיתת-חינוך,2010-05-05,רונית,0501234567', value: text, onChanged: (x) => text = x),
        Row(children: [SoftButton(label: '📥 ייבא', tone: 1, onTap: () {
          Navigator.of(c2).pop();
          setState(() { _importing = true; });
          Future.delayed(const Duration(milliseconds: 600), () { if (!mounted) return; setState(() { _importResult = _StuData.importCsv(text, _who); _importing = false; if (_importResult!['ok'] == 0) { _error = 'ייבוא נכשל: אין שורות תקינות (${_importResult!['skipped']} נדחו) — בדוק/י את עמודות-ה-CSV'; _importResult = null; } }); });
        })]),
      ])),
    ));
  }

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

// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): TeacherFacts — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══
class TeacherFacts {
  static const String entity = 'Teacher';
  static const String label = 'מורה'; // מונח-הישות מ-entity-terms (דאטה)
  static int get count => ((_StuData.db['families'] as List?)?.length ?? 0); // רשומות הזרע-הראשי "families" (seed-db)
  static const List<Map<String, String>> metricDefs = <Map<String, String>>[{'key': 'highN', 'label': '🔴 סיכון-גבוה', 'tone': 'danger'}, {'key': 'newN', 'label': '🆕 חדשים-השנה', 'tone': 'plain'}, {'key': 'midN', 'label': '🟠 סיכון-בינוני', 'tone': 'plain'}, {'key': 'medicalN', 'label': '🩺 רפואי/צרכים', 'tone': 'plain'}, {'key': 'noParentN', 'label': '📵 ללא-הורה-מעודכן', 'tone': 'danger'}, {'key': 'openTicketsN', 'label': '📨 פניות-פתוחות', 'tone': 'plain'}]; // 6 מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי)
  static Map<String, String> get metrics => <String, String>{'highN': '${_StuData.highN}', 'newN': '${_StuData.newN}', 'midN': '${_StuData.midN}', 'medicalN': '${_StuData.medicalN}', 'noParentN': '${_StuData.noParentN}', 'openTicketsN': '${_StuData.openTicketsN}'};
  static const String heroKey = 'highN'; // ה-StatHero של הזהב (המטרה המוצהרת)
  static String get hero => metrics[heroKey] ?? '$count';
  static String get heroLabel => '🔴 סיכון-גבוה';
}
