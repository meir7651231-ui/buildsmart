// 🏗️ StudioApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 6 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "חוגים ותפוסה" ⇒ Course ⇐ schoolos_courses.dart (strong · שמות 23/39)
//   "בני משפחה לפי גיל" ⇒ Member ⇐ schoolos_students.dart (strong · שמות 16/17)
//   "מדריכה עם שעות" ⇒ Teacher ⇐ schoolos_students.dart (strong · שמות 8/19)
//   "שיוכים פתוחים" ⇒ ShopAssignment ⇐ schoolos_teachers.dart (medium · שמות 3/9)
//   "קריטריון זכאות להנחה" ⇒ ShopCriterion ⇐ schoolos_courses.dart (medium · שמות 3/4)
//   "נדבות לפי חודש" ⇒ Donation ⇐ schoolos_fees.dart (strong · שמות 5/7)
//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: Course:∅ · Member:1 עמודות · Teacher:9 עמודות · ShopAssignment:∅ · ShopCriterion:∅ · Donation:∅
//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): Course:initialMetric · Member:initialMetric · Teacher:initialMetric · ShopAssignment:initialMetric · ShopCriterion:initialMetric · Donation:∅
//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: Course:initialPanelId · Member:initialPanelId · Teacher:initialPanelId · ShopAssignment:initialPanel · ShopCriterion:initialPanelId · Donation:initialPanelId
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: CourseFacts.kpiNoTeacher · MemberFacts.highN · TeacherFacts.highN · ShopAssignmentFacts.absentN · ShopCriterionFacts.kpiNoTeacher · DonationFacts.count
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (אטום-דאטה)
import 'gen_retarget_course_from_crs.dart' show CourseScreen, CourseFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_member_from_stu.dart' show MemberScreen, MemberFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_teacher_from_stu.dart' show TeacherScreen, TeacherFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopassignment_from_tch.dart' show ShopAssignmentScreen, ShopAssignmentFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopcriterion_from_crs.dart' show ShopCriterionScreen, ShopCriterionFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_donation_from_fee.dart' show DonationScreen, DonationFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

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
        SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: '${vis.length}/${modules.length}', label: 'מסכים מחוברים')),
        if (vis.contains(0)) GestureDetector(key: const ValueKey('hero-Course'), onTap: () { final id = CourseFacts.heroFirstId; _go(context, id == null ? const CourseScreen() : CourseScreen(initialPanelId: id, initialMetric: CourseFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: CourseFacts.hero, label: CourseFacts.heroLabel))), // Course · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('hero-Member'), onTap: () { final id = MemberFacts.heroFirstId; _go(context, id == null ? const MemberScreen() : MemberScreen(initialPanelId: id, initialMetric: MemberFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: MemberFacts.hero, label: MemberFacts.heroLabel))), // Member · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('hero-Teacher'), onTap: () { final id = TeacherFacts.heroFirstId; _go(context, id == null ? const TeacherScreen() : TeacherScreen(initialPanelId: id, initialMetric: TeacherFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: TeacherFacts.hero, label: TeacherFacts.heroLabel))), // Teacher · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('hero-ShopAssignment'), onTap: () { final id = ShopAssignmentFacts.heroFirstId; _go(context, id == null ? const ShopAssignmentScreen() : ShopAssignmentScreen(initialPanel: id, initialMetric: ShopAssignmentFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: ShopAssignmentFacts.hero, label: ShopAssignmentFacts.heroLabel))), // ShopAssignment · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(4)) GestureDetector(key: const ValueKey('hero-ShopCriterion'), onTap: () { final id = ShopCriterionFacts.heroFirstId; _go(context, id == null ? const ShopCriterionScreen() : ShopCriterionScreen(initialPanelId: id, initialMetric: ShopCriterionFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: ShopCriterionFacts.hero, label: ShopCriterionFacts.heroLabel))), // ShopCriterion · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(5)) GestureDetector(key: const ValueKey('hero-Donation'), onTap: () { final id = DonationFacts.heroFirstId; _go(context, id == null ? const DonationScreen() : DonationScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: DonationFacts.hero, label: DonationFacts.heroLabel))), // Donation · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) const EmptyState(glyph: '🔍', message: 'אין מודול שתואם לחיפוש') else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) DsNavTile(glyph: '🧬', title: 'חוג', sub: '${CourseFacts.count} ${CourseFacts.label} · חוגים ותפוסה', onTap: () => _go(context, const CourseScreen())),
        if (vis.contains(1)) DsNavTile(glyph: '🧬', title: 'בני משפחה', sub: '${MemberFacts.count} ${MemberFacts.label} · בני משפחה לפי גיל', onTap: () => _go(context, const MemberScreen())),
        if (vis.contains(2)) DsNavTile(glyph: '🧬', title: 'מורה', sub: '${TeacherFacts.count} ${TeacherFacts.label} · מדריכה עם שעות', onTap: () => _go(context, const TeacherScreen())),
        if (vis.contains(3)) DsNavTile(glyph: '🧬', title: 'שיוך', sub: '${ShopAssignmentFacts.count} ${ShopAssignmentFacts.label} · שיוכים פתוחים', onTap: () => _go(context, const ShopAssignmentScreen())),
        if (vis.contains(4)) DsNavTile(glyph: '🧬', title: 'קריטריון', sub: '${ShopCriterionFacts.count} ${ShopCriterionFacts.label} · קריטריון זכאות להנחה', onTap: () => _go(context, const ShopCriterionScreen())),
        if (vis.contains(5)) DsNavTile(glyph: '🧬', title: 'תרומות', sub: '${DonationFacts.count} ${DonationFacts.label} · נדבות לפי חודש', onTap: () => _go(context, const DonationScreen())),
      ]),
    ]);
  }
}
