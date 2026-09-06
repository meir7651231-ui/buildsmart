// 🎯 TeacherScreen — retarget של schoolos_students.dart לישות Teacher (GENMAX·G5c/G5d · הכרעה-24) · מחולל דטרמיניסטי: retarget.mjs --module schoolos_students.dart --entity Teacher
//   זרע-ראשי: families (מועמדים: families(27/33) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) members(11/15) tasks(9/12) enrollments(8/11) courses(6/9) events(6/8) teachers(4/4) audit(4/4)) · מיפוי שם 8 · ערוץ 0 · טיפוס-יחיד 2 · מקום-שמור 19 · חוזה-מנוע (לא משתנה) 4
//   id⇒id(name) · name⇒name(name) · phone⇒phone(name) · phone2⇒phone2(name) · email⇒email(name) · address⇒address(name) · notes⇒notes(name) · idNum⇒idNum(name) · status⇒∅(engine-contract) · createdAt⇒∅(engine-contract) · docs⇒∅(engine-contract) · members⇒∅(engine-contract) · father⇒∅(reserved(6 מועמדים)) · mother⇒∅(reserved(6 מועמדים)) · city⇒∅(reserved(6 מועמדים)) · language⇒∅(reserved(6 מועמדים)) · maritalStatus⇒∅(reserved(6 מועמדים)) · tzedaka⇒∅(reserved(6 מועמדים)) · discount⇒∅(reserved(6 מועמדים)) · addedAt⇒startDate(unique) · cred⇒∅(reserved) · log⇒∅(reserved) · first⇒∅(reserved(6 מועמדים)) · gender⇒∅(reserved(6 מועמדים)) · birth⇒∅(reserved) · school⇒∅(reserved(6 מועמדים)) · grade⇒∅(reserved(6 מועמדים)) · health⇒∅(reserved(6 מועמדים)) · mSefach⇒payToOther(unique) · mInvite⇒∅(reserved) · mRecommend⇒∅(reserved) · mPhotos⇒∅(reserved) · mVideos⇒∅(reserved)
//   עור-forge (G12c/e): BareStat⇒ForgeStatPlain ×0 (ב-Wrap) · ×0 (ב-Row, Expanded) · פנימיים: button×5 statusChip×0 banner×0 emptyState×0 mediaRow×0 · StatHero⇒ForgeStatPlain ×0 · KpiTile⇒— · DsNavTile⇒— — fields לפי תפקידי-חריצים; צבעי-מצב-DS לא מועברים
//   תפר-עובדות (G9b): TeacherFacts · count=families.length (seed-db) · מדדים 0 · hero=count · שורות-מדד (G10a) ∅ · תפר-כניסה ∅ · תפר-סינון-מדד ∅ · תפר-הזרקה db (families/members · 0 עמודות-שמורות)
//   שדות-Teacher בלי מקור (מקום-שמור, יאירו כשיוזרם נתון): specialty, payRate, payMethod, payeeName, payeePhone, payeeIdNum, bankName, bankBranch, bankAccount · תוויות: מונחי student (תלמיד/ה/תלמידים) ⇒ Teacher (מורה/—) · 2 החלפות · הזרע = זרע-הצבה של המקור, לא ערך-אמת של Teacher
// 🎓 SchoolOS · מודול-תלמידים — נבנה בדרך (THE-WAY · הכרעה 23-ב/ג/ד) מול SPEC-STUDENTS-FULL-2026-09-04.
// מטרה: "לדעת מי כל תלמיד באמת — לימודית, חברתית, רגשית ומשפחתית — ולראות את מי-שנופל לפני שהוא נופל."
// פעולות-יסוד (לא אזורי-מפרט): איתור · הערכת-מצב · חיבור-אותות-להכרעה · זיהוי-חריגה · הכרעה · ביצוע · אימות.
// כל חלקיק-תובנה = הרכבת כמה אטומי-מדף (תצוגה ⊕ לוגיקה); עובדה (תווית+ערך) = אטום-יחיד לגיטימי.
// אפס-זיוף (§20-ג): רק שדות עם מקור-אמת באימפריה (סכמת-maor: Member · Family · Enrollment · Course ·
// Teacher · WorkTask · OrgEvent · AuditEntry — `dart-maor/schema-fields.dart`). שדה חסר-מקור = מקום-שמור (חוק-7).
// זהות/קשר/תאריך מוזרקים (חוק-6): today · roleDefs · db — לעולם לא אטום.
// G17c · מטרה (צעד 1, אדם): לדעת מי מלמד מה ומתי · פעולות-יסוד (צעד 2, אדם): איתור · רישום ⇒ חלקיקים (המנוע): stu.locate · stu.form
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
import '../dart-forge-bs/action/action.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/card/card.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/input/input.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)
import '../dart-forge-bs/header/header.dart'; // G12c · עור-forge במודול (skin.stat/hero) — אטומי-DS הוחלפו באטומי-forge עם fields; צבעי-מצב של ה-DS (סכנה/תקין) לא מועברים (האטום לובש את החריץ)

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
  static Map<String, dynamic> trend90(Map<String, dynamic> s) => trend(s, lastN: 4); // חלון-רבעוני

  // ─── משפחה (מקור: Family) ───
  static Map<String, dynamic> fam(Map<String, dynamic> s) => s['family'] as Map<String, dynamic>;
  static String parentName(Map<String, dynamic> s) {
    final f = fam(s);
    final m = (f['mother'] as String?) ?? '', d = (f['father'] as String?) ?? '';
    return m.isNotEmpty ? m : d.isNotEmpty ? d : '—';
  }
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
  // ═══ חוזה-עמודות · מקום-שמור (חוק-7 · מבחן-הקונכייה) — 18 עמודות-המפרט כשקעי-דאטה ═══
  //   נגזרת(get) = תמיד-מוצגת · שדה(key) = מוארת רק כשרשומה כלשהי נושאת ערך (חסר ⇒ שקט). fmt = עיצוב-ערך אופציונלי.
  //   הוספת שדה לרשומה (photo/grades/…) ⇒ העמודה מאירה לבד, אפס-שינוי-קוד.
  static int roleCtx = 0; // התפקיד-הפעיל (מוזרק מהמסך לפני רינדור-טבלה)
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
  static List<Map<String, dynamic>> homeroomCourses() => [for (final c in (db['courses'] as List).cast<Map<String, dynamic>>()) if (c['cat'] == 'חינוך' && '${c['end']}'.compareTo(today) >= 0) c];
  static void editField(Map<String, dynamic> s, String key, String value, String who) { // עריכה = כתיבה לשדה-האמת (Member/Family)
    if (const {'phone', 'city', 'address', 'language', 'mother', 'father', 'email'}.contains(key)) { fam(s)[key] = value; } else { s[key] = value; }
    if (key == 'first') { s['name'] = '$value ${s['last']}'; }
    log(who, 'edit', '${s['id']} · $key');
  }
  // אישורי-הורים: מדיה (Member.mPhotos/mVideos/mInvite/mRecommend = מקור-אמת) · טיולים/תרופות = מקום-שמור (מוצגים דרך WorkTask.ref.consent)
  static const consentDefs = [
    {'key': 'mPhotos', 'label': 'צילום'}, {'key': 'mVideos', 'label': 'וידאו'}, {'key': 'mInvite', 'label': 'הזמנות'}, {'key': 'mRecommend', 'label': 'המלצות'},
  ];
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
  static String who(int role) => roleDefs[role]['email'] as String;
  static List<Map<String, dynamic>> scoped(int role, List<Map<String, dynamic>> xs) {
    final sc = roleDefs[role]['scope'] as Map?;
    if (sc == null) return xs;
    if (sc['teacherId'] != null) return xs.where((s) => courseOf(mainEnrollment(s)?['courseId'] as String?)?['teacherId'] == sc['teacherId']).toList();
    if (sc['famId'] != null) return xs.where((s) => s['famId'] == sc['famId']).toList();
    return xs;
  }
  // חשיפת שדה-מוגן: מותרת ⇒ נרשמת בלוג-חשיפה (אודיט act=expose); אסורה ⇒ '🔒' (מצב פרטיות-נעולה)
  // ═══ אוטומציות-חכמות (הכרעה 23-ג · פרואקטיבי): המערכת מתריעה לפני שדבר נשמט — כולן מנועי-מדף/שדות-אמת ═══
  // 1. קפיצת-סיכון: ציון-היום מול ציון-לפני-30-יום (אותו מנוע על תת-הדאטה עד cutoff) — הפרש ≥15 = התרעה
  static String _cutoff = '';
  static List<Map<String, dynamic>> cohort(Map<String, dynamic> s) => active.where((o) => o['grade'] == s['grade']).toList();
  static int percentile(Map<String, dynamic> s) { final c = cohort(s); if (c.length < 2) return 50; final me = risk(s); return (c.where((o) => risk(o) < me).length * 100 / (c.length - 1)).round().clamp(0, 100); }
  // 8. דוח-יועץ שבועי (טקסט מהאותות): סיכון-גבוה · קפיצות · פניות-פתוחות · ללא-הורה · אישורים-פגים
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
  int _sort = 0; // 0=סיכון · 1=כיתה · 2=שם — SegmentedSwitch→דירוג
  final Map<String, String> _locks = {}; // צירי-סינון פעילים (finderMatches) — AND
  int _role = 0; // 0=מנהל · 1=יועץ · 2=מחנך · 3=מזכירות · 4=הורה · 5=צפייה (חוק-6 זהות-מוזרקת; בורר מדגים גידור)
  bool _importing = false; // מצב-מיוחד: ייבוא-בתהליך
  Map<String, int>? _importResult; // תוצאת-ייבוא אחרונה
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
  String get _who => _StuData.who(_role); // זהות-מוזרקת (חוק-6) מבורר-התפקיד
  // ─── גיליונות-קלט (DsField/DsEnumField מהמדף) — קלט-אמת מהמשתמש, לא ערכים מומצאים ───
  void _prompt(BuildContext ctx, String title, String hint, void Function(String) onSave) {
    var v = '';
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => Padding(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(c2).viewInsets.bottom + 12),
      child: ForgeStripPanelFrame(fields: ['', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        ForgeDsField(state: (v).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [title, ''], control: DsField(label: title, hint: hint, value: v, onChanged: (x) => v = x, bare: true)),
        Row(children: [Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () { if (v.trim().isNotEmpty) { onSave(v.trim()); Navigator.of(c2).pop(); } }, child: ForgeToneButton(items: [['💾 שמור']], variants: const <int>[1])))]),
      ])),
    ));
  }
  void _pick(BuildContext ctx, String title, List<String> options, void Function(String) onSave) {
    var v = options.isEmpty ? '' : options.first;
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, builder: (c2) => StatefulBuilder(builder: (c2, setS) => Padding(
      padding: const EdgeInsets.all(12),
      child: ForgeStripPanelFrame(fields: ['', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title, style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        ForgeDsEnumField(fields: [title], control: DsEnumField(label: title, options: options, value: v, onChanged: (x) => setS(() => v = x), bare: true)),
        Row(children: [Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () { if (v.isNotEmpty) { onSave(v); Navigator.of(c2).pop(); } }, child: ForgeToneButton(items: [['💾 שמור']], variants: const <int>[1])))]),
      ])),
    )));
  }
  void _editForm(BuildContext ctx, Map<String, dynamic> s, void Function(void Function()) act) {
    final f = _StuData.fam(s);
    final vals = <String, String>{'first': '${s['first']}', 'school': '${s['school'] ?? ''}', 'mother': '${f['mother']}', 'father': '${f['father']}', 'phone': '${f['phone']}', 'city': '${f['city']}', 'address': '${f['address']}', 'language': '${f['language']}'};
    const labels = {'first': 'שם פרטי', 'school': 'בית-ספר', 'mother': 'אם', 'father': 'אב', 'phone': 'טלפון-הורה', 'city': 'ישוב', 'address': 'כתובת', 'language': 'שפת-בית'};
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => DraggableScrollableSheet(
      initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.95, expand: false,
      builder: (c2, scroll) => Padding(padding: const EdgeInsets.all(12), child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
        Text('עריכה · ${s['name']}', style: const TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        for (final k in vals.keys) ForgeDsField(state: (vals[k]!).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [labels[k]!, ''], control: DsField(label: labels[k]!, hint: '', value: vals[k]!, onChanged: (x) => vals[k] = x, bare: true)),
        _gap(8),
        Row(children: [Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () { act(() { for (final k in vals.keys) { if (vals[k] != '${k == 'first' || k == 'school' ? s[k] ?? '' : f[k]}') _StuData.editField(s, k, vals[k]!, _who); } }); Navigator.of(c2).pop(); }, child: ForgeToneButton(items: [['💾 שמור']], variants: const <int>[1])))]),
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
      builder: (c2, scroll) => Padding(padding: const EdgeInsets.all(12), child: ForgeStripPanelFrame(fields: ['', ''], child: ListView(controller: scroll, padding: const EdgeInsets.all(6), children: [
        const Text('רישום מורה חדש/ה', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        for (final k in vals.keys) ForgeDsField(state: (vals[k]!).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: [labels[k]!, ''], control: DsField(label: labels[k]!, hint: '', value: vals[k]!, onChanged: (x) => vals[k] = x, bare: true)),
        ForgeDsEnumField(fields: ['כיתה'], control: DsEnumField(label: 'כיתה', options: classes, value: cls, onChanged: (x) => setS(() => cls = x), bare: true)),
        _gap(8),
        Row(children: [Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
          if (vals['first']!.trim().isEmpty || vals['last']!.trim().isEmpty) return;
          setState(() => _StuData.addStudent(first: vals['first']!.trim(), last: vals['last']!.trim(), courseName: cls, birth: vals['birth']!.trim(), parent: vals['parent']!.trim(), phone: vals['phone']!.trim(), who: _who));
          Navigator.of(c2).pop();
        }, child: ForgeToneButton(items: [['💾 רשום']], variants: const <int>[1])))]),
      ]))),
    )));
  }
  // ייבוא-CSV: הדבקת-טקסט ⇒ parseCsv ⇒ רישומים; מצב "ייבוא-בתהליך" שמור (מאיר בזמן העיבוד)
  void _importForm(BuildContext ctx) {
    var text = '';
    showModalBottomSheet<void>(context: ctx, backgroundColor: Colors.transparent, isScrollControlled: true, builder: (c2) => Padding(
      padding: EdgeInsets.only(left: 12, right: 12, bottom: MediaQuery.of(c2).viewInsets.bottom + 12),
      child: ForgeStripPanelFrame(fields: ['', ''], child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('ייבוא תלמידים (CSV)', style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w800)),
        const Text('עמודות: שם-פרטי, שם-משפחה, כיתה, לידה, הורה, טלפון — שורה לכל מורה', style: TextStyle(color: _muted, fontSize: 12)),
        ForgeDsField(state: (text).toString().trim().isEmpty ? ForgeDsFieldState.empty : ForgeDsFieldState.filled, fields: ['CSV', ''], control: DsField(label: 'CSV', hint: 'דנה,כהן,י׳-1 · כיתת-חינוך,2010-05-05,רונית,0501234567', value: text, onChanged: (x) => text = x, bare: true)),
        Row(children: [Flexible(child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: () {
          Navigator.of(c2).pop();
          setState(() { _importing = true; });
          Future.delayed(const Duration(milliseconds: 600), () { if (!mounted) return; setState(() { _importResult = _StuData.importCsv(text, _who); _importing = false; if (_importResult!['ok'] == 0) { _error = 'ייבוא נכשל: אין שורות תקינות (${_importResult!['skipped']} נדחו) — בדוק/י את עמודות-ה-CSV'; _importResult = null; } }); });
        }, child: ForgeToneButton(items: [['📥 ייבא']], variants: const <int>[1])))]),
      ])),
    ));
  }

  // רענון-דאטה → מצב-טעינה שמור (700ms מדגים; חיבור-אסינק אמיתי יאיר אותו זהה)
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
    return DsScaffold(title: 'TeacherScreen', subtitle: 'TeacherScreen · מודול-משנה מחולל · 1 בונים מחווטים-לשקעי-הזהב', icon: '🧬', header: false, children: [ForgeCenteredPageHeader(fields: ['', 'TeacherScreen', 'TeacherScreen · מודול-משנה מחולל · 1 בונים מחווטים-לשקעי-הזהב']), ...[
      _gap(10),
    ]]);
  }
}

// ═══ תפר-עובדות ציבורי (G9b · לרכזת-האפליקציה): TeacherFacts — נגזרות-אמת של דאטה-המודול; כל ערך = ביטוי חי על הזרע/המנועים (§20-ג), אפס ליטרל-מומצא. מחולל: retarget.mjs ═══
class TeacherFacts {
  static const String entity = 'Teacher';
  static const String label = 'מורה'; // מונח-הישות מ-entity-terms (דאטה)
  static int get count => ((_StuData.db['families'] as List?)?.length ?? 0); // רשומות הזרע-הראשי "families" (seed-db)
  static const List<Map<String, String>> metricDefs = <Map<String, String>>[]; // 0 מדדים חצובים משורת-ה-KPI של הזהב (BareStat/StatHero ⇐ getter-סטטי מספרי) — אין getter-סטטי בשורת-ה-KPI ⇒ ריק, לא מומצא
  static Map<String, String> get metrics => <String, String>{};
  static const String heroKey = 'count'; // אין מדדים ⇒ count
  static String get hero => metrics[heroKey] ?? '$count';
  static String get heroLabel => label;
  static const String idKey = 'id'; // מפתח-המזהה בזרע (אחרי retarget)
  static List<Map<String, dynamic>> get rows => ((_StuData.db['families'] as List?) ?? const []).cast<Map<String, dynamic>>(); // כל רשומות הזרע-הראשי (seed-db)
  static Map<String, dynamic>? byId(String id) { for (final r in [for (final k in const <String>[]) ...heroRows(k), ...rows]) { if ('${r[idKey] ?? r['id']}' == id) return r; } return null; } // שורות-המדד קודם (הן מסוג-הרשומה שהפאנל צורך — בזהב-התלמידים הפאנל פותח תלמיד, הזרע-הראשי-לפי-מפתחות הוא families), ואז הזרע-הראשי
  static List<Map<String, dynamic>> heroRows(String key) { switch (key) {  default: return const []; } } // G10a · 0 מדדים עם שורות (צורת X.where(P).length)
  static String? get heroFirstId { final r = heroRows(heroKey); return r.isEmpty ? null : '${r.first[idKey]}'; } // הרשומה-הראשונה של ה-hero — יעד-הקפיצה מהרכזת
  // G10b-ב · תפר-הזרקה (חוק-6: הדאטה מוזרקת, לא מומצאת): seed() = זרע-ההצבה של הזהב · seedList/rowList = היכן רשומת-המסך חיה (מצורת _build()) · reservedColumns = עמודות-מקום-שמור של G5h
  static Map<String, dynamic> seed() => _StuData.seed();
  static const String seedList = 'families';
  static const String? rowList = 'members'; // null ⇒ רשומת-המסך = רשומת-הזרע עצמה
  static const List<String> reservedColumns = <String>[];
  static const String? tableView = null; // תווית-המבט שמגלה את הטבלה (null ⇒ הטבלה תמיד גלויה)
}
