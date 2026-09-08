// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «היום» של בלגן: מיזוג ספקי-ה-Today של 30 מודולים — באיחור ראשון · היום · הרשומות הפתוחות (3 למעלה, השאר מקופל) · ממתין-לאישורך · עשיתי-לבד · מחר. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_home_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_mail.dart';
import '../dart-ui-bs/ds/ds_store.dart';
import 'gen_balagan_confirm.dart';
import 'gen_balagan_moments.dart';
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
import 'package:url_launcher/url_launcher.dart';

typedef _Items = List<DsTodayItem> Function(DateTime today, {required int dayDelta});
typedef _Props = List<Widget> Function(BuildContext context, DateTime today);
typedef _Card = Widget Function(BuildContext context, Map<String, String> r);
typedef _Props2 = List<Widget> Function(BuildContext context, DateTime today, {bool chain});
class _Mod { const _Mod(this.name, this.open, this.items, this.proposals, this.card, this.autopilot, this.done, this.index); final String name; final List<Map<String, String>> Function() open; final _Items items; final _Props2 proposals; final _Card card; final void Function() autopilot; final List<Map<String, String>> Function() done; final int index; }

class GenBalaganHomeScreen extends StatefulWidget {
  const GenBalaganHomeScreen({super.key});
  @override
  State<GenBalaganHomeScreen> createState() => _GenBalaganHomeScreenState();
}

class _GenBalaganHomeScreenState extends State<GenBalaganHomeScreen> {
  static const _mods = <_Mod>[
    _Mod(GenAppCalendarHomeScreenToday.module, GenAppCalendarHomeScreenToday.open, GenAppCalendarHomeScreenToday.items, GenAppCalendarHomeScreenToday.proposals, GenAppCalendarHomeScreenToday.card, GenAppCalendarHomeScreenToday.autopilot, GenAppCalendarHomeScreenToday.done, 0),
    _Mod(GenAppTasksHomeScreenToday.module, GenAppTasksHomeScreenToday.open, GenAppTasksHomeScreenToday.items, GenAppTasksHomeScreenToday.proposals, GenAppTasksHomeScreenToday.card, GenAppTasksHomeScreenToday.autopilot, GenAppTasksHomeScreenToday.done, 1),
    _Mod(GenAppPeruk01HomeScreenToday.module, GenAppPeruk01HomeScreenToday.open, GenAppPeruk01HomeScreenToday.items, GenAppPeruk01HomeScreenToday.proposals, GenAppPeruk01HomeScreenToday.card, GenAppPeruk01HomeScreenToday.autopilot, GenAppPeruk01HomeScreenToday.done, 2),
    _Mod(GenAppPeruk02HomeScreenToday.module, GenAppPeruk02HomeScreenToday.open, GenAppPeruk02HomeScreenToday.items, GenAppPeruk02HomeScreenToday.proposals, GenAppPeruk02HomeScreenToday.card, GenAppPeruk02HomeScreenToday.autopilot, GenAppPeruk02HomeScreenToday.done, 3),
    _Mod(GenAppPeruk03HomeScreenToday.module, GenAppPeruk03HomeScreenToday.open, GenAppPeruk03HomeScreenToday.items, GenAppPeruk03HomeScreenToday.proposals, GenAppPeruk03HomeScreenToday.card, GenAppPeruk03HomeScreenToday.autopilot, GenAppPeruk03HomeScreenToday.done, 4),
    _Mod(GenAppPeruk04HomeScreenToday.module, GenAppPeruk04HomeScreenToday.open, GenAppPeruk04HomeScreenToday.items, GenAppPeruk04HomeScreenToday.proposals, GenAppPeruk04HomeScreenToday.card, GenAppPeruk04HomeScreenToday.autopilot, GenAppPeruk04HomeScreenToday.done, 5),
    _Mod(GenAppPeruk05HomeScreenToday.module, GenAppPeruk05HomeScreenToday.open, GenAppPeruk05HomeScreenToday.items, GenAppPeruk05HomeScreenToday.proposals, GenAppPeruk05HomeScreenToday.card, GenAppPeruk05HomeScreenToday.autopilot, GenAppPeruk05HomeScreenToday.done, 6),
    _Mod(GenAppPeruk06HomeScreenToday.module, GenAppPeruk06HomeScreenToday.open, GenAppPeruk06HomeScreenToday.items, GenAppPeruk06HomeScreenToday.proposals, GenAppPeruk06HomeScreenToday.card, GenAppPeruk06HomeScreenToday.autopilot, GenAppPeruk06HomeScreenToday.done, 7),
    _Mod(GenAppPeruk07HomeScreenToday.module, GenAppPeruk07HomeScreenToday.open, GenAppPeruk07HomeScreenToday.items, GenAppPeruk07HomeScreenToday.proposals, GenAppPeruk07HomeScreenToday.card, GenAppPeruk07HomeScreenToday.autopilot, GenAppPeruk07HomeScreenToday.done, 8),
    _Mod(GenAppPeruk08HomeScreenToday.module, GenAppPeruk08HomeScreenToday.open, GenAppPeruk08HomeScreenToday.items, GenAppPeruk08HomeScreenToday.proposals, GenAppPeruk08HomeScreenToday.card, GenAppPeruk08HomeScreenToday.autopilot, GenAppPeruk08HomeScreenToday.done, 9),
    _Mod(GenAppPeruk09HomeScreenToday.module, GenAppPeruk09HomeScreenToday.open, GenAppPeruk09HomeScreenToday.items, GenAppPeruk09HomeScreenToday.proposals, GenAppPeruk09HomeScreenToday.card, GenAppPeruk09HomeScreenToday.autopilot, GenAppPeruk09HomeScreenToday.done, 10),
    _Mod(GenAppPeruk10HomeScreenToday.module, GenAppPeruk10HomeScreenToday.open, GenAppPeruk10HomeScreenToday.items, GenAppPeruk10HomeScreenToday.proposals, GenAppPeruk10HomeScreenToday.card, GenAppPeruk10HomeScreenToday.autopilot, GenAppPeruk10HomeScreenToday.done, 11),
    _Mod(GenAppPeruk11HomeScreenToday.module, GenAppPeruk11HomeScreenToday.open, GenAppPeruk11HomeScreenToday.items, GenAppPeruk11HomeScreenToday.proposals, GenAppPeruk11HomeScreenToday.card, GenAppPeruk11HomeScreenToday.autopilot, GenAppPeruk11HomeScreenToday.done, 12),
    _Mod(GenAppPeruk12HomeScreenToday.module, GenAppPeruk12HomeScreenToday.open, GenAppPeruk12HomeScreenToday.items, GenAppPeruk12HomeScreenToday.proposals, GenAppPeruk12HomeScreenToday.card, GenAppPeruk12HomeScreenToday.autopilot, GenAppPeruk12HomeScreenToday.done, 13),
    _Mod(GenAppPeruk13HomeScreenToday.module, GenAppPeruk13HomeScreenToday.open, GenAppPeruk13HomeScreenToday.items, GenAppPeruk13HomeScreenToday.proposals, GenAppPeruk13HomeScreenToday.card, GenAppPeruk13HomeScreenToday.autopilot, GenAppPeruk13HomeScreenToday.done, 14),
    _Mod(GenAppPeruk14HomeScreenToday.module, GenAppPeruk14HomeScreenToday.open, GenAppPeruk14HomeScreenToday.items, GenAppPeruk14HomeScreenToday.proposals, GenAppPeruk14HomeScreenToday.card, GenAppPeruk14HomeScreenToday.autopilot, GenAppPeruk14HomeScreenToday.done, 15),
    _Mod(GenAppPeruk15HomeScreenToday.module, GenAppPeruk15HomeScreenToday.open, GenAppPeruk15HomeScreenToday.items, GenAppPeruk15HomeScreenToday.proposals, GenAppPeruk15HomeScreenToday.card, GenAppPeruk15HomeScreenToday.autopilot, GenAppPeruk15HomeScreenToday.done, 16),
    _Mod(GenAppPeruk16HomeScreenToday.module, GenAppPeruk16HomeScreenToday.open, GenAppPeruk16HomeScreenToday.items, GenAppPeruk16HomeScreenToday.proposals, GenAppPeruk16HomeScreenToday.card, GenAppPeruk16HomeScreenToday.autopilot, GenAppPeruk16HomeScreenToday.done, 17),
    _Mod(GenAppPeruk17HomeScreenToday.module, GenAppPeruk17HomeScreenToday.open, GenAppPeruk17HomeScreenToday.items, GenAppPeruk17HomeScreenToday.proposals, GenAppPeruk17HomeScreenToday.card, GenAppPeruk17HomeScreenToday.autopilot, GenAppPeruk17HomeScreenToday.done, 18),
    _Mod(GenAppPeruk18HomeScreenToday.module, GenAppPeruk18HomeScreenToday.open, GenAppPeruk18HomeScreenToday.items, GenAppPeruk18HomeScreenToday.proposals, GenAppPeruk18HomeScreenToday.card, GenAppPeruk18HomeScreenToday.autopilot, GenAppPeruk18HomeScreenToday.done, 19),
    _Mod(GenAppPeruk19HomeScreenToday.module, GenAppPeruk19HomeScreenToday.open, GenAppPeruk19HomeScreenToday.items, GenAppPeruk19HomeScreenToday.proposals, GenAppPeruk19HomeScreenToday.card, GenAppPeruk19HomeScreenToday.autopilot, GenAppPeruk19HomeScreenToday.done, 20),
    _Mod(GenAppPeruk20HomeScreenToday.module, GenAppPeruk20HomeScreenToday.open, GenAppPeruk20HomeScreenToday.items, GenAppPeruk20HomeScreenToday.proposals, GenAppPeruk20HomeScreenToday.card, GenAppPeruk20HomeScreenToday.autopilot, GenAppPeruk20HomeScreenToday.done, 21),
    _Mod(GenAppPeruk21HomeScreenToday.module, GenAppPeruk21HomeScreenToday.open, GenAppPeruk21HomeScreenToday.items, GenAppPeruk21HomeScreenToday.proposals, GenAppPeruk21HomeScreenToday.card, GenAppPeruk21HomeScreenToday.autopilot, GenAppPeruk21HomeScreenToday.done, 22),
    _Mod(GenAppPeruk22HomeScreenToday.module, GenAppPeruk22HomeScreenToday.open, GenAppPeruk22HomeScreenToday.items, GenAppPeruk22HomeScreenToday.proposals, GenAppPeruk22HomeScreenToday.card, GenAppPeruk22HomeScreenToday.autopilot, GenAppPeruk22HomeScreenToday.done, 23),
    _Mod(GenAppPeruk23HomeScreenToday.module, GenAppPeruk23HomeScreenToday.open, GenAppPeruk23HomeScreenToday.items, GenAppPeruk23HomeScreenToday.proposals, GenAppPeruk23HomeScreenToday.card, GenAppPeruk23HomeScreenToday.autopilot, GenAppPeruk23HomeScreenToday.done, 24),
    _Mod(GenAppPeruk24HomeScreenToday.module, GenAppPeruk24HomeScreenToday.open, GenAppPeruk24HomeScreenToday.items, GenAppPeruk24HomeScreenToday.proposals, GenAppPeruk24HomeScreenToday.card, GenAppPeruk24HomeScreenToday.autopilot, GenAppPeruk24HomeScreenToday.done, 25),
    _Mod(GenAppPeruk25HomeScreenToday.module, GenAppPeruk25HomeScreenToday.open, GenAppPeruk25HomeScreenToday.items, GenAppPeruk25HomeScreenToday.proposals, GenAppPeruk25HomeScreenToday.card, GenAppPeruk25HomeScreenToday.autopilot, GenAppPeruk25HomeScreenToday.done, 26),
    _Mod(GenAppPeruk26HomeScreenToday.module, GenAppPeruk26HomeScreenToday.open, GenAppPeruk26HomeScreenToday.items, GenAppPeruk26HomeScreenToday.proposals, GenAppPeruk26HomeScreenToday.card, GenAppPeruk26HomeScreenToday.autopilot, GenAppPeruk26HomeScreenToday.done, 27),
    _Mod(GenAppPeruk27HomeScreenToday.module, GenAppPeruk27HomeScreenToday.open, GenAppPeruk27HomeScreenToday.items, GenAppPeruk27HomeScreenToday.proposals, GenAppPeruk27HomeScreenToday.card, GenAppPeruk27HomeScreenToday.autopilot, GenAppPeruk27HomeScreenToday.done, 28),
    _Mod(GenAppPeruk28HomeScreenToday.module, GenAppPeruk28HomeScreenToday.open, GenAppPeruk28HomeScreenToday.items, GenAppPeruk28HomeScreenToday.proposals, GenAppPeruk28HomeScreenToday.card, GenAppPeruk28HomeScreenToday.autopilot, GenAppPeruk28HomeScreenToday.done, 29),
  ];
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);
  static String _iso(DateTime d) => d.toIso8601String().substring(0, 10);

  Future<void> _digest(String lead, int hardToday) async {
    if (kIsWeb) return;
    final now = DateTime.now(); final hour = int.tryParse(appStore.setting('digestHour', '8')) ?? 8; final key = _iso(_day(now));
    if (now.hour < hour || appStore.setting('digestShown') == key) return;
    try {
      final n = FlutterLocalNotificationsPlugin();
      await n.initialize(const InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings()));
      await n.show(1, gen_balagan_home_c0, lead, const NotificationDetails(android: AndroidNotificationDetails('balagan_digest', 'digest')));
      if (hardToday > 0) await n.show(2, gen_balagan_home_c1, '$hardToday', const NotificationDetails(android: AndroidNotificationDetails('balagan_hard', 'hard')));
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
    setState(() { if (r == null) { _mailNote = gen_balagan_home_c2; } else { _mail = r; } });
  }
  // התוכנית להיום (Motion/Reclaim בגרסת-בלגן): הדברים של היום מסודרים לבלוקים מתחילת-היום (עריך) — דחוף/קשיח ראשון, בלוק-מיקוד שמור אם יש ≤4 דברים. דטרמיניסטי; «ליומן» לכל בלוק.
  List<Widget> _plan(DateTime today, List<DsTodayItem> overdue, List<DsTodayItem> todayItems) {
    final start = (int.tryParse(appStore.setting('dayStart', '9')) ?? 9).clamp(0, 23); final block = (int.tryParse(appStore.setting('blockMin', '30')) ?? 30).clamp(5, 240);
    final items = [...overdue.where((x) => x.hard), ...overdue.where((x) => !x.hard), ...todayItems.where((x) => x.hard), ...todayItems.where((x) => !x.hard)];
    if (items.isEmpty) return const [];
    final out = <Widget>[]; var t = DateTime(today.year, today.month, today.day, start);
    String hm(DateTime d) => '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    String cal(DateTime a, DateTime b, String title) { String z(DateTime d) => d.toIso8601String().substring(0, 16).replaceAll(RegExp(r'[-:]'), ''); return 'https://calendar.google.com/calendar/render?action=TEMPLATE&text=' + Uri.encodeComponent(title) + '&dates=' + z(a) + '00/' + z(b) + '00'; }
    var i = 0;
    for (final it in items) {
      if (i == 2 && items.length <= 4) { final e = t.add(const Duration(minutes: 60)); out.add(DsActionRow(title: gen_balagan_home_c3.replaceAll('{time}', hm(t)).replaceAll('{title}', gen_balagan_home_c4), sub: '', actions: [gen_balagan_home_c5], onAct: (_) => launchUrl(Uri.parse(cal(t, e, gen_balagan_home_c6)), mode: LaunchMode.externalApplication))); t = e; }
      final e = t.add(Duration(minutes: block)); final a = t;
      out.add(DsActionRow(title: gen_balagan_home_c7.replaceAll('{time}', hm(a)).replaceAll('{title}', it.title), sub: it.module, actions: [gen_balagan_home_c8], onAct: (_) => launchUrl(Uri.parse(cal(a, e, it.title)), mode: LaunchMode.externalApplication)));
      t = e; i++;
    }
    return out;
  }
  List<Widget> _inbox(BuildContext context) {
    final out = <Widget>[];
    for (final m in _mail) {
      if (appStore.decision('mail:${m.id}').isNotEmpty) continue;
      final hits = balaganIdentify(m.subject + ' ' + m.snippet, k: 1); if (hits.isEmpty) continue;
      final mod = hits.first.module;
      out.add(DsApproveCard(question: gen_balagan_home_c9.replaceAll('{subject}', m.subject).replaceAll('{module}', mod.title), source: gen_balagan_home_c10.replaceAll('{from}', m.from).replaceAll('{date}', m.date), okLabel: gen_balagan_home_c11, noLabel: gen_balagan_home_c12,
        onOk: () { appStore.decide('mail:${m.id}', 'ok'); final facts = balaganFacts(m.subject + ' · ' + m.snippet, mod); Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: mod, facts: facts))); },
        onNo: () => appStore.decide('mail:${m.id}', 'no')));
    }
    return out;
  }
  // שרשרת חוצת-מודולים: רשומה שנסגרה ⇒ הצעד-הבא (שם מהפירוק) מזוהה כמודול ⇒ «להתחיל עכשיו?» ⇒ טופס-האישור של המודול השני (הזיכרון ממלא)
  List<Widget> _chain(BuildContext context) {
    final out = <Widget>[];
    for (final m in _mods) {
      final bm = kBalaganModules[m.index]; if (bm.chain.isEmpty) continue;
      for (final r in m.done()) {
        final rid = r[AppStore.idKey] ?? '';
        final hits = balaganIdentify(bm.chain.first, k: 1); if (hits.isEmpty || hits.first.module.index == m.index) continue;
        final to = hits.first.module;
        out.add(DsApproveCard(question: gen_balagan_home_c13.replaceAll('{from}', bm.title).replaceAll('{to}', to.title), source: bm.title + ' · ' + appStore.displayOf(bm.rootSlug, rid), okLabel: gen_balagan_home_c14, noLabel: gen_balagan_home_c15,
          onOk: () { appStore.decide('next:$rid', 'ok'); appStore.logAction('next', gen_balagan_home_c16.replaceAll('{to}', to.title).replaceAll('{from}', bm.title), entity: bm.rootSlug, rid: rid, field: 'next:$rid'); Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: to, facts: const {}))); },
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
    final todayItems = all0.where((x) => !x.overdue).toList();
    final tomorrow = <DsTodayItem>[for (final m in _mods) ...m.items(today, dayDelta: 1)]..sort((a, b) => a.due.compareTo(b.due));
    final pending = <Widget>[..._inbox(context), ..._chain(context), for (final m in _mods) ...m.proposals(context, today, chain: false)];
    final cards = <Widget>[for (final m in _mods) for (final r in m.open()) m.card(context, r)];
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next') && e['undone'] != '1').take(5).toList();
    final n = overdue.length + todayItems.length + pending.length;
    final lead = n == 0 && cards.isEmpty ? gen_balagan_home_c17 : n <= 1 ? gen_balagan_home_c18 : gen_balagan_home_c19.replaceAll('{n}', n.toString());
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    final plan = _plan(today, overdue, todayItems);
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    final empty = n == 0 && cards.isEmpty;
    return DsScaffold(title: gen_balagan_home_c20, subtitle: empty ? gen_balagan_home_c21 : lead, icon: gen_balagan_home_c22, children: [
      DsQuickAdd(hint: gen_balagan_home_c23, autofocus: true, onSubmit: (s) { final hits = balaganIdentify(s); if (hits.isEmpty) { setState(() => _mailNote = gen_balagan_home_c24); return; } final m = hits.first.module; Navigator.of(context).push<bool>(MaterialPageRoute<bool>(builder: (_) => GenBalaganConfirmScreen(module: m, facts: balaganFacts(s, m), alternatives: hits.skip(1).map((h) => h.module).toList(), text: s))); }),   // שורה אחת מהמסך-הראשון ⇒ זיהוי ⇒ טופס-אישור: אפס ניווט
      if (!empty) DsLoadMeter(count: n, label: gen_balagan_home_c25.replaceAll('{n}', n.toString()), stateLabels: [gen_balagan_home_c26, gen_balagan_home_c27, gen_balagan_home_c28]),
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 12), child: Text(lead, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      if (overdue.isNotEmpty) DsSection(title: gen_balagan_home_c29, tone: 2, children: [for (final it in overdue) DsActionRow(title: it.title, sub: it.sub + ' · ' + it.module, tone: 2, actions: it.actions, onAct: it.act)]),   // D6/P6/P7 · באיחור ראשון
      if (todayItems.isNotEmpty) DsSection(title: gen_balagan_home_c30, children: [for (final it in todayItems) DsActionRow(title: it.title, sub: it.sub + ' · ' + it.module, actions: it.actions, onAct: it.act)]),
      if (plan.isNotEmpty) DsFold(title: gen_balagan_home_c31.replaceAll('{n}', plan.length.toString()), details: plan),   // תזמון-אוטומטי: מקופל — הוא מסתכל כשהוא רוצה
      ...cards.take(3),   // 3 למעלה
      if (cards.length > 3) DsFold(title: gen_balagan_home_c32.replaceAll('{n}', (cards.length - 3).toString()), details: cards.skip(3).toList()),
      if (_mailNote.isNotEmpty) DsNote(message: _mailNote, label: '', tone: 0),
      if (pending.isNotEmpty) DsSection(title: gen_balagan_home_c33 + ' · ' + pending.length.toString(), children: pending),   // D5 · הגיע (מייל) · הצעד-הבא (שרשרת) · תזכורות
      if (did.isNotEmpty) DsSection(title: gen_balagan_home_c34 + ' · ' + did.length.toString(), children: [for (final e in did) DsLogRow(text: e['what'] ?? '', undoLabel: gen_balagan_home_c35, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (tomorrow.isNotEmpty) DsFold(title: gen_balagan_home_c36 + ' (' + tomorrow.length.toString() + ')', details: [for (final it in tomorrow) DsActionRow(title: it.title, sub: it.sub + ' · ' + it.module)]),   // D8
      if (!empty && overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_balagan_home_c37, style: TextStyle(color: lk.muted, fontSize: 14))),
      if (empty) DsNote(message: gen_balagan_home_c38, label: '', tone: 0),
    ]);
  });
}
