// 🏗️ TzedakaApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 7 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "קופות צדקה לפי רכז" ⇒ TzCoordinator ⇐ schoolos_fees.dart (strong · שמות 5/10)
//   "מבצע גיוס עם יעד" ⇒ TzCampaign ⇐ schoolos_courses.dart (strong · שמות 5/7)
//   "מוצר עם מחיר ומלאי" ⇒ ShopProduct ⇐ schoolos_rooms.dart (strong · שמות 4/7)
//   "חנות שותפה עם כתובת" ⇒ ShopStore ⇐ schoolos_students.dart (strong · שמות 4/6)
//   "מורה עם שעות ושיעורים" ⇒ Teacher ⇐ schoolos_students.dart (strong · שמות 8/19)
//   "שיבוצים של השנה" ⇒ Enrollment ⇐ schoolos_fees.dart (strong · שמות 4/26)
//   "תורמים לפי סכום" ⇒ Supporter ⇐ schoolos_fees.dart (strong · שמות 11/24)
//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: TzCoordinator:∅ · TzCampaign:∅ · ShopProduct:∅ · ShopStore:0 עמודות · Teacher:9 עמודות · Enrollment:∅ · Supporter:∅
//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): TzCoordinator:∅ · TzCampaign:initialMetric · ShopProduct:initialMetric · ShopStore:initialMetric · Teacher:initialMetric · Enrollment:∅ · Supporter:∅
//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: TzCoordinator:initialPanelId · TzCampaign:initialPanelId · ShopProduct:initialPanelId · ShopStore:initialPanelId · Teacher:initialPanelId · Enrollment:initialPanelId · Supporter:initialPanelId
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: TzCoordinatorFacts.count · TzCampaignFacts.kpiNoTeacher · ShopProductFacts.unavailableN · ShopStoreFacts.highN · TeacherFacts.highN · EnrollmentFacts.count · SupporterFacts.count
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (אטום-דאטה)
import 'gen_retarget_tzcoordinator_from_fee.dart' show TzCoordinatorScreen, TzCoordinatorFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_tzcampaign_from_crs.dart' show TzCampaignScreen, TzCampaignFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopproduct_from_rm.dart' show ShopProductScreen, ShopProductFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopstore_from_stu.dart' show ShopStoreScreen, ShopStoreFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_teacher_from_stu.dart' show TeacherScreen, TeacherFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_enrollment_from_fee.dart' show EnrollmentScreen, EnrollmentFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_supporter_from_fee.dart' show SupporterScreen, SupporterFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

class TzedakaApp extends StatelessWidget {
  const TzedakaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Tzedaka', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true), home: const TzedakaHubScreen());
}

class TzedakaHubScreen extends StatefulWidget {
  const TzedakaHubScreen({super.key});
  @override
  State<TzedakaHubScreen> createState() => _TzedakaHubScreenState();
}

class _TzedakaHubScreenState extends State<TzedakaHubScreen> {
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = <String>['רכז', 'מבצע', 'מוצר', 'חנות', 'מורה', 'שיבוצים', 'תורם']; // 7 מסכים מחווטים
  String _q = ''; // חיפוש-רכזת נגזר (G9c): DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — צורת-האיתור של הזהב (23-ג), לא .contains שטוח
  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  // שורות-החיפוש = נגזרת של תפר-העובדות: כותרת · מונח-הישות · המשפט · תוויות-המדדים — אפס דאטה-חדש
  static final rows = <Map<String, dynamic>>[
    {'i': 0, 'title': 'רכז', 'label': TzCoordinatorFacts.label, 'text': 'קופות צדקה לפי רכז', 'terms': [for (final d in TzCoordinatorFacts.metricDefs) '${d['label']}']},
    {'i': 1, 'title': 'מבצע', 'label': TzCampaignFacts.label, 'text': 'מבצע גיוס עם יעד', 'terms': [for (final d in TzCampaignFacts.metricDefs) '${d['label']}']},
    {'i': 2, 'title': 'מוצר', 'label': ShopProductFacts.label, 'text': 'מוצר עם מחיר ומלאי', 'terms': [for (final d in ShopProductFacts.metricDefs) '${d['label']}']},
    {'i': 3, 'title': 'חנות', 'label': ShopStoreFacts.label, 'text': 'חנות שותפה עם כתובת', 'terms': [for (final d in ShopStoreFacts.metricDefs) '${d['label']}']},
    {'i': 4, 'title': 'מורה', 'label': TeacherFacts.label, 'text': 'מורה עם שעות ושיעורים', 'terms': [for (final d in TeacherFacts.metricDefs) '${d['label']}']},
    {'i': 5, 'title': 'שיבוצים', 'label': EnrollmentFacts.label, 'text': 'שיבוצים של השנה', 'terms': [for (final d in EnrollmentFacts.metricDefs) '${d['label']}']},
    {'i': 6, 'title': 'תורם', 'label': SupporterFacts.label, 'text': 'תורמים לפי סכום', 'terms': [for (final d in SupporterFacts.metricDefs) '${d['label']}']},
  ];
  static List<String> termsOf(Map<String, dynamic> r) => ['${r['title']}', '${r['label']}', '${r['text']}', ...(r['terms'] as List).cast<String>()];
  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) {
    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();
    return DsScaffold(title: 'Tzedaka', subtitle: '7 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
        SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: '${vis.length}/${modules.length}', label: 'מסכים מחוברים')),
        if (vis.contains(0)) GestureDetector(key: const ValueKey('hero-TzCoordinator'), onTap: () { final id = TzCoordinatorFacts.heroFirstId; _go(context, id == null ? const TzCoordinatorScreen() : TzCoordinatorScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: TzCoordinatorFacts.hero, label: TzCoordinatorFacts.heroLabel))), // TzCoordinator · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('hero-TzCampaign'), onTap: () { final id = TzCampaignFacts.heroFirstId; _go(context, id == null ? const TzCampaignScreen() : TzCampaignScreen(initialPanelId: id, initialMetric: TzCampaignFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: TzCampaignFacts.hero, label: TzCampaignFacts.heroLabel))), // TzCampaign · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('hero-ShopProduct'), onTap: () { final id = ShopProductFacts.heroFirstId; _go(context, id == null ? const ShopProductScreen() : ShopProductScreen(initialPanelId: id, initialMetric: ShopProductFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: ShopProductFacts.hero, label: ShopProductFacts.heroLabel))), // ShopProduct · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('hero-ShopStore'), onTap: () { final id = ShopStoreFacts.heroFirstId; _go(context, id == null ? const ShopStoreScreen() : ShopStoreScreen(initialPanelId: id, initialMetric: ShopStoreFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: ShopStoreFacts.hero, label: ShopStoreFacts.heroLabel))), // ShopStore · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(4)) GestureDetector(key: const ValueKey('hero-Teacher'), onTap: () { final id = TeacherFacts.heroFirstId; _go(context, id == null ? const TeacherScreen() : TeacherScreen(initialPanelId: id, initialMetric: TeacherFacts.heroKey)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: TeacherFacts.hero, label: TeacherFacts.heroLabel))), // Teacher · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(5)) GestureDetector(key: const ValueKey('hero-Enrollment'), onTap: () { final id = EnrollmentFacts.heroFirstId; _go(context, id == null ? const EnrollmentScreen() : EnrollmentScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: EnrollmentFacts.hero, label: EnrollmentFacts.heroLabel))), // Enrollment · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(6)) GestureDetector(key: const ValueKey('hero-Supporter'), onTap: () { final id = SupporterFacts.heroFirstId; _go(context, id == null ? const SupporterScreen() : SupporterScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: SupporterFacts.hero, label: SupporterFacts.heroLabel))), // Supporter · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) const EmptyState(glyph: '🔍', message: 'אין מודול שתואם לחיפוש') else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) DsNavTile(glyph: '🧬', title: 'רכז', sub: '${TzCoordinatorFacts.count} ${TzCoordinatorFacts.label} · קופות צדקה לפי רכז', onTap: () => _go(context, const TzCoordinatorScreen())),
        if (vis.contains(1)) DsNavTile(glyph: '🧬', title: 'מבצע', sub: '${TzCampaignFacts.count} ${TzCampaignFacts.label} · מבצע גיוס עם יעד', onTap: () => _go(context, const TzCampaignScreen())),
        if (vis.contains(2)) DsNavTile(glyph: '🧬', title: 'מוצר', sub: '${ShopProductFacts.count} ${ShopProductFacts.label} · מוצר עם מחיר ומלאי', onTap: () => _go(context, const ShopProductScreen())),
        if (vis.contains(3)) DsNavTile(glyph: '🧬', title: 'חנות', sub: '${ShopStoreFacts.count} ${ShopStoreFacts.label} · חנות שותפה עם כתובת', onTap: () => _go(context, const ShopStoreScreen())),
        if (vis.contains(4)) DsNavTile(glyph: '🧬', title: 'מורה', sub: '${TeacherFacts.count} ${TeacherFacts.label} · מורה עם שעות ושיעורים', onTap: () => _go(context, const TeacherScreen())),
        if (vis.contains(5)) DsNavTile(glyph: '🧬', title: 'שיבוצים', sub: '${EnrollmentFacts.count} ${EnrollmentFacts.label} · שיבוצים של השנה', onTap: () => _go(context, const EnrollmentScreen())),
        if (vis.contains(6)) DsNavTile(glyph: '🧬', title: 'תורם', sub: '${SupporterFacts.count} ${SupporterFacts.label} · תורמים לפי סכום', onTap: () => _go(context, const SupporterScreen())),
      ]),
    ]);
  }
}
