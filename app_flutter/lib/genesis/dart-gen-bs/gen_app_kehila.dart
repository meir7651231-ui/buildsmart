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
import 'gen_retarget_volunteer_from_fee.dart';
import 'gen_retarget_donation_from_fee.dart';
import 'gen_retarget_room_from_rm.dart';
import 'gen_retarget_family_from_stu.dart';
import 'gen_retarget_shopitem_from_crs.dart';

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
  @override
  Widget build(BuildContext context) => DsScaffold(title: 'Kehila', subtitle: '5 מודולים ממשפטים · כל אחד חצוב מהזהב', icon: '🧬', children: [
    Wrap(spacing: 12, runSpacing: 12, children: [ // KPI-רכזת (G9b): עובדות-אמת בלבד — כמו _Home של הזהב (מסכים-מחוברים + הדחוף של כל מודול)
      SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: '${modules.length}', label: 'מסכים מחוברים')),
      SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: VolunteerFacts.hero, label: VolunteerFacts.heroLabel)), // Volunteer · אין מדדים ⇒ count
      SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: DonationFacts.hero, label: DonationFacts.heroLabel)), // Donation · אין מדדים ⇒ count
      SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: RoomFacts.hero, label: RoomFacts.heroLabel)), // Room · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
      SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: FamilyFacts.hero, label: FamilyFacts.heroLabel)), // Family · ה-StatHero של הזהב (המטרה המוצהרת)
      SizedBox(width: 168, child: KpiTile(glyph: '🧬', value: ShopItemFacts.hero, label: ShopItemFacts.heroLabel)), // ShopItem · המדד הראשון שהזהב צובע-סכנה כשאינו-אפס
    ]),
    const SizedBox(height: 8),
    DsSection(title: 'כלים', children: [
      DsNavTile(glyph: '🧬', title: 'מתנדבים', sub: '${VolunteerFacts.count} ${VolunteerFacts.label} · ניהול מתנדבים עם טלפון ואזור', onTap: () => _go(context, const VolunteerScreen())),
      DsNavTile(glyph: '🧬', title: 'תרומות', sub: '${DonationFacts.count} ${DonationFacts.label} · רשימת תרומות לפי תאריך וסכום', onTap: () => _go(context, const DonationScreen())),
      DsNavTile(glyph: '🧬', title: 'חדרים', sub: '${RoomFacts.count} ${RoomFacts.label} · מעקב חדרים ושעות', onTap: () => _go(context, const RoomScreen())),
      DsNavTile(glyph: '🧬', title: 'משפחה', sub: '${FamilyFacts.count} ${FamilyFacts.label} · מסך משפחות עם כתובת', onTap: () => _go(context, const FamilyScreen())),
      DsNavTile(glyph: '🧬', title: 'פריט', sub: '${ShopItemFacts.count} ${ShopItemFacts.label} · פריטי קטלוג במלאי', onTap: () => _go(context, const ShopItemScreen())),
    ]),
  ]);
}
