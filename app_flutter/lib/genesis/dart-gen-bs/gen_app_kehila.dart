// 🏗️ KehilaApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 6 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "ניהול מתנדבים עם טלפון ואזור" ⇒ Volunteer ⇐ schoolos_fees.dart (strong · שמות 5/8)
//   "רשימת תרומות לפי תאריך וסכום" ⇒ Donation ⇐ schoolos_fees.dart (strong · שמות 5/7)
//   "מעקב חדרים ושעות" ⇒ Room ⇐ schoolos_rooms.dart (strong · שמות 11/12)
//   "מסך משפחות עם כתובת" ⇒ Family ⇐ schoolos_students.dart (strong · שמות 19/25)
//   "פריטי קטלוג במלאי" ⇒ ShopItem ⇐ schoolos_courses.dart (strong · שמות 4/13)
//   "תלמידים לפי גיל" ⇒ Member ⇐ schoolos_students.dart (strong · שמות 16/17)
//   ⚪ "רשימת ספקים עם מחירים" ⇒ אין מונח-ישות במשפט — מקום-שמור (אין המצאה)
//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: Volunteer:∅ · Donation:∅ · Room:∅ · Family:5 עמודות · ShopItem:∅ · Member:1 עמודות
//   G12c · תפקידי-עור: kpi=ForgeStatPlain · hero=ForgeStatPlain · stat=ForgeStatPlain · navTile=ForgeGridHubCard · empty=ForgeAnimatedEmpty · button=ForgeToneButton · statusChip=ForgeStatusChip · banner=ForgeToneBanner · emptyState=ForgeAnimatedEmpty · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegPickerSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeStripPanelFrame · timeline=ForgeNotifRow · field=ForgeDsField · enumField=ForgeDsEnumField · numberField=ForgeDsNumberField · dateField=ForgeDsDateFieldInput · search=ForgeDsSearch · pageHeader=ForgeCenteredPageHeader · table=ForgeDataGrid · bars=ForgeWaveformBars · board=ForgeKanbanBoard · calendar=ForgeEventCalendar
//   G12b · עור: forge — אריח-KPI = ForgeStatPlain (card · 2 חריצים · תוכן-העיצוב ["Label","248"] ⇒ ערך בחריץ 1, תווית בחריץ 0, השאר '') — הצבה של הבעלים ב-app-golden, מאומתת מבנית
//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): Volunteer:∅ · Donation:∅ · Room:initialMetric · Family:initialMetric · ShopItem:initialMetric · Member:initialMetric
//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: Volunteer:initialPanelId · Donation:initialPanelId · Room:initialPanelId · Family:initialPanelId · ShopItem:initialPanelId · Member:initialPanelId
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: VolunteerFacts.count · DonationFacts.count · RoomFacts.unavailableN · FamilyFacts.highN · ShopItemFacts.kpiNoTeacher · MemberFacts.highN
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-forge-bs/card/card.dart'; // G12b/c · עור-forge
import '../dart-forge-bs/feedback/feedback.dart'; // G12b/c · עור-forge
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (אטום-דאטה)
import 'gen_retarget_volunteer_from_fee_ske93605.dart' show VolunteerScreen, VolunteerFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_donation_from_fee_ske93605.dart' show DonationScreen, DonationFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_room_from_rm_ske93605.dart' show RoomScreen, RoomFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_family_from_stu_ske93605.dart' show FamilyScreen, FamilyFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopitem_from_crs_ske93605.dart' show ShopItemScreen, ShopItemFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_member_from_stu_ske93605.dart' show MemberScreen, MemberFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

class KehilaApp extends StatelessWidget {
  const KehilaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Kehila', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: DsTokens.fontBody), home: const KehilaHubScreen()); // גופן-הגוף של ה-DS (מצורף לחבילה) — לא Roboto-מ-CDN: האתר-המחולל עצמאי גם בלי רשת (L69)
}

class KehilaHubScreen extends StatefulWidget {
  const KehilaHubScreen({super.key});
  @override
  State<KehilaHubScreen> createState() => _KehilaHubScreenState();
}

class _KehilaHubScreenState extends State<KehilaHubScreen> {
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = <String>['מתנדבים', 'תרומות', 'חדרים', 'משפחה', 'פריט', 'בני משפחה']; // 6 מסכים מחווטים
  String _q = ''; // חיפוש-רכזת נגזר (G9c): DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — צורת-האיתור של הזהב (23-ג), לא .contains שטוח
  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  // שורות-החיפוש = נגזרת של תפר-העובדות: כותרת · מונח-הישות · המשפט · תוויות-המדדים — אפס דאטה-חדש
  static final rows = <Map<String, dynamic>>[
    {'i': 0, 'title': 'מתנדבים', 'label': VolunteerFacts.label, 'text': 'ניהול מתנדבים עם טלפון ואזור', 'terms': [for (final d in VolunteerFacts.metricDefs) '${d['label']}']},
    {'i': 1, 'title': 'תרומות', 'label': DonationFacts.label, 'text': 'רשימת תרומות לפי תאריך וסכום', 'terms': [for (final d in DonationFacts.metricDefs) '${d['label']}']},
    {'i': 2, 'title': 'חדרים', 'label': RoomFacts.label, 'text': 'מעקב חדרים ושעות', 'terms': [for (final d in RoomFacts.metricDefs) '${d['label']}']},
    {'i': 3, 'title': 'משפחה', 'label': FamilyFacts.label, 'text': 'מסך משפחות עם כתובת', 'terms': [for (final d in FamilyFacts.metricDefs) '${d['label']}']},
    {'i': 4, 'title': 'פריט', 'label': ShopItemFacts.label, 'text': 'פריטי קטלוג במלאי', 'terms': [for (final d in ShopItemFacts.metricDefs) '${d['label']}']},
    {'i': 5, 'title': 'בני משפחה', 'label': MemberFacts.label, 'text': 'תלמידים לפי גיל', 'terms': [for (final d in MemberFacts.metricDefs) '${d['label']}']},
  ];
  static List<String> termsOf(Map<String, dynamic> r) => ['${r['title']}', '${r['label']}', '${r['text']}', ...(r['terms'] as List).cast<String>()];
  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) {
    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();
    return DsScaffold(title: 'Kehila', subtitle: '6 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
        SizedBox(width: 168, child: ForgeStatPlain(fields: ['מסכים מחוברים', '${vis.length}/${modules.length}'])),
        if (vis.contains(0)) GestureDetector(key: const ValueKey('hero-Volunteer'), onTap: () { final id = VolunteerFacts.heroFirstId; _go(context, id == null ? const VolunteerScreen() : VolunteerScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [VolunteerFacts.heroLabel, VolunteerFacts.hero]))), // Volunteer · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('hero-Donation'), onTap: () { final id = DonationFacts.heroFirstId; _go(context, id == null ? const DonationScreen() : DonationScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [DonationFacts.heroLabel, DonationFacts.hero]))), // Donation · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('hero-Room'), onTap: () { final id = RoomFacts.heroFirstId; _go(context, id == null ? const RoomScreen() : RoomScreen(initialPanelId: id, initialMetric: RoomFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [RoomFacts.heroLabel, RoomFacts.hero]))), // Room · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('hero-Family'), onTap: () { final id = FamilyFacts.heroFirstId; _go(context, id == null ? const FamilyScreen() : FamilyScreen(initialPanelId: id, initialMetric: FamilyFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [FamilyFacts.heroLabel, FamilyFacts.hero]))), // Family · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(4)) GestureDetector(key: const ValueKey('hero-ShopItem'), onTap: () { final id = ShopItemFacts.heroFirstId; _go(context, id == null ? const ShopItemScreen() : ShopItemScreen(initialPanelId: id, initialMetric: ShopItemFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [ShopItemFacts.heroLabel, ShopItemFacts.hero]))), // ShopItem · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(5)) GestureDetector(key: const ValueKey('hero-Member'), onTap: () { final id = MemberFacts.heroFirstId; _go(context, id == null ? const MemberScreen() : MemberScreen(initialPanelId: id, initialMetric: MemberFacts.heroKey)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [MemberFacts.heroLabel, MemberFacts.hero]))), // Member · ה-StatHero של הזהב (המטרה המוצהרת) · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) ForgeAnimatedEmpty(fields: ['אין מודול שתואם לחיפוש', 'נסה מילה אחרת']) else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) GestureDetector(key: const ValueKey('nav-Volunteer'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const VolunteerScreen()), child: ForgeGridHubCard(fields: ['מתנדבים', '${VolunteerFacts.count} ${VolunteerFacts.label} · ניהול מתנדבים עם טלפון ואזור'])), // אריח-ניווט forge (G12c)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('nav-Donation'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const DonationScreen()), child: ForgeGridHubCard(fields: ['תרומות', '${DonationFacts.count} ${DonationFacts.label} · רשימת תרומות לפי תאריך וסכום'])), // אריח-ניווט forge (G12c)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('nav-Room'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const RoomScreen()), child: ForgeGridHubCard(fields: ['חדרים', '${RoomFacts.count} ${RoomFacts.label} · מעקב חדרים ושעות'])), // אריח-ניווט forge (G12c)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('nav-Family'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const FamilyScreen()), child: ForgeGridHubCard(fields: ['משפחה', '${FamilyFacts.count} ${FamilyFacts.label} · מסך משפחות עם כתובת'])), // אריח-ניווט forge (G12c)
        if (vis.contains(4)) GestureDetector(key: const ValueKey('nav-ShopItem'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const ShopItemScreen()), child: ForgeGridHubCard(fields: ['פריט', '${ShopItemFacts.count} ${ShopItemFacts.label} · פריטי קטלוג במלאי'])), // אריח-ניווט forge (G12c)
        if (vis.contains(5)) GestureDetector(key: const ValueKey('nav-Member'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const MemberScreen()), child: ForgeGridHubCard(fields: ['בני משפחה', '${MemberFacts.count} ${MemberFacts.label} · תלמידים לפי גיל'])), // אריח-ניווט forge (G12c)
      ]),
    ]);
  }
}
