// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «היום» של בלגן: מיזוג ספקי-ה-Today של 30 מודולים — באיחור ראשון · היום · הרשומות הפתוחות (3 למעלה, השאר מקופל) · ממתין-לאישורך · עשיתי-לבד · מחר. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_home_content.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_mail.dart';
import 'gen_balagan_confirm.dart';
import 'gen_balagan_moments.dart';
import 'gen_balagan_topics.dart';
import 'gen_app_calendar_home.dart';
import 'gen_app_tasks_home.dart';
import 'gen_app_peruk01_home.dart';
import 'gen_app_peruk02_home.dart';
import 'gen_app_peruk03_home.dart';
import 'gen_app_peruk04_home.dart';
import 'gen_app_peruk05_home.dart';
import 'gen_app_peruk06_home.dart';
import 'gen_app_peruk07_home.dart';
import 'gen_app_peruk08_home.dart';
import 'gen_app_peruk09_home.dart';
import 'gen_app_peruk10_home.dart';
import 'gen_app_peruk11_home.dart';
import 'gen_app_peruk12_home.dart';
import 'gen_app_peruk13_home.dart';
import 'gen_app_peruk14_home.dart';
import 'gen_app_peruk15_home.dart';
import 'gen_app_peruk16_home.dart';
import 'gen_app_peruk17_home.dart';
import 'gen_app_peruk18_home.dart';
import 'gen_app_peruk19_home.dart';
import 'gen_app_peruk20_home.dart';
import 'gen_app_peruk21_home.dart';
import 'gen_app_peruk22_home.dart';
import 'gen_app_peruk23_home.dart';
import 'gen_app_peruk24_home.dart';
import 'gen_app_peruk25_home.dart';
import 'gen_app_peruk26_home.dart';
import 'gen_app_peruk27_home.dart';
import 'gen_app_peruk28_home.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import '../dart-ui-bs/ds/ds_voice.dart';
import 'package:url_launcher/url_launcher.dart';

typedef _Items = List<DsTodayItem> Function(DateTime today, {required int dayDelta});
typedef _Props = List<Widget> Function(BuildContext context, DateTime today);
typedef _Card = Widget Function(BuildContext context, Map<String, String> r);
typedef _Props2 = List<Widget> Function(BuildContext context, DateTime today, {bool chain, bool rem});
typedef _Undated = List<DsTodayItem> Function(DateTime today);
class _Mod { const _Mod(this.name, this.open, this.items, this.proposals, this.card, this.autopilot, this.done, this.undated, this.stale, this.remPending, this.index); final String name; final List<Map<String, String>> Function() open; final _Items items; final _Props2 proposals; final _Card card; final void Function() autopilot; final List<Map<String, String>> Function() done; final _Undated undated; final _Undated stale; final _Undated remPending; final int index; }

/// ב׳-מא · תאריך כמו שאומרים אותו (היום · מחר · אתמול · יום שלישי 8.9 · 15.9 · 3.10.2027) — ל«היום», לשיתוף ולכרטיס-האדם
String balaganDayLabel(DateTime d, DateTime today) { DateTime day(DateTime x) => DateTime(x.year, x.month, x.day); final n = day(d).difference(day(today)).inDays; if (n == 0) return gen_balagan_home_c0; if (n == 1) return gen_balagan_home_c1; if (n == -1) return gen_balagan_home_c2; final dm = '${d.day}.${d.month}' + (d.year == today.year ? '' : '.${d.year}'); return n.abs() <= 6 ? gen_balagan_home_c3.replaceAll('{day}', gen_balagan_home_c4.split(',')[d.weekday % 7]) + ' ' + dm : dm; }
/// ב׳-מב · «3 ימים לפני · יום לפני · ביום» — תיאור-ההיסטים כמו שאומרים (ל«בלגן» ולכרטיס-המרוכז)
String balaganOffsetsLabel(String offsets) => offsets.split(',').map((x) => int.tryParse(x.trim()) ?? 0).map((o) => o == 0 ? gen_balagan_home_c5 : o == 1 ? gen_balagan_home_c6 : gen_balagan_home_c7.replaceAll('{n}', o.toString())).join(' · ');
/// ב׳-מח · מתי זה קרה, כמו שאומרים: עכשיו · לפני 5 דק׳ · לפני שעה · לפני 3 שעות · אתמול · יום שני 7.9
String balaganAgo(DateTime at, DateTime now) { final m = now.difference(at).inMinutes; if (m < 1) return gen_balagan_home_c8; if (m < 60) return gen_balagan_home_c9.replaceAll('{n}', m.toString()); final h = now.difference(at).inHours; if (h < 2) return gen_balagan_home_c10; if (at.year == now.year && at.month == now.month && at.day == now.day) return gen_balagan_home_c11.replaceAll('{n}', h.toString()); return balaganDayLabel(at, now); }
/// «שתף את היום»: טקסט קריא של באיחור/היום (עם שעות) — נגזרת של אותן שורות; ללוח + wa.me (הנמען נבחר בוואטסאפ)
String balaganDayText(List<DsTodayItem> overdue, List<DsTodayItem> todayItems, DateTime today, {double money = 0, List<DsTodayItem> tomorrow = const []}) {
  final b = StringBuffer(gen_balagan_home_c12 + ' · ' + gen_balagan_home_c13.split(',')[today.weekday % 7] + ' ' + today.day.toString() + '.' + today.month.toString() + '\n');   // ב׳-מא · תאריך כמו שאומרים
  if (overdue.isNotEmpty) { b.write(gen_balagan_home_c14 + ':\n'); for (final it in overdue) { b.write('• ' + it.title + ' (' + it.module + ')\n'); } }
  if (todayItems.isNotEmpty) { b.write(gen_balagan_home_c15 + ':\n'); for (final it in todayItems) { b.write('• ' + (it.time.isNotEmpty ? it.time + ' ' : '') + it.title + ' (' + it.module + ')\n'); } }
  if (money > 0) b.write(gen_balagan_home_c16.replaceAll('{n}', balaganFmtMoney(money)) + '\n');   // ב׳-כט · כסף-במבט גם בשיתוף
  if (tomorrow.isNotEmpty) { b.write(gen_balagan_home_c17 + ':\n'); for (final it in tomorrow) { b.write('• ' + (it.time.isNotEmpty ? it.time + ' ' : '') + it.title + ' (' + it.module + ')\n'); } }   // ב׳-מא · בערב משתפים גם את מחר
  return b.toString().trim();
}

/// ב׳-כט · כסף-במבט: סכום שדה-הסכום הראשי (הראשון שאינו אחוז) של התיקים שבשורות — כל תיק פעם אחת. נגזרת של הרשומות, אפס-שדה-חדש, אפס-ניחוש: אין סכום ⇒ 0
double balaganMoney(List<DsTodayItem> items) {
  var total = 0.0; final seen = <String>{};
  for (final it in items) {
    final key = it.module + '|' + it.rid; if (it.rid.isEmpty || !seen.add(key)) continue;
    final ms = kBalaganModules.where((m) => m.title == it.module); if (ms.isEmpty) continue; final m = ms.first;
    final fs = m.numFields.where((f) => !m.percentFields.contains(f)); if (fs.isEmpty) continue;
    final r = appStore.byId(m.rootSlug, it.rid); if (r == null) continue;
    final v = double.tryParse((r[fs.first] ?? '').replaceAll(',', '').trim()); if (v != null) total += v;
  }
  return total;
}
String balaganFmtMoney(double v) => v.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
/// ב׳-לו · גיבוי: הכל במכשיר בלבד (חוק-6) ⇒ גיל-הגיבוי בימים (−1 = מעולם) ומתי מזכירים (≥10 תיקים · מעולם או ≥30 יום). היום מוזרק
int balaganBackupAge(String backupAt, DateTime today) { final d = DateTime.tryParse(backupAt); return d == null ? -1 : DateTime(today.year, today.month, today.day).difference(DateTime(d.year, d.month, d.day)).inDays; }
bool balaganBackupDue(int records, int age) => records >= 10 && (age < 0 || age >= 30);

class GenBalaganHomeScreen extends StatefulWidget {
  const GenBalaganHomeScreen({super.key});
  @override
  State<GenBalaganHomeScreen> createState() => _GenBalaganHomeScreenState();
}

class _GenBalaganHomeScreenState extends State<GenBalaganHomeScreen> {
  static const _mods = <_Mod>[
    _Mod(GenAppCalendarHomeScreenToday.module, GenAppCalendarHomeScreenToday.open, GenAppCalendarHomeScreenToday.items, GenAppCalendarHomeScreenToday.proposals, GenAppCalendarHomeScreenToday.card, GenAppCalendarHomeScreenToday.autopilot, GenAppCalendarHomeScreenToday.done, GenAppCalendarHomeScreenToday.undated, GenAppCalendarHomeScreenToday.stale, GenAppCalendarHomeScreenToday.remPending, 0),
    _Mod(GenAppTasksHomeScreenToday.module, GenAppTasksHomeScreenToday.open, GenAppTasksHomeScreenToday.items, GenAppTasksHomeScreenToday.proposals, GenAppTasksHomeScreenToday.card, GenAppTasksHomeScreenToday.autopilot, GenAppTasksHomeScreenToday.done, GenAppTasksHomeScreenToday.undated, GenAppTasksHomeScreenToday.stale, GenAppTasksHomeScreenToday.remPending, 1),
    _Mod(GenAppPeruk01HomeScreenToday.module, GenAppPeruk01HomeScreenToday.open, GenAppPeruk01HomeScreenToday.items, GenAppPeruk01HomeScreenToday.proposals, GenAppPeruk01HomeScreenToday.card, GenAppPeruk01HomeScreenToday.autopilot, GenAppPeruk01HomeScreenToday.done, GenAppPeruk01HomeScreenToday.undated, GenAppPeruk01HomeScreenToday.stale, GenAppPeruk01HomeScreenToday.remPending, 2),
    _Mod(GenAppPeruk02HomeScreenToday.module, GenAppPeruk02HomeScreenToday.open, GenAppPeruk02HomeScreenToday.items, GenAppPeruk02HomeScreenToday.proposals, GenAppPeruk02HomeScreenToday.card, GenAppPeruk02HomeScreenToday.autopilot, GenAppPeruk02HomeScreenToday.done, GenAppPeruk02HomeScreenToday.undated, GenAppPeruk02HomeScreenToday.stale, GenAppPeruk02HomeScreenToday.remPending, 3),
    _Mod(GenAppPeruk03HomeScreenToday.module, GenAppPeruk03HomeScreenToday.open, GenAppPeruk03HomeScreenToday.items, GenAppPeruk03HomeScreenToday.proposals, GenAppPeruk03HomeScreenToday.card, GenAppPeruk03HomeScreenToday.autopilot, GenAppPeruk03HomeScreenToday.done, GenAppPeruk03HomeScreenToday.undated, GenAppPeruk03HomeScreenToday.stale, GenAppPeruk03HomeScreenToday.remPending, 4),
    _Mod(GenAppPeruk04HomeScreenToday.module, GenAppPeruk04HomeScreenToday.open, GenAppPeruk04HomeScreenToday.items, GenAppPeruk04HomeScreenToday.proposals, GenAppPeruk04HomeScreenToday.card, GenAppPeruk04HomeScreenToday.autopilot, GenAppPeruk04HomeScreenToday.done, GenAppPeruk04HomeScreenToday.undated, GenAppPeruk04HomeScreenToday.stale, GenAppPeruk04HomeScreenToday.remPending, 5),
    _Mod(GenAppPeruk05HomeScreenToday.module, GenAppPeruk05HomeScreenToday.open, GenAppPeruk05HomeScreenToday.items, GenAppPeruk05HomeScreenToday.proposals, GenAppPeruk05HomeScreenToday.card, GenAppPeruk05HomeScreenToday.autopilot, GenAppPeruk05HomeScreenToday.done, GenAppPeruk05HomeScreenToday.undated, GenAppPeruk05HomeScreenToday.stale, GenAppPeruk05HomeScreenToday.remPending, 6),
    _Mod(GenAppPeruk06HomeScreenToday.module, GenAppPeruk06HomeScreenToday.open, GenAppPeruk06HomeScreenToday.items, GenAppPeruk06HomeScreenToday.proposals, GenAppPeruk06HomeScreenToday.card, GenAppPeruk06HomeScreenToday.autopilot, GenAppPeruk06HomeScreenToday.done, GenAppPeruk06HomeScreenToday.undated, GenAppPeruk06HomeScreenToday.stale, GenAppPeruk06HomeScreenToday.remPending, 7),
    _Mod(GenAppPeruk07HomeScreenToday.module, GenAppPeruk07HomeScreenToday.open, GenAppPeruk07HomeScreenToday.items, GenAppPeruk07HomeScreenToday.proposals, GenAppPeruk07HomeScreenToday.card, GenAppPeruk07HomeScreenToday.autopilot, GenAppPeruk07HomeScreenToday.done, GenAppPeruk07HomeScreenToday.undated, GenAppPeruk07HomeScreenToday.stale, GenAppPeruk07HomeScreenToday.remPending, 8),
    _Mod(GenAppPeruk08HomeScreenToday.module, GenAppPeruk08HomeScreenToday.open, GenAppPeruk08HomeScreenToday.items, GenAppPeruk08HomeScreenToday.proposals, GenAppPeruk08HomeScreenToday.card, GenAppPeruk08HomeScreenToday.autopilot, GenAppPeruk08HomeScreenToday.done, GenAppPeruk08HomeScreenToday.undated, GenAppPeruk08HomeScreenToday.stale, GenAppPeruk08HomeScreenToday.remPending, 9),
    _Mod(GenAppPeruk09HomeScreenToday.module, GenAppPeruk09HomeScreenToday.open, GenAppPeruk09HomeScreenToday.items, GenAppPeruk09HomeScreenToday.proposals, GenAppPeruk09HomeScreenToday.card, GenAppPeruk09HomeScreenToday.autopilot, GenAppPeruk09HomeScreenToday.done, GenAppPeruk09HomeScreenToday.undated, GenAppPeruk09HomeScreenToday.stale, GenAppPeruk09HomeScreenToday.remPending, 10),
    _Mod(GenAppPeruk10HomeScreenToday.module, GenAppPeruk10HomeScreenToday.open, GenAppPeruk10HomeScreenToday.items, GenAppPeruk10HomeScreenToday.proposals, GenAppPeruk10HomeScreenToday.card, GenAppPeruk10HomeScreenToday.autopilot, GenAppPeruk10HomeScreenToday.done, GenAppPeruk10HomeScreenToday.undated, GenAppPeruk10HomeScreenToday.stale, GenAppPeruk10HomeScreenToday.remPending, 11),
    _Mod(GenAppPeruk11HomeScreenToday.module, GenAppPeruk11HomeScreenToday.open, GenAppPeruk11HomeScreenToday.items, GenAppPeruk11HomeScreenToday.proposals, GenAppPeruk11HomeScreenToday.card, GenAppPeruk11HomeScreenToday.autopilot, GenAppPeruk11HomeScreenToday.done, GenAppPeruk11HomeScreenToday.undated, GenAppPeruk11HomeScreenToday.stale, GenAppPeruk11HomeScreenToday.remPending, 12),
    _Mod(GenAppPeruk12HomeScreenToday.module, GenAppPeruk12HomeScreenToday.open, GenAppPeruk12HomeScreenToday.items, GenAppPeruk12HomeScreenToday.proposals, GenAppPeruk12HomeScreenToday.card, GenAppPeruk12HomeScreenToday.autopilot, GenAppPeruk12HomeScreenToday.done, GenAppPeruk12HomeScreenToday.undated, GenAppPeruk12HomeScreenToday.stale, GenAppPeruk12HomeScreenToday.remPending, 13),
    _Mod(GenAppPeruk13HomeScreenToday.module, GenAppPeruk13HomeScreenToday.open, GenAppPeruk13HomeScreenToday.items, GenAppPeruk13HomeScreenToday.proposals, GenAppPeruk13HomeScreenToday.card, GenAppPeruk13HomeScreenToday.autopilot, GenAppPeruk13HomeScreenToday.done, GenAppPeruk13HomeScreenToday.undated, GenAppPeruk13HomeScreenToday.stale, GenAppPeruk13HomeScreenToday.remPending, 14),
    _Mod(GenAppPeruk14HomeScreenToday.module, GenAppPeruk14HomeScreenToday.open, GenAppPeruk14HomeScreenToday.items, GenAppPeruk14HomeScreenToday.proposals, GenAppPeruk14HomeScreenToday.card, GenAppPeruk14HomeScreenToday.autopilot, GenAppPeruk14HomeScreenToday.done, GenAppPeruk14HomeScreenToday.undated, GenAppPeruk14HomeScreenToday.stale, GenAppPeruk14HomeScreenToday.remPending, 15),
    _Mod(GenAppPeruk15HomeScreenToday.module, GenAppPeruk15HomeScreenToday.open, GenAppPeruk15HomeScreenToday.items, GenAppPeruk15HomeScreenToday.proposals, GenAppPeruk15HomeScreenToday.card, GenAppPeruk15HomeScreenToday.autopilot, GenAppPeruk15HomeScreenToday.done, GenAppPeruk15HomeScreenToday.undated, GenAppPeruk15HomeScreenToday.stale, GenAppPeruk15HomeScreenToday.remPending, 16),
    _Mod(GenAppPeruk16HomeScreenToday.module, GenAppPeruk16HomeScreenToday.open, GenAppPeruk16HomeScreenToday.items, GenAppPeruk16HomeScreenToday.proposals, GenAppPeruk16HomeScreenToday.card, GenAppPeruk16HomeScreenToday.autopilot, GenAppPeruk16HomeScreenToday.done, GenAppPeruk16HomeScreenToday.undated, GenAppPeruk16HomeScreenToday.stale, GenAppPeruk16HomeScreenToday.remPending, 17),
    _Mod(GenAppPeruk17HomeScreenToday.module, GenAppPeruk17HomeScreenToday.open, GenAppPeruk17HomeScreenToday.items, GenAppPeruk17HomeScreenToday.proposals, GenAppPeruk17HomeScreenToday.card, GenAppPeruk17HomeScreenToday.autopilot, GenAppPeruk17HomeScreenToday.done, GenAppPeruk17HomeScreenToday.undated, GenAppPeruk17HomeScreenToday.stale, GenAppPeruk17HomeScreenToday.remPending, 18),
    _Mod(GenAppPeruk18HomeScreenToday.module, GenAppPeruk18HomeScreenToday.open, GenAppPeruk18HomeScreenToday.items, GenAppPeruk18HomeScreenToday.proposals, GenAppPeruk18HomeScreenToday.card, GenAppPeruk18HomeScreenToday.autopilot, GenAppPeruk18HomeScreenToday.done, GenAppPeruk18HomeScreenToday.undated, GenAppPeruk18HomeScreenToday.stale, GenAppPeruk18HomeScreenToday.remPending, 19),
    _Mod(GenAppPeruk19HomeScreenToday.module, GenAppPeruk19HomeScreenToday.open, GenAppPeruk19HomeScreenToday.items, GenAppPeruk19HomeScreenToday.proposals, GenAppPeruk19HomeScreenToday.card, GenAppPeruk19HomeScreenToday.autopilot, GenAppPeruk19HomeScreenToday.done, GenAppPeruk19HomeScreenToday.undated, GenAppPeruk19HomeScreenToday.stale, GenAppPeruk19HomeScreenToday.remPending, 20),
    _Mod(GenAppPeruk20HomeScreenToday.module, GenAppPeruk20HomeScreenToday.open, GenAppPeruk20HomeScreenToday.items, GenAppPeruk20HomeScreenToday.proposals, GenAppPeruk20HomeScreenToday.card, GenAppPeruk20HomeScreenToday.autopilot, GenAppPeruk20HomeScreenToday.done, GenAppPeruk20HomeScreenToday.undated, GenAppPeruk20HomeScreenToday.stale, GenAppPeruk20HomeScreenToday.remPending, 21),
    _Mod(GenAppPeruk21HomeScreenToday.module, GenAppPeruk21HomeScreenToday.open, GenAppPeruk21HomeScreenToday.items, GenAppPeruk21HomeScreenToday.proposals, GenAppPeruk21HomeScreenToday.card, GenAppPeruk21HomeScreenToday.autopilot, GenAppPeruk21HomeScreenToday.done, GenAppPeruk21HomeScreenToday.undated, GenAppPeruk21HomeScreenToday.stale, GenAppPeruk21HomeScreenToday.remPending, 22),
    _Mod(GenAppPeruk22HomeScreenToday.module, GenAppPeruk22HomeScreenToday.open, GenAppPeruk22HomeScreenToday.items, GenAppPeruk22HomeScreenToday.proposals, GenAppPeruk22HomeScreenToday.card, GenAppPeruk22HomeScreenToday.autopilot, GenAppPeruk22HomeScreenToday.done, GenAppPeruk22HomeScreenToday.undated, GenAppPeruk22HomeScreenToday.stale, GenAppPeruk22HomeScreenToday.remPending, 23),
    _Mod(GenAppPeruk23HomeScreenToday.module, GenAppPeruk23HomeScreenToday.open, GenAppPeruk23HomeScreenToday.items, GenAppPeruk23HomeScreenToday.proposals, GenAppPeruk23HomeScreenToday.card, GenAppPeruk23HomeScreenToday.autopilot, GenAppPeruk23HomeScreenToday.done, GenAppPeruk23HomeScreenToday.undated, GenAppPeruk23HomeScreenToday.stale, GenAppPeruk23HomeScreenToday.remPending, 24),
    _Mod(GenAppPeruk24HomeScreenToday.module, GenAppPeruk24HomeScreenToday.open, GenAppPeruk24HomeScreenToday.items, GenAppPeruk24HomeScreenToday.proposals, GenAppPeruk24HomeScreenToday.card, GenAppPeruk24HomeScreenToday.autopilot, GenAppPeruk24HomeScreenToday.done, GenAppPeruk24HomeScreenToday.undated, GenAppPeruk24HomeScreenToday.stale, GenAppPeruk24HomeScreenToday.remPending, 25),
    _Mod(GenAppPeruk25HomeScreenToday.module, GenAppPeruk25HomeScreenToday.open, GenAppPeruk25HomeScreenToday.items, GenAppPeruk25HomeScreenToday.proposals, GenAppPeruk25HomeScreenToday.card, GenAppPeruk25HomeScreenToday.autopilot, GenAppPeruk25HomeScreenToday.done, GenAppPeruk25HomeScreenToday.undated, GenAppPeruk25HomeScreenToday.stale, GenAppPeruk25HomeScreenToday.remPending, 26),
    _Mod(GenAppPeruk26HomeScreenToday.module, GenAppPeruk26HomeScreenToday.open, GenAppPeruk26HomeScreenToday.items, GenAppPeruk26HomeScreenToday.proposals, GenAppPeruk26HomeScreenToday.card, GenAppPeruk26HomeScreenToday.autopilot, GenAppPeruk26HomeScreenToday.done, GenAppPeruk26HomeScreenToday.undated, GenAppPeruk26HomeScreenToday.stale, GenAppPeruk26HomeScreenToday.remPending, 27),
    _Mod(GenAppPeruk27HomeScreenToday.module, GenAppPeruk27HomeScreenToday.open, GenAppPeruk27HomeScreenToday.items, GenAppPeruk27HomeScreenToday.proposals, GenAppPeruk27HomeScreenToday.card, GenAppPeruk27HomeScreenToday.autopilot, GenAppPeruk27HomeScreenToday.done, GenAppPeruk27HomeScreenToday.undated, GenAppPeruk27HomeScreenToday.stale, GenAppPeruk27HomeScreenToday.remPending, 28),
    _Mod(GenAppPeruk28HomeScreenToday.module, GenAppPeruk28HomeScreenToday.open, GenAppPeruk28HomeScreenToday.items, GenAppPeruk28HomeScreenToday.proposals, GenAppPeruk28HomeScreenToday.card, GenAppPeruk28HomeScreenToday.autopilot, GenAppPeruk28HomeScreenToday.done, GenAppPeruk28HomeScreenToday.undated, GenAppPeruk28HomeScreenToday.stale, GenAppPeruk28HomeScreenToday.remPending, 29),
  ];
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);
  void _openItem(BuildContext context, DsTodayItem it) { final ms = kBalaganModules.where((m) => m.title == it.module); if (ms.isEmpty || it.rid.isEmpty) return; Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(ms.first.rootSlug, it.rid))); }   // ב׳-לט · הקשה על השורה ⇒ התיק

  Future<void> _digest(String lead, int hardToday) async {
    if (kIsWeb) return;
    final now = DateTime.now(); final hour = int.tryParse(appStore.setting('digestHour', '8')) ?? 8; final key = _iso(_day(now));
    if (now.hour < hour || appStore.setting('digestShown') == key) return;
    try {
      final n = FlutterLocalNotificationsPlugin();
      await n.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
      await n.show(1, gen_balagan_home_c18, lead, const NotificationDetails(android: AndroidNotificationDetails('balagan_digest', 'digest')));
      if (hardToday > 0) await n.show(2, gen_balagan_home_c19, '$hardToday', const NotificationDetails(android: AndroidNotificationDetails('balagan_hard', 'hard')));
      appStore.setSetting('digestShown', key);
    } catch (_) {}
  }
  void _autopilotAll() { for (final m in _mods) { m.autopilot(); } }
  // «הגיע» — שקע-המייל (טוקן-הלקוח, חוק-6): פעם בפתיחה; כל מכתב שטרם הוכרע ⇒ זיהוי-הרגע ⇒ הצעה. בלי טוקן ⇒ כלום. כשל ⇒ שורה אחת כנה.
  List<DsMailItem> _mail = const []; bool _mailTried = false; String _mailNote = '';
  Future<void> _fetchMail() async {
    if (_mailTried) return; _mailTried = true;
    final tok = appStore.setting('mail.token'); if (tok.isEmpty) return;
    final r = await dsMailRecent(token: tok, query: appStore.setting('mail.query', 'newer_than:7d'));
    if (!mounted) return;
    setState(() { if (r == null) { _mailNote = gen_balagan_home_c20; } else { _mail = r; } });
  }
  // התוכנית להיום (Motion/Reclaim בגרסת-בלגן): הדברים של היום מסודרים לבלוקים מתחילת-היום (עריך) — דחוף/קשיח ראשון, בלוק-מיקוד שמור אם יש ≤4 דברים. דטרמיניסטי; «ליומן» לכל בלוק.
  Future<void> _shareDay(List<DsTodayItem> overdue, List<DsTodayItem> todayItems, int planN, [List<DsTodayItem> tomorrow = const []]) async {
    final t = balaganDayText(overdue, todayItems, _day(DateTime.now()), money: balaganMoney([...overdue, ...todayItems]), tomorrow: tomorrow);
    await Clipboard.setData(ClipboardData(text: t)); setState(() => _mailNote = gen_balagan_home_c21);
    launchUrl(Uri.parse('https://wa.me/?text=' + Uri.encodeComponent(t)), mode: LaunchMode.externalApplication);
  }
  List<Widget> _plan(BuildContext context, DateTime today, List<DsTodayItem> overdue, List<DsTodayItem> todayItems) {
    final start = (int.tryParse(appStore.setting('dayStart', '9')) ?? 9).clamp(0, 23); final block = (int.tryParse(appStore.setting('blockMin', '30')) ?? 30).clamp(5, 240);
    final items = [...overdue.where((x) => x.hard), ...overdue.where((x) => !x.hard), ...todayItems.where((x) => x.hard), ...todayItems.where((x) => !x.hard)];
    if (items.isEmpty) return const [];
    final out = <Widget>[]; var t = DateTime(today.year, today.month, today.day, start);
    String hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    // רגע עם שעה קבועה (16:30) = בלוק מקובע; השאר ממלאים סביבו — לא דורסים אותו
    final fixed = <List<dynamic>>[]; for (final it in items) { if (it.time.isEmpty) continue; final hh = int.tryParse(it.time.substring(0, 2)) ?? 0, mm = int.tryParse(it.time.substring(3, 5)) ?? 0; final a = DateTime(today.year, today.month, today.day, hh, mm); fixed.add([a, a.add(Duration(minutes: block)), it]); }
    fixed.sort((x, y) => (x[0] as DateTime).compareTo(y[0] as DateTime));
    DateTime free(DateTime from) { var x = from; var moved = true; while (moved) { moved = false; for (final f in fixed) { final a = f[0] as DateTime, e = f[1] as DateTime; if (x.isBefore(e) && x.add(Duration(minutes: block)).isAfter(a)) { x = e; moved = true; } } } return x; }
    final rows = <List<dynamic>>[for (final f in fixed) [f[0], f[1], f[2]]];
    String cal(DateTime a, DateTime b, String title) { String z(DateTime d) => d.toIso8601String().substring(0, 16).replaceAll(RegExp(r'[-:]'), ''); return 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + Uri.encodeComponent(title) + '&dates=' + z(a) + '00/' + z(b) + '00'; }
    var i = 0;
    for (final it in items.where((x) => x.time.isEmpty)) {
      if (i == 2 && items.length <= 4) { final a0 = free(t); final e = a0.add(const Duration(minutes: 60)); rows.add([a0, e, null]); t = e; }
      final a = free(t); final e = a.add(Duration(minutes: block));
      rows.add([a, e, it]); t = e; i++;
    }
    rows.sort((x, y) => (x[0] as DateTime).compareTo(y[0] as DateTime));
    for (final r in rows) {
      final a = r[0] as DateTime, e = r[1] as DateTime; final it = r[2] as DsTodayItem?;
      final title = it == null ? gen_balagan_home_c22 : it.title;
      out.add(DsActionRow(title: gen_balagan_home_c23.replaceAll('{time}', hm(a)).replaceAll('{title}', title), sub: it == null ? '' : it.module, onOpen: it == null ? null : () => _openItem(context, it), actions: [gen_balagan_home_c24], onAct: (_) => launchUrl(Uri.parse(cal(a, e, title)), mode: LaunchMode.externalApplication)));
    }
    return out;
  }
  List<Widget> _inbox(BuildContext context) {
    final out = <Widget>[];
    for (final m in _mail) {
      if (appStore.decision('mail:${m.id}').isNotEmpty) continue;
      final hits = balaganIdentify(m.subject + ' ' + m.snippet, k: 1); if (hits.isEmpty) continue;
      final mod = hits.first.module;
      out.add(DsApproveCard(question: gen_balagan_home_c25.replaceAll('{subject}', m.subject).replaceAll('{module}', mod.title), source: gen_balagan_home_c26.replaceAll('{from}', m.from).replaceAll('{date}', m.date), okLabel: gen_balagan_home_c27, noLabel: gen_balagan_home_c28,
        onOk: () { appStore.decide('mail:${m.id}', 'ok'); final facts = balaganFacts(m.subject + ' · ' + m.snippet, mod); Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: mod, facts: facts))); },
        onNo: () => appStore.decide('mail:${m.id}', 'no')));
    }
    return out;
  }
  // שרשרת חוצת-מודולים: רשומה שנסגרה ⇒ הצעד-הבא (שם מהפירוק) מזוהה כמודול ⇒ «להתחיל עכשיו?» ⇒ טופס-האישור של המודול השני (הזיכרון ממלא)
  final _standing = <String>{};
  List<Widget> _chain(BuildContext context) {
    final out = <Widget>[];
    // תיק שעומד: פתוח ≥7 ימים מאז יצירתו, בלי שום פעולה ביומן ⇒ «לסגור?» (סגירה = השלב-האחרון; דחייה = הכרעה נזכרת)
    final today = DateTime.now(); _standing.clear();   // ב׳-ל · מי שכבר שואלים עליו «לסגור?» לא חוזר גם ב«נשכחים» (שאלה אחת לתיק)
    for (final m in _mods) {
      final bm = kBalaganModules[m.index]; if (bm.stages == 0) continue;
      for (final r in m.open()) {
        final rid = r[AppStore.idKey] ?? ''; final at = DateTime.tryParse(r['__at'] ?? ''); if (at == null) continue;
        final days = today.difference(at).inDays; if (days < 7 || appStore.decision('stale:$rid').isNotEmpty) continue;
        if (appStore.log.any((e) => e['rid'] == rid && e['undone'] != '1' && e['kind'] != 'add')) continue;
        final who = bm.title + ' · ' + appStore.displayOf(bm.rootSlug, rid); _standing.add(rid);
        out.add(DsApproveCard(question: gen_balagan_home_c29.replaceAll('{who}', who).replaceAll('{n}', days.toString()), source: who, okLabel: gen_balagan_home_c30, noLabel: gen_balagan_home_c31,
          onOk: () { final prev = appStore.stageOf(bm.rootSlug, rid).toString(); appStore.update(bm.rootSlug, rid, {AppStore.stageKey: (bm.stages - 1).toString()}); appStore.decide('stale:$rid', 'ok'); appStore.logAction('auto', gen_balagan_home_c32.replaceAll('{who}', who).replaceAll('{n}', days.toString()), entity: bm.rootSlug, rid: rid, field: AppStore.stageKey, prev: prev); },
          onNo: () => appStore.decide('stale:$rid', 'no')));
      }
    }
    for (final m in _mods) {
      final bm = kBalaganModules[m.index]; if (bm.chain.isEmpty) continue;
      for (final r in m.done()) {
        final rid = r[AppStore.idKey] ?? '';
        final hits = balaganIdentify(bm.chain.first, k: 1); if (hits.isEmpty || hits.first.module.index == m.index) continue;
        final to = hits.first.module;
        out.add(DsApproveCard(question: gen_balagan_home_c33.replaceAll('{from}', bm.title).replaceAll('{to}', to.title), source: bm.title + ' · ' + appStore.displayOf(bm.rootSlug, rid), okLabel: gen_balagan_home_c34, noLabel: gen_balagan_home_c35,
          onOk: () { appStore.decide('next:$rid', 'ok'); appStore.logAction('next', gen_balagan_home_c36.replaceAll('{to}', to.title).replaceAll('{from}', bm.title), entity: bm.rootSlug, rid: rid, field: 'next:$rid'); Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: to, facts: const {}))); },
          onNo: () => appStore.decide('next:$rid', 'no')));
      }
    }
    return out;
  }
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { _autopilotAll(); _fetchMail(); }); appStore.addListener(_onStore); }
  void _onStore() { WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) _autopilotAll(); }); }
  @override
  void dispose() { appStore.removeListener(_onStore); super.dispose(); }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = _day(DateTime.now());
    final all0 = <DsTodayItem>[for (final m in _mods) ...m.items(today, dayDelta: 0)]..sort((a, b) => a.due.compareTo(b.due));
    final overdue = all0.where((x) => x.overdue).toList();
    final todayItems = all0.where((x) => !x.overdue).toList()..sort((a, b) { final ta = a.time.isEmpty ? '99:99' : a.time, tb = b.time.isEmpty ? '99:99' : b.time; final c = ta.compareTo(tb); return c != 0 ? c : a.due.compareTo(b.due); });   // עם-שעה לפי השעה, בלי-שעה אחריהם
    final tomorrow = <DsTodayItem>[for (final m in _mods) ...m.items(today, dayDelta: 1)]..sort((a, b) => a.due.compareTo(b.due));
    final soon = <List<dynamic>>[for (var d = 2; d <= 7; d++) for (final m in _mods) for (final it in m.items(today, dayDelta: d)) [d, it]];   // השבוע הקרוב: ימים 2–7, לפי יום ⇒ הוא רואה מה בא, לא רק מחר
    // ב׳-לז · תזכורות-מרוכזות: יותר מ-3 מועדים קרובים בלי הכרעה ⇒ כרטיס אחד לכולם (הכרעה אחת · יומן אחד · החזר אחד) במקום n כרטיסים שמציפים את «ממתין» ואת מד-העומס
    final rems = <DsTodayItem>[for (final m in _mods) ...m.remPending(today)]; final groupRem = rems.length > 3;
    final remKeys = [for (final r in rems) 'rem:' + r.rid + ':' + r.field]; final remDays = balaganOffsetsLabel(appStore.setting('offsets', '3,1,0'));
    void remAll(String v) { for (final k in remKeys) appStore.decide(k, v); appStore.logAction('decide', gen_balagan_home_c37.replaceAll('{n}', remKeys.length.toString()), field: remKeys.first, prev: remKeys.skip(1).join(',')); }
    final pending = <Widget>[..._inbox(context), ..._chain(context), if (groupRem) DsApproveCard(question: gen_balagan_home_c38.replaceAll('{n}', rems.length.toString()).replaceAll('{days}', remDays), source: gen_balagan_home_c39, okLabel: gen_balagan_home_c40, noLabel: gen_balagan_home_c41, alwaysLabel: gen_balagan_home_c42, onOk: () => remAll('ok'), onNo: () => remAll('no'), onAlways: () { appStore.setSetting('always:rem', '1'); remAll('ok'); }), for (final m in _mods) ...m.proposals(context, today, chain: false, rem: !groupRem)];
    final undated = <DsTodayItem>[for (final m in _mods) ...m.undated(today)];
    final stale = <DsTodayItem>[for (final m in _mods) for (final it in m.stale(today)) if (!_standing.contains(it.rid)) it];   // ב׳-ל · נשכחים: תיק פתוח ש«היום» הפסיק לדבר עליו — לא נעלם; מי שכבר ב«לסגור?» לא מוכפל
    final money = balaganMoney([...overdue, ...todayItems]); final moneyTm = balaganMoney(tomorrow); final moneyWk = balaganMoney([for (final x in soon) x[1] as DsTodayItem]);   // ב׳-כט · כסף-במבט: כמה כסף עומד היום/מחר — מהשורות עצמן   // ב׳-כח · תיקים בלי מועד: לא נעלמים — מקופלים עם «קבע למחר / לשבוע / התעלם»
    // סדר-הכרטיסים = דחיפות: מועד קרוב קודם (מהשורות של היום/מחר/השבוע), ואז החדש-ביותר (__at) — 3 למעלה שמשנים משהו
    final dueOf = <String, DateTime>{}; for (final it in [...all0, ...tomorrow, for (final x in soon) x[1] as DsTodayItem]) { final key = it.module + '|' + it.rid; if (!dueOf.containsKey(key) || it.due.isBefore(dueOf[key]!)) dueOf[key] = it.due; }
    final cardRows = <List<dynamic>>[for (final m in _mods) for (final r in m.open()) [dueOf[m.name + '|' + (r['__id'] ?? '')], r['__at'] ?? '', m.card(context, r), m.name, r['__id'] ?? '']];
    cardRows.sort((a, b) { final da = a[0] as DateTime?, db = b[0] as DateTime?; if (da != null && db != null) { final c = da.compareTo(db); if (c != 0) return c; } else if (da != null) { return -1; } else if (db != null) { return 1; } return (b[1] as String).compareTo(a[1] as String); });
    final cards = <Widget>[for (final x in cardRows) x[2] as Widget];
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next' || e['kind'] == 'add' || e['kind'] == 'done' || e['kind'] == 'del' || e['kind'] == 'merge') && e['undone'] != '1').take(5).toList();
    // «השבוע» — שמירת-זמן (§המוצר): נגזרת של היומן מיום-ראשון; הדקות-לפעולה = הגדרה עריכה, לא טענה
    final weekStart = today.subtract(Duration(days: today.weekday % 7));
    final wk = appStore.log.where((e) => e['undone'] != '1' && !(DateTime.tryParse(e['at'] ?? '') ?? DateTime(2000)).isBefore(weekStart)).toList();
    int cnt(String kind) => wk.where((e) => e['kind'] == kind).length;
    int mins(String key, String def) => int.tryParse(appStore.setting(key, def)) ?? int.parse(def);
    final wAdd = cnt('add'), wSend = cnt('send'), wAuto = cnt('auto') + cnt('decide') + cnt('next') + cnt('done');
    final wSaved = wAdd * mins('minAdd', '4') + wSend * mins('minSend', '12') + wAuto * mins('minAuto', '3');
    final n = overdue.length + todayItems.length + pending.length;
    final lead = n == 0 && cards.isEmpty ? gen_balagan_home_c43 : n <= 1 ? gen_balagan_home_c44 : gen_balagan_home_c45.replaceAll('{n}', n.toString());
    final first = overdue.isNotEmpty ? overdue.first : (todayItems.isNotEmpty ? todayItems.first : null);   // הדבר-האחד (הכרעה-29): הכותרת = מה שדחוף עכשיו, לא ספירה
    // ערב: מהשעה שנקבעה «היום» מראה גם את מחר פתוח — סיכום-היום ומה מחכה, בלי לפתוח קיפול
    final evening = DateTime.now().hour >= ((int.tryParse(appStore.setting('eveningHour', '18')) ?? 18).clamp(0, 23));
    final lead2 = evening && (todayItems.isNotEmpty || tomorrow.isNotEmpty) ? gen_balagan_home_c46.replaceAll('{n}', (overdue.length + todayItems.length).toString()).replaceAll('{m}', tomorrow.length.toString()) : lead;
    final headline = first != null ? first.title : lead2;
    // הפעולה האחרונה (עד 90 שניות) עם «החזר» — «סיים» מעלים שורה, וההחזר צריך להיות איפה שהעין
    final lastAct = appStore.log.isNotEmpty ? appStore.log.first : null;
    final lastAt = lastAct == null ? null : DateTime.tryParse(lastAct['at'] ?? '');
    final showUndo = lastAct != null && lastAt != null && lastAct['undone'] != '1' && DateTime.now().difference(lastAt).inSeconds <= 90 && (lastAct['kind'] == 'done' || lastAct['kind'] == 'auto' || lastAct['kind'] == 'add' || lastAct['kind'] == 'merge' || lastAct['kind'] == 'del' || lastAct['kind'] == 'decide');
    final nRec = [for (final m in kBalaganModules) ...appStore.records(m.rootSlug)].length; final bAge = balaganBackupAge(appStore.setting('backupAt'), today); final backupDue = balaganBackupDue(nRec, bAge);   // ב׳-לו
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    final plan = _plan(context, today, overdue, todayItems);
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    final empty = n == 0 && cards.isEmpty;
    return DsScaffold(title: gen_balagan_home_c47, subtitle: empty ? gen_balagan_home_c48 : lead, icon: gen_balagan_home_c49, children: [
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: DsQuickAdd(hint: gen_balagan_home_c50, autofocus: true, onSubmit: (s0) { final parts = balaganSplit(s0); final s = parts.first; if (parts.length == 1 && balaganPerson(s) != null) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-לו · שם שכבר בתיקים ⇒ הכרטיס שלו */ for (final dd in [balaganDates(s.trim(), today)]) { if (parts.length == 1 && dd.length == 1 && dd.first.start == 0 && dd.first.end == s.trim().length) { final d = DateTime.parse(dd.first.iso + 'T12:00:00'); Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: DateTime(d.year, d.month, d.day).difference(today).inDays))); return; } } /* ב׳-מד · «מחר» / «יום ראשון» לבד ⇒ מסך-היום של אותו יום */ final hits = balaganIdentify(s); if (hits.isEmpty) { setState(() => _mailNote = gen_balagan_home_c51); return; } final m = hits.first.module; Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: m, facts: balaganFacts(s, m), alternatives: hits.skip(1).map((h) => h.module).toList(), text: s, queue: parts.sublist(1)))); })), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c52, onTap: () async { if (!voiceSupported) { setState(() => _mailNote = gen_balagan_home_c53); return; } setState(() => _mailNote = gen_balagan_home_c54); final t = await voiceListen('he-IL'); if (!mounted) return; setState(() => _mailNote = (t == null || t.isEmpty) ? gen_balagan_home_c55 : ''); if (t == null || t.isEmpty) return; final parts = balaganSplit(t); final s = parts.first; if (parts.length == 1 && balaganPerson(s) != null) { Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => GenBalaganTopicsScreen(initialQuery: s.trim()))); return; } /* ב׳-מ · «רות לוי» בקול ⇒ הכרטיס */ final hits = balaganIdentify(s); if (hits.isEmpty) { setState(() => _mailNote = gen_balagan_home_c56); return; } Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: hits.first.module, facts: balaganFacts(s, hits.first.module), alternatives: hits.skip(1).map((h) => h.module).toList(), text: s, queue: parts.sublist(1)))); })]),   // שורה אחת / קול מהמסך-הראשון ⇒ זיהוי ⇒ טופס-אישור: אפס ניווט
      if (!empty) DsLoadMeter(count: n, label: gen_balagan_home_c57.replaceAll('{n}', n.toString()), stateLabels: [gen_balagan_home_c58, gen_balagan_home_c59, gen_balagan_home_c60]),
      if (money > 0 || moneyTm > 0) Padding(padding: const EdgeInsets.only(top: 6), child: Text([if (money > 0) gen_balagan_home_c61.replaceAll('{n}', balaganFmtMoney(money)), if (moneyTm > 0) gen_balagan_home_c62.replaceAll('{n}', balaganFmtMoney(moneyTm))].join(' · '), style: TextStyle(color: lk.ink, fontSize: 15, fontWeight: FontWeight.w600))),   // ב׳-כט · כסף-במבט
      if (showUndo) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: DsNote(message: gen_balagan_home_c63.replaceAll('{what}', lastAct['what'] ?? ''), label: '', tone: 0)), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c64, onTap: () => appStore.undo(lastAct['id'] ?? ''))])),
      if (backupDue) Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [Expanded(child: DsNote(message: bAge < 0 ? gen_balagan_home_c65 : gen_balagan_home_c66.replaceAll('{n}', bAge.toString()), label: '', tone: 1)), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c67, onTap: () async { final t = appStore.exportJson(); await Clipboard.setData(ClipboardData(text: t)); appStore.setSetting('backupAt', _iso(today)); setState(() => _mailNote = gen_balagan_home_c68.replaceAll('{n}', t.length.toString())); })])),   // ב׳-לו · גיבוי: מקומי-בלבד ⇒ תזכורת מעולם/30 יום, העתקה בהקשה
      if (!empty) Padding(padding: const EdgeInsets.only(top: 6), child: Row(children: [DsChipButton(label: gen_balagan_home_c69, onTap: () => _shareDay(overdue, todayItems, plan.length, evening ? tomorrow : const []))])),   // היום כטקסט: ללוח + וואטסאפ (לעצמו / לבן-הזוג) — אפס-שרת
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 4), child: Text(headline, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      if (first != null) Padding(padding: const EdgeInsets.only(bottom: 12), child: Text((first.overdue ? gen_balagan_home_c70 : first.sub) + ' · ' + first.module + ' · ' + lead2, style: TextStyle(color: lk.muted, fontSize: 14))),
      if (overdue.isNotEmpty) DsSection(title: gen_balagan_home_c71, tone: 2, children: [for (final it in overdue) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), tone: 2, onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // D6/P6/P7 · באיחור ראשון
      if (todayItems.isNotEmpty) DsSection(title: gen_balagan_home_c72, children: [for (final it in todayItems) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),
      if (plan.isNotEmpty) DsFold(title: gen_balagan_home_c73.replaceAll('{n}', plan.length.toString()), details: plan),   // תזמון-אוטומטי: מקופל — הוא מסתכל כשהוא רוצה
      ...cards.take(3),   // 3 למעלה
      if (cards.length > 3) DsFold(title: gen_balagan_home_c74.replaceAll('{n}', (cards.length - 3).toString()), details: [for (final x in cardRows.skip(3)) for (final ms in [kBalaganModules.where((mm) => mm.title == x[3])]) DsActionRow(title: ms.isEmpty ? (x[3] as String) : appStore.displayOf(ms.first.rootSlug, x[4] as String), sub: (x[3] as String) + ((x[0] as DateTime?) == null ? '' : ' · ' + balaganDayLabel(x[0] as DateTime, today)), onOpen: () { if (ms.isNotEmpty) Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(ms.first.rootSlug, x[4] as String))); })]),   // ב׳-מו · «עוד» = שורה לכל תיק (שם · מודול · המועד הקרוב), הקשה ⇒ התיק — לא כרטיס של 200px
      if (_mailNote.isNotEmpty) DsNote(message: _mailNote, label: '', tone: 0),
      if (pending.isNotEmpty) DsSection(title: gen_balagan_home_c75 + ' · ' + pending.length.toString(), children: pending),   // D5 · הגיע (מייל) · הצעד-הבא (שרשרת) · תזכורות
      if (did.isNotEmpty) DsSection(title: gen_balagan_home_c76 + ' · ' + did.length.toString(), children: [for (final e in did) DsLogRow(text: e['what'] ?? '', sub: (() { final at = DateTime.tryParse(e['at'] ?? ''); return at == null ? '' : balaganAgo(at, DateTime.now()); })(), undoLabel: gen_balagan_home_c77, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (wk.isNotEmpty) DsFold(title: gen_balagan_home_c78.replaceAll('{n}', wk.length.toString()).replaceAll('{m}', wSaved.toString()), details: [if (wAdd > 0) DsActionRow(title: gen_balagan_home_c79.replaceAll('{n}', wAdd.toString())), if (wSend > 0) DsActionRow(title: gen_balagan_home_c80.replaceAll('{n}', wSend.toString())), if (wAuto > 0) DsActionRow(title: gen_balagan_home_c81.replaceAll('{n}', wAuto.toString())), DsNote(message: gen_balagan_home_c82, label: '', tone: 0)]),   // שמירת-זמן: מקופל, מוכח מהיומן
      if (soon.isNotEmpty) DsFold(title: gen_balagan_home_c83.replaceAll('{n}', soon.length.toString()) + (moneyWk > 0 ? ' · ' + gen_balagan_home_c84.replaceAll('{n}', balaganFmtMoney(moneyWk)) : ''), details: [Padding(padding: const EdgeInsets.only(bottom: 8), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final d in soon.map((x) => x[0] as int).toSet().toList()) DsChipButton(label: balaganDayLabel(today.add(Duration(days: d)), today) + ' · ' + soon.where((x) => x[0] == d).length.toString(), onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: d))))])), /* ב׳-מה · יום ⇒ מסך-היום */ for (final x in soon) DsActionRow(title: balaganDayLabel(today.add(Duration(days: x[0] as int)), today) + ' · ' + (x[1] as DsTodayItem).title, sub: [(x[1] as DsTodayItem).sub, (x[1] as DsTodayItem).module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, x[1] as DsTodayItem), actions: (x[1] as DsTodayItem).actions, onAct: (x[1] as DsTodayItem).act)]),   // ב׳-לד · גם השבוע עם פעולות
      if (tomorrow.isNotEmpty) DsFold(open: evening, title: gen_balagan_home_c85 + ' (' + tomorrow.length.toString() + ')' + (moneyTm > 0 ? ' · ' + gen_balagan_home_c86.replaceAll('{n}', balaganFmtMoney(moneyTm)) : ''), details: [for (final it in tomorrow) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // D8
      if (undated.isNotEmpty) DsFold(title: gen_balagan_home_c87.replaceAll('{n}', undated.length.toString()), details: [DsNote(message: gen_balagan_home_c88, label: '', tone: 0), for (final it in undated) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // ב׳-כח · בלי תאריך
      if (stale.isNotEmpty) DsFold(title: gen_balagan_home_c89.replaceAll('{n}', stale.length.toString()), details: [DsNote(message: gen_balagan_home_c90, label: '', tone: 0), for (final it in stale) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => _openItem(context, it), actions: it.actions, onAct: it.act)]),   // ב׳-ל · נשכחים
      if (!empty && overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_balagan_home_c91, style: TextStyle(color: lk.muted, fontSize: 14))),
      if (empty) DsNote(message: gen_balagan_home_c92, label: '', tone: 0),
      if (empty) Padding(padding: const EdgeInsets.only(top: 14), child: Text(gen_balagan_home_c93, style: TextStyle(color: lk.muted, fontSize: 13))),
      if (empty) Padding(padding: const EdgeInsets.only(top: 6), child: Wrap(spacing: 8, runSpacing: 8, children: [for (final ex in gen_balagan_home_c94.split('|')) DsChipButton(label: ex, onTap: () { final hits = balaganIdentify(ex); if (hits.isEmpty) return; Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: hits.first.module, facts: balaganFacts(ex, hits.first.module), alternatives: hits.skip(1).map((h) => h.module).toList(), text: ex))); })])),   // מסך ריק = הדרך בהקשה אחת
    ]);
  });
}

/// ב׳-מד · מסך-יום: «מה מחכה ביום ראשון?» — אותן שורות של «היום» (פעולות · הקשה ⇒ תיק · ₪), לכל יום; נגזרת, אפס-נתון-חדש
class BalaganDay extends StatelessWidget {
  const BalaganDay({required this.delta, super.key});
  final int delta;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(animation: appStore, builder: (context, _) {
    final today = DateTime.now(); final t0 = DateTime(today.year, today.month, today.day);
    final items = <DsTodayItem>[for (final m in _GenBalaganHomeScreenState._mods) ...m.items(t0, dayDelta: delta)]..sort((a, b) { final ta = a.time.isEmpty ? '99:99' : a.time, tb = b.time.isEmpty ? '99:99' : b.time; return ta.compareTo(tb); });
    final money = balaganMoney(items);
    void open(DsTodayItem it) { final ms = kBalaganModules.where((m) => m.title == it.module); if (ms.isEmpty || it.rid.isEmpty) return; Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => balaganOpenRoot(ms.first.rootSlug, it.rid))); }
    return DsScaffold(title: balaganDayLabel(t0.add(Duration(days: delta)), t0), subtitle: gen_balagan_home_c95, icon: gen_balagan_home_c96, children: [
      Padding(padding: const EdgeInsets.only(bottom: 10), child: Row(children: [DsChipButton(label: '‹ ' + balaganDayLabel(t0.add(Duration(days: delta - 1)), t0), onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: delta - 1)))), const SizedBox(width: 8), DsChipButton(label: balaganDayLabel(t0.add(Duration(days: delta + 1)), t0) + ' ›', onTap: () => Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => BalaganDay(delta: delta + 1))))])),   // ב׳-מה · דפדוף: יום קודם / יום הבא
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [Expanded(child: DsQuickAdd(hint: gen_balagan_home_c97, autofocus: false, onSubmit: (s0) { final s = s0.trim(); if (s.isEmpty) return; final hits = balaganIdentify(s); if (hits.isEmpty) return; final m = hits.first.module; final facts = balaganFacts(s, m); if (m.dateFields.isNotEmpty && !m.dateFields.any((f) => (facts[f] ?? '').trim().isNotEmpty)) { final hard = m.fields.where((f) => f.type == 'date' && f.required); facts[hard.isNotEmpty ? hard.first.label : m.dateFields.first] = _GenBalaganHomeScreenState._iso(t0.add(Duration(days: delta))); } Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: m, facts: facts, alternatives: hits.skip(1).map((h) => h.module).toList(), text: s))); })), const SizedBox(width: 8), DsChipButton(label: gen_balagan_home_c98, onTap: () { final t = balaganDayText(const [], items, t0.add(Duration(days: delta)), money: money); Clipboard.setData(ClipboardData(text: t)); launchUrl(Uri.parse('https://wa.me/?text=' + Uri.encodeComponent(t)), mode: LaunchMode.externalApplication); })])),   // ב׳-מט · רגע ליום הזה: המועד כבר מוכן · ב׳-נא · «שתף» את היום ההוא
      if (items.isEmpty) DsNote(message: gen_balagan_home_c99, label: '', tone: 0),
      if (money > 0) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(gen_balagan_home_c100.replaceAll('{n}', balaganFmtMoney(money)), style: TextStyle(color: DsLook.of(context).ink, fontSize: 15, fontWeight: FontWeight.w600))),
      for (final it in items) DsActionRow(title: it.title, sub: [it.sub, it.module].where((x) => x.isNotEmpty).join(' · '), onOpen: () => open(it), actions: it.actions, onAct: it.act),
    ]);
  });
}
