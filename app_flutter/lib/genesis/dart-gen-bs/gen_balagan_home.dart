// 🧭 חולל ע"י balagan (G33 · הכרעה-29) — «היום» של בלגן: מיזוג ספקי-ה-Today של 28 מודולים — באיחור ראשון · היום · הרשומות הפתוחות (3 למעלה, השאר מקופל) · ממתין-לאישורך · עשיתי-לבד · מחר. אל תערוך ידנית.
import '../dart-data-bs/auto/gen_balagan_home_content.dart';
import '../dart-ui-bs/ds/ds.dart';
import '../dart-ui-bs/ds/ds_store.dart';
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

typedef _Items = List<DsTodayItem> Function(DateTime today, {required int dayDelta});
typedef _Props = List<Widget> Function(BuildContext context, DateTime today);
typedef _Card = Widget Function(BuildContext context, Map<String, String> r);
class _Mod { const _Mod(this.name, this.open, this.items, this.proposals, this.card, this.autopilot); final String name; final List<Map<String, String>> Function() open; final _Items items; final _Props proposals; final _Card card; final void Function() autopilot; }

class GenBalaganHomeScreen extends StatefulWidget {
  const GenBalaganHomeScreen({super.key});
  @override
  State<GenBalaganHomeScreen> createState() => _GenBalaganHomeScreenState();
}

class _GenBalaganHomeScreenState extends State<GenBalaganHomeScreen> {
  static const _mods = <_Mod>[
    _Mod(GenAppPeruk01HomeScreenToday.module, GenAppPeruk01HomeScreenToday.open, GenAppPeruk01HomeScreenToday.items, GenAppPeruk01HomeScreenToday.proposals, GenAppPeruk01HomeScreenToday.card, GenAppPeruk01HomeScreenToday.autopilot),
    _Mod(GenAppPeruk02HomeScreenToday.module, GenAppPeruk02HomeScreenToday.open, GenAppPeruk02HomeScreenToday.items, GenAppPeruk02HomeScreenToday.proposals, GenAppPeruk02HomeScreenToday.card, GenAppPeruk02HomeScreenToday.autopilot),
    _Mod(GenAppPeruk03HomeScreenToday.module, GenAppPeruk03HomeScreenToday.open, GenAppPeruk03HomeScreenToday.items, GenAppPeruk03HomeScreenToday.proposals, GenAppPeruk03HomeScreenToday.card, GenAppPeruk03HomeScreenToday.autopilot),
    _Mod(GenAppPeruk04HomeScreenToday.module, GenAppPeruk04HomeScreenToday.open, GenAppPeruk04HomeScreenToday.items, GenAppPeruk04HomeScreenToday.proposals, GenAppPeruk04HomeScreenToday.card, GenAppPeruk04HomeScreenToday.autopilot),
    _Mod(GenAppPeruk05HomeScreenToday.module, GenAppPeruk05HomeScreenToday.open, GenAppPeruk05HomeScreenToday.items, GenAppPeruk05HomeScreenToday.proposals, GenAppPeruk05HomeScreenToday.card, GenAppPeruk05HomeScreenToday.autopilot),
    _Mod(GenAppPeruk06HomeScreenToday.module, GenAppPeruk06HomeScreenToday.open, GenAppPeruk06HomeScreenToday.items, GenAppPeruk06HomeScreenToday.proposals, GenAppPeruk06HomeScreenToday.card, GenAppPeruk06HomeScreenToday.autopilot),
    _Mod(GenAppPeruk07HomeScreenToday.module, GenAppPeruk07HomeScreenToday.open, GenAppPeruk07HomeScreenToday.items, GenAppPeruk07HomeScreenToday.proposals, GenAppPeruk07HomeScreenToday.card, GenAppPeruk07HomeScreenToday.autopilot),
    _Mod(GenAppPeruk08HomeScreenToday.module, GenAppPeruk08HomeScreenToday.open, GenAppPeruk08HomeScreenToday.items, GenAppPeruk08HomeScreenToday.proposals, GenAppPeruk08HomeScreenToday.card, GenAppPeruk08HomeScreenToday.autopilot),
    _Mod(GenAppPeruk09HomeScreenToday.module, GenAppPeruk09HomeScreenToday.open, GenAppPeruk09HomeScreenToday.items, GenAppPeruk09HomeScreenToday.proposals, GenAppPeruk09HomeScreenToday.card, GenAppPeruk09HomeScreenToday.autopilot),
    _Mod(GenAppPeruk10HomeScreenToday.module, GenAppPeruk10HomeScreenToday.open, GenAppPeruk10HomeScreenToday.items, GenAppPeruk10HomeScreenToday.proposals, GenAppPeruk10HomeScreenToday.card, GenAppPeruk10HomeScreenToday.autopilot),
    _Mod(GenAppPeruk11HomeScreenToday.module, GenAppPeruk11HomeScreenToday.open, GenAppPeruk11HomeScreenToday.items, GenAppPeruk11HomeScreenToday.proposals, GenAppPeruk11HomeScreenToday.card, GenAppPeruk11HomeScreenToday.autopilot),
    _Mod(GenAppPeruk12HomeScreenToday.module, GenAppPeruk12HomeScreenToday.open, GenAppPeruk12HomeScreenToday.items, GenAppPeruk12HomeScreenToday.proposals, GenAppPeruk12HomeScreenToday.card, GenAppPeruk12HomeScreenToday.autopilot),
    _Mod(GenAppPeruk13HomeScreenToday.module, GenAppPeruk13HomeScreenToday.open, GenAppPeruk13HomeScreenToday.items, GenAppPeruk13HomeScreenToday.proposals, GenAppPeruk13HomeScreenToday.card, GenAppPeruk13HomeScreenToday.autopilot),
    _Mod(GenAppPeruk14HomeScreenToday.module, GenAppPeruk14HomeScreenToday.open, GenAppPeruk14HomeScreenToday.items, GenAppPeruk14HomeScreenToday.proposals, GenAppPeruk14HomeScreenToday.card, GenAppPeruk14HomeScreenToday.autopilot),
    _Mod(GenAppPeruk15HomeScreenToday.module, GenAppPeruk15HomeScreenToday.open, GenAppPeruk15HomeScreenToday.items, GenAppPeruk15HomeScreenToday.proposals, GenAppPeruk15HomeScreenToday.card, GenAppPeruk15HomeScreenToday.autopilot),
    _Mod(GenAppPeruk16HomeScreenToday.module, GenAppPeruk16HomeScreenToday.open, GenAppPeruk16HomeScreenToday.items, GenAppPeruk16HomeScreenToday.proposals, GenAppPeruk16HomeScreenToday.card, GenAppPeruk16HomeScreenToday.autopilot),
    _Mod(GenAppPeruk17HomeScreenToday.module, GenAppPeruk17HomeScreenToday.open, GenAppPeruk17HomeScreenToday.items, GenAppPeruk17HomeScreenToday.proposals, GenAppPeruk17HomeScreenToday.card, GenAppPeruk17HomeScreenToday.autopilot),
    _Mod(GenAppPeruk18HomeScreenToday.module, GenAppPeruk18HomeScreenToday.open, GenAppPeruk18HomeScreenToday.items, GenAppPeruk18HomeScreenToday.proposals, GenAppPeruk18HomeScreenToday.card, GenAppPeruk18HomeScreenToday.autopilot),
    _Mod(GenAppPeruk19HomeScreenToday.module, GenAppPeruk19HomeScreenToday.open, GenAppPeruk19HomeScreenToday.items, GenAppPeruk19HomeScreenToday.proposals, GenAppPeruk19HomeScreenToday.card, GenAppPeruk19HomeScreenToday.autopilot),
    _Mod(GenAppPeruk20HomeScreenToday.module, GenAppPeruk20HomeScreenToday.open, GenAppPeruk20HomeScreenToday.items, GenAppPeruk20HomeScreenToday.proposals, GenAppPeruk20HomeScreenToday.card, GenAppPeruk20HomeScreenToday.autopilot),
    _Mod(GenAppPeruk21HomeScreenToday.module, GenAppPeruk21HomeScreenToday.open, GenAppPeruk21HomeScreenToday.items, GenAppPeruk21HomeScreenToday.proposals, GenAppPeruk21HomeScreenToday.card, GenAppPeruk21HomeScreenToday.autopilot),
    _Mod(GenAppPeruk22HomeScreenToday.module, GenAppPeruk22HomeScreenToday.open, GenAppPeruk22HomeScreenToday.items, GenAppPeruk22HomeScreenToday.proposals, GenAppPeruk22HomeScreenToday.card, GenAppPeruk22HomeScreenToday.autopilot),
    _Mod(GenAppPeruk23HomeScreenToday.module, GenAppPeruk23HomeScreenToday.open, GenAppPeruk23HomeScreenToday.items, GenAppPeruk23HomeScreenToday.proposals, GenAppPeruk23HomeScreenToday.card, GenAppPeruk23HomeScreenToday.autopilot),
    _Mod(GenAppPeruk24HomeScreenToday.module, GenAppPeruk24HomeScreenToday.open, GenAppPeruk24HomeScreenToday.items, GenAppPeruk24HomeScreenToday.proposals, GenAppPeruk24HomeScreenToday.card, GenAppPeruk24HomeScreenToday.autopilot),
    _Mod(GenAppPeruk25HomeScreenToday.module, GenAppPeruk25HomeScreenToday.open, GenAppPeruk25HomeScreenToday.items, GenAppPeruk25HomeScreenToday.proposals, GenAppPeruk25HomeScreenToday.card, GenAppPeruk25HomeScreenToday.autopilot),
    _Mod(GenAppPeruk26HomeScreenToday.module, GenAppPeruk26HomeScreenToday.open, GenAppPeruk26HomeScreenToday.items, GenAppPeruk26HomeScreenToday.proposals, GenAppPeruk26HomeScreenToday.card, GenAppPeruk26HomeScreenToday.autopilot),
    _Mod(GenAppPeruk27HomeScreenToday.module, GenAppPeruk27HomeScreenToday.open, GenAppPeruk27HomeScreenToday.items, GenAppPeruk27HomeScreenToday.proposals, GenAppPeruk27HomeScreenToday.card, GenAppPeruk27HomeScreenToday.autopilot),
    _Mod(GenAppPeruk28HomeScreenToday.module, GenAppPeruk28HomeScreenToday.open, GenAppPeruk28HomeScreenToday.items, GenAppPeruk28HomeScreenToday.proposals, GenAppPeruk28HomeScreenToday.card, GenAppPeruk28HomeScreenToday.autopilot),
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
  @override
  void initState() { super.initState(); WidgetsBinding.instance.addPostFrameCallback((_) { _autopilotAll(); }); appStore.addListener(_onStore); }
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
    final pending = <Widget>[for (final m in _mods) ...m.proposals(context, today)];
    final cards = <Widget>[for (final m in _mods) for (final r in m.open()) m.card(context, r)];
    final did = appStore.log.where((e) => (e['kind'] == 'decide' || e['kind'] == 'auto' || e['kind'] == 'next') && e['undone'] != '1').take(5).toList();
    final n = overdue.length + todayItems.length + pending.length;
    final lead = n == 0 && cards.isEmpty ? gen_balagan_home_c2 : n <= 1 ? gen_balagan_home_c3 : gen_balagan_home_c4.replaceAll('{n}', n.toString());
    final hardToday = todayItems.where((x) => x.hard && x.due == today).length;
    WidgetsBinding.instance.addPostFrameCallback((_) { _digest(lead, hardToday); });
    final lk = DsLook.of(context);
    final empty = n == 0 && cards.isEmpty;
    return DsScaffold(title: gen_balagan_home_c5, subtitle: empty ? gen_balagan_home_c6 : lead, icon: gen_balagan_home_c7, children: [
      if (!empty) DsLoadMeter(count: n, label: gen_balagan_home_c8.replaceAll('{n}', n.toString()), stateLabels: [gen_balagan_home_c9, gen_balagan_home_c10, gen_balagan_home_c11]),
      Padding(padding: const EdgeInsets.only(top: 16, bottom: 12), child: Text(lead, style: TextStyle(color: lk.ink, fontSize: 28, fontWeight: FontWeight.w600, height: 1.2))),
      if (overdue.isNotEmpty) DsSection(title: gen_balagan_home_c12, tone: 2, children: [for (final it in overdue) DsActionRow(title: it.title, sub: it.sub + ' · ' + it.module, tone: 2, actions: it.actions, onAct: it.act)]),   // D6/P6/P7 · באיחור ראשון
      if (todayItems.isNotEmpty) DsSection(title: gen_balagan_home_c13, children: [for (final it in todayItems) DsActionRow(title: it.title, sub: it.sub + ' · ' + it.module, actions: it.actions, onAct: it.act)]),
      ...cards.take(3),   // 3 למעלה
      if (cards.length > 3) DsFold(title: gen_balagan_home_c14.replaceAll('{n}', (cards.length - 3).toString()), details: cards.skip(3).toList()),
      if (pending.isNotEmpty) DsSection(title: gen_balagan_home_c15 + ' · ' + pending.length.toString(), children: pending),   // D5
      if (did.isNotEmpty) DsSection(title: gen_balagan_home_c16 + ' · ' + did.length.toString(), children: [for (final e in did) DsLogRow(text: e['what'] ?? '', undoLabel: gen_balagan_home_c17, onUndo: () => appStore.undo(e['id'] ?? ''))]),   // T2
      if (tomorrow.isNotEmpty) DsFold(title: gen_balagan_home_c18 + ' (' + tomorrow.length.toString() + ')', details: [for (final it in tomorrow) DsActionRow(title: it.title, sub: it.sub + ' · ' + it.module)]),   // D8
      if (!empty && overdue.isEmpty && todayItems.isEmpty && pending.isEmpty) Padding(padding: const EdgeInsets.only(top: 12), child: Text(gen_balagan_home_c19, style: TextStyle(color: lk.muted, fontSize: 14))),
      if (empty) DsNote(message: gen_balagan_home_c20, label: '', tone: 0),
    ]);
  });
}
