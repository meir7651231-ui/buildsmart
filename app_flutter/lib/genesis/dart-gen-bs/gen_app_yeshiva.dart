// 🏗️ YeshivaApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 4 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "בני משפחה לפי גיל" ⇒ Member ⇐ schoolos_students.dart (strong · שמות 16/17)
//   "רשימת תרומות לפי תאריך וסכום" ⇒ Donation ⇐ schoolos_fees.dart (strong · שמות 5/7)
//   "מעקב חדרים ושעות" ⇒ Room ⇐ schoolos_rooms.dart (strong · שמות 11/12)
//   "מורים ומדריכות" ⇒ Teacher ⇐ schoolos_students.dart (strong · שמות 8/19)
//   G10b-ב · תפר-הזרקה (db) ⇒ בדיקה שמזריקה שדה-סכמה שמור על רשומת-המסך ורואה את העמודה מאירה: Member:1 עמודות · Donation:∅ · Room:∅ · Teacher:0 עמודות
//   G12c · תפקידי-עור: kpi=ForgeStatPlain · hero=ForgeStatPlain · stat=ForgeStatPlain · navTile=ForgeGridHubCard · empty=ForgeAnimatedEmpty · button=ForgeToneButton · statusChip=ForgeStatusChip · banner=ForgeToneBanner · emptyState=ForgeAnimatedEmpty · mediaRow=ForgeContactTile · section=ForgeTitledSection · frame=ForgeStripPanelFrame · segmented=ForgeSegPickerSelection · chip=ForgeFacetChip · meter=ForgeLinearProgressStatus · glass=ForgeStripPanelFrame · timeline=ForgeNotifRow · field=ForgeDsField · enumField=ForgeDsEnumField · numberField=ForgeDsNumberField · dateField=ForgeDsDateFieldInput · search=ForgeDsSearch · pageHeader=ForgeCenteredPageHeader · table=ForgeDataGrid · bars=ForgeWaveformBars · board=ForgeKanbanBoard · calendar=ForgeEventCalendar
//   G12b · עור: forge — אריח-KPI = ForgeStatPlain (card · 2 חריצים · תוכן-העיצוב ["Label","248"] ⇒ ערך בחריץ 1, תווית בחריץ 0, השאר '') — הצבה של הבעלים ב-app-golden, מאומתת מבנית
//   G10b · עם הקפיצה נשלח גם initialMetric=heroKey ⇒ הטבלה במודול מסוננת לשורות-המדד (באנר + ביטול): Member:∅ · Donation:∅ · Room:∅ · Teacher:∅
//   G10a · אריח-hero ⇒ טאפ פותח את המודול על הרשומה-הראשונה של המדד (<E>Facts.heroFirstId ⇒ <E>Screen(initialPanelId)) — תפר-כניסה חצוב מצורת initialPanel של זהב-המורים: Member:initialPanelId · Donation:initialPanelId · Room:initialPanelId · Teacher:∅
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: MemberFacts.count · DonationFacts.count · RoomFacts.count · TeacherFacts.count
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
import 'gen_retarget_member_from_stu_p515873_ske93605.dart' show MemberScreen, MemberFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_donation_from_fee_p27d7fd_ske93605.dart' show DonationScreen, DonationFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_room_from_rm_pb3f005_ske93605.dart' show RoomScreen, RoomFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_teacher_from_stu_p09f962_ske93605.dart' show TeacherScreen, TeacherFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

class YeshivaApp extends StatelessWidget {
  const YeshivaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Yeshiva', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true, fontFamily: DsTokens.fontBody), home: const YeshivaHubScreen()); // גופן-הגוף של ה-DS (מצורף לחבילה) — לא Roboto-מ-CDN: האתר-המחולל עצמאי גם בלי רשת (L69)
}

class YeshivaHubScreen extends StatefulWidget {
  const YeshivaHubScreen({super.key});
  @override
  State<YeshivaHubScreen> createState() => _YeshivaHubScreenState();
}

class _YeshivaHubScreenState extends State<YeshivaHubScreen> {
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = <String>['בני משפחה', 'תרומות', 'חדרים', 'מורה']; // 4 מסכים מחווטים
  String _q = ''; // חיפוש-רכזת נגזר (G9c): DsSearch ⊕ smartFilter ⊕ smartScore ⊕ normSearch — צורת-האיתור של הזהב (23-ג), לא .contains שטוח
  static String _norm(dynamic q) => normSearch(q, NORM_SEARCH_T);
  static Iterable _expand(dynamic q, dynamic norm) => [norm(q)];
  static num _score(dynamic exp, dynamic term) => _norm(term).contains('$exp') ? 100 : 0;
  static num _scoreOf(dynamic q, dynamic terms) => smartScore(q, terms, _norm, _expand, _score) as num;
  static bool _hasQuery(dynamic q) => (q as String).trim().isNotEmpty;
  // שורות-החיפוש = נגזרת של תפר-העובדות: כותרת · מונח-הישות · המשפט · תוויות-המדדים — אפס דאטה-חדש
  static final rows = <Map<String, dynamic>>[
    {'i': 0, 'title': 'בני משפחה', 'label': MemberFacts.label, 'text': 'בני משפחה לפי גיל', 'terms': [for (final d in MemberFacts.metricDefs) '${d['label']}']},
    {'i': 1, 'title': 'תרומות', 'label': DonationFacts.label, 'text': 'רשימת תרומות לפי תאריך וסכום', 'terms': [for (final d in DonationFacts.metricDefs) '${d['label']}']},
    {'i': 2, 'title': 'חדרים', 'label': RoomFacts.label, 'text': 'מעקב חדרים ושעות', 'terms': [for (final d in RoomFacts.metricDefs) '${d['label']}']},
    {'i': 3, 'title': 'מורה', 'label': TeacherFacts.label, 'text': 'מורים ומדריכות', 'terms': [for (final d in TeacherFacts.metricDefs) '${d['label']}']},
  ];
  static List<String> termsOf(Map<String, dynamic> r) => ['${r['title']}', '${r['label']}', '${r['text']}', ...(r['terms'] as List).cast<String>()];
  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) {
    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();
    return DsScaffold(title: 'Yeshiva', subtitle: '4 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
        SizedBox(width: 168, child: ForgeStatPlain(fields: ['מסכים מחוברים', '${vis.length}/${modules.length}'])),
        if (vis.contains(0)) GestureDetector(key: const ValueKey('hero-Member'), onTap: () { final id = MemberFacts.heroFirstId; _go(context, id == null ? const MemberScreen() : MemberScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [MemberFacts.heroLabel, MemberFacts.hero]))), // Member · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('hero-Donation'), onTap: () { final id = DonationFacts.heroFirstId; _go(context, id == null ? const DonationScreen() : DonationScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [DonationFacts.heroLabel, DonationFacts.hero]))), // Donation · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('hero-Room'), onTap: () { final id = RoomFacts.heroFirstId; _go(context, id == null ? const RoomScreen() : RoomScreen(initialPanelId: id)); }, child: SizedBox(width: 168, child: ForgeStatPlain(fields: [RoomFacts.heroLabel, RoomFacts.hero]))), // Room · אין מדדים ⇒ count · טאפ ⇒ המודול פתוח על רשומת-ה-hero הראשונה (G10a)
        if (vis.contains(3)) SizedBox(key: const ValueKey('hero-Teacher'), width: 168, child: ForgeStatPlain(fields: [TeacherFacts.heroLabel, TeacherFacts.hero])), // Teacher · אין מדדים ⇒ count · אין תפר-כניסה (אין זרע/פאנל)
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) ForgeAnimatedEmpty(fields: ['אין מודול שתואם לחיפוש', 'נסה מילה אחרת']) else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) GestureDetector(key: const ValueKey('nav-Member'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const MemberScreen()), child: ForgeGridHubCard(fields: ['בני משפחה', '${MemberFacts.count} ${MemberFacts.label} · בני משפחה לפי גיל'])), // אריח-ניווט forge (G12c)
        if (vis.contains(1)) GestureDetector(key: const ValueKey('nav-Donation'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const DonationScreen()), child: ForgeGridHubCard(fields: ['תרומות', '${DonationFacts.count} ${DonationFacts.label} · רשימת תרומות לפי תאריך וסכום'])), // אריח-ניווט forge (G12c)
        if (vis.contains(2)) GestureDetector(key: const ValueKey('nav-Room'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const RoomScreen()), child: ForgeGridHubCard(fields: ['חדרים', '${RoomFacts.count} ${RoomFacts.label} · מעקב חדרים ושעות'])), // אריח-ניווט forge (G12c)
        if (vis.contains(3)) GestureDetector(key: const ValueKey('nav-Teacher'), behavior: HitTestBehavior.opaque, onTap: () => _go(context, const TeacherScreen()), child: ForgeGridHubCard(fields: ['מורה', '${TeacherFacts.count} ${TeacherFacts.label} · מורים ומדריכות'])), // אריח-ניווט forge (G12c)
      ]),
    ]);
  }
}
