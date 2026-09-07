// 🏗️ SechirutApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 3 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "תיק לבדיקה עם מועד חתימה" ⇒ AyinCase ⇐ schoolos_fees.dart (weak · שמות 1/15)
//   "לקוח עם טלפון ועיר" ⇒ Family ⇐ schoolos_students.dart (strong · שמות 19/25)
//   "רשימת תרומות לפי תאריך וסכום" ⇒ Donation ⇐ schoolos_fees.dart (strong · שמות 5/7)
//   ⚪ "תלמידים לפי סיכון" ⇒ ישות חוזרת (AyinCase)
//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: AyinCase:∅ · Family:5 עמודות · Donation:∅
//   G12c · תפקידי-עור: kpi=ForgeStatPlain · hero=ForgeStatPlain · stat=ForgeStatPlain · navTile=ForgeGridHubCard · empty=ForgeAnimatedEmpty · button=ForgeToneButton · statusChip=ForgeStatusChip · banner=ForgeToneBanner · emptyState=ForgeAnimatedEmpty · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegPickerSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeStripPanelFrame · timeline=ForgeNotifRow · field=ForgeDsField · enumField=ForgeDsEnumField · numberField=ForgeDsNumberField · dateField=ForgeDsDateFieldInput · search=ForgeDsSearch · pageHeader=ForgeCenteredPageHeader · table=ForgeDataGrid · bars=ForgeBarChart · board=ForgeKanbanBoard · calendar=ForgeEventCalendar
//   G12b · עור: forge — אריח-KPI = ForgeStatPlain (card · 2 חריצים · תוכן-העיצוב ["Label","248"] ⇒ ערך בחריץ 1, תווית בחריץ 0, השאר '') — הצבה של הבעלים ב-app-golden, מאומתת מבנית
//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): AyinCase:∅ · Family:∅ · Donation:∅
//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: AyinCase:initialPanelId · Family:initialPanelId · Donation:initialPanelId
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: AyinCaseFacts.count · FamilyFacts.count · DonationFacts.count
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
import 'gen_retarget_ayincase_from_fee_pc912dd_skeda887.dart' show AyinCaseScreen, AyinCaseFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_family_from_stu_pd71638_skeda887.dart' show FamilyScreen, FamilyFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_donation_from_fee_pc912dd_skeda887.dart' show DonationScreen, DonationFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

class SechirutApp extends StatelessWidget {
  const SechirutApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Sechirut', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: DsTokens.fontBody), home: const SechirutHubScreen()); // גופן-הגוף של ה-DS (מצורף לחבילה) — לא Roboto-מ-CDN: האתר-המחולל עצמאי גם בלי רשת (L69)
}

class SechirutHubScreen extends StatefulWidget {
  const SechirutHubScreen({super.key});
  @override
  State<SechirutHubScreen> createState() => _SechirutHubScreenState();
}

class _SechirutHubScreenState extends State<SechirutHubScreen> {
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = <String>['תיק', 'משפחה', 'תרומות']; // 3 מסכים מחווטים
  String _q = ''; // חיפוש-רכזת נגזר (G9c): DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — צורת-האיתור של הזהב (23-ג), לא .contains שטוח
  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  // שורות-החיפוש = נגזרת של תפר-העובדות: כותרת · מונח-הישות · המשפט · תוויות-המדדים — אפס דאטה-חדש
  static final rows = <Map<String, dynamic>>[
    {'i': 0, 'title': 'תיק', 'label': AyinCaseFacts.label, 'text': 'תיק לבדיקה עם מועד חתימה', 'terms': [for (final d in AyinCaseFacts.metricDefs) '${d['label']}']},
    {'i': 1, 'title': 'משפחה', 'label': FamilyFacts.label, 'text': 'לקוח עם טלפון ועיר', 'terms': [for (final d in FamilyFacts.metricDefs) '${d['label']}']},
    {'i': 2, 'title': 'תרומות', 'label': DonationFacts.label, 'text': 'רשימת תרומות לפי תאריך וסכום', 'terms': [for (final d in DonationFacts.metricDefs) '${d['label']}']},
  ];
  static List<String> termsOf(Map<String, dynamic> r) => ['${r['title']}', '${r['label']}', '${r['text']}', ...(r['terms'] as List).cast<String>()];
  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) {
    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();
    return DsScaffold(title: 'Sechirut', subtitle: '3 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
        SizedBox(width: 168, child: ForgeStatPlain(fields: ['מסכים מחוברים', '${vis.length}/${modules.length}'])),
        if (vis.contains(0)) GestureDetector(key: const ValueKey('hero-AyinCase'), onTap: () { final id = AyinCaseFacts.heroFirstId; _go(context, id == null ? const AyinCaseScreen() : AyinCaseScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [AyinCaseFacts.heroLabel, AyinCaseFacts.hero]))), // AyinCase · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('hero-Family'), onTap: () { final id = FamilyFacts.heroFirstId; _go(context, id == null ? const FamilyScreen() : FamilyScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [FamilyFacts.heroLabel, FamilyFacts.hero]))), // Family · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('hero-Donation'), onTap: () { final id = DonationFacts.heroFirstId; _go(context, id == null ? const DonationScreen() : DonationScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [DonationFacts.heroLabel, DonationFacts.hero]))), // Donation · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) ForgeAnimatedEmpty(fields: ['אין מודול שתואם לחיפוש', 'נסה מילה אחרת']) else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) GestureDetector(key: const ValueKey('nav-AyinCase'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const AyinCaseScreen()), child: ForgeGridHubCard(fields: ['תיק', '${AyinCaseFacts.count} ${AyinCaseFacts.label} · תיק לבדיקה עם מועד חתימה'])), // אריח-ניווט forge (G12c)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('nav-Family'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const FamilyScreen()), child: ForgeGridHubCard(fields: ['משפחה', '${FamilyFacts.count} ${FamilyFacts.label} · לקוח עם טלפון ועיר'])), // אריח-ניווט forge (G12c)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('nav-Donation'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const DonationScreen()), child: ForgeGridHubCard(fields: ['תרומות', '${DonationFacts.count} ${DonationFacts.label} · רשימת תרומות לפי תאריך וסכום'])), // אריח-ניווט forge (G12c)
      ]),
    ]);
  }
}
