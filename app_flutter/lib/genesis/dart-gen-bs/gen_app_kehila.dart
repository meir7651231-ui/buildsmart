// 🏗️ KehilaApp — אפליקציה ממשפטים (GENMAX·G9 · §22): 5 מודולים · מחולל דטרמיניסטי: app-from-sentences.mjs (sentence⇒entity⇒pickModule⇒retarget) — כל מודול חצוב מהזהב, לא נכתב
//   "ניהול מתנדבים עם טלפון ואזור" ⇒ Volunteer ⇐ schoolos_fees.dart (strong · שמות 5/8)
//   "רשימת תרומות לפי תאריך וסכום" ⇒ Donation ⇐ schoolos_fees.dart (strong · שמות 5/7)
//   "מעקב חדרים ושעות" ⇒ Room ⇐ schoolos_rooms.dart (strong · שמות 11/12)
//   "מסך משפחות עם כתובת" ⇒ Family ⇐ schoolos_students.dart (strong · שמות 19/25)
//   "פריטי קטלוג במלאי" ⇒ ShopItem ⇐ schoolos_courses.dart (strong · שמות 4/13)
//   ⚪ "רשימת ספקים עם מחירים" ⇒ אין מונח-ישות במשפט — מקום-שמור (אין המצאה)
//   G9b · KPI-רכזת נגזר: כל אריח = <E>Facts של המודול (count חי של הזרע · hero = המדד שהזהב הכריז/צבע-סכנה) — אפס ערך מומצא: VolunteerFacts.count · DonationFacts.count · RoomFacts.unavailableN · FamilyFacts.highN · ShopItemFacts.kpiNoTeacher
import 'package:flutter/material.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/premium/dataviz/kpi_tile.dart';
import '../dart-ui-bs/ds/ds_search.dart'; // איתור: חיפוש-מבוקר (value+onChanged)
import '../dart-ui-bs/premium/feedback/empty_state.dart'; // אין-תוצאות
import '../dart-maor/smart-filter.dart'; // איתור: סינון+מיון-לפי-ציון (מדף)
import '../dart-maor/smart-score.dart'; // איתור: ניקוד רב-מילתי AND (מדף)
import '../dart-maor/norm-search.dart'; // איתור: נרמול-חיפוש עברי (מדף)
import '../dart-data-maor/norm-search-strings.dart'; // NORM_SEARCH_T (אטום-דאטה)
import 'gen_retarget_volunteer_from_fee.dart' show VolunteerScreen, VolunteerFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_donation_from_fee.dart' show DonationScreen, DonationFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_room_from_rm.dart' show RoomScreen, RoomFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_family_from_stu.dart' show FamilyScreen, FamilyFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות
import 'gen_retarget_shopitem_from_crs.dart' show ShopItemScreen, ShopItemFacts; // רק התפר הציבורי (מסך+עובדות) — מחלקות-ציבוריות אחרות של הזהב (DashInput) לא מתנגשות

class KehilaApp extends StatelessWidget {
  const KehilaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(title: 'Kehila', debugShowCheckedModeBanner: false, theme: ThemeData(brightness: Brightness.dark, useMaterial3: true), home: const KehilaHubScreen());
}

class KehilaHubScreen extends StatefulWidget {
  const KehilaHubScreen({super.key});
  @override
  State<KehilaHubScreen> createState() => _KehilaHubScreenState();
}

class _KehilaHubScreenState extends State<KehilaHubScreen> {
  static void _go(BuildContext c, Widget screen) => Navigator.push(c, MaterialPageRoute(builder: (_) => screen));
  static const modules = <String>['מתנדבים', 'תרומות', 'חדרים', 'משפחה', 'פריט']; // 5 מסכים מחווטים
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
  ];
  static List<String> termsOf(Map<String, dynamic> r) => ['${r['title']}', '${r['label']}', '${r['text']}', ...(r['terms'] as List).cast<String>()];
  static List<Map<String, dynamic>> searchModules(List<Map<String, dynamic>> rs, String q) => (smartFilter(q, rs, (it) => termsOf(it as Map<String, dynamic>), _hasQuery, _scoreOf) as List).cast<Map<String, dynamic>>();
  @override
  Widget build(BuildContext context) {
    final vis = searchModules(rows, _q).map((r) => r['i'] as int).toSet();
    return DsScaffold(title: 'Kehila', subtitle: '5 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
      DsSearch(value: _q, onChanged: (v) => setState(() => _q = v)),
      const SizedBox(height: 8),
      Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
        SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: '${vis.length}/${modules.length}', label: 'מסכים מחוברים')),
        if (vis.contains(0)) SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: VolunteerFacts.hero, label: VolunteerFacts.heroLabel)), // Volunteer · אין מדדים ⇒ count
        if (vis.contains(1)) SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: DonationFacts.hero, label: DonationFacts.heroLabel)), // Donation · אין מדדים ⇒ count
        if (vis.contains(2)) SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: RoomFacts.hero, label: RoomFacts.heroLabel)), // Room · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
        if (vis.contains(3)) SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: FamilyFacts.hero, label: FamilyFacts.heroLabel)), // Family · ה-StatHero של הזהב (המטרה המוצהרת)
        if (vis.contains(4)) SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: ShopItemFacts.hero, label: ShopItemFacts.heroLabel)), // ShopItem · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
      ]),
      const SizedBox(height: 8),
      if (vis.isEmpty) const EmptyState(glyph: '🔍', message: 'אין מודול שתואם לחיפוש') else DsSection(title: 'כלים · ${vis.length}', children: [
        if (vis.contains(0)) DsNavTile(glyph: '🧬', title: 'מתנדבים', sub: '${VolunteerFacts.count} ${VolunteerFacts.label} · ניהול מתנדבים עם טלפון ואזור', onTap: () => _go(context, const VolunteerScreen())),
        if (vis.contains(1)) DsNavTile(glyph: '🧬', title: 'תרומות', sub: '${DonationFacts.count} ${DonationFacts.label} · רשימת תרומות לפי תאריך וסכום', onTap: () => _go(context, const DonationScreen())),
        if (vis.contains(2)) DsNavTile(glyph: '🧬', title: 'חדרים', sub: '${RoomFacts.count} ${RoomFacts.label} · מעקב חדרים ושעות', onTap: () => _go(context, const RoomScreen())),
        if (vis.contains(3)) DsNavTile(glyph: '🧬', title: 'משפחה', sub: '${FamilyFacts.count} ${FamilyFacts.label} · מסך משפחות עם כתובת', onTap: () => _go(context, const FamilyScreen())),
        if (vis.contains(4)) DsNavTile(glyph: '🧬', title: 'פריט', sub: '${ShopItemFacts.count} ${ShopItemFacts.label} · פריטי קטלוג במלאי', onTap: () => _go(context, const ShopItemScreen())),
      ]),
    ]);
  }
}
