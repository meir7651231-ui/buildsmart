// 🏗️ StudioApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 6 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "חוגים ותפוסה" ⇒ Course ⇐ schoolos_courses.dart (strong · שמות 23/39)
//   "בני משפחה לפי גיל" ⇒ Member ⇐ schoolos_students.dart (strong · שמות 16/17)
//   "מדריכה עם שעות" ⇒ Teacher ⇐ schoolos_students.dart (strong · שמות 8/19)
//   "שיוכים פתוחים" ⇒ ShopAssignment ⇐ schoolos_teachers.dart (medium · שמות 3/9)
//   "קריטריון זכאות להנחה" ⇒ ShopCriterion ⇐ schoolos_courses.dart (medium · שמות 3/4)
//   "נדבות לפי חודש" ⇒ Donation ⇐ schoolos_fees.dart (strong · שמות 5/7)
//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: Course:∅ · Member:1 עמודות · Teacher:9 עמודות · ShopAssignment:∅ · ShopCriterion:∅ · Donation:∅
//   G12c · תפקידי-עור: kpi=ForgeStatBlock · navTile=ForgeHubTile · empty=ForgeSearchEmptyState · stat=ForgeMetricTile · hero=ForgeStatBlock
//   G12b · עור: forge — אריח-KPI = ForgeStatBlock (dataviz · 3 חריצים · תוכן-העיצוב ["Label","248","12% Meta"] ⇒ ערך בחריץ 1, תווית בחריץ 0, השאר '') — הצבה של הבעלים ב-app-golden, מאומתת מבנית
//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): Course:initialMetric · Member:initialMetric · Teacher:initialMetric · ShopAssignment:initialMetric · ShopCriterion:initialMetric · Donation:∅
//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: Course:initialPanelId · Member:initialPanelId · Teacher:initialPanelId · ShopAssignment:initialPanel · ShopCriterion:initialPanelId · Donation:initialPanelId
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: CourseFacts.kpiNoTeacher · MemberFacts.highN · TeacherFacts.highN · ShopAssignmentFacts.absentN · ShopCriterionFacts.kpiNoTeacher · DonationFacts.count
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-forge-bs/dataviz/dataviz.dart'; // G12b/c · עור-forge
import '../dart-forge-bs/card/card.dart'; // G12b/c · עור-forge
import '../dart-forge-bs/feedback/feedback.dart'; // G12b/c · עור-forge
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (אטום-דאטה)
import 'gen_retarget_course_from_crs_sk139238.dart' show CourseScreen, CourseFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_member_from_stu_sk139238.dart' show MemberScreen, MemberFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_teacher_from_stu_sk139238.dart' show TeacherScreen, TeacherFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopassignment_from_tch_sk139238.dart' show ShopAssignmentScreen, ShopAssignmentFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopcriterion_from_crs_sk139238.dart' show ShopCriterionScreen, ShopCriterionFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_donation_from_fee_sk139238.dart' show DonationScreen, DonationFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

class StudioApp extends StatelessWidget {
  const StudioApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Studio', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: DsTokens.fontBody), home: const StudioHubScreen()); // גופן-הגוף של ה-DS (מצורף לחבילה) — לא Roboto-מ-CDN: האתר-המחולל עצמאי גם בלי רשת (L69)
}

class StudioHubScreen extends StatefulWidget {
  const StudioHubScreen({super.key});
  @override
  State<StudioHubScreen> createState() => _StudioHubScreenState();
}

class _StudioHubScreenState extends State<StudioHubScreen> {
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = <String>['חוג', 'בני משפחה', 'מורה', 'שיוך', 'קריטריון', 'תרומות']; // 6 מסכים מחווטים
  String _q = ''; // חיפוש-רכזת נגזר (G9c): DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — צורת-האיתור של הזהב (23-ג), לא .contains שטוח
  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  // שורות-החיפוש = נגזרת של תפר-העובדות: כותרת · מונח-הישות · המשפט · תוויות-המדדים — אפס דאטה-חדש
  static final rows = <Map<String, dynamic>>[
    {'i': 0, 'title': 'חוג', 'label': CourseFacts.label, 'text': 'חוגים ותפוסה', 'terms': [for (final d in CourseFacts.metricDefs) '${d['label']}']},
    {'i': 1, 'title': 'בני משפחה', 'label': MemberFacts.label, 'text': 'בני משפחה לפי גיל', 'terms': [for (final d in MemberFacts.metricDefs) '${d['label']}']},
    {'i': 2, 'title': 'מורה', 'label': TeacherFacts.label, 'text': 'מדריכה עם שעות', 'terms': [for (final d in TeacherFacts.metricDefs) '${d['label']}']},
    {'i': 3, 'title': 'שיוך', 'label': ShopAssignmentFacts.label, 'text': 'שיוכים פתוחים', 'terms': [for (final d in ShopAssignmentFacts.metricDefs) '${d['label']}']},
    {'i': 4, 'title': 'קריטריון', 'label': ShopCriterionFacts.label, 'text': 'קריטריון זכאות להנחה', 'terms': [for (final d in ShopCriterionFacts.metricDefs) '${d['label']}']},
    {'i': 5, 'title': 'תרומות', 'label': DonationFacts.label, 'text': 'נדבות לפי חודש', 'terms': [for (final d in DonationFacts.metricDefs) '${d['label']}']},
  ];
  static List<String> termsOf(Map<String, dynamic> r) => ['${r['title']}', '${r['label']}', '${r['text']}', ...(r['terms'] as List).cast<String>()];
  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) {
    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();
    return DsScaffold(title: 'Studio', subtitle: '6 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
        SizedBox(width: 168, child: ForgeStatBlock(fields: ['מסכים מחוברים', '${vis.length}/${modules.length}', ''])),
        if (vis.contains(0)) GestureDetector(key: const ValueKey('hero-Course'), onTap: () { final id = CourseFacts.heroFirstId; _go(context, id == null ? const CourseScreen() : CourseScreen(initialPanelId: id, initialMetric: CourseFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatBlock(fields: [CourseFacts.heroLabel, CourseFacts.hero, '']))), // Course · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('hero-Member'), onTap: () { final id = MemberFacts.heroFirstId; _go(context, id == null ? const MemberScreen() : MemberScreen(initialPanelId: id, initialMetric: MemberFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatBlock(fields: [MemberFacts.heroLabel, MemberFacts.hero, '']))), // Member · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('hero-Teacher'), onTap: () { final id = TeacherFacts.heroFirstId; _go(context, id == null ? const TeacherScreen() : TeacherScreen(initialPanelId: id, initialMetric: TeacherFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatBlock(fields: [TeacherFacts.heroLabel, TeacherFacts.hero, '']))), // Teacher · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('hero-ShopAssignment'), onTap: () { final id = ShopAssignmentFacts.heroFirstId; _go(context, id == null ? const ShopAssignmentScreen() : ShopAssignmentScreen(initialPanel: id, initialMetric: ShopAssignmentFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatBlock(fields: [ShopAssignmentFacts.heroLabel, ShopAssignmentFacts.hero, '']))), // ShopAssignment · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(4)) GestureDetector(key: const ValueKey('hero-ShopCriterion'), onTap: () { final id = ShopCriterionFacts.heroFirstId; _go(context, id == null ? const ShopCriterionScreen() : ShopCriterionScreen(initialPanelId: id, initialMetric: ShopCriterionFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatBlock(fields: [ShopCriterionFacts.heroLabel, ShopCriterionFacts.hero, '']))), // ShopCriterion · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(5)) GestureDetector(key: const ValueKey('hero-Donation'), onTap: () { final id = DonationFacts.heroFirstId; _go(context, id == null ? const DonationScreen() : DonationScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatBlock(fields: [DonationFacts.heroLabel, DonationFacts.hero, '']))), // Donation · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) ForgeSearchEmptyState(fields: ['אין מודול שתואם לחיפוש', 'נסה מילה אחרת']) else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) GestureDetector(key: const ValueKey('nav-Course'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const CourseScreen()), child: ForgeHubTile(fields: ['חוג', '${CourseFacts.count} ${CourseFacts.label} · חוגים ותפוסה'])), // אריח-ניווט forge (G12c)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('nav-Member'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const MemberScreen()), child: ForgeHubTile(fields: ['בני משפחה', '${MemberFacts.count} ${MemberFacts.label} · בני משפחה לפי גיל'])), // אריח-ניווט forge (G12c)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('nav-Teacher'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const TeacherScreen()), child: ForgeHubTile(fields: ['מורה', '${TeacherFacts.count} ${TeacherFacts.label} · מדריכה עם שעות'])), // אריח-ניווט forge (G12c)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('nav-ShopAssignment'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const ShopAssignmentScreen()), child: ForgeHubTile(fields: ['שיוך', '${ShopAssignmentFacts.count} ${ShopAssignmentFacts.label} · שיוכים פתוחים'])), // אריח-ניווט forge (G12c)
        if (vis.contains(4)) GestureDetector(key: const ValueKey('nav-ShopCriterion'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const ShopCriterionScreen()), child: ForgeHubTile(fields: ['קריטריון', '${ShopCriterionFacts.count} ${ShopCriterionFacts.label} · קריטריון זכאות להנחה'])), // אריח-ניווט forge (G12c)
        if (vis.contains(5)) GestureDetector(key: const ValueKey('nav-Donation'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const DonationScreen()), child: ForgeHubTile(fields: ['תרומות', '${DonationFacts.count} ${DonationFacts.label} · נדבות לפי חודש'])), // אריח-ניווט forge (G12c)
      ]),
    ]);
  }
}
